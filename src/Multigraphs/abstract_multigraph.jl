using LightGraphs
using SparseArrays

import Base: show, eltype, copy
import LightGraphs: nv, has_edge, has_vertex, add_edge!, rem_edge!, rem_vertex!,
    rem_vertices!, add_vertex!, add_vertices!, outneighbors, inneighbors, vertices, edges,
    adjacency_matrix, src, dst, nv, edgetype

export AbstractMultigraph
# export multype

"""
    AbstractMultigraph{T}<:AbstractGraph{T}

An abstract type representing a multigraph.
"""
abstract type AbstractMultigraph{T<:Integer} <:AbstractGraph{T} end

function copy(mg::AbstractMultigraph{T}) where {T} end

function show(io::IO, mg::AbstractMultigraph{T}) where {T}
    dir = is_directed(mg) ? "directed" : "undirected"
    print(io, "{$(nv(mg)), $(ne(mg))} $(dir) $(T) multigraph")
end

eltype(mg::AbstractMultigraph{T}) where {T<:Integer} = T
multype(mg::AbstractMultigraph) = Int
edgetype(mg::AbstractMultigraph) = MultipleEdge{eltype(mg), multype(mg)}

function nv(mg::AbstractMultigraph) end
function vertices(mg::AbstractMultigraph) end

function adjacency_matrix(mg::AbstractMultigraph) end

function has_edge(mg::AbstractMultigraph, e::AbstractMultipleEdge)
    s = src(e)
    d = dst(e)
    if s in vertices(mg) && d in vertices(mg)
        return mul(mg, s, d) >= mul(e)
    else
        return false
    end
end

has_edge(mg::AbstractMultigraph, t) = has_edge(mg, MultipleEdge(t))
add_edge!(mg::AbstractMultigraph, t) = add_edge!(mg, MultipleEdge(t))
rem_edge!(mg::AbstractMultigraph, t) = rem_edge!(mg, MultipleEdge(t))

has_edge(mg::AbstractMultigraph, x, y) = has_edge(mg, MultipleEdge(x, y))
add_edge!(mg::AbstractMultigraph, x, y) = add_edge!(mg, MultipleEdge(x, y))
rem_edge!(mg::AbstractMultigraph, x, y) = rem_edge!(mg, MultipleEdge(x, y))

"""
    has_edge(mg::AbstractMultigraph, s, d, mul)

Return `true` if `mg` has a multiple edge from `s` to `d` whose multiplicity
is not less than `mul`.

## Examples
```jldoctest
julia> using LightGraphs, Multigraphs

julia> mg = Multigraph(3);

julia> add_edge!(mg, 1, 2, 2);

julia> has_edge(mg, 1, 2, 3)
false

julia> has_edge(mg, 1, 2, 2)
true
```
"""
has_edge(mg::AbstractMultigraph, x, y, z) = has_edge(mg, MultipleEdge(x, y, z))

"""
    add_edge!(mg::AbstractMultigraph, s, d, mul)

Add a multiple edge from `s` to `d` multiplicity `mul`. If there is a multiple
edge from `s` to `d`, it will increase its multiplicity by `mul`.

Return `true` multiple edge was added successfully, otherwise return `false`.

## Examples
```jldoctest
julia> using LightGraphs, Multigraphs

julia> mg = Multigraph(3);

julia> e = MultipleEdge(1, 2, 1);

julia> add_edge!(mg, e);

julia> ne(mg, true)
1

julia> add_edge!(mg, e);

julia> ne(mg, true)
2
```
"""
add_edge!(mg::AbstractMultigraph, x, y, z) = add_edge!(mg, MultipleEdge(x, y, z))

"""
    rem_edge!(mg::AbstractMultigraph, s, d, mul)

Remove the multiplicity of edge from `s` to `d` by `mul` in `mg`, if `mg` has such
a multiple edge.

## Examples
```jldoctest
julia> using LightGraphs, Multigraphs

julia> mg = Multigraph(3);

julia> add_edge!(mg, 1, 2, 2);

julia> rem_edge!(mg, 1, 2, 3)
false

julia> rem_edge!(mg, 1, 2, 2)
true
```
"""
rem_edge!(mg::AbstractMultigraph, x, y, z) = rem_edge!(mg, MultipleEdge(x, y, z))

has_vertex(mg::AbstractMultigraph, v::Integer) = v in vertices(mg)
rem_vertex!(mg::AbstractMultigraph{T}, v::T) where {T<:Integer} = rem_vertices!(mg, [v])
add_vertex!(mg::AbstractMultigraph{T}) where {T<:Integer} = add_vertices!(mg, one(T))

function outneighbors(mg::AbstractMultigraph, v) end
function inneighbors(mg::AbstractMultigraph, v) end

"""
    edges(mg::AbstractMultigraph)

Return a  `MultipleEdgeIter` for `mg`.

## Examples
```jltestdoc
julia>
julia> using LightGraphs, Multigraphs

julia> mg = Multigraph(path_graph(4));

julia> add_edge!(mg, 1, 3, 2);

julia> collect(edges(mg))
4-element Array{Any,1}:
 Multiple edge 1 => 2 with multiplicity 1
 Multiple edge 1 => 3 with multiplicity 2
 Multiple edge 2 => 3 with multiplicity 1
 Multiple edge 3 => 4 with multiplicity 1

```
"""
edges(mg::AbstractMultigraph) = MultipleEdgeIter(mg)

"""
    mul(mg::AbstractMultigraph, src, dst)

Return the multiplicity of the edge from `src` to `dst`.
"""
