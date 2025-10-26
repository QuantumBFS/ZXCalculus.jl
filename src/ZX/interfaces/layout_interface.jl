"""
Layout Interface for AbstractZXCircuit

This file documents and declares layout information for visualization and analysis of ZX-circuits.
All concrete implementations of AbstractZXCircuit must implement these methods.

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

# Declare interface functions
function qubit_loc end
function column_loc end
function generate_layout! end
function spider_sequence end
