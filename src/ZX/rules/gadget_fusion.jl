struct GadgetFusionRule <: AbstractRule end

function Base.match(::GadgetFusionRule, zxg::ZXGraph{T, P}) where {T, P}
    matches = Match{T}[]
    vs = spiders(zxg)
    gad_ids = vs[[spider_type(zxg, v) == SpiderType.Z && (degree(zxg, v)) == 1 for v in vs]]
    gads = [(v, neighbors(zxg, v)[1], setdiff(neighbors(zxg, neighbors(zxg, v)[1]), [v])) for v in gad_ids]

    for i in 1:length(gads)
        v1, v2, gad_v = gads[i]
        for j in (i + 1):length(gads)
            u1, u2, gad_u = gads[j]
            if gad_u == gad_v &&
               (spider_type(zxg, v2) == SpiderType.Z && is_pauli_phase(phase(zxg, v2))) &&
               (spider_type(zxg, u2) == SpiderType.Z && is_pauli_phase(phase(zxg, u2)))
                push!(matches, Match{T}([v1, v2, u1, u2]))
            end
        end
    end
    return matches
end

function check_rule(::GadgetFusionRule, zxg::ZXGraph{T, P}, vs::Vector{T}) where {T, P}
    @inbounds if all(has_vertex(zxg.mg, v) for v in vs)
        v1, v2, u1, u2 = vs
        if spider_type(zxg, v1) == SpiderType.Z && (degree(zxg, v1)) == 1 &&
           spider_type(zxg, u1) == SpiderType.Z && (degree(zxg, u1)) == 1
            if v2 == neighbors(zxg, v1)[1] && u2 == neighbors(zxg, u1)[1]
                gad_v = setdiff(neighbors(zxg, v2), [v1])
                gad_u = setdiff(neighbors(zxg, u2), [u1])
                if gad_u == gad_v && is_pauli_phase(phase(zxg, v2)) && is_pauli_phase(phase(zxg, u2))
                    return true
                end
            end
        end
    end
    return false
end

function rewrite!(::GadgetFusionRule, zxg::ZXGraph{T, P}, vs::Vector{T}) where {T, P}
    v1, v2, u1, u2 = vs
    if is_one_phase(phase(zxg, v2))
        add_global_phase!(zxg, phase(zxg, v1))
        set_phase!(zxg, v2, zero(P))
        set_phase!(zxg, v1, -phase(zxg, v1))
        zxg.phase_ids[v1] = (zxg.phase_ids[v1][1], -zxg.phase_ids[v1][2])
    end
    if is_one_phase(phase(zxg, u2))
        add_global_phase!(zxg, phase(zxg, u1))
        set_phase!(zxg, u2, zero(P))
        set_phase!(zxg, u1, -phase(zxg, u1))
        zxg.phase_ids[u1] = (zxg.phase_ids[u1][1], -zxg.phase_ids[u1][2])
    end

    set_phase!(zxg, v1, phase(zxg, v1)+phase(zxg, u1))

    add_power!(zxg, degree(zxg, v2)-2)
    rem_spiders!(zxg, [u1, u2])
    return zxg
end

function rewrite!(::GadgetFusionRule, circ::ZXCircuit{T, P}, vs::Vector{T}) where {T, P}
    v, _, u, _ = vs
    @assert merge_phase_tracking!(circ, u, v) "Failed to merge phase tracking of $u and $v in Gadget Fusion rule."
    rewrite!(GadgetFusionRule(), circ.zx_graph, vs)
    return circ
end