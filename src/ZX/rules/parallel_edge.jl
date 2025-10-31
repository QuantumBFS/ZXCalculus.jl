struct ParallelEdgeRemovalRule <: AbstractRule end

function Base.match(::ParallelEdgeRemovalRule, zxd::ZXDiagram{T, P}) where {T, P}
    matches = Match{T}[]
    for e in edges(zxd)
        mul(e) == 1 && continue
        v1 = src(e)
        v2 = dst(e)
        push!(matches, Match{T}([min(v1, v2), max(v1, v2)]))
    end
    return matches
end

function check_rule(::ParallelEdgeRemovalRule, zxd::ZXDiagram{T, P}, vs::Vector{T}) where {T, P}
    v1, v2 = vs
    return has_edge(zxd, v1, v2) && (mul(zxd, v1, v2) > 1)
end

function rewrite!(::ParallelEdgeRemovalRule, zxd::ZXDiagram{T, P}, vs::Vector{T}) where {T, P}
    v1, v2 = vs
    st1 = spider_type(zxd, v1)
    st2 = spider_type(zxd, v2)
    m = mul(zxd, v1, v2)
    if st1 == st2 && (st1 in (SpiderType.Z, SpiderType.X))
        rem_edge!(zxd, v1, v2)
        isodd(m) && add_edge!(zxd, v1, v2)
    elseif (st1, st2) == (SpiderType.X, SpiderType.Z) || (st1, st2) == (SpiderType.Z, SpiderType.X)
        rem_edge!(zxd, v1, v2)
        isodd(m) && add_edge!(zxd, v1, v2)
        add_power!(zxd, -div(m, 2)*2)
    elseif st1 == SpiderType.H && st2 == SpiderType.H
        @assert degree(zxd, v1) == degree(zxd, v2) == 2 "ParallelEdgeRemovalRule: H spiders must have degree 2."
        rem_spiders!(zxd, [v1, v2])
    elseif st1 == SpiderType.H || st2 == SpiderType.H
        if st2 == SpiderType.H
            (v1, v2) = (v2, v1)
            (st1, st2) == (st2, st1)
        end
        @assert degree(zxd, v2) == 2 "ParallelEdgeRemovalRule: H spider must have degree 2."
        @assert st2 in (SpiderType.Z, SpiderType.X) "ParallelEdgeRemovalRule: H-box self-loop should be connected to Z/X-spider."
        set_phase!(zxd, v2, phase(zxd, v2)+1)
        add_power!(zxd, -1)
        rem_spider!(zxd, v1)
    else
        error("ParallelEdgeRemovalRule: unsupported spider types.")
    end
    return zxd
end