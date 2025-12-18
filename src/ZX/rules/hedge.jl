struct HEdgeRule <: AbstractRule end

function Base.match(::HEdgeRule, zxg::ZXGraph{T, P}) where {T, P}
    matches = Match{T}[]
    for e in edges(zxg)
        v1, v2 = src(e), dst(e)
        if is_hadamard(zxg, v1, v2)
            push!(matches, Match{T}([min(v1, v2), max(v1, v2)]))
        end
    end
    return matches
end

function check_rule(::HEdgeRule, zxg::ZXGraph{T, P}, vs::Vector{T}) where {T, P}
    v1, v2 = vs
    return has_edge(zxg, v1, v2) && is_hadamard(zxg, v1, v2)
end

function rewrite!(::HEdgeRule, zxg::ZXGraph{T, P}, vs::Vector{T}) where {T, P}
    @inbounds v1, v2 = vs
    rem_edge!(zxg, v1, v2)
    add_spider!(zxg, SpiderType.H, zero(P), [v1, v2], [EdgeType.SIM, EdgeType.SIM])
    return zxg
end
