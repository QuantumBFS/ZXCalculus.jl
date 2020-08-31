module ZXCalculus

include("Multigraphs/multiple_edge.jl")
include("Multigraphs/abstract_multigraph.jl")
include("Multigraphs/multigraph_adjlist.jl")
include("Multigraphs/multiple_edge_iter.jl")

include("abstract_zx_diagram.jl")
include("zx_layout.jl")
include("zx_diagram.jl")
include("zx_graph.jl")
include("rules.jl")

include("simplify.jl")

include("circuit_extraction.jl")
include("phase_teleportation.jl")

include("deprecations.jl")

end # module
