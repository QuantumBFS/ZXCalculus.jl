"""
    ancilla_extraction(zxg::ZXGraph) -> ZXDiagram

Extract a quantum circuit from a general `ZXGraph` even without a gflow. 
It will introduce post-selection operators.
"""
function ancilla_extraction(zxg::ZXGraph)
    nzxg = copy(zxg)
    simplify!(Rule(:scalar), nzxg)
    ins = copy(get_inputs(nzxg))
    outs = copy(get_outputs(nzxg))
    nbits = length(outs)
    gads = Dict{Int, Int}()
    for v in spiders(nzxg)
        if spider_type(nzxg, v) == SpiderType.Z && degree(nzxg, v) == 1
            v1 = neighbors(nzxg, v)[1]
            if phase(nzxg, v1) in (0, 1)
                gads[v1] = v
            end
        end
    end

    for i in eachindex(ins)
        v = ins[i]
        @inbounds u = neighbors(nzxg, v)[1]
        if !is_hadamard(nzxg, u, v)
            insert_spider!(nzxg, u, v)
        end
    end
    
    frontiers = copy(outs)
    circ = ZXDiagram(nbits)
    unextracts = Set(spiders(nzxg))
    qubit_map = Dict{Int, Int}()
    for i in eachindex(ins)
        v = ins[i]
        qubit_map[v] = i
        delete!(unextracts, v)
    end
    for i in eachindex(frontiers)
        @inbounds v = frontiers[i]
        qubit_map[v] = i
        delete!(unextracts, v)
        @inbounds v1 = neighbors(nzxg, v)[1]
        if !(v1 in ins)
            is_hadamard(nzxg, v, v1) && pushfirst_gate!(circ, Val(:H), i)
            frontiers[i] = v1
            qubit_map[v1] = i
            rem_edge!(nzxg, v, v1)
        end
    end

    while !isempty(unextracts)
        update_frontier_ancilla!(frontiers, nzxg, gads, qubit_map, unextracts, circ)
    end

    for v in frontiers
        if degree(nzxg, v) == 1
            @inbounds v1 = neighbors(nzxg, v)[1]
            if is_hadamard(nzxg, v1, v)
                pushfirst_gate!(circ, Val(:H), qubit_map[v])
            end
        end
    end

    M = biadjacency(nzxg, frontiers, ins)
    M, steps = normalize_perm(M)
    for step in steps
        @assert step.op === :swap
        # pushfirst_gate!(circ, Val(:SWAP), [step.r1, step.r2])
        pushfirst_gate!(circ, Val(:CNOT), step.r1, step.r2)
        pushfirst_gate!(circ, Val(:CNOT), step.r2, step.r1)
        pushfirst_gate!(circ, Val(:CNOT), step.r1, step.r2)
    end

    simplify!(Rule(:i1), circ)
    simplify!(Rule(:i2), circ)
    return circ
end

