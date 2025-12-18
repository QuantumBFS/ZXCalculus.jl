struct HBoxRule <: AbstractRule end

function Base.match(::HBoxRule, zxd::ZXDiagram{T, P}) where {T, P}
    matches = Match{T}[]
    for v1 in spiders(zxd)
        if spider_type(zxd, v1) == SpiderType.H && (degree(zxd, v1)) == 2
            for v2 in neighbors(zxd, v1)
                if spider_type(zxd, v2) == SpiderType.H && (degree(zxd, v2)) == 2
                    v2 >= v1 && push!(matches, Match{T}([v1, v2]))
                end
            end
        end
    end
    return matches
end

function check_rule(::HBoxRule, zxd::ZXDiagram{T, P}, vs::Vector{T}) where {T, P}
    @inbounds v1, v2 = vs
    (has_vertex(zxd.mg, v1) && has_vertex(zxd.mg, v2)) || return false
    if spider_type(zxd, v1) == SpiderType.H && spider_type(zxd, v2) == SpiderType.H && has_edge(zxd.mg, v1, v2)
        if (degree(zxd, v1)) == 2 && (degree(zxd, v2)) == 2
            return true
        end
    end
    return false
end

function rewrite!(::HBoxRule, zxd::ZXDiagram{T, P}, vs::Vector{T}) where {T, P}
    @inbounds v1, v2 = vs
    nb1 = neighbors(zxd, v1, count_mul=true)
    nb2 = neighbors(zxd, v2, count_mul=true)
    @inbounds v3 = (nb1[1] == v2 ? nb1[2] : nb1[1])
    @inbounds v4 = (nb2[1] == v1 ? nb2[2] : nb2[1])
    add_edge!(zxd, v3, v4)
    rem_spiders!(zxd, [v1, v2])
    return zxd
end

function Base.match(::HBoxRule, zxg::ZXGraph{T, P}) where {T, P}
    matches = Match{T}[]
    for v1 in spiders(zxg)
        if spider_type(zxg, v1) == SpiderType.H && (degree(zxg, v1)) == 2
            push!(matches, Match{T}([v1]))
        end
    end
    return matches
end

function check_rule(::HBoxRule, zxg::ZXGraph{T, P}, vs::Vector{T}) where {T, P}
    @inbounds v = vs[1]
    has_vertex(zxg, v) || return false
    return spider_type(zxg, v) == SpiderType.H && (degree(zxg, v)) == 2
end

function rewrite!(::HBoxRule, zxg::ZXGraph{T, P}, vs::Vector{T}) where {T, P}
    @inbounds v = vs[1]
    u, w = neighbors(zxg, v)
    et_u = edge_type(zxg, v, u)
    et_w = edge_type(zxg, v, w)
    et_new = et_u === et_w ? EdgeType.HAD : EdgeType.SIM
    rem_spider!(zxg, v)
    add_edge!(zxg, u, w, et_new)
    return zxg
end
