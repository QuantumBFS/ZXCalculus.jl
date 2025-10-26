using Interfaces

"""
Circuit Interface for AbstractZXCircuit

This interface defines circuit-specific operations including structure queries and gate operations.
It extends AbstractZXDiagram with circuit semantics.

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
_components_circuit = (
    mandatory=(
        # Circuit structure
        nqubits=x -> nqubits(x)::Int,
        get_inputs=x -> get_inputs(x)::Vector,
        get_outputs=x -> get_outputs(x)::Vector,

        # Gate operations
        (push_gate!)=(x, args...) -> push_gate!(x, args...),
        (pushfirst_gate!)=(x, args...) -> pushfirst_gate!(x, args...),
    ),
    optional=(;)
)

# Don't create CircuitInterface yet - will be combined with layout_interface
# @interface CircuitInterface AbstractZXCircuit _components_circuit "Circuit structure and gate operations"
