"""
    $(TYPEDEF)

Removes identity spiders connected to two spiders or a Pauli spider connected to one Z-spider via a Hadamard edge.
"""
struct IdentityRemovalRule <: AbstractRule end

function Base.match(::IdentityRemovalRule, zxg::ZXGraph{T, P}) where {T, P}
    matches = Match{T}[]
    for v2 in spiders(zxg)
        nb2 = neighbors(zxg, v2)
        if spider_type(zxg, v2) == SpiderType.Z && length(nb2) == 2
            v1, v3 = nb2
            if is_zero_phase(phase(zxg, v2))
                if spider_type(zxg, v1) == spider_type(zxg, v3) == SpiderType.Z
                    if is_hadamard(zxg, v1, v2) && is_hadamard(zxg, v2, v3)
                        push!(matches, Match{T}([v1, v2, v3]))
                    end
                elseif (spider_type(zxg, v1) in (SpiderType.In, SpiderType.Out)) &&
                       (spider_type(zxg, v3) in (SpiderType.In, SpiderType.Out))
                    push!(matches, Match{T}([v1, v2, v3]))
                end
            elseif is_one_phase(phase(zxg, v2))
                if spider_type(zxg, v1) == spider_type(zxg, v3) == SpiderType.Z
                    is_hadamard(zxg, v2, v3) || continue
                    is_hadamard(zxg, v2, v1) || continue
                    if degree(zxg, v1) == 1
                        push!(matches, Match{T}([v1, v2, v3]))
                    elseif degree(zxg, v3) == 1
                        push!(matches, Match{T}([v3, v2, v1]))
                    end
                end
            end
        end
    end
    return matches
end

function check_rule(::IdentityRemovalRule, zxg::ZXGraph{T, P}, vs::Vector{T}) where {T, P}
    v1, v2, v3 = vs
    if has_vertex(zxg, v2)
        nb2 = neighbors(zxg, v2)
        if spider_type(zxg, v2) == SpiderType.Z && length(nb2) == 2
            (v1 in nb2 && v3 in nb2) || return false
            if is_zero_phase(phase(zxg, v2))
                if spider_type(zxg, v1) == spider_type(zxg, v3) == SpiderType.Z
                    return is_hadamard(zxg, v1, v2) && is_hadamard(zxg, v2, v3)
                end
                if (spider_type(zxg, v1) in (SpiderType.In, SpiderType.Out)) &&
                   (spider_type(zxg, v3) in (SpiderType.In, SpiderType.Out))
                    return true
                end
            else
                is_one_phase(phase(zxg, v2))
                if spider_type(zxg, v1) == spider_type(zxg, v3) == SpiderType.Z
                    return degree(zxg, v1) == 1 && is_hadamard(zxg, v2, v3) && is_hadamard(zxg, v2, v1)
                end
            end
        end
    end
    return false
end

function rewrite!(::IdentityRemovalRule, zxg::ZXGraph{T, P}, vs::Vector{T}) where {T, P}
    v1, v2, v3 = vs
    if is_one_phase(phase(zxg, v2))
        set_phase!(zxg, v2, zero(P))
        set_phase!(zxg, v1, -phase(zxg, v1))
    end
    if (spider_type(zxg, v1) in (SpiderType.In, SpiderType.Out)) ||
       (spider_type(zxg, v3) in (SpiderType.In, SpiderType.Out))
        rem_spider!(zxg, v2)
        et = (edge_type(zxg, v1, v2) == edge_type(zxg, v2, v3)) ? EdgeType.HAD : EdgeType.SIM
        add_edge!(zxg, v1, v3, et)
    else
        set_phase!(zxg, v3, phase(zxg, v3)+phase(zxg, v1))
        for v in neighbors(zxg, v1)
            v == v2 && continue
            add_edge!(zxg, v, v3, edge_type(zxg, v, v1))
        end
        rem_spiders!(zxg, [v1, v2])
    end
    return zxg
end

function rewrite!(::IdentityRemovalRule, circ::ZXCircuit{T, P}, vs::Vector{T}) where {T, P}
    v1, v2, v3 = vs
    if is_one_phase(phase(circ, v2))
        @assert flip_phase_tracking_sign!(circ, v1) "failed to flip phase tracking sign for $v1"
    end

    if spider_type(circ, v1) == spider_type(circ, v3) == SpiderType.Z
        @assert merge_phase_tracking!(circ, v1, v3) "failed to merge phase tracking id from $v1 to $v3"
    end

    rewrite!(IdentityRemovalRule(), circ.zx_graph, vs)
    return circ
end
