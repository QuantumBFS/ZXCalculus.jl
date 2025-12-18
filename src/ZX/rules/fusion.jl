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

function check_rule(::FusionRule, zxd::ZXDiagram{T, P}, vs::Vector{T}) where {T, P}
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

function rewrite!(::FusionRule, zxd::ZXDiagram{T, P}, vs::Vector{T}) where {T, P}
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

function Base.match(::FusionRule, zxg::ZXGraph{T, P}) where {T, P}
    matches = Match{T}[]
    for v1 in spiders(zxg)
        if spider_type(zxg, v1) == SpiderType.Z || spider_type(zxg, v1) == SpiderType.X
            for v2 in neighbors(zxg, v1)
                if spider_type(zxg, v1) == spider_type(zxg, v2) && !is_hadamard(zxg, v1, v2) && v2 >= v1
                    push!(matches, Match{T}([v1, v2]))
                end
            end
        end
    end
    return matches
end

function check_rule(::FusionRule, zxg::ZXGraph{T, P}, vs::Vector{T}) where {T, P}
    v1, v2 = vs
    (has_vertex(zxg.mg, v1) && has_vertex(zxg.mg, v2)) || return false
    if spider_type(zxg, v1) == SpiderType.Z || spider_type(zxg, v1) == SpiderType.X
        if v2 in neighbors(zxg, v1)
            if spider_type(zxg, v1) == spider_type(zxg, v2) && !is_hadamard(zxg, v1, v2) && v2 >= v1
                return true
            end
        end
    end
    return false
end

function rewrite!(::FusionRule, zxg::ZXGraph{T, P}, vs::Vector{T}) where {T, P}
    v1, v2 = vs
    for v3 in neighbors(zxg, v2)
        if v3 != v1
            et = edge_type(zxg, v2, v3)
            add_edge!(zxg, v1, v3, et)
        end
    end
    set_phase!(zxg, v1, phase(zxg, v1)+phase(zxg, v2))
    rem_spider!(zxg, v2)
    return zxg
end

function rewrite!(::FusionRule, circ::ZXCircuit{T, P}, vs::Vector{T}) where {T, P}
    v_to, v_from = vs
    rewrite!(FusionRule(), base_zx_graph(circ), vs)
    merge_phase_tracking!(circ, v_from, v_to)
    return circ
end