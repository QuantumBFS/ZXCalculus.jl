"""
Circuit Interface for AbstractZXCircuit

This file declares circuit-specific operations including structure queries and gate operations.
All concrete implementations of AbstractZXCircuit must implement these methods.

Supported gates: :Z, :X, :H, :CNOT, :CZ, :SWAP
Rotation gates (:Z, :X) accept an optional phase parameter.
"""

# Circuit structure

"""
    $(TYPEDSIGNATURES)

Get the number of qubits in the circuit.

Returns an integer representing the qubit count.
"""
nqubits(::AbstractZXCircuit) = error("nqubits not implemented")

"""
    $(TYPEDSIGNATURES)

Get the ordered input spider vertices of the circuit.

Returns a vector of vertex identifiers in qubit order.
"""
get_inputs(::AbstractZXCircuit) = error("get_inputs not implemented")

"""
    $(TYPEDSIGNATURES)

Get the ordered output spider vertices of the circuit.

Returns a vector of vertex identifiers in qubit order.
"""
get_outputs(::AbstractZXCircuit) = error("get_outputs not implemented")

# Gate operations

"""
    push_gate!(circ::AbstractZXCircuit, ::Val{gate}, locs..., [phase])

Add a gate to the end of the circuit.

# Arguments

  - `circ`: The circuit to modify
  - `gate`: Gate type as Val (e.g., `Val(:H)`, `Val(:CNOT)`)
  - `locs`: Qubit locations where the gate is applied
  - `phase`: Optional phase parameter for phase gates (:Z, :X)

# Supported gates

  - Single-qubit: `:Z`, `:X`, `:H`
  - Two-qubit: `:CNOT`, `:CZ`, `:SWAP`
"""
function push_gate! end

"""
    pushfirst_gate!(circ::AbstractZXCircuit, ::Val{gate}, locs..., [phase])

Add a gate to the beginning of the circuit.

# Arguments

  - `circ`: The circuit to modify
  - `gate`: Gate type as Val (e.g., `Val(:H)`, `Val(:CNOT)`)
  - `locs`: Qubit locations where the gate is applied
  - `phase`: Optional phase parameter for phase gates (:Z, :X)

# Supported gates

  - Single-qubit: `:Z`, `:X`, `:H`
  - Two-qubit: `:CNOT`, `:CZ`, `:SWAP`
"""
function pushfirst_gate! end
