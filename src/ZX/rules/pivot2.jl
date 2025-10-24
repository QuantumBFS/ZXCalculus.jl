struct Pivot2Rule <: AbstractRule end

function Base.match(::Pivot2Rule, zxg::ZXGraph{T, P}) where {T, P}
    matches = Match{T}[]
    vs = spiders(zxg)
    vB = [get_inputs(zxg); get_outputs(zxg)]
    for i in 1:length(vB)
        push!(vB, neighbors(zxg, vB[i])[1])
    end
    sort!(vB)
    gadgets = T[]
    for v in vs
        if spider_type(zxg, v) == SpiderType.Z && length(neighbors(zxg, v)) == 1
            push!(gadgets, v, neighbors(zxg, v)[1])
        end
    end
    sort!(gadgets)

    v_matched = T[]

    for v1 in vs
        if spider_type(zxg, v1) == SpiderType.Z && length(searchsorted(vB, v1)) == 0 &&
           (degree(zxg, v1)) > 1 && !is_clifford_phase(phase(zxg, v1)) &&
           length(neighbors(zxg, v1)) > 1 && v1 ∉ v_matched
            for v2 in neighbors(zxg, v1)
                if spider_type(zxg, v2) == SpiderType.Z &&
                   length(searchsorted(vB, v2)) == 0 &&
                   is_pauli_phase(phase(zxg, v2))
                    if length(searchsorted(gadgets, v2)) == 0 && v2 ∉ v_matched
                        push!(matches, Match{T}([v1, v2]))
                        push!(v_matched, v1, v2)
                    end
                end
            end
        end
    end
    return matches
end

function check_rule(::Pivot2Rule, zxg::ZXGraph{T, P}, vs::Vector{T}) where {T, P}
    v1, v2 = vs
    if has_vertex(zxg.mg, v1)
        if spider_type(zxg, v1) == SpiderType.Z && is_interior(zxg, v1) &&
           (degree(zxg, v1)) > 1 && !is_clifford_phase(phase(zxg, v1)) &&
           length(neighbors(zxg, v1)) > 1
            if v2 in neighbors(zxg, v1)
                if spider_type(zxg, v2) == SpiderType.Z && is_interior(zxg, v2) &&
                   is_pauli_phase(phase(zxg, v2))
                    if all(length(neighbors(zxg, u)) > 1 for u in neighbors(zxg, v2))
                        return true
                    end
                end
            end
        end
    end
    return false
end

function rewrite!(::Pivot2Rule, zxg::ZXGraph{T, P}, vs::Vector{T}) where {T, P}
    # u has non-Clifford phase
    u, v = vs
    phase_u = phase(zxg, u)
    phase_v = phase(zxg, v)
    nb_u = setdiff(neighbors(zxg, u), [v])
    nb_v = setdiff(neighbors(zxg, v), [u])

    U = setdiff(nb_u, nb_v)
    V = setdiff(nb_v, nb_u)
    W = intersect(nb_u, nb_v)
    add_power!(zxg, (length(U)+length(V)-1)*length(W) + length(U)*(length(V)-1))

    sgn_phase_v = is_zero_phase(Phase(phase_v)) ? 1 : -1

    # DONE: to ZXCircuit
    # phase_id_u = zxg.phase_ids[u]
    # if sgn_phase_v < 0
    #     zxg.phase_ids[u] = (phase_id_u[1], -phase_id_u[2])
    #     phase_id_u = zxg.phase_ids[u]
    # end
    rem_spider!(zxg, u)
    for u0 in U, v0 in V

        add_edge!(zxg, u0, v0)
    end
    for u0 in U, w0 in W

        add_edge!(zxg, u0, w0)
    end
    for v0 in V, w0 in W

        add_edge!(zxg, v0, w0)
    end
    for u0 in U
        set_phase!(zxg, u0, phase(zxg, u0)+phase_v)
    end
    for w0 in W
        set_phase!(zxg, w0, phase(zxg, w0)+phase_v+1)
    end
    gad = add_spider!(zxg, SpiderType.Z, P(sgn_phase_v*phase_u))
    add_edge!(zxg, v, gad)
    set_phase!(zxg, v, zero(P))

    # DONE: to ZXCircuit
    # zxg.phase_ids[gad] = phase_id_u
    # zxg.phase_ids[v] = (v, 1)

    return zxg, gad
end

function rewrite!(::Pivot2Rule, circ::ZXCircuit{T, P}, vs::Vector{T}) where {T, P}
    u, v = vs

    if is_one_phase(phase(circ, v))
        @assert flip_phase_tracking_sign!(circ, u) "failed to flip phase tracking sign for $u"
    end
    phase_id_u = circ.phase_ids[u]
    _, gad = rewrite!(Pivot2Rule(), circ.zx_graph, vs)

    circ.phase_ids[gad] = phase_id_u
    # TODO: verify why phase id of v is assigned (v, 1)
    circ.phase_ids[v] = (v, 1)
    delete!(circ.phase_ids, u)
    return circ
end