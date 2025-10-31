"""
    $(TYPEDEF)

Applying pivoting rule when an internal Pauli Z-spider `u` is connected to a Z-spider `v` on the boundary via a Hadamard edge.
"""
struct PivotBoundaryRule <: AbstractRule end

function Base.match(::PivotBoundaryRule, zxg::ZXGraph{T, P}) where {T, P}
    matches = Match{T}[]
    vB = [get_inputs(zxg); get_outputs(zxg)]
    sort!(vB)
    for b in vB
        # v2 in vB
        v = neighbors(zxg, b)[1]
        if spider_type(zxg, v) == SpiderType.Z && length(neighbors(zxg, v)) > 2
            for u in neighbors(zxg, v)
                if spider_type(zxg, u) == SpiderType.Z && is_hadamard(zxg, u, v) &&
                   is_interior(zxg, u) && is_pauli_phase(phase(zxg, u))
                    push!(matches, Match{T}([u, v, b]))
                end
            end
        end
    end
    return matches
end

function check_rule(::PivotBoundaryRule, zxg::ZXGraph{T, P}, vs::Vector{T}) where {T, P}
    u, v, b = vs
    (has_vertex(zxg, u) && has_vertex(zxg, v) && has_vertex(zxg, b)) || return false
    spider_type(zxg, b) in (SpiderType.In, SpiderType.Out) || return false
    if has_vertex(zxg, u)
        if spider_type(zxg, u) == SpiderType.Z && is_interior(zxg, u) &&
           is_pauli_phase(phase(zxg, u))
            if has_edge(zxg, u, v) && spider_type(zxg, v) == SpiderType.Z && is_hadamard(zxg, u, v) &&
               has_edge(zxg, v, b) && length(neighbors(zxg, v)) > 2
                return true
            end
        end
    end
    return false
end

function rewrite!(::PivotBoundaryRule, zxg::ZXGraph{T, P}, vs::Vector{T}) where {T, P}
    u, v, b = vs
    et = edge_type(zxg, v, b)
    new_v = insert_spider!(zxg, v, b)[1]
    w = insert_spider!(zxg, v, new_v)
    set_edge_type!(zxg, b, new_v, et)
    set_phase!(zxg, new_v, phase(zxg, v))
    set_phase!(zxg, v, zero(P))
    rewrite!(Pivot1Rule(), zxg, Match{T}([min(u, v), max(u, v)]))
    return zxg, new_v, w
end

function rewrite!(::PivotBoundaryRule, circ::ZXCircuit{T, P}, vs::Vector{T}) where {T, P}
    _, v, b = vs
    _, new_v, w = rewrite!(PivotBoundaryRule(), base_zx_graph(circ), vs)

    v_bound_master = b
    if !isnothing(circ.master)
        v_master = neighbors(circ.master, v_bound_master)[1]
        # TODO: add edge type here for simple edges
        if is_hadamard(circ, new_v, b)
            w_master = insert_spider!(circ.master, v_bound_master, v_master, SpiderType.Z)[1]
        else
            # TODO: add edge type here for simple edges
            w_master = insert_spider!(circ.master, v_bound_master, v_master, SpiderType.X)[1]
        end
        circ.phase_ids[w] = (w_master, 1)
    end

    if !isnothing(circ.master)
        circ.phase_ids[new_v] = circ.phase_ids[v]
        delete!(circ.phase_ids, v)
    end

    return circ
end
