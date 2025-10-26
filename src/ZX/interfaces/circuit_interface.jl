"""
Circuit Interface for AbstractZXCircuit

This file documents and declares circuit-specific operations including structure queries and gate operations.
All concrete implementations of AbstractZXCircuit must implement these methods.

# Methods (5 total):

## Circuit Structure (3):
- `nqubits(circ)`: Number of qubits in the circuit
- `get_inputs(circ)`: Get ordered input spider vertices
- `get_outputs(circ)`: Get ordered output spider vertices

## Gate Operations (2):
- `push_gate!(circ, ::Val{gate}, locs..., [phase])`: Add gate to end of circuit
- `pushfirst_gate!(circ, ::Val{gate}, locs..., [phase])`: Add gate to beginning of circuit

Supported gates: :Z, :X, :H, :CNOT, :CZ, :SWAP
Phase gates (:Z, :X) accept an optional phase parameter.
"""

# Declare interface functions
function nqubits end
function get_inputs end
function get_outputs end
function push_gate! end
function pushfirst_gate! end
