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
    $(TYPEDSIGNATURES)

Add a gate to the end of the circuit.
"""
push_gate!(::AbstractZXCircuit, args...) = error("push_gate! not implemented")

"""
    $(TYPEDSIGNATURES)

Add a gate to the beginning of the circuit.
"""
pushfirst_gate!(::AbstractZXCircuit, args...) = error("pushfirst_gate! not implemented")
