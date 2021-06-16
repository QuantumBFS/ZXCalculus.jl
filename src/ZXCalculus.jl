module ZXCalculus

using YaoHIR
using MLStyle
using YaoLocations
using YaoHIR.IntrinsicOperation
using YaoLocations: plain
using LightGraphs
using Multigraphs

import LightGraphs: nv, ne, outneighbors, inneighbors, neighbors, rem_edge!,
    add_edge!, has_edge, degree, indegree, outdegree

export ZXGraph, spider_type, phase, convert_to_chain, convert_to_zxd

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
