function Base.match(::Rule{:lc}, zxg::ZXGraph{T, P}) where {T, P}
    matches = Match{T}[]
    vs = spiders(zxg)
    vB = [get_inputs(zxg); get_outputs(zxg)]
    for i in 1:length(vB)
        push!(vB, neighbors(zxg, vB[i])[1])
    end
    sort!(vB)
    for v in vs
        if spider_type(zxg, v) == SpiderType.Z &&
           is_half_integer_phase(phase(zxg, v))
            if length(searchsorted(vB, v)) == 0
                if degree(zxg, v) == 1
                    # rewrite phase gadgets first
                    pushfirst!(matches, Match{T}([neighbors(zxg, v)[1]]))
                    pushfirst!(matches, Match{T}([v]))
                else
                    push!(matches, Match{T}([v]))
                end
            end
        end
    end
    return matches
end

function check_rule(::Rule{:lc}, zxg::ZXGraph{T, P}, vs::Vector{T}) where {T, P}
    @inbounds v = vs[1]
    has_vertex(zxg.mg, v) || return false
    if has_vertex(zxg.mg, v)
        if spider_type(zxg, v) == SpiderType.Z &&
           is_half_integer_phase(phase(zxg, v))
            if is_interior(zxg, v)
                return true
            end
        end
    end
    return false
end

function rewrite!(r::Rule{:lc}, zxg::ZXGraph{T, P}, vs::Vector{T}) where {T, P}
    @inbounds v = vs[1]
    phase_v = phase(zxg, v)
    if phase_v == 1//2
        add_global_phase!(zxg, P(1//4))
    else
        add_global_phase!(zxg, P(-1//4))
    end
    nb = neighbors(zxg, v)
    n = length(nb)
    add_power!(zxg, (n-1)*(n-2)//2)
    rem_spider!(zxg, v)
    for u1 in nb, u2 in nb

        if u2 > u1
            add_edge!(zxg, u1, u2, EdgeType.HAD)
        end
    end
    for u in nb
        set_phase!(zxg, u, phase(zxg, u)-phase_v)
    end
    return zxg
end
