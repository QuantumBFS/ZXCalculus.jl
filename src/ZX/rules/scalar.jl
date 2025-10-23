struct ScalarRule <: AbstractRule end

function Base.match(::ScalarRule, zxg::Union{ZXGraph{T, P}, ZXDiagram{T, P}}) where {T, P}
    matches = Match{T}[]
    vs = spiders(zxg)
    for v in vs
        if degree(zxg, v) == 0
            if spider_type(zxg, v) in (SpiderType.Z, SpiderType.X)
                push!(matches, Match{T}([v]))
            end
        end
    end
    return matches
end

function check_rule(::ScalarRule, zxg::Union{ZXGraph{T, P}, ZXDiagram{T, P}}, vs::Vector{T}) where {T, P}
    @inbounds v = vs[1]
    if has_vertex(zxg.mg, v)
        if degree(zxg, v) == 0
            if spider_type(zxg, v) in (SpiderType.Z, SpiderType.X)
                return true
            end
        end
    end
    return false
end

function rewrite!(::ScalarRule, zxg::Union{ZXGraph{T, P}, ZXDiagram{T, P}}, vs::Vector{T}) where {T, P}
    @inbounds v = vs[1]
    rem_spider!(zxg, v)
    return zxg
end
