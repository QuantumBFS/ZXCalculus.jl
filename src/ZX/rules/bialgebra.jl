function Base.match(::Rule{:b}, zxd::ZXDiagram{T, P}) where {T, P}
    matches = Match{T}[]
    for v1 in spiders(zxd)
        if spider_type(zxd, v1) == SpiderType.X && is_zero_phase(phase(zxd, v1)) && (degree(zxd, v1)) == 3
            for v2 in neighbors(zxd, v1)
                if spider_type(zxd, v2) == SpiderType.Z && is_zero_phase(phase(zxd, v2)) && (degree(zxd, v2)) == 3 &&
                   mul(zxd.mg, v1, v2) == 1
                    push!(matches, Match{T}([v1, v2]))
                end
            end
        end
    end
    return matches
end

function check_rule(r::Rule{:b}, zxd::ZXDiagram{T, P}, vs::Vector{T}) where {T, P}
    v1, v2 = vs
    (has_vertex(zxd.mg, v1) && has_vertex(zxd.mg, v2)) || return false
    if spider_type(zxd, v1) == SpiderType.X && is_zero_phase(phase(zxd, v1)) && (degree(zxd, v1)) == 3
        if v2 in neighbors(zxd, v1)
            if spider_type(zxd, v2) == SpiderType.Z && is_zero_phase(phase(zxd, v2)) && (degree(zxd, v2)) == 3 &&
               mul(zxd.mg, v1, v2) == 1
                return true
            end
        end
    end
    return false
end

function rewrite!(r::Rule{:b}, zxd::ZXDiagram{T, P}, vs::Vector{T}) where {T, P}
    v1, v2 = vs
    nb1 = neighbors(zxd, v1)
    nb2 = neighbors(zxd, v2)
    v3, v4 = nb1[nb1 .!= v2]
    v5, v6 = nb2[nb2 .!= v1]

    # TODO
    a1 = insert_spider!(zxd, v1, v3, SpiderType.Z)[1]
    a2 = insert_spider!(zxd, v1, v4, SpiderType.Z)[1]
    a3 = insert_spider!(zxd, v2, v5, SpiderType.X)[1]
    a4 = insert_spider!(zxd, v2, v6, SpiderType.X)[1]
    rem_spiders!(zxd, [v1, v2])

    add_edge!(zxd, a1, a3)
    add_edge!(zxd, a1, a4)
    add_edge!(zxd, a2, a3)
    add_edge!(zxd, a2, a4)
    add_power!(zxd, 1)
    return zxd
end
