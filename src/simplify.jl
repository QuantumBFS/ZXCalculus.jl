export replace!, simplify!, clifford_simplification, full_reduction

const MAX_ITERATION = Ref{Int}(1000)

"""
    replace!(r, zxd)
Match and replace with the rule `r`.
"""
function replace!(r::AbstractRule, zxd::AbstractZXDiagram)
    matches = match(r, zxd)
    rewrite!(r, zxd, matches)
    return zxd
end

"""
    simplify!(r, zxd)
Simplify `zxd` with the rule `r`.
"""
function simplify!(r::AbstractRule, zxd::AbstractZXDiagram)
    i = 1
    matches = match(r, zxd)
    while length(matches) > 0
        rewrite!(r, zxd, matches)
        matches = match(r, zxd)
        i += 1
        if i > MAX_ITERATION.x && r in (Rule{:p2}(), Rule{:p3}(), Rule{:pab}())
            @warn "Try to simplify this ZX-diagram with rule $r more than $(MAX_ITERATION.x) iterarions"
            break
        end
    end
    return zxd
end

"""
    clifford_simplification(zxd)
Simplify `zxd` with the algorithms in [arXiv:1902.03178](https://arxiv.org/abs/1902.03178).
"""
function clifford_simplification(circ::ZXDiagram)
    zxg = ZXGraph(circ)
    zxg = clifford_simplification(zxg)

    return circuit_extraction(zxg)
end

function clifford_simplification(zxg::ZXGraph)
    simplify!(Rule{:lc}(), zxg)
    simplify!(Rule{:p1}(), zxg)
    replace!(Rule{:pab}(), zxg)

    return zxg
end

function full_reduction(cir::ZXDiagram)
    zxg = ZXGraph(cir)
    zxg = full_reduction(zxg)

    return circuit_extraction(zxg)
end

function full_reduction(zxg::ZXGraph)
    simplify!(Rule{:lc}(), zxg)
    simplify!(Rule{:p1}(), zxg)
    simplify!(Rule{:p2}(), zxg)
    simplify!(Rule{:p3}(), zxg)
    simplify!(Rule{:p1}(), zxg)
    match_id = match(Rule{:id}(), zxg)
    match_gf = match(Rule{:gf}(), zxg)
    while length(match_id) + length(match_gf) > 0
        rewrite!(Rule{:id}(), zxg, match_id)
        rewrite!(Rule{:gf}(), zxg, match_gf)
        simplify!(Rule{:lc}(), zxg)
        simplify!(Rule{:p1}(), zxg)
        simplify!(Rule{:p2}(), zxg)
        simplify!(Rule{:p3}(), zxg)
        simplify!(Rule{:p1}(), zxg)
        match_id = match(Rule{:id}(), zxg)
        match_gf = match(Rule{:gf}(), zxg)
    end

    return zxg
end

function bring_swap_forward!(qc::QCircuit)
    qc_swap = QCircuit(nqubits(qc))
    for i = gate_count(qc):-1:1
        g = qc.gates[i]
        if g.name === :SWAP
            push_gate!(qc_swap, g)
            loc1 = g.loc
            loc2 = g.ctrl
            loc_map = Dict{Int, Int}(loc1 => loc2, loc2 => loc1)

            # delete g
            deleteat!(qc, i)
            
            # change previous gates
            for j in (i-1):-1:1
                pg = qc.gates[j]
                if pg.loc in (loc1, loc2)
                    pg.loc = loc_map[pg.loc]
                end
                if pg.ctrl in (loc1, loc2)
                    pg.ctrl = loc_map[pg.ctrl]
                end
            end
        end
    end
    qc.gates = [qc_swap.gates; qc.gates]
    return qc
end

function swap_simplification!(qc::QCircuit)
    i1 = 1
    i2 = 0
    for i = 1:gate_count(qc)
        if qc.gates[i].name === :SWAP
            i2 = i
        else
            break
        end
    end
    qc_swap = qc[i1:i2]
    deleteat!(qc, i1:i2)
    perm = collect(1:nqubits(qc_swap))
    for i = gate_count(qc_swap):-1:1
        g = qc_swap.gates[i]
        loc1 = g.loc
        loc2 = g.ctrl
        temp = perm[loc1]
        perm[loc1] = perm[loc2]
        perm[loc2] = temp
    end

    rec = collect(1:nqubits(qc_swap))
    subperms = []
    while length(rec) > 0
        id = rec[1]
        sp = Int[]
        while !(id in sp)
            push!(sp, id)
            deleteat!(rec, findfirst(isequal(id), rec))
            id = perm[id]
        end
        push!(subperms, sp)
    end

    qc_swap_opt = QCircuit(nqubits(qc_swap))
    for subperm in subperms
        for k in 2:length(subperm)
            push_gate!(qc_swap_opt, Val(:SWAP), subperm[1], subperm[k])
        end
    end
    qc.gates = [qc_swap_opt.gates; qc.gates] 
    return qc
end

function reduce_swap!(qc::QCircuit)
    i1 = 1
    i2 = 0
    for i = 1:gate_count(qc)
        if qc.gates[i].name === :SWAP
            i2 = i
        else
            break
        end
    end
    qc_swap = qc[i1:i2]
    deleteat!(qc, i1:i2)

    for i = gate_count(qc_swap):-1:1
        g_swap = qc_swap.gates[i]
        qmap = Dict(g_swap.loc => g_swap.ctrl, g_swap.ctrl => g_swap.loc)
        j = 1
        while j <= gate_count(qc)
            g = qc.gates[j]
            if g.name === :CNOT && haskey(qmap, g.loc) && haskey(qmap, g.ctrl)
                insert!(qc, j+1, QGate(Val(:CNOT), g.ctrl, g.loc))
                break
            else
                if haskey(qmap, g.loc)
                    g.loc = qmap[g.loc]
                end
                if haskey(qmap, g.ctrl)
                    g.ctrl = qmap[g.ctrl]
                end
                j += 1
            end
        end
        if j > gate_count(qc)
            push_gate!(qc, Val(:CNOT), g_swap.loc, g_swap.ctrl)
            push_gate!(qc, Val(:CNOT), g_swap.ctrl, g_swap.loc)
            push_gate!(qc, Val(:CNOT), g_swap.loc, g_swap.ctrl)
        end
    end

    return qc
end