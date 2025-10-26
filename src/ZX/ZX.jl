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
export AbstractZXDiagram, AbstractZXCircuit, ZXDiagram, ZXGraph, ZXCircuit

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

# Load types
include("types/spider_type.jl")
include("types/edge_type.jl")
include("types/zx_layout.jl")

# Load interfaces
include("interfaces/abstract_zx_diagram.jl")
include("interfaces/graph_interface.jl")
include("interfaces/calculus_interface.jl")
include("interfaces/abstract_zx_circuit.jl")
include("interfaces/circuit_interface.jl")
include("interfaces/layout_interface.jl")

# Load utilities
include("utils/conversion.jl")

# Load implementations
# ZXDiagram must be loaded first (needed by ZXGraph and ZXCircuit constructors)
include("implementations/zx_diagram/type.jl")
include("implementations/zx_diagram/graph_ops.jl")
include("implementations/zx_diagram/calculus_ops.jl")
include("implementations/zx_diagram/circuit_ops.jl")
include("implementations/zx_diagram/layout_ops.jl")
include("implementations/zx_diagram/composition_ops.jl")

# ZXGraph
include("implementations/zx_graph/type.jl")
include("implementations/zx_graph/graph_ops.jl")
include("implementations/zx_graph/calculus_ops.jl")

# ZXCircuit
include("implementations/zx_circuit/type.jl")
include("implementations/zx_circuit/graph_ops.jl")
include("implementations/zx_circuit/calculus_ops.jl")
include("implementations/zx_circuit/circuit_ops.jl")
include("implementations/zx_circuit/layout_ops.jl")
include("implementations/zx_circuit/phase_tracking.jl")

# Rules and algorithms
include("rules/rules.jl")
include("simplify.jl")

include("circuit_extraction.jl")
include("phase_teleportation.jl")

include("ir.jl")

include("equality.jl")

end
