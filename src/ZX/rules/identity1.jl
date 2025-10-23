struct Identity1Rule <: AbstractRule end

function Base.match(::Identity1Rule, zxd::ZXDiagram{T, P}) where {T, P}
    matches = Match{T}[]
    for v1 in spiders(zxd)
        if spider_type(zxd, v1) == SpiderType.Z || spider_type(zxd, v1) == SpiderType.X
            if is_zero_phase(phase(zxd, v1)) && (degree(zxd, v1)) == 2
                push!(matches, Match{T}([v1]))
            end
        end
    end
    return matches
end

function check_rule(r::Identity1Rule, zxd::ZXDiagram{T, P}, vs::Vector{T}) where {T, P}
    @inbounds v1 = vs[1]
    has_vertex(zxd.mg, v1) || return false
    if spider_type(zxd, v1) == SpiderType.Z || spider_type(zxd, v1) == SpiderType.X
        if is_zero_phase(phase(zxd, v1)) && (degree(zxd, v1)) == 2
            return true
        end
    end
    return false
end

function rewrite!(r::Identity1Rule, zxd::ZXDiagram{T, P}, vs::Vector{T}) where {T, P}
    @inbounds v1 = vs[1]
    v2, v3 = neighbors(zxd, v1, count_mul=true)
    add_edge!(zxd, v2, v3)
    rem_spider!(zxd, v1)
    return zxd
end
