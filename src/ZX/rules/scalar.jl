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
    p = phase(zxg, v)
    if is_zero_phase(p)
        add_power!(zxg, 2)
    elseif is_pi_phase(p)
        add_power!(zxg, -Inf)
    elseif p == Phase(1//2)
        add_power!(zxg, 1)
        add_global_phase!(zxg, Phase(1//4))
    elseif p == Phase(3//2)
        add_power!(zxg, 1)
        add_global_phase!(zxg, Phase(-1//4))
    else
        @warn "Ignoring non-Clifford scalar spider with phase $p"
    end
    rem_spider!(zxg, v)
    return zxg
end
