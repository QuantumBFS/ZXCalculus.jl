"""
    AbstractZXCircuit{T, P} <: AbstractZXDiagram{T, P}

Abstract type for ZX-diagrams with circuit structure.

This type represents ZX-diagrams that have explicit quantum circuit semantics,
including ordered inputs, outputs, and layout information for visualization.

# Interface Requirements

Concrete subtypes must implement both:

 1. The `AbstractZXDiagram` interface (graph operations)
 2. The circuit-specific interface defined by `@interface`

Use `Interfaces.test` to verify implementations.

# See also

  - [`AbstractZXDiagram`](@ref): Base abstract type for all ZX-diagrams
  - [`ZXCircuit`](@ref): Main implementation with ZXGraph composition
  - [`ZXGraph`](@ref): Pure graph representation without circuit assumptions
"""
abstract type AbstractZXCircuit{T <: Integer, P <: AbstractPhase} <: AbstractZXDiagram{T, P} end

# Define the circuit-specific interface using Interfaces.jl
_components_zxcircuit = (
    mandatory=(
        # Circuit structure
        nqubits=x -> nqubits(x)::Int,
        get_inputs=x -> get_inputs(x)::Vector,
        get_outputs=x -> get_outputs(x)::Vector,

        # Layout information
        qubit_loc=(x, v) -> qubit_loc(x, v),
        column_loc=(x, v) -> column_loc(x, v),
        (generate_layout!)=x -> generate_layout!(x),
        spider_sequence=x -> spider_sequence(x),

        # Gate operations (circuit-specific)
        (push_gate!)=(x, args...) -> push_gate!(x, args...),
        (pushfirst_gate!)=(x, args...) -> pushfirst_gate!(x, args...)
    ),
    optional=(;)
)

@interface AbstractZXCircuitInterface AbstractZXCircuit _components_zxcircuit "Interface for ZX-diagrams with circuit structure"
