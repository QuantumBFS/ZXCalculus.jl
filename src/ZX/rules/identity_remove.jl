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
                push!(matches, Match{T}([v1, v2, v3]))
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
                return true
            elseif is_one_phase(phase(zxg, v2))
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
    if spider_type(zxg, v1) == spider_type(zxg, v3) == SpiderType.Z &&
       edge_type(zxg, v1, v2) == edge_type(zxg, v2, v3)
        rem_spider!(zxg, v2)
        if v1 != v3
            add_edge!(zxg, v1, v3, EdgeType.SIM)
            rewrite!(FusionRule(), zxg, Match{T}([v1, v3]))
        end
    else
        et = (edge_type(zxg, v1, v2) == edge_type(zxg, v2, v3)) ? EdgeType.SIM : EdgeType.HAD
        rem_spider!(zxg, v2)
        add_edge!(zxg, v1, v3, et)
    end
    return zxg
end

function rewrite!(::IdentityRemovalRule, circ::ZXCircuit{T, P}, vs::Vector{T}) where {T, P}
    v1, v2, v3 = vs
    if is_one_phase(phase(circ, v2))
        @assert flip_phase_tracking_sign!(circ, v1) "failed to flip phase tracking sign for $v1"
    end

    if spider_type(circ, v1) == spider_type(circ, v3) == SpiderType.Z && v1 != v3
        @assert merge_phase_tracking!(circ, v3, v1) "failed to merge phase tracking id from $v3 to $v1"
    end

    rewrite!(IdentityRemovalRule(), circ.zx_graph, vs)
    return circ
end
