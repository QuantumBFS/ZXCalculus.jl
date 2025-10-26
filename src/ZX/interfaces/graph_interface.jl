"""
Graph Interface for AbstractZXDiagram

This file documents the Graphs.jl-compatible interface that all ZX-diagrams must implement.
The methods are imported from Graphs.jl and implementations should define them for their types.

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

All methods from Graphs.jl are imported and should be extended by concrete implementations.
"""

# Import Graphs.jl methods that should be implemented
using Graphs

# These methods are imported from Graphs.jl and should be extended by implementations:
# - Graphs.nv
# - Graphs.ne
# - Graphs.degree
# - Graphs.indegree
# - Graphs.outdegree
# - Graphs.neighbors
# - Graphs.outneighbors
# - Graphs.inneighbors
# - Graphs.has_edge
# - Graphs.add_edge!
# - Graphs.rem_edge!