function update_frontier_ancilla!(frontiers, nzxg, gads, qubit_map, unextracts, circ)
    nbs = Int[]
    for i in 1:length(frontiers)
        v = frontiers[i]
        if phase(nzxg, v) != 0
            pushfirst_gate!(circ, Val(:Z), i, phase(nzxg, v))
            set_phase!(nzxg, v, zero(phase(nzxg, v)))
        end
        for j in (i+1):length(frontiers)
            u = frontiers[j]
            if has_edge(nzxg, u, v)
                pushfirst_gate!(circ, Val(:CZ), i, j)
                rem_edge!(nzxg, u, v)
            end
        end
    end
    for i in eachindex(frontiers)
        v = frontiers[i]
        nb_v = neighbors(nzxg, v)
        if length(nb_v) == 1 
            delete!(unextracts, v)
            @inbounds u = nb_v[1]
            if spider_type(nzxg, u) == SpiderType.Z
                pushfirst_gate!(circ, Val(:H), i)
                frontiers[i] = u
                qubit_map[u] = i
                rem_edge!(nzxg, u, v)
                return frontiers
            end
        elseif length(nb_v) == 0
            delete!(unextracts, v)
        end
        for u in nb_v
            if haskey(gads, u)
                rewrite!(Rule(:pivot), nzxg, [u, gads[u], v])
                pushfirst_gate!(circ, Val(:H), i)
                delete!(unextracts, gads[u])
                delete!(gads, u)
                frontiers[i] = u
                qubit_map[u] = i
                return frontiers
            else
                spider_type(nzxg, u) == SpiderType.Z && 
                !(u in nbs) && push!(nbs, u)
            end
        end
    end

    length(nbs) == 0 && return frontiers

    M = biadjacency(nzxg, frontiers, nbs)
    M0, steps = gaussian_elimination(M)
    ws = Int[]
    @inbounds for i = 1:length(frontiers)
        if sum(M0[i,:]) == 1
            push!(ws, nbs[findfirst(isone, M0[i,:])])
        end
    end
    if length(ws) > 0
        @inbounds for e in findall(M .== 1)
            if has_edge(nzxg, frontiers[e[1]], nbs[e[2]])
                rem_edge!(nzxg, frontiers[e[1]], nbs[e[2]])
            end
        end
        @inbounds for e in findall(M0 .== 1)
            add_edge!(nzxg, frontiers[e[1]], nbs[e[2]])
        end

        @inbounds for step in steps
            if step.op == :addto
                ctrl = qubit_map[frontiers[step.r2]]
                loc = qubit_map[frontiers[step.r1]]
                pushfirst_gate!(circ, Val{:CNOT}(), loc, ctrl)
            elseif step.op == :swap
                q1 = qubit_map[frontiers[step.r1]]
                q2 = qubit_map[frontiers[step.r2]]

                # pushfirst_gate!(circ, Val{:SWAP}(), [q1, q2])
                pushfirst_gate!(circ, Val{:CNOT}(), q1, q2)
                pushfirst_gate!(circ, Val{:CNOT}(), q2, q1)
                pushfirst_gate!(circ, Val{:CNOT}(), q1, q2)
            end
        end
        return frontiers
    else
        w = nbs[1]
        push!(frontiers, w)
        add_ancilla!(circ, SpiderType.Z, SpiderType.Z)
        qubit_map[w] = length(frontiers)
        return frontiers
    end
end

"""
    circuit_extraction(zxg::ZXGraph)

Extract circuit from a graph-like ZX-diagram.
"""
function circuit_extraction(zxg::ZXGraph{T, P}) where {T, P}
    nzxg = copy(zxg)
    nbits = nqubits(nzxg)
    gads = Set{T}()
    for v in spiders(nzxg)
        if spider_type(nzxg, v) == SpiderType.Z && degree(nzxg, v) == 1
            v1 = neighbors(nzxg, v)[1]
            if phase(nzxg, v1) in (0, 1)
                push!(gads, v, v1)
            end
        end
    end

    Outs = get_outputs(nzxg)
    Ins = get_inputs(nzxg)
    if nbits == 0
        nbits = length(Outs)
    end
    cir = Chain()
    if length(Outs) != length(Ins)
        return cir
    end
    for v1 in Ins
        @inbounds v2 = neighbors(nzxg, v1)[1]
        if !is_hadamard(nzxg, v1, v2)
            insert_spider!(nzxg, v1, v2)
        end
    end
    @inbounds frontier = [neighbors(nzxg, v)[1] for v in Outs]
    qubit_map = Dict(zip(frontier, 1:nbits))

    for i = 1:nbits
        @inbounds w = neighbors(nzxg, Outs[i])[1]
        @inbounds if is_hadamard(nzxg, w, Outs[i])
            pushfirst_gate!(cir, Val{:H}(), i)
        end
        if phase(nzxg, w) != 0
            pushfirst_gate!(cir, Val{:Rz}(), i, phase(nzxg, w))
            set_phase!(nzxg, w, zero(P)) 
        end
        @inbounds rem_edge!(nzxg, w, Outs[i])
    end
    for i = 1:nbits
        for j = i+1:nbits
            @inbounds if has_edge(nzxg, frontier[i], frontier[j])
                if is_hadamard(nzxg, frontier[i], frontier[j])
                    pushfirst_gate!(cir, Val{:CZ}(), i, j)
                    rem_edge!(nzxg, frontier[i], frontier[j])
                end
            end
        end
    end

    old_frontier = copy(frontier)
    max_iter = 1000
    current_iter = 1
    while !isempty(frontier)
        update_frontier!(nzxg, gads, frontier, qubit_map, cir)
        if frontier != old_frontier
            old_frontier = copy(frontier)
            current_iter = 1
        else
            current_iter += 1
            if current_iter > max_iter
                error("Circuit extraction failed!")
            end
        end
    end

    frontier = T[]
    for v in Ins
        nb = neighbors(nzxg, v)
        if length(nb) > 0
            push!(frontier, nb[])
        end
    end
    sort!(frontier, by = (v->qubit_map[v]))
    M = biadjacency(nzxg, frontier, Ins)
    M, steps = gaussian_elimination(M)
    for step in steps
        if step.op == :addto
            ctrl = step.r2
            loc = step.r1
            pushfirst_gate!(cir, Val{:CNOT}(), loc, ctrl)
        elseif step.op == :swap
            q1 = step.r1
            q2 = step.r2
            pushfirst_gate!(cir, Val{:SWAP}(), q1, q2)
        end
    end

    simplify_swap!(cir)
    return cir
