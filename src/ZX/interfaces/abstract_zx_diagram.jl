"""
    AbstractZXDiagram{T, P}

Abstract type for ZX-diagrams, representing graph-like quantum circuit diagrams.

This type defines the base interface for all ZX-diagram representations, providing
graph operations and spider (vertex) manipulation methods.

# Interface Requirements

Concrete subtypes must implement the following interfaces:
- `graph_interface.jl`: Graph operations (Graphs.jl compatibility)
- `calculus_interface.jl`: Spider and scalar operations (ZX-calculus)

Use `Interfaces.test` to verify implementations.

See also: [`AbstractZXCircuit`](@ref), [`ZXGraph`](@ref), [`ZXCircuit`](@ref)
"""
abstract type AbstractZXDiagram{T <: Integer, P <: AbstractPhase} end
