# Calculus Interface Implementation for ZXGraph

# Spider queries
spiders(zxg::ZXGraph) = vertices(zxg.mg)
spider_type(zxg::ZXGraph, v::Integer) = zxg.st[v]
spider_types(zxg::ZXGraph) = zxg.st
phase(zxg::ZXGraph, v::Integer) = zxg.ps[v]
phases(zxg::ZXGraph) = zxg.ps

# Edge type queries (ZXGraph-specific)
edge_type(zxg::ZXGraph, v1::Integer, v2::Integer) = zxg.et[(min(v1, v2), max(v1, v2))]
is_zx_spider(zxg::ZXGraph, v::Integer) = spider_type(zxg, v) in (SpiderType.Z, SpiderType.X)

function is_hadamard(zxg::ZXGraph, v1::Integer, v2::Integer)
    @assert has_edge(zxg, v1, v2) "no edge between $v1 and $v2"
    return edge_type(zxg, v1, v2) == EdgeType.HAD
end

# Spider manipulation
function set_phase!(zxg::ZXGraph{T, P}, v::T, p::P) where {T, P}
    @assert has_vertex(zxg, v) "no vertex $v in graph"
    # TODO: should not allow setting phase for non-Z/X spiders
    # if is_zx_spider(zxg, v)
    zxg.ps[v] = round_phase(p)
    return true
    # end
    # return false
end

function set_spider_type!(zxg::ZXGraph, v::Integer, st::SpiderType.SType)
    @assert has_vertex(zxg, v) "no vertex $v in graph"
    zxg.st[v] = st
    return true
end

function set_edge_type!(zxg::ZXGraph, v1::Integer, v2::Integer, etype::EdgeType.EType)
    @assert has_edge(zxg, v1, v2) "no edge between $v1 and $v2"
    zxg.et[(min(v1, v2), max(v1, v2))] = etype
    return true
end

function add_spider!(zxg::ZXGraph{T, P}, st::SpiderType.SType, phase::P=zero(P), connect::Vector{T}=T[]) where {
        T <: Integer, P}
    v = add_vertex!(zxg.mg)[1]
    set_spider_type!(zxg, v, st)
    set_phase!(zxg, v, phase)
    if all(has_vertex(zxg, c) for c in connect)
        for c in connect
            add_edge!(zxg, v, c)
        end
    end
    return v
end

function rem_spiders!(zxg::ZXGraph{T, P}, vs::Vector{T}) where {T, P}
    if rem_vertices!(zxg.mg, vs)
        for v in vs
            delete!(zxg.ps, v)
            delete!(zxg.st, v)
        end
        return true
    end
    return false
end

rem_spider!(zxg::ZXGraph{T, P}, v::T) where {T, P} = rem_spiders!(zxg, [v])

function insert_spider!(zxg::ZXGraph{T, P}, v1::T, v2::T,
        stype::SpiderType.SType=SpiderType.Z, phase::P=zero(P)) where {T <: Integer, P}
    v = add_spider!(zxg, stype, phase, [v1, v2])
    rem_edge!(zxg, v1, v2)
    return v
end

# Global properties
scalar(zxg::ZXGraph) = zxg.scalar

function add_global_phase!(zxg::ZXGraph{T, P}, p::P) where {T, P}
    add_phase!(zxg.scalar, p)
    return zxg
end

function add_power!(zxg::ZXGraph, n)
    add_power!(zxg.scalar, n)
    return zxg
end

tcount(cir::ZXGraph) = sum(!is_clifford_phase(phase(cir, v)) for v in spiders(cir) if is_zx_spider(cir, v))

function round_phases!(zxg::ZXGraph{T, P}) where {T <: Integer, P}
    ps = zxg.ps
    for v in keys(ps)
        while ps[v] < 0
            ps[v] += 2
        end
        ps[v] = round_phase(ps[v])
    end
end

function reduce_parallel_edges!(zxg::ZXGraph, v1::Integer, v2::Integer, etype::EdgeType.EType)
    st1 = spider_type(zxg, v1)
    st2 = spider_type(zxg, v2)
    @assert is_zx_spider(zxg, v1) && is_zx_spider(zxg, v2) "Trying to process parallel edges to non-Z/X spider $v1 or $v2"
    function parallel_edge_helper()
        add_power!(zxg, -2)
        return rem_edge!(zxg, v1, v2)
    end

    if st1 == st2
        if edge_type(zxg, v1, v2) === etype === EdgeType.HAD
            parallel_edge_helper()
        elseif edge_type(zxg, v1, v2) !== etype
            set_edge_type!(zxg, v1, v2, EdgeType.SIM)
            reduce_self_loop!(zxg, v1, EdgeType.HAD)
        end
    elseif st1 != st2
        if edge_type(zxg, v1, v2) === etype === EdgeType.SIM
            parallel_edge_helper()
        elseif edge_type(zxg, v1, v2) !== etype
            set_edge_type!(zxg, v1, v2, EdgeType.HAD)
            reduce_self_loop!(zxg, v1, EdgeType.HAD)
        end
    end
    return zxg
end

function reduce_self_loop!(zxg::ZXGraph, v::Integer, etype::EdgeType.EType)
    @assert is_zx_spider(zxg, v) "Trying to process a self-loop on non-Z/X spider $v"
    if etype == EdgeType.HAD
        set_phase!(zxg, v, phase(zxg, v)+1)
        add_power!(zxg, -1)
    end
    return zxg
end
