export circuit_extraction

"""
    circuit_extraction(zxg::ZXGraph)

Extract circuit from a graph-like ZX-diagram.
"""
function circuit_extraction(zxg::ZXGraph{T, P}) where {T, P}
    nzxg = copy(zxg)
    nbits = nzxg.layout.nbits

    cir = ZXDiagram(nbits)
    if nbits > 0
        Outs = [a[end] for a in nzxg.layout.spider_seq]
        Ins = [a[1] for a in nzxg.layout.spider_seq]
        frontier = [a[end-1] for a in nzxg.layout.spider_seq]
    else
        vs = spiders(nzxg)
        sts = [st[v] for v in vs]
        Outs = vs[sts .== SpiderType.Out]
        Ins = vs[sts .== SpiderType.In]
        if length(Outs) == length(Ins)
            return
        end
        frontier = [neighbors(nzxg, v)[1] for v in Outs]
        nbits = length(Outs)
    end
    for v1 in Ins
        v2 = neighbors(nzxg, v1)[1]
        if !is_hadamard(nzxg, v1, v2)
            insert_spider!(nzxg, v1, v2)
        end
    end
    extracted = copy(Outs)

    for i = 1:nbits
        if is_hadamard(nzxg, frontier[i], Outs[i])
            pushfirst_gate!(cir, Val{:H}(), i)
        end
        if phase(nzxg, frontier[i]) != 0
            pushfirst_gate!(cir, Val{:Z}(), i, phase(nzxg, frontier[i]))
            nzxg.ps[frontier[i]] = 0
        end
        rem_edge!(nzxg, frontier[i], Outs[i])
    end
    for i = 1:nbits
        for j = i+1:nbits
            if is_hadamard(nzxg, frontier[i], frontier[j])
                pushfirst_ctrl_gate!(cir, Val{:CZ}(), frontier[i], frontier[j])
                rem_edge!(nzxg, frontier[i], frontier[j])
            end
        end
    end
    extracted = [extracted; frontier]

    while !isempty(setdiff(spiders(nzxg), extracted))
        frontier = update_frontier!(nzxg, frontier, cir)
        extracted = [extracted; frontier]
    end
    replace!(Rule{:i1}(), cir)
    replace!(Rule{:i2}(), cir)
    return cir
end

"""
    update_frontier!(zxg, frontier, cir)

Update frontier. This is a important step in the circuit extraction algorithm.
For more detail, please check the paper [arXiv:1902.03178](https://arxiv.org/abs/1902.03178).
"""
function update_frontier!(zxg::ZXGraph{T, P}, frontier::Vector{T}, cir::ZXDiagram{T, P}) where {T, P}
    frontier = frontier[[spider_type(zxg, f) == SpiderType.Z for f in frontier]]
    N = Set{T}()
    for f in frontier
        union!(N, neighbors(zxg, f))
    end
    N = collect(N)
    # N = N[[spider_type(zxg, nh) == SpiderType.Z for nh in N]]
    sort!(N, by = v -> qubit_loc(zxg.layout, v))
    M = biadjancency(zxg, frontier, N)
    M0, _ = gaussian_elimination(M)
    ws = T[]
    for i = 1:length(frontier)
        if sum(M0[i,:]) == 1
            push!(ws, N[findfirst(isone, M0[i,:])])
        end
    end
    M1 = biadjancency(zxg, frontier, ws)
    for e in findall(M .== 1)
        rem_edge!(zxg, frontier[e[1]], N[e[2]])
    end
    M0, steps = gaussian_elimination(M1)
    M0 = reverse_gaussian_elimination(M, steps[end:-1:1])
    for e in findall(M0 .== 1)
        if sum(M0[e[1],:]) != 1
            add_edge!(zxg, frontier[e[1]], N[e[2]])
        end
    end

    for step in steps
        if step.op == :addto
            ctrl = qubit_loc(zxg.layout, frontier[step.r2])
            loc = qubit_loc(zxg.layout, frontier[step.r1])
            pushfirst_ctrl_gate!(cir, Val{:CNOT}(), loc, ctrl)
        else
            q1 = qubit_loc(zxg.layout, frontier[step.r1])
            q2 = qubit_loc(zxg.layout, frontier[step.r2])
            pushfirst_gate!(cir, Val{:SWAP}(), [q1, q2])
        end
    end
    frontier = deleteat!(frontier, [sum(M[i,:]) == 1 for i in 1:length(frontier)])

    for w in ws
        pushfirst_gate!(cir, Val{:H}(), qubit_loc(zxg.layout, w))
        if spider_type(zxg, w) == SpiderType.Z
            pushfirst_gate!(cir, Val{:Z}(), qubit_loc(zxg.layout, w), phase(zxg, w))
            zxg.ps[w] = 0
        end
        push!(frontier, w)
    end
    for i1 = 1:length(ws)
        for i2 = i1+1:length(ws)
            if has_edge(zxg, ws[i1], ws[i2])
                pushfirst_ctrl_gate!(cir, Val{:CZ}(), qubit_loc(zxg.layout, ws[i1]),
                    qubit_loc(zxg.layout, ws[i2]))
                rem_edge!(zxg, ws[i1], ws[i2])
            end
        end
    end
    sort!(frontier, by = v -> qubit_loc(zxg.layout, v))
    return frontier
end

"""
    biadjancency(zxg, F, N)

Return the biadjancency matrix of `zxg` from vertices in `F` to vertices in `N`.
"""
function biadjancency(zxg::ZXGraph{T, P}, F::Vector{T}, N::Vector{T}) where {T, P}
    M = zeros(Int, length(F), length(N))

    for i = 1:length(F)
        for v2 in neighbors(zxg, F[i])
            if v2 in N
                M[i, findfirst(isequal(v2), N)] = 1
            end
        end
    end
    return M
end

"""
    GEStep

A struct for representing steps in the Gaussian elimination.
"""
struct GEStep
    op::Symbol
    r1::Int
    r2::Int
end

"""
    gaussian_elimination(M[, steps])

Return result and steps of Gaussian elimination of matrix `M`. Here we assume
that the elements of `M` is in binary field F_2 = {0,1}.
"""
function gaussian_elimination(M::Matrix{T}, steps::Vector{GEStep} = Vector{GEStep}()) where {T<:Integer}
    M = copy(M)
    nr, nc = size(M)
    current_col = 1
    for i = 1:nr
        if sum(M[i,:]) == 0
            continue
        end
        while current_col <= nc
            r0 = findfirst(!iszero, M[i:nr, current_col])
            if r0 != nothing
                r0 += i - 1
                r0 == i && break
                r_temp = M[i,:]
                M[i,:] = M[r0,:]
                M[r0,:] = r_temp
                step = GEStep(:swap, i, r0)
                push!(steps, step)
                break
            else
                current_col += 1
            end
        end
        current_col > nc && break
        for j = 1:nr
            j == i && continue
            if M[j, current_col] == M[i, current_col]
                M[j,:] = M[j,:] .⊻ M[i,:]
                step = GEStep(:addto, i, j)
                push!(steps, step)
            end
        end
        current_col += 1
    end
    M, steps
end

"""
    reverse_gaussian_elimination(M, steps)

Apply back the operations in `steps` to `M`.
"""
function reverse_gaussian_elimination(M, steps)
    for i = length(steps):-1:1
        s = steps[i]
        op = s.op
        r1 = s.r1
        r2 = s.r2
        if op == :addto
            M[r2,:] = M[r2,:] .⊻ M[r1,:]
        else
            r_temp = M[r1,:]
            M[r1,:] = M[r2,:]
            M[r2,:] = r_temp
        end
    end
    M
end
