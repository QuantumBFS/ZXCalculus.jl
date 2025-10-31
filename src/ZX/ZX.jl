module ZX

using DocStringExtensions
using Graphs, Multigraphs, YaoHIR, YaoLocations
using YaoHIR.IntrinsicOperation
using YaoHIR: Chain
using YaoLocations: plain
using MLStyle
using ..Utils: AbstractPhase, Phase,
               is_zero_phase, is_one_phase, is_pauli_phase,
               is_half_integer_phase, is_clifford_phase, round_phase
using ..Utils: safe_convert, continued_fraction
import ..Utils: Scalar,
                add_phase!, add_power!

# Load types
export SpiderType, EdgeType
include("types/spider_type.jl")
include("types/edge_type.jl")
include("types/zx_layout.jl")

# Load interfaces
export AbstractZXDiagram
include("interfaces/abstract_zx_diagram.jl")
export AbstractZXCircuit
include("interfaces/abstract_zx_circuit.jl")

include("interfaces/graph_interface.jl")
export spiders, spider_types, phases, spider_type, phase,
       set_phase!, add_spider!, rem_spider!, rem_spiders!, insert_spider!,
       scalar, add_global_phase!, add_power!,
       tcount, round_phases!, plot
include("interfaces/calculus_interface.jl")
export nqubits, get_inputs, get_outputs,
       qubit_loc, column_loc, generate_layout!,
       pushfirst_gate!, push_gate!, base_zx_graph
include("interfaces/circuit_interface.jl")
export qubit_loc, column_loc, generate_layout!, spider_sequence
include("interfaces/layout_interface.jl")

# Load implementations
# ZXGraph
export ZXGraph
include("implementations/zx_graph/type.jl")
include("implementations/zx_graph/graph_interface.jl")
include("implementations/zx_graph/calculus_interface.jl")

# ZXDiagram
export ZXDiagram
include("implementations/zx_diagram/type.jl")
include("implementations/zx_diagram/graph_interface.jl")
include("implementations/zx_diagram/calculus_interface.jl")
include("implementations/zx_diagram/circuit_interface.jl")
include("implementations/zx_diagram/layout_interface.jl")
include("implementations/zx_diagram/composition_interface.jl")

# ZXCircuit
export ZXCircuit
include("implementations/zx_circuit/type.jl")
include("implementations/zx_circuit/calculus_interface.jl")
include("implementations/zx_circuit/circuit_interface.jl")
include("implementations/zx_circuit/layout_interface.jl")
include("implementations/zx_circuit/composition_interface.jl")
include("implementations/zx_circuit/phase_tracking.jl")

# Rules and algorithms
export AbstractRule
export Rule, Match
export FusionRule, XToZRule, Identity1Rule, HBoxRule,
       PiRule, CopyRule, BialgebraRule,
       LocalCompRule, Pivot1Rule, Pivot2Rule, Pivot3Rule,
       PivotBoundaryRule, PivotGadgetRule,
       IdentityRemovalRule, GadgetFusionRule,
       ScalarRule, ParallelEdgeRemovalRule
include("rules/rules.jl")

export rewrite!, simplify!
include("algorithms/simplify.jl")

export clifford_simplification, full_reduction, circuit_extraction, phase_teleportation, ancilla_extraction
include("algorithms/clifford_simplification.jl")
include("algorithms/full_reduction.jl")
include("algorithms/circuit_extraction.jl")
include("algorithms/phase_teleportation.jl")

export convert_to_chain, convert_to_zx_circuit, convert_to_zxd
include("ir.jl")

export concat!, dagger, contains_only_bare_wires, verify_equality
include("equality.jl")

end
