function Base.match(::Rule{:id}, zxg::ZXGraph{T, P}) where {T, P}
    matches = Match{T}[]
    for v2 in spiders(zxg)
        nb2 = neighbors(zxg, v2)
        if spider_type(zxg, v2) == SpiderType.Z && length(nb2) == 2
            v1, v3 = nb2
            if is_zero_phase(phase(zxg, v2))
                if spider_type(zxg, v1) == SpiderType.Z && spider_type(zxg, v3) == SpiderType.Z
                    push!(matches, Match{T}([v1, v2, v3]))
                end

                if (
                    (
                    spider_type(zxg, v1) == SpiderType.In ||
                    spider_type(zxg, v1) == SpiderType.Out
                ) && (
                    spider_type(zxg, v3) == SpiderType.In ||
                    spider_type(zxg, v3) == SpiderType.Out
                )
                )
                    push!(matches, Match{T}([v1, v2, v3]))
                end
            else
                is_one_phase(phase(zxg, v2))
                if spider_type(zxg, v1) == SpiderType.Z && spider_type(zxg, v3) == SpiderType.Z
                    if degree(zxg, v1) == 1
                        push!(matches, Match{T}([v1, v2, v3]))
                    elseif degree(zxg, v3) == 1
                        push!(matches, Match{T}([v1, v2, v3]))
                    end
                end
            end
        end
    end
    return matches
end

function check_rule(::Rule{:id}, zxg::ZXGraph{T, P}, vs::Vector{T}) where {T, P}
    v1, v2, v3 = vs
    if has_vertex(zxg.mg, v2)
        nb2 = neighbors(zxg, v2)
        if spider_type(zxg, v2) == SpiderType.Z && length(nb2) == 2
            (v1 in nb2 && v3 in nb2) || return false
            if is_zero_phase(phase(zxg, v2))
                if spider_type(zxg, v1) == SpiderType.Z && spider_type(zxg, v3) == SpiderType.Z
                    return true
                end
                if ((spider_type(zxg, v1) == SpiderType.In || spider_type(zxg, v1) == SpiderType.Out) &&
                    (spider_type(zxg, v3) == SpiderType.In || spider_type(zxg, v3) == SpiderType.Out))
                    return true
                end

            else
                is_one_phase(phase(zxg, v2))
                if spider_type(zxg, v1) == SpiderType.Z && spider_type(zxg, v3) == SpiderType.Z
                    return degree(zxg, v1) == 1 || degree(zxg, v3) == 1
                end
            end
        end
    end
    return false
end

function rewrite!(::Rule{:id}, zxg::ZXGraph{T, P}, vs::Vector{T}) where {T, P}
    v1, v2, v3 = vs
    if is_one_phase(phase(zxg, v2))
        set_phase!(zxg, v2, zero(P))
        set_phase!(zxg, v1, -phase(zxg, v1))
        zxg.phase_ids[v1] = (zxg.phase_ids[v1][1], -zxg.phase_ids[v1][2])
    end
    if ((spider_type(zxg, v1) == SpiderType.In || spider_type(zxg, v1) == SpiderType.Out ||
         spider_type(zxg, v3) == SpiderType.In || spider_type(zxg, v3) == SpiderType.Out))
        rem_spider!(zxg, v2)
        add_edge!(zxg, v1, v3, EdgeType.SIM)

    else
        set_phase!(zxg, v3, phase(zxg, v3)+phase(zxg, v1))
        id1, mul1 = zxg.phase_ids[v1]
        id3, mul3 = zxg.phase_ids[v3]
        set_phase!(zxg.master, id3, (mul3 * phase(zxg.master, id3) + mul1 * phase(zxg.master, id1)) * mul3)
        set_phase!(zxg.master, id1, zero(P))
        for v in neighbors(zxg, v1)
            v == v2 && continue
            add_edge!(zxg, v, v3, is_hadamard(zxg, v, v1) ? EdgeType.HAD : EdgeType.SIM)
        end
        rem_spiders!(zxg, [v1, v2])
    end
    return zxg
end
