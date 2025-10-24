struct PivotBoundaryRule <: AbstractRule end

function Base.match(::PivotBoundaryRule, zxg::ZXGraph{T, P}) where {T, P}
    matches = Match{T}[]
    vs = spiders(zxg)
    vB = [get_inputs(zxg); get_outputs(zxg)]
    for i in 1:length(vB)
        push!(vB, neighbors(zxg, vB[i])[1])
    end
    sort!(vB)
    for v2 in vB
        if spider_type(zxg, v2) == SpiderType.Z && length(neighbors(zxg, v2)) > 2
            for v1 in neighbors(zxg, v2)
                if spider_type(zxg, v1) == SpiderType.Z &&
                   length(searchsorted(vB, v1)) == 0 &&
                   is_pauli_phase(phase(zxg, v1))
                    nb_v2 = setdiff(neighbors(zxg, v2), [v1])
                    v3 = zero(T)
                    for u in nb_v2
                        if spider_type(zxg, u) in (SpiderType.In, SpiderType.Out)
                            v3 = u
                            break
                        end
                    end
                    push!(matches, Match{T}([v1, v2, v3]))
                end
            end
        end
    end
    return matches
end

function check_rule(::PivotBoundaryRule, zxg::ZXGraph{T, P}, vs::Vector{T}) where {T, P}
    v1, v2, v3 = vs
    (has_vertex(zxg.mg, v1) && has_vertex(zxg.mg, v2) && has_vertex(zxg.mg, v3)) || return false
    spider_type(zxg, v3) in (SpiderType.In, SpiderType.Out) || return false
    if has_vertex(zxg.mg, v1)
        if spider_type(zxg, v1) == SpiderType.Z && is_interior(zxg, v1) &&
           is_pauli_phase(phase(zxg, v1))
            if v2 in neighbors(zxg, v1)
                if spider_type(zxg, v2) == SpiderType.Z && !is_interior(zxg, v2) &&
                   length(neighbors(zxg, v2)) > 2
                    return true
                end
            end
        end
    end
    return false
end

function rewrite!(::PivotBoundaryRule, zxg::ZXGraph{T, P}, vs::Vector{T}) where {T, P}
    u, v, v_bound = vs

    et = edge_type(zxg, v, v_bound)
    new_v = insert_spider!(zxg, v, v_bound)[1]
    w = insert_spider!(zxg, v, new_v)
    set_edge_type!(zxg, v_bound, new_v, et)
    set_phase!(zxg, new_v, phase(zxg, v))
    set_phase!(zxg, v, zero(P))
    return rewrite!(Pivot1Rule(), zxg, Match{T}([u, v])), new_v, w
end

function rewrite!(::PivotBoundaryRule, circ::ZXCircuit{T, P}, vs::Vector{T}) where {T, P}
    _, v, v_bound = vs
    _, new_v, w = rewrite!(PivotBoundaryRule(), circ.zx_graph, vs)

    v_bound_master = v_bound
    v_master = neighbors(circ.master, v_bound_master)[1]
    # TODO: add edge type here for simple edges
    if is_hadamard(circ, new_v, v_bound)
        w_master = insert_spider!(circ.master, v_bound_master, v_master, SpiderType.Z)[1]
    else
        # TODO: add edge type here for simple edges
        w_master = insert_spider!(circ.master, v_bound_master, v_master, SpiderType.X)[1]
    end

    circ.phase_ids[w] = (w_master, 1)
    circ.phase_ids[new_v] = circ.phase_ids[v]
    delete!(circ.phase_ids, v)

    return circ
end
