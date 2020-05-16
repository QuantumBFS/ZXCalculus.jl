"""
    Multigraphs

An multigraph extension for `LightGraphs`.
"""
module Multigraphs

include("multiple_edge.jl")
include("abstract_multigraph.jl")
include("multigraph_adjlist.jl")
include("di_multigraph.jl")
include("multiple_edge_iter.jl")

end # module
