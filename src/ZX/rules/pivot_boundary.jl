function Base.match(::Rule{:pab}, zxg::ZXGraph{T, P}) where {T, P}
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
                if spider_type(zxg, v1) == SpiderType.Z && length(searchsorted(vB, v1)) == 0 &&
                   is_pauli_phase(phase(zxg, v1))
                    push!(matches, Match{T}([v1, v2]))
                end
            end
        end
    end
    return matches
end

function check_rule(::Rule{:pab}, zxg::ZXGraph{T, P}, vs::Vector{T}) where {T, P}
    v1, v2 = vs
    (has_vertex(zxg.mg, v1) && has_vertex(zxg.mg, v2)) || return false
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

function rewrite!(::Rule{:pab}, zxg::ZXGraph{T, P}, vs::Vector{T}) where {T, P}
    u, v = vs
    phase_v = phase(zxg, v)
    nb_v = neighbors(zxg, v)
    v_bound = zero(T)
    for v0 in nb_v
        if spider_type(zxg, v0) != SpiderType.Z
            v_bound = v0
            break
        end
    end
    @inbounds if is_hadamard(zxg, v, v_bound)
        # TODO
        w = insert_spider!(zxg, v, v_bound)[1]

        zxg.et[(v_bound, w)] = EdgeType.SIM
        v_bound_master = v_bound
        v_master = neighbors(zxg.master, v_bound_master)[1]
        w_master = insert_spider!(zxg.master, v_bound_master, v_master, SpiderType.Z)[1]
        # @show w, w_master
        zxg.phase_ids[w] = (w_master, 1)

        # set_phase!(zxg, w, phase(zxg, v))
        # zxg.phase_ids[w] = zxg.phase_ids[v]
        # set_phase!(zxg, v, zero(P))
        # zxg.phase_ids[v] = (v, 1)
    else
        # TODO
        w = insert_spider!(zxg, v, v_bound)[1]
        # insert_spider!(zxg, w, v_bound, phase_v)
        # w = neighbors(zxg, v_bound)[1]
        # set_phase!(zxg, w, phase(zxg, v))
        # zxg.phase_ids[w] = zxg.phase_ids[v]

        v_bound_master = v_bound
        v_master = neighbors(zxg.master, v_bound_master)[1]
        w_master = insert_spider!(zxg.master, v_bound_master, v_master, SpiderType.X)[1]
        # @show w, w_master
        zxg.phase_ids[w] = (w_master, 1)

        # set_phase!(zxg, v, zero(P))
        # zxg.phase_ids[v] = (v, 1)
        # rem_edge!(zxg, w, v_bound)
        # add_edge!(zxg, w, v_bound, EdgeType.SIM)
    end
    return rewrite!(Rule{:p1}(), zxg, Match{T}([u, v]))
end
