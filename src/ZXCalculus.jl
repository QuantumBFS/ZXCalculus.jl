module ZXCalculus

using YaoHIR
using MLStyle
using YaoLocations
using YaoHIR: X, Y, Z, H, S, T, Rx, Ry, Rz, UGate, shift
using YaoLocations: plain

export convert_to_block_ir, convert_to_zxd

include("phase.jl")
include("scalar.jl")
include("abstract_zx_diagram.jl")
include("zx_layout.jl")
include("zx_diagram.jl")
include("zx_graph.jl")
include("rules.jl")
include("simplify.jl")

include("ir.jl")

include("circuit_extraction.jl")
include("phase_teleportation.jl")

include("deprecations.jl")

end # module
