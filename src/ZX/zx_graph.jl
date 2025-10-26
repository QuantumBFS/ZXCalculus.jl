module EdgeType
@enum EType SIM HAD
end

"""
    ZXGraph{T, P}

This is the type for representing the graph-like ZX-diagrams.
"""
struct ZXGraph{T <: Integer, P <: AbstractPhase} <: AbstractZXDiagram{T, P}
    mg::Multigraph{T}
    ps::Dict{T, P}
    st::Dict{T, SpiderType.SType}
    et::Dict{Tuple{T, T}, EdgeType.EType}
    scalar::Scalar{P}
end

function Base.copy(zxg::ZXGraph{T, P}) where {T, P}
    return ZXGraph{T, P}(
        copy(zxg.mg), copy(zxg.ps),
        copy(zxg.st), copy(zxg.et),
        copy(zxg.scalar)
    )
end

function ZXGraph()
    return ZXGraph{Int, Phase}(Multigraph(zero(Int)), Dict{Int, Phase}(), Dict{Int, SpiderType.SType}(),
        Dict{Tuple{Int, Int}, EdgeType.EType}(), Scalar{Phase}(0, Phase(0 // 1)))
end

function ZXGraph(zxd::ZXDiagram{T, P}) where {T, P}
    zxd = copy(zxd)
    simplify!(ParallelEdgeRemovalRule(), zxd)
    et = Dict{Tuple{T, T}, EdgeType.EType}()
    for e in edges(zxd)
        @assert mul(zxd, src(e), dst(e)) == 1 "ZXCircuit: multiple edges should have been removed."
        s, d = src(e), dst(e)
        et[(min(s, d), max(s, d))] = EdgeType.SIM
    end
    return ZXGraph{T, P}(zxd.mg, zxd.ps, zxd.st, et, zxd.scalar)
end

Graphs.has_edge(zxg::ZXGraph, vs...) = has_edge(zxg.mg, vs...)
Graphs.has_vertex(zxg::ZXGraph, v::Integer) = has_vertex(zxg.mg, v)
Graphs.nv(zxg::ZXGraph) = nv(zxg.mg)
Graphs.ne(zxg::ZXGraph) = ne(zxg.mg)
Graphs.outneighbors(zxg::ZXGraph, v::Integer) = outneighbors(zxg.mg, v)
Graphs.inneighbors(zxg::ZXGraph, v::Integer) = inneighbors(zxg.mg, v)
Graphs.neighbors(zxg::ZXGraph, v::Integer) = neighbors(zxg.mg, v)
Graphs.degree(zxg::ZXGraph, v::Integer) = degree(zxg.mg, v)
Graphs.indegree(zxg::ZXGraph, v::Integer) = degree(zxg, v)
Graphs.outdegree(zxg::ZXGraph, v::Integer) = degree(zxg, v)
Graphs.edges(zxg::ZXGraph) = Graphs.edges(zxg.mg)
function Graphs.rem_edge!(zxg::ZXGraph, v1::Integer, v2::Integer)
    if rem_edge!(zxg.mg, v1, v2)
        delete!(zxg.et, (min(v1, v2), max(v1, v2)))
        return true
    end
    return false
end

function Graphs.add_edge!(zxg::ZXGraph, v1::Integer, v2::Integer, etype::EdgeType.EType=EdgeType.HAD)
    if has_vertex(zxg, v1) && has_vertex(zxg, v2)
        if v1 == v2
            reduce_self_loop!(zxg, v1, etype)
            return true
        else
            if !has_edge(zxg, v1, v2)
                add_edge!(zxg.mg, v1, v2)
                zxg.et[(min(v1, v2), max(v1, v2))] = etype
            else
                reduce_parallel_edges!(zxg, v1, v2, etype)
            end
            return true
        end
    end
    return false
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

spider_type(zxg::ZXGraph, v::Integer) = zxg.st[v]
spider_types(zxg::ZXGraph) = zxg.st
edge_type(zxg::ZXGraph, v1::Integer, v2::Integer) = zxg.et[(min(v1, v2), max(v1, v2))]
is_zx_spider(zxg::ZXGraph, v::Integer) = spider_type(zxg, v) in (SpiderType.Z, SpiderType.X)

function set_spider_type!(zxg::ZXGraph, v::Integer, st::SpiderType.SType)
    if has_vertex(zxg, v)
        zxg.st[v] = st
        return true
    end
    return false
end

function set_edge_type!(zxg::ZXGraph, v1::Integer, v2::Integer, etype::EdgeType.EType)
    if has_edge(zxg, v1, v2)
        zxg.et[(min(v1, v2), max(v1, v2))] = etype
        return true
    end
    return false
end

phase(zxg::ZXGraph, v::Integer) = zxg.ps[v]
phases(zxg::ZXGraph) = zxg.ps
function set_phase!(zxg::ZXGraph{T, P}, v::T, p::P) where {T, P}
    if has_vertex(zxg, v)
        while p < 0
            p += 2
        end
        zxg.ps[v] = round_phase(p)
        return true
    end
    return false
end

# Note: Circuit-specific methods (nqubits, qubit_loc, column_loc, generate_layout!)
# have been moved to AbstractZXCircuit interface.
# ZXGraph is a pure graph representation without circuit structure assumptions.

function is_hadamard(zxg::ZXGraph, v1::Integer, v2::Integer)
    if has_edge(zxg, v1, v2)
        src = min(v1, v2)
        dst = max(v1, v2)
        return zxg.et[(src, dst)] == EdgeType.HAD
    else
        error("no edge between $v1 and $v2")
    end
    return false
end
spiders(zxg::ZXGraph) = vertices(zxg.mg)

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

function add_spider!(zxg::ZXGraph{T, P}, st::SpiderType.SType, phase::P=zero(P), connect::Vector{T}=T[]) where {
        T <: Integer, P}
    v = add_vertex!(zxg.mg)[1]
    set_phase!(zxg, v, phase)
    zxg.st[v] = st
    if all(has_vertex(zxg, c) for c in connect)
        for c in connect
            add_edge!(zxg, v, c)
        end
    end
    return v
end
function insert_spider!(zxg::ZXGraph{T, P}, v1::T, v2::T,
        stype::SpiderType.SType=SpiderType.Z, phase::P=zero(P)) where {T <: Integer, P}
    v = add_spider!(zxg, stype, phase, [v1, v2])
    rem_edge!(zxg, v1, v2)
    return v
end

tcount(cir::ZXGraph) = sum(!is_clifford_phase(phase(cir, v)) for v in spiders(cir) if is_zx_spider(cir, v))

function print_spider(io::IO, zxg::ZXGraph{T}, v::T) where {T <: Integer}
    st_v = spider_type(zxg, v)
    if st_v == SpiderType.Z
        printstyled(io, "S_$(v){phase = $(phase(zxg, v))"*(zxg.ps[v] isa Phase ? "}" : "⋅π}"); color=:green)
    elseif st_v == SpiderType.X
        printstyled(io, "S_$(v){phase = $(phase(zxg, v))"*(zxg.ps[v] isa Phase ? "}" : "⋅π}"); color=:red)
    elseif st_v == SpiderType.H
        printstyled(io, "H_$(v)", color=:yellow)
    elseif st_v == SpiderType.In
        print(io, "S_$(v){input}")
    elseif st_v == SpiderType.Out
        print(io, "S_$(v){output}")
    end
end

function Base.show(io::IO, zxg::ZXGraph{T}) where {T <: Integer}
    println(io, "ZX-graph with $(nv(zxg)) vertices and $(ne(zxg)) edges:")
    vs = sort!(spiders(zxg))
    for i in 1:length(vs)
        for j in (i + 1):length(vs)
            if has_edge(zxg, vs[i], vs[j])
                print(io, "(")
                print_spider(io, zxg, vs[i])
                if is_hadamard(zxg, vs[i], vs[j])
                    printstyled(io, " <-> "; color=:blue)
                else
                    print(io, " <-> ")
                end
                print_spider(io, zxg, vs[j])
                print(io, ")\n")
            end
        end
    end
end

function round_phases!(zxg::ZXGraph{T, P}) where {T <: Integer, P}
    ps = zxg.ps
    for v in keys(ps)
        while ps[v] < 0
            ps[v] += 2
        end
        ps[v] = round_phase(ps[v])
    end
end

"""
    is_interior(zxg::ZXGraph, v)

Return `true` if `v` is a interior spider of `zxg`.
"""
function is_interior(zxg::ZXGraph{T, P}, v::T) where {T, P}
    if has_vertex(zxg, v)
        (spider_type(zxg, v) == SpiderType.In || spider_type(zxg, v) == SpiderType.Out) && return false
        for u in neighbors(zxg, v)
            if spider_type(zxg, u) == SpiderType.In || spider_type(zxg, u) == SpiderType.Out
                return false
            end
        end
        return true
    end
    return false
end

# Helper functions for finding input/output spiders in a ZXGraph
# Note: These are not methods - ZXGraph has no circuit structure guarantees.
# Use ZXCircuit if you need ordered inputs/outputs.

"""
    find_inputs(zxg::ZXGraph)

Find all spiders with type `SpiderType.In` in the graph.
This is a search utility and does not guarantee circuit structure or ordering.
"""
find_inputs(zxg::ZXGraph) = [v for v in spiders(zxg) if spider_type(zxg, v) == SpiderType.In]
get_inputs(zxg::ZXGraph) = find_inputs(zxg)

"""
    find_outputs(zxg::ZXGraph)

Find all spiders with type `SpiderType.Out` in the graph.
This is a search utility and does not guarantee circuit structure or ordering.
"""
find_outputs(zxg::ZXGraph) = [v for v in spiders(zxg) if spider_type(zxg, v) == SpiderType.Out]
get_outputs(zxg::ZXGraph) = find_outputs(zxg)

scalar(zxg::ZXGraph) = zxg.scalar

function add_global_phase!(zxg::ZXGraph{T, P}, p::P) where {T, P}
    add_phase!(zxg.scalar, p)
    return zxg
end

function add_power!(zxg::ZXGraph, n)
    add_power!(zxg.scalar, n)
    return zxg
end

function plot(zxd::ZXGraph{T, P}; kwargs...) where {T, P}
    return error("missing extension, please use Vega with 'using Vega, DataFrames'")
end
