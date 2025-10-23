struct CopyRule <: AbstractRule end

function Base.match(::CopyRule, zxd::ZXDiagram{T, P}) where {T, P}
    matches = Match{T}[]
    for v1 in spiders(zxd)
        if spider_type(zxd, v1) == SpiderType.X && is_zero_phase(phase(zxd, v1)) && (degree(zxd, v1)) == 1
            for v2 in neighbors(zxd, v1)
                if spider_type(zxd, v2) == SpiderType.Z
                    push!(matches, Match{T}([v1, v2]))
                end
            end
        end
    end
    return matches
end

function check_rule(r::CopyRule, zxd::ZXDiagram{T, P}, vs::Vector{T}) where {T, P}
    v1, v2 = vs
    (has_vertex(zxd.mg, v1) && has_vertex(zxd.mg, v1)) || return false
    if spider_type(zxd, v1) == SpiderType.X && is_zero_phase(phase(zxd, v1)) && (degree(zxd, v1)) == 1
        if v2 in neighbors(zxd, v1)
            if spider_type(zxd, v2) == SpiderType.Z
                return true
            end
        end
    end
    return false
end

function rewrite!(r::CopyRule, zxd::ZXDiagram{T, P}, vs::Vector{T}) where {T, P}
    v1, v2 = vs
    ph = phase(zxd, v1)
    rem_spider!(zxd, v1)
    add_power!(zxd, 1)
    nb = neighbors(zxd, v2, count_mul=true)
    for v3 in nb
        add_spider!(zxd, SpiderType.X, ph, [v3])
        add_power!(zxd, -1)
    end
    rem_spider!(zxd, v2)
    return zxd
end
