module ZXCalculus

include("phase.jl")
include("scalar.jl")
include("abstract_zx_diagram.jl")
include("zx_layout.jl")
include("zx_diagram.jl")
include("qcircuit.jl")
include("zx_graph.jl")
include("rules.jl")

include("simplify.jl")

include("circuit_extraction.jl")
include("phase_teleportation.jl")

include("deprecations.jl")

end # module
