using Interfaces

"""
Layout Interface for AbstractZXCircuit

This interface defines layout information for visualization and analysis of ZX-circuits.
It provides spatial positioning of spiders in the circuit diagram.

# Methods (4 total):

## Layout Queries:
- `qubit_loc(circ, v)`: Get the qubit (row) location of spider v
- `column_loc(circ, v)`: Get the column (time) location of spider v

## Layout Generation:
- `generate_layout!(circ)`: Generate or update the layout for the circuit
- `spider_sequence(circ)`: Get ordered sequence of spiders for each qubit

# Layout Coordinates

- Qubit location: Integer representing which qubit wire (1 to nqubits)
- Column location: Rational representing time/depth in the circuit
- Spider sequence: Vector of vectors, one per qubit, ordered by column
"""
_components_layout = (
    mandatory=(
        # Layout queries
        qubit_loc=(x, v) -> qubit_loc(x, v),
        column_loc=(x, v) -> column_loc(x, v),

        # Layout generation
        (generate_layout!)=x -> generate_layout!(x),
        spider_sequence=x -> spider_sequence(x),
    ),
    optional=(;)
)

# Combine circuit and layout components into AbstractZXCircuitInterface for compatibility
_components_zxcircuit = (
    mandatory=merge(
        _components_circuit.mandatory,
        _components_layout.mandatory
    ),
    optional=(;)
)

@interface AbstractZXCircuitInterface AbstractZXCircuit _components_zxcircuit "Interface for ZX-diagrams with circuit structure"
