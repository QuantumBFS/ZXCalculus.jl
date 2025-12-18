"""
    $(TYPEDEF)

Abstract type for ZX-diagrams with circuit structure.

This type represents ZX-diagrams that have explicit quantum circuit semantics,
including ordered inputs, outputs, and layout information for visualization.

# Interface Requirements

Concrete subtypes must implement both:

 1. The `AbstractZXDiagram` interfaces (graph_interface, calculus_interface)

 2. The circuit-specific interfaces defined here:

      + `circuit_interface.jl`: Circuit structure and gate operations
      + `layout_interface.jl`: Layout information for visualization

Use `Interfaces.test` to verify implementations.

# See also

  - [`AbstractZXDiagram`](@ref): Base abstract type for all ZX-diagrams
  - [`ZXCircuit`](@ref): Main implementation with ZXGraph composition
  - [`ZXGraph`](@ref): Pure graph representation without circuit assumptions
"""
abstract type AbstractZXCircuit{T <: Integer, P <: AbstractPhase} <: AbstractZXDiagram{T, P} end
