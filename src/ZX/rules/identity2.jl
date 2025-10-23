function Base.match(::Rule{:i2}, zxd::ZXDiagram{T, P}) where {T, P}
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

function check_rule(r::Rule{:i2}, zxd::ZXDiagram{T, P}, vs::Vector{T}) where {T, P}
    @inbounds v1, v2 = vs
    (has_vertex(zxd.mg, v1) && has_vertex(zxd.mg, v2)) || return false
    if spider_type(zxd, v1) == SpiderType.H && spider_type(zxd, v2) == SpiderType.H && has_edge(zxd.mg, v1, v2)
        if (degree(zxd, v1)) == 2 && (degree(zxd, v2)) == 2
            return true
        end
    end
    return false
end

function rewrite!(r::Rule{:i2}, zxd::ZXDiagram{T, P}, vs::Vector{T}) where {T, P}
    @inbounds v1, v2 = vs
    nb1 = neighbors(zxd, v1, count_mul=true)
    nb2 = neighbors(zxd, v2, count_mul=true)
    @inbounds v3 = (nb1[1] == v2 ? nb1[2] : nb1[1])
    @inbounds v4 = (nb2[1] == v1 ? nb2[2] : nb2[1])
    add_edge!(zxd, v3, v4)
    rem_spiders!(zxd, [v1, v2])
    return zxd
end
