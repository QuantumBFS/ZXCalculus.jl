module ZX

using Graphs, Multigraphs, YaoHIR, YaoLocations
using YaoHIR.IntrinsicOperation
using YaoHIR: Chain
using YaoLocations: plain
using MLStyle
using ..Utils: AbstractPhase, Phase,
               is_zero_phase, is_one_phase, is_pauli_phase,
               is_half_integer_phase, is_clifford_phase, round_phase

import ..Utils: Scalar,
                add_phase!, add_power!

export spiders,
       tcount, spider_type, phase, rem_spider!, rem_spiders!, pushfirst_gate!, push_gate!

export SpiderType, EdgeType
export AbstractZXDiagram, ZXDiagram, ZXGraph, ZXCircuit

export AbstractRule
export Rule, Match
export FusionRule, XToZRule,
       Identity1Rule, HBoxRule,
       PiRule, CopyRule, BialgebraRule,
       LocalCompRule,
       Pivot1Rule, Pivot2Rule, Pivot3Rule,
       PivotBoundaryRule, PivotGadgetRule,
       IdentityRemovalRule, GadgetFusionRule,
       ScalarRule, ParallelEdgeRemovalRule

export rewrite!, simplify!

export convert_to_chain, convert_to_zxd, convert_to_zxwd
export clifford_simplification, full_reduction, circuit_extraction, phase_teleportation
export plot
export concat!, dagger, contains_only_bare_wires, verify_equality

include("abstract_zx_diagram.jl")
include("abstract_zx_circuit.jl")
include("zx_layout.jl")
include("zx_diagram.jl")
include("zx_graph.jl")
include("zx_circuit.jl")

include("rules/rules.jl")
include("simplify.jl")

include("circuit_extraction.jl")
include("phase_teleportation.jl")

include("ir.jl")

include("equality.jl")

end
