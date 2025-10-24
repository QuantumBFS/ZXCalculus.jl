struct XToZRule <: AbstractRule end

function Base.match(::XToZRule, zxd::ZXDiagram{T, P}) where {T, P}
    matches = Match{T}[]
    for v1 in spiders(zxd)
        if spider_type(zxd, v1) == SpiderType.X
            push!(matches, Match{T}([v1]))
        end
    end
    return matches
end

function check_rule(::XToZRule, zxd::ZXDiagram{T, P}, vs::Vector{T}) where {T, P}
    @inbounds v1 = vs[1]
    has_vertex(zxd.mg, v1) || return false
    if spider_type(zxd, v1) == SpiderType.X
        return true
    end
    return false
end

function rewrite!(::XToZRule, zxd::ZXDiagram{T, P}, vs::Vector{T}) where {T, P}
    @inbounds v1 = vs[1]
    for v2 in neighbors(zxd, v1)
        if v2 != v1
            insert_spider!(zxd, v1, v2, SpiderType.H)
        end
    end
    zxd.st[v1] = SpiderType.Z
    return zxd
end

function Base.match(::XToZRule, zxg::ZXGraph{T, P}) where {T, P}
    matches = Match{T}[]
    for v1 in spiders(zxg)
        if spider_type(zxg, v1) == SpiderType.X
            push!(matches, Match{T}([v1]))
        end
    end
    return matches
end

function check_rule(::XToZRule, zxg::ZXGraph{T, P}, vs::Vector{T}) where {T, P}
    @inbounds v1 = vs[1]
    has_vertex(zxg.mg, v1) || return false
    if spider_type(zxg, v1) == SpiderType.X
        return true
    end
    return false
end

function rewrite!(::XToZRule, zxg::ZXGraph{T, P}, vs::Vector{T}) where {T, P}
    @inbounds v1 = vs[1]
    set_spider_type!(zxg, v1, SpiderType.Z)
    for v2 in neighbors(zxg, v1)
        if v2 != v1
            et = edge_type(zxg, v1, v2)
            set_edge_type!(zxg, v1, v2, et === EdgeType.SIM ? EdgeType.HAD : EdgeType.SIM)
        end
    end
    return zxg
end