end

"""
    update_frontier!(zxg, frontier, qubit_map, cir)

Update frontier. This is an important step in the circuit extraction algorithm.
For more detail, please check the paper [arXiv:1902.03178](https://arxiv.org/abs/1902.03178).
"""
function update_frontier!(zxg::ZXGraph{T, P}, gads::Set{T}, frontier::Vector{T}, qubit_map::Dict{T, Int}, cir) where {T, P}
    # TODO: use inplace methods
    deleteat!(frontier, [spider_type(zxg, f) != SpiderType.Z || (degree(zxg, f)) == 0 for f in frontier])

    for i = 1:length(frontier)
        v = frontier[i]
        nb_v = neighbors(zxg, v)
        u = findfirst([u in gads for u in nb_v])
          if !isnothing(u)
            u = nb_v[u]
            gad_u = zero(T)
            for w in neighbors(zxg, u)
                if w in gads
                    gad_u = w
                    break
                end
            end
            rewrite!(Rule{:pivot}(), zxg, [u, gad_u, v])
            pop!(gads, u)
            pop!(gads, gad_u)
            frontier[i] = u
            qubit_map[u] = qubit_map[v]
            pushfirst_gate!(cir, Val(:H), qubit_map[u])
            delete!(qubit_map, v)
            for j = 1:length(frontier)
                for k = j+1:length(frontier)
                    if is_hadamard(zxg, frontier[j], frontier[k])
                        pushfirst_gate!(cir, Val(:CZ), qubit_map[frontier[j]], qubit_map[frontier[k]])
                        rem_edge!(zxg, frontier[j], frontier[k])
                    end
                end
            end

            return frontier
        end
    end

    SetN = Set{T}()
    for f in frontier
        union!(SetN, neighbors(zxg, f))
    end
    N = collect(SetN)

    M = biadjacency(zxg, frontier, N)
    M0, steps = gaussian_elimination(M)
    ws = T[]
    @inbounds for i = 1:length(frontier)
        if sum(M0[i,:]) == 1
            push!(ws, N[findfirst(isone, M0[i,:])])
        end
    end
    # M1 = biadjacency(zxg, frontier, ws)
    @inbounds for e in findall(M .== 1)
        if has_edge(zxg, frontier[e[1]], N[e[2]])
            rem_edge!(zxg, frontier[e[1]], N[e[2]])
        end
    end
    @inbounds for e in findall(M0 .== 1)
        add_edge!(zxg, frontier[e[1]], N[e[2]])
    end

    @inbounds for step in steps
        if step.op == :addto
            ctrl = qubit_map[frontier[step.r2]]
            loc = qubit_map[frontier[step.r1]]
            pushfirst_gate!(cir, Val{:CNOT}(), loc, ctrl)
        elseif step.op == :swap
            q1 = qubit_map[frontier[step.r1]]
            q2 = qubit_map[frontier[step.r2]]

            pushfirst_gate!(cir, Val{:SWAP}(), q1, q2)
        end
    end

    for i in 1:length(frontier)
        v = frontier[i]
        if degree(zxg, v) > 1
            continue
        end
        w = neighbors(zxg, v)[1]
        if is_hadamard(zxg, v, w)
            pushfirst_gate!(cir, Val(:H), qubit_map[v])
        end
        if spider_type(zxg, w) == SpiderType.Z
            qubit_map[w] = qubit_map[v]
            if phase(zxg, w) != 0
                pushfirst_gate!(cir, Val{:Rz}(), qubit_map[w], phase(zxg, w))
                set_phase!(zxg, w, zero(P))
            end
            rem_edge!(zxg, v, w)
        else
            rem_edge!(zxg, v, w)
            add_edge!(zxg, v, w, EdgeType.SIM)
        end
        frontier[i] = w
    end

    @inbounds for i1 = 1:length(frontier)
        for i2 = i1+1:length(frontier)
            if has_edge(zxg, frontier[i1], frontier[i2])
                pushfirst_gate!(cir, Val{:CZ}(), qubit_map[frontier[i1]],
                    qubit_map[frontier[i2]])
                rem_edge!(zxg, frontier[i1], frontier[i2])
            end
        end
    end
    return frontier
