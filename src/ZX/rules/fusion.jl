struct FusionRule <: AbstractRule end

function Base.match(::FusionRule, zxd::ZXDiagram{T, P}) where {T, P}
    matches = Match{T}[]
    for v1 in spiders(zxd)
        if spider_type(zxd, v1) == SpiderType.Z || spider_type(zxd, v1) == SpiderType.X
            for v2 in neighbors(zxd, v1)
                if spider_type(zxd, v1) == spider_type(zxd, v2) && v2 >= v1
                    push!(matches, Match{T}([v1, v2]))
                end
            end
        end
    end
    return matches
end

function check_rule(r::FusionRule, zxd::ZXDiagram{T, P}, vs::Vector{T}) where {T, P}
    v1, v2 = vs
    (has_vertex(zxd.mg, v1) && has_vertex(zxd.mg, v2)) || return false
    if spider_type(zxd, v1) == SpiderType.Z || spider_type(zxd, v1) == SpiderType.X
        if v2 in neighbors(zxd, v1)
            if spider_type(zxd, v1) == spider_type(zxd, v2) && v2 >= v1
                return true
            end
        end
    end
    return false
end

function rewrite!(r::FusionRule, zxd::ZXDiagram{T, P}, vs::Vector{T}) where {T, P}
    v1, v2 = vs
    for v3 in neighbors(zxd, v2)
        if v3 != v1
            add_edge!(zxd, v1, v3)
        end
    end
    set_phase!(zxd, v1, phase(zxd, v1)+phase(zxd, v2))
    rem_spider!(zxd, v2)
    return zxd
end
