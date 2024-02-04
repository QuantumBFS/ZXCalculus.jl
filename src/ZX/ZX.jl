module ZX

using Graphs, Multigraphs, YaoHIR, YaoLocations
using YaoHIR.IntrinsicOperation
using YaoHIR: Chain
using YaoLocations: plain
using MLStyle
using ..Utils: Scalar, Phase, add_phase!

import ..Utils: add_power!

export spiders,
    tcount, spider_type, phase, rem_spider!, rem_spiders!, pushfirst_gate!, push_gate!

export SpiderType, EdgeType
export AbstractZXDiagram, ZXDiagram, ZXGraph

export AbstractRule
export Rule, Match

export rewrite!, simplify!

export convert_to_chain, convert_to_zxd
export clifford_simplification, full_reduction, circuit_extraction, phase_teleportation
export plot
export concat!, dagger,  contains_only_bare_wires, verify_equality

include("abstract_zx_diagram.jl")
include("zx_layout.jl")
include("zx_diagram.jl")
include("zx_graph.jl")

include("rules.jl")
include("simplify.jl")

include("circuit_extraction.jl")
include("phase_teleportation.jl")

include("ir.jl")

include("equality.jl")
end