end

"""
    biadjacency(zxg, F, N)

Return the biadjacency matrix of `zxg` from vertices in `F` to vertices in `N`.
"""
function biadjacency(zxg::ZXGraph{T, P}, F::Vector{T}, N::Vector{T}) where {T, P}
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
function gaussian_elimination(M::Matrix{T}, steps::Vector{GEStep} = Vector{GEStep}(); rev = false) where {T<:Integer}
    M = copy(M)
    nr, nc = size(M)
    current_col = 1
    for i = 1:nr
        if sum(M[i,:]) == 0
            continue
        end
        while current_col <= nc
            rs = findall(!iszero, M[i:nr, current_col])
            if length(rs) > 0
                sort!(rs, by = k -> sum(M[k,:]), rev = rev)
                r0 = rs[1]
                r0 += i - 1
                r0 == i && break
                M_r0 = M[r0,:]
                M[r0,:] = M[i,:]
                M[i,:] = M_r0
                step = GEStep(:swap, r0, i)
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
    return M, steps
end

function normalize_perm(M::Matrix{T}, steps::Vector{GEStep} = Vector{GEStep}()) where {T<:Integer}
    nr, nc = size(M)
    @assert nc <= nr
    @assert all(sum(M; dims = 1) .<= 1) && all(sum(M; dims = 2) .<= 1)
    @assert sum(M) == nc

    cur_r = 1
    while cur_r <= nc
        cur_c = cur_r
        if M[cur_r, cur_c] != 1
            tar_r = findfirst(isone, M[:, cur_r])
            tar_c = findfirst(isone, M[cur_r, :])
            M[cur_r, cur_c] = 1
            M[tar_r, cur_c] = 0
            if !isnothing(tar_c)
                M[tar_r, tar_c] = 1
                M[cur_r, tar_c] = 0
            end
            push!(steps, GEStep(:swap, cur_r, tar_r))
        end
        cur_r += 1
    end

    return M, steps
end

# """
#     reverse_gaussian_elimination(M, steps)
#
# Apply back the operations in `steps` to `M`.
# """
# function reverse_gaussian_elimination(M, steps)
#     for i = length(steps):-1:1
#         s = steps[i]
#         op = s.op
#         r1 = s.r1
#         r2 = s.r2
#         if op == :addto
#             M[r2,:] = M[r2,:] .⊻ M[r1,:]
#         else
#             r_temp = M[r1,:]
#             M[r1,:] = M[r2,:]
#             M[r2,:] = r_temp
#         end
#     end
#     return M
# end
