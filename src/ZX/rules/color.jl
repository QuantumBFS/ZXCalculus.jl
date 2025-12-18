struct XToZRule <: AbstractRule end
struct ZToXRule <: AbstractRule end

Base.match(::XToZRule, zxd::ZXDiagram{T, P}) where {T, P} = match_spider_type(zxd, SpiderType.X)
Base.match(::XToZRule, zxd::ZXGraph{T, P}) where {T, P} = match_spider_type(zxd, SpiderType.X)
Base.match(::ZToXRule, zxd::ZXDiagram{T, P}) where {T, P} = match_spider_type(zxd, SpiderType.Z)
Base.match(::ZToXRule, zxd::ZXGraph{T, P}) where {T, P} = match_spider_type(zxd, SpiderType.Z)
function match_spider_type(zxd::AbstractZXDiagram{T, P}, st::SpiderType.SType) where {T, P}
    matches = Match{T}[]
    for v1 in spiders(zxd)
        if spider_type(zxd, v1) == st
            push!(matches, Match{T}([v1]))
        end
    end
    return matches
end

check_rule(::XToZRule, zxd::ZXDiagram{T, P}, vs::Vector{T}) where {T, P} = check_spider_type(zxd, vs, SpiderType.X)
check_rule(::XToZRule, zxg::ZXGraph{T, P}, vs::Vector{T}) where {T, P} = check_spider_type(zxg, vs, SpiderType.X)
check_rule(::ZToXRule, zxd::ZXDiagram{T, P}, vs::Vector{T}) where {T, P} = check_spider_type(zxd, vs, SpiderType.Z)
check_rule(::ZToXRule, zxg::ZXGraph{T, P}, vs::Vector{T}) where {T, P} = check_spider_type(zxg, vs, SpiderType.Z)

function check_spider_type(zxd::AbstractZXDiagram{T, P}, vs::Vector{T}, st::SpiderType.SType) where {T, P}
    @inbounds v1 = vs[1]
    has_vertex(zxd.mg, v1) || return false
    return spider_type(zxd, v1) == st
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

function rewrite!(::Union{XToZRule, ZToXRule}, zxg::ZXGraph{T, P}, vs::Vector{T}) where {T, P}
    @inbounds v1 = vs[1]
    st = spider_type(zxg, v1) == SpiderType.X ? SpiderType.Z : SpiderType.X
    set_spider_type!(zxg, v1, st)
    for v2 in neighbors(zxg, v1)
        if v2 != v1
            et = edge_type(zxg, v1, v2) === EdgeType.SIM ? EdgeType.HAD : EdgeType.SIM
            set_edge_type!(zxg, v1, v2, et)
        end
    end
    return zxg
end
