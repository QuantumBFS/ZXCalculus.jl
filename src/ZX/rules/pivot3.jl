struct Pivot3Rule <: AbstractRule end

function Base.match(::Pivot3Rule, zxg::ZXGraph{T, P}) where {T, P}
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

    for v1 in vB
        if spider_type(zxg, v1) == SpiderType.Z && length(searchsorted(vB, v1)) > 0 &&
           !is_clifford_phase(phase(zxg, v1)) && length(neighbors(zxg, v1)) > 1 &&
           v1 ∉ v_matched
            for v2 in neighbors(zxg, v1)
                if spider_type(zxg, v2) == SpiderType.Z && length(searchsorted(vB, v2)) == 0 &&
                   is_pauli_phase(phase(zxg, v2)) && length(searchsorted(gadgets, v2)) == 0 && v2 ∉ v_matched
                    push!(matches, Match{T}([v1, v2]))
                    push!(v_matched, v1, v2)
                end
            end
        end
    end
    return matches
end

function check_rule(::Pivot3Rule, zxg::ZXGraph{T, P}, vs::Vector{T}) where {T, P}
    v1, v2 = vs
    if has_vertex(zxg.mg, v1)
        if spider_type(zxg, v1) == SpiderType.Z && !is_interior(zxg, v1) &&
           !is_clifford_phase(phase(zxg, v1)) && length(neighbors(zxg, v1)) > 1
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

function rewrite!(::Pivot3Rule, zxg::ZXGraph{T, P}, vs::Vector{T}) where {T, P}
    # u is the boundary spider
    u, v = vs
    phase_u = phase(zxg, u)
    phase_v = phase(zxg, v)
    nb_u = setdiff(neighbors(zxg, u), [v])
    nb_v = setdiff(neighbors(zxg, v), [u])
    bd_u = nb_u[findfirst([u0 in get_inputs(zxg) || u0 in get_outputs(zxg) for u0 in nb_u])]
    setdiff!(nb_u, [bd_u])

    U = setdiff(nb_u, nb_v)
    V = setdiff(nb_v, nb_u)
    W = intersect(nb_u, nb_v)
    add_power!(zxg, (length(U)+length(V))*length(W) + (length(U)+1)*(length(V)-1))

    phase_id_u = zxg.phase_ids[u]
    sgn_phase_v = is_zero_phase(Phase(phase_v)) ? 1 : -1

    if sgn_phase_v < 0
        zxg.phase_ids[u] = (phase_id_u[1], -phase_id_u[2])
        phase_id_u = zxg.phase_ids[u]
    end
    phase_id_v = zxg.phase_ids[v]
    rem_edge!(zxg, u, v)
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
        rem_edge!(zxg, u, u0)
        set_phase!(zxg, u0, phase(zxg, u0)+phase_v)
    end
    for v0 in V
        add_edge!(zxg, u, v0)
    end
    for w0 in W
        set_phase!(zxg, w0, phase(zxg, w0)+phase_v+1)
    end
    set_phase!(zxg, v, zero(P))
    set_phase!(zxg, u, phase_v)
    gad = add_spider!(zxg, SpiderType.Z, P(sgn_phase_v*phase_u))
    add_edge!(zxg, v, gad)
    zxg.phase_ids[gad] = phase_id_u
    zxg.phase_ids[u] = phase_id_v
    zxg.phase_ids[v] = (v, 1)

    if is_hadamard(zxg, u, bd_u)
        rem_edge!(zxg, u, bd_u)
        add_edge!(zxg, u, bd_u, EdgeType.SIM)
    else
        rem_edge!(zxg, u, bd_u)
        add_edge!(zxg, u, bd_u)
    end
    return zxg
end
