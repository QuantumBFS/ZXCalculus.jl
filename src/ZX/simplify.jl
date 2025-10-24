const MAX_ITERATION = Ref{Int}(1000)

"""
    replace!(r, zxd)

Match and replace with the rule `r`.
"""
function Base.replace!(r::AbstractRule, zxd::AbstractZXDiagram)
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
        if i > MAX_ITERATION.x && r in (Pivot2Rule(), Pivot3Rule(), PivotBoundaryRule())
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
    zxg = ZXCircuit(circ)
    zxg = clifford_simplification(zxg)
    return zxg
end

function clifford_simplification(zxg::Union{ZXCircuit, ZXGraph})
    simplify!(LocalCompRule(), zxg)
    simplify!(Pivot1Rule(), zxg)
    match_id = match(IdentityRemovalRule(), zxg)
    while length(match_id) > 0
        rewrite!(IdentityRemovalRule(), zxg, match_id)
        simplify!(LocalCompRule(), zxg)
        simplify!(Pivot1Rule(), zxg)
        match_id = match(IdentityRemovalRule(), zxg)
    end
    replace!(PivotBoundaryRule(), zxg)

    return zxg
end

function clifford_simplification(bir::BlockIR)
    zxd = convert_to_zxd(bir)
    zxg = clifford_simplification(zxd)
    chain = circuit_extraction(zxg)
    return BlockIR(bir.parent, bir.nqubits, chain)
end

function full_reduction(cir::ZXDiagram)
    zxg = ZXCircuit(cir)
    zxg = full_reduction(zxg)
    return zxg
end

function full_reduction(zxg::Union{ZXGraph, ZXCircuit})
    simplify!(LocalCompRule(), zxg)
    simplify!(Pivot1Rule(), zxg)
    simplify!(Pivot2Rule(), zxg)
    simplify!(Pivot3Rule(), zxg)
    replace!(PivotBoundaryRule(), zxg)
    simplify!(Pivot1Rule(), zxg)
    match_id = match(IdentityRemovalRule(), zxg)
    match_gf = match(GadgetFusionRule(), zxg)
    while length(match_id) + length(match_gf) > 0
        rewrite!(IdentityRemovalRule(), zxg, match_id)
        rewrite!(GadgetFusionRule(), zxg, match_gf)
        simplify!(LocalCompRule(), zxg)
        simplify!(Pivot1Rule(), zxg)
        simplify!(Pivot2Rule(), zxg)
        simplify!(Pivot3Rule(), zxg)
        replace!(PivotBoundaryRule(), zxg)
        simplify!(Pivot1Rule(), zxg)
        match_id = match(IdentityRemovalRule(), zxg)
        match_gf = match(GadgetFusionRule(), zxg)
    end

    return zxg
end

function full_reduction(bir::BlockIR)
    zxd = convert_to_zxd(bir)
    zxg = full_reduction(zxd)
    chain = circuit_extraction(zxg)
    return BlockIR(bir.parent, bir.nqubits, chain)
end

function compose_permutation(p1::Dict{Int, Int}, p2::Dict{Int, Int})
    p2 = copy(p2)
    p = Dict{Int, Int}()
    for (k1, v1) in p1
        if haskey(p2, v1)
            p[k1] = p2[v1]
            delete!(p2, v1)
        else
            p[k1] = v1
        end
    end
    for (k2, v2) in p2
        p[k2] = v2
    end
    return p
end

map_locations(d::Dict{T, T}, g::Gate) where {T <: Integer} = Gate(g.operation, map_locations(d, g.locations))
map_locations(d::Dict{T, T}, cg::Ctrl) where {T <: Integer} = Ctrl(map_locations(d, cg.gate), map_locations(d, cg.ctrl))
function map_locations(d::Dict{T, T}, locs::Locations) where {T <: Integer}
    return Locations(Tuple(haskey(d, i) ? d[i] : i for i in locs.storage))
end
map_locations(d::Dict{T, T}, locs::CtrlLocations) where {T <: Integer} = CtrlLocations(map_locations(d, locs.storage))

function simplify_swap!(qc::Chain; replace_swap::Bool=true)
    chain_after_swap = Chain()
    loc_map = Dict{Int, Int}()
    while length(qc.args) > 0
        g = pop!(qc.args)
        if g isa Gate
            if g.operation === SWAP
                loc1, loc2 = plain(g.locations)[1:2]
                loc_map = compose_permutation(Dict{Int, Int}(loc1 => loc2, loc2 => loc1), loc_map)
                continue
            end
        end
        pushfirst!(chain_after_swap.args, map_locations(loc_map, g))
    end
    chain_swap = generate_swap(loc_map)
    replace_swap && replace_swap!(chain_swap, chain_after_swap)
    for g in chain_swap.args
        push!(qc.args, g)
    end
    for g in chain_after_swap.args
        push!(qc.args, g)
    end
    return qc
end

function generate_swap(loc_map::Dict{T, T}) where {T <: Integer}
    perm = copy(loc_map)
    subperms = []
    while length(perm) > 0
        k, v = pop!(perm)
        k == v && continue
        sp = [k]
        while !(v in sp)
            push!(sp, v)
            v = pop!(perm, v)
        end
        push!(subperms, sp)
    end

    qc_swap = []
    for subperm in subperms
        for k in 2:length(subperm)
            push!(qc_swap, Gate(SWAP, Locations((subperm[1], subperm[k]))))
        end
    end
    return Chain(qc_swap...)
end

function replace_swap!(chain_swap::Chain, chain_after_swap::Chain)
    qc_swap = chain_swap.args
    qc_after_swap = chain_after_swap.args
    while length(qc_swap) > 0
        g_swap = pop!(qc_swap)
        loc1, loc2 = g_swap.locations.storage[1:2]
        qmap = Dict(loc1 => loc2, loc2 => loc1)
        j = 1
        while j <= length(qc_after_swap)
            g = qc_after_swap[j]
            j += 1
            if g isa Ctrl
                if g.gate === X && length(g.gate.locations) == 1 && length(g.ctrl) == 1
                    loc = plain(g.gate.locations)[]
                    ctrl = plain(g.ctrl.storage)[]
                    if haskey(qmap, loc) && haskey(qmap, ctrl)
                        insert!(qc, j, convert_to_gate(Val(:CNOT), ctrl, loc))
                        break
                    end
                end
            end
            qc_after_swap[j - 1] = map_locations(qmap, qc_after_swap[j - 1])
        end
        if j > length(qc_after_swap)
            push!(qc_after_swap, convert_to_gate(Val(:CNOT), loc1, loc2))
            push!(qc_after_swap, convert_to_gate(Val(:CNOT), loc2, loc1))
            push!(qc_after_swap, convert_to_gate(Val(:CNOT), loc1, loc2))
        end
    end

    return chain_swap, chain_after_swap
end