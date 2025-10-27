"""
Graph Interface for AbstractZXDiagram

This file declares the Graphs.jl-compatible interface that all ZX-diagrams must implement.
All concrete subtypes of AbstractZXDiagram should implement these methods.

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

# Declare interface methods with abstract type signatures
# Vertex and edge counts
Graphs.nv(::AbstractZXDiagram) = error("nv not implemented")
Graphs.ne(::AbstractZXDiagram) = error("ne not implemented")

# Degree queries
Graphs.degree(::AbstractZXDiagram, v) = error("degree not implemented")
Graphs.indegree(::AbstractZXDiagram, v) = error("indegree not implemented")
Graphs.outdegree(::AbstractZXDiagram, v) = error("outdegree not implemented")

# Neighbor queries
Graphs.neighbors(::AbstractZXDiagram, v) = error("neighbors not implemented")
Graphs.outneighbors(::AbstractZXDiagram, v) = error("outneighbors not implemented")
Graphs.inneighbors(::AbstractZXDiagram, v) = error("inneighbors not implemented")

# Edge operations
Graphs.has_edge(::AbstractZXDiagram, v1, v2) = error("has_edge not implemented")
Graphs.add_edge!(::AbstractZXDiagram, v1, v2) = error("add_edge! not implemented")
Graphs.rem_edge!(::AbstractZXDiagram, v1, v2) = error("rem_edge! not implemented")
