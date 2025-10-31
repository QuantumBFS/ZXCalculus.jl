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
Graphs.nv(circ::AbstractZXCircuit) = Graphs.nv(base_zx_graph(circ))
Graphs.ne(::AbstractZXDiagram) = error("ne not implemented")
Graphs.ne(circ::AbstractZXCircuit) = Graphs.ne(base_zx_graph(circ))

# Degree queries
Graphs.degree(::AbstractZXDiagram, v) = error("degree not implemented")
Graphs.degree(circ::AbstractZXCircuit, v) = Graphs.degree(base_zx_graph(circ), v)
Graphs.indegree(::AbstractZXDiagram, v) = error("indegree not implemented")
Graphs.indegree(circ::AbstractZXCircuit, v) = Graphs.indegree(base_zx_graph(circ), v)
Graphs.outdegree(::AbstractZXDiagram, v) = error("outdegree not implemented")
Graphs.outdegree(circ::AbstractZXCircuit, v) = Graphs.outdegree(base_zx_graph(circ), v)

# Neighbor queries
Graphs.neighbors(::AbstractZXDiagram, v) = error("neighbors not implemented")
Graphs.neighbors(circ::AbstractZXCircuit, v) = Graphs.neighbors(base_zx_graph(circ), v)
Graphs.outneighbors(::AbstractZXDiagram, v) = error("outneighbors not implemented")
Graphs.outneighbors(circ::AbstractZXCircuit, v) = Graphs.outneighbors(base_zx_graph(circ), v)
Graphs.inneighbors(::AbstractZXDiagram, v) = error("inneighbors not implemented")
Graphs.inneighbors(circ::AbstractZXCircuit, v) = Graphs.inneighbors(base_zx_graph(circ), v)

# Edge operations
Graphs.has_edge(::AbstractZXDiagram, v1, v2) = error("has_edge not implemented")
Graphs.has_edge(circ::AbstractZXCircuit, v1, v2) = Graphs.has_edge(base_zx_graph(circ), v1, v2)
Graphs.add_edge!(::AbstractZXDiagram, v1, v2, args...) = error("add_edge! not implemented")
Graphs.add_edge!(circ::AbstractZXCircuit, v1, v2, args...) = Graphs.add_edge!(base_zx_graph(circ), v1, v2, args...)
Graphs.rem_edge!(::AbstractZXDiagram, v1, v2) = error("rem_edge! not implemented")
Graphs.rem_edge!(circ::AbstractZXCircuit, v1, v2) = Graphs.rem_edge!(base_zx_graph(circ), v1, v2)
