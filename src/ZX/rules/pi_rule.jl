struct PiRule <: AbstractRule end

function Base.match(::PiRule, zxd::ZXDiagram{T, P}) where {T, P}
    matches = Match{T}[]
    for v1 in spiders(zxd)
        if spider_type(zxd, v1) == SpiderType.X && is_one_phase(phase(zxd, v1)) && (degree(zxd, v1)) == 2
            for v2 in neighbors(zxd, v1)
                if spider_type(zxd, v2) == SpiderType.Z
                    push!(matches, Match{T}([v1, v2]))
                end
            end
        end
    end
    return matches
end

function check_rule(r::PiRule, zxd::ZXDiagram{T, P}, vs::Vector{T}) where {T, P}
    v1, v2 = vs
    (has_vertex(zxd.mg, v1) && has_vertex(zxd.mg, v2)) || return false
    if spider_type(zxd, v1) == SpiderType.X && is_one_phase(phase(zxd, v1)) &&
       (degree(zxd, v1)) == 2
        if v2 in neighbors(zxd, v1)
            if spider_type(zxd, v2) == SpiderType.Z
                return true
            end
        end
    end
    return false
end

function rewrite!(r::PiRule, zxd::ZXDiagram{T, P}, vs::Vector{T}) where {T, P}
    v1, v2 = vs
    add_global_phase!(zxd, phase(zxd, v2))
    set_phase!(zxd, v2, -phase(zxd, v2))
    nb = neighbors(zxd, v2, count_mul=true)
    for v3 in nb
        # TODO
        v3 != v1 && insert_spider!(zxd, v2, v3, SpiderType.X, phase(zxd, v1))
    end
    if neighbors(zxd, v1) != [v2]
        add_edge!(zxd, neighbors(zxd, v1))
        rem_spider!(zxd, v1)
    end
    return zxd
end
