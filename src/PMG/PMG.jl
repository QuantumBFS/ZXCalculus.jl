module PMG

using Graphs

import Graphs: AbstractEdge, src, dst, nv, ne, neighbors
import Graphs.SimpleGraphs: vertices

export HalfEdge, src, dst, new_edge, PlanarMultigraph

include("planar_multigraph.jl")

end # module PlanarMultigraph
