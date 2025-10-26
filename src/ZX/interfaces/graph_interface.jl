using Interfaces

"""
Graph Interface for AbstractZXDiagram

This interface defines the Graphs.jl-compatible operations that all ZX-diagrams must implement.
It provides basic graph structure queries and manipulation methods.

# Methods (11 total):

## Vertex and Edge Counts:
- `Graphs.nv(zxd)`: Number of vertices (spiders)
- `Graphs.ne(zxd)`: Number of edges

## Degree Queries:
- `Graphs.degree(zxd, v)`: Total degree of vertex v
- `Graphs.indegree(zxd, v)`: In-degree of vertex v
- `Graphs.outdegree(zxd, v)`: Out-degree of vertex v

## Neighbor Queries:
- `Graphs.neighbors(zxd, v)`: All neighbors of v
- `Graphs.outneighbors(zxd, v)`: Out-neighbors of v
- `Graphs.inneighbors(zxd, v)`: In-neighbors of v

## Edge Operations:
- `Graphs.has_edge(zxd, v1, v2)`: Check if edge exists
- `Graphs.add_edge!(zxd, v1, v2)`: Add an edge
- `Graphs.rem_edge!(zxd, v1, v2)`: Remove an edge
"""
_components_graph = (
    mandatory=(
        # Vertex and edge counts
        nv=x -> Graphs.nv(x)::Int,
        ne=x -> Graphs.ne(x)::Int,

        # Degree queries
        degree=(x, v) -> Graphs.degree(x, v)::Int,
        indegree=(x, v) -> Graphs.indegree(x, v)::Int,
        outdegree=(x, v) -> Graphs.outdegree(x, v)::Int,

        # Neighbor queries
        neighbors=(x, v) -> Graphs.neighbors(x, v)::Vector,
        outneighbors=(x, v) -> Graphs.outneighbors(x, v)::Vector,
        inneighbors=(x, v) -> Graphs.inneighbors(x, v)::Vector,

        # Edge operations
        has_edge=(x, v1, v2) -> Graphs.has_edge(x, v1, v2)::Bool,
        (add_edge!)=(x, v1, v2) -> Graphs.add_edge!(x, v1, v2),
        (rem_edge!)=(x, v1, v2) -> Graphs.rem_edge!(x, v1, v2),
    ),
    optional=(;)
)

@interface GraphInterface AbstractZXDiagram _components_graph "Graphs.jl-compatible interface for ZX-diagrams"
