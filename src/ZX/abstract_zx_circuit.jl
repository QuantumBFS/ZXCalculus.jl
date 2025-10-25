"""
    AbstractZXCircuit{T, P} <: AbstractZXDiagram{T, P}

Abstract type for ZX-diagrams with circuit structure.

This type represents ZX-diagrams that have explicit quantum circuit semantics,
including ordered inputs, outputs, and layout information for visualization.

# Circuit-specific interface

Concrete subtypes must implement:
- `nqubits(zxc)`: Return the number of qubits
- `get_inputs(zxc)`: Return ordered input spiders
- `get_outputs(zxc)`: Return ordered output spiders
- `qubit_loc(zxc, v)`: Return the qubit location of spider `v`
- `column_loc(zxc, v)`: Return the column location of spider `v`
- `generate_layout!(zxc)`: Generate layout information for visualization
- `spider_sequence(zxc)`: Return spiders ordered by qubit and column
- `push_gate!(zxc, args...)`: Add a gate at the end of the circuit
- `pushfirst_gate!(zxc, args...)`: Add a gate at the beginning of the circuit

In addition to the basic graph operations required by `AbstractZXDiagram`.

# See also
- [`AbstractZXDiagram`](@ref): Base abstract type for all ZX-diagrams
- [`ZXCircuit`](@ref): Main implementation with ZXGraph composition
- [`ZXGraph`](@ref): Pure graph representation without circuit assumptions
"""
abstract type AbstractZXCircuit{T <: Integer, P <: AbstractPhase} <: AbstractZXDiagram{T, P} end

# Circuit-specific interface declarations
# These methods must be implemented by concrete subtypes

nqubits(zxd::AbstractZXCircuit) = throw(MethodError(ZX.nqubits, zxd))
get_inputs(zxd::AbstractZXCircuit) = throw(MethodError(ZX.get_inputs, zxd))
get_outputs(zxd::AbstractZXCircuit) = throw(MethodError(ZX.get_outputs, zxd))
qubit_loc(zxd::AbstractZXCircuit, v) = throw(MethodError(ZX.qubit_loc, (zxd, v)))
column_loc(zxd::AbstractZXCircuit, v) = throw(MethodError(ZX.column_loc, (zxd, v)))
generate_layout!(zxd::AbstractZXCircuit) = throw(MethodError(ZX.generate_layout!, zxd))
spider_sequence(zxd::AbstractZXCircuit) = throw(MethodError(ZX.spider_sequence, zxd))
push_gate!(zxd::AbstractZXCircuit, args...) = throw(MethodError(ZX.push_gate!, (zxd, args...)))
pushfirst_gate!(zxd::AbstractZXCircuit, args...) = throw(MethodError(ZX.pushfirst_gate!, (zxd, args...)))
