"""
    ZXGraph{T, P}

This is the type for representing the graph-like ZX-diagrams.

A pure graph representation without circuit structure assumptions.
Spiders of type In/Out can exist but are treated as searchable vertices,
not as ordered inputs/outputs.
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

function plot(zxd::ZXGraph{T, P}; kwargs...) where {T, P}
    return error("missing extension, please use Vega with 'using Vega, DataFrames'")
end
