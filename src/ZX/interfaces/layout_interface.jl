"""
Layout Interface for AbstractZXCircuit

This file declares layout information for visualization and analysis of ZX-circuits.
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

# Declare interface methods with abstract type signatures

# Layout queries
qubit_loc(::AbstractZXCircuit, v) = error("qubit_loc not implemented")
column_loc(::AbstractZXCircuit, v) = error("column_loc not implemented")

# Layout generation
generate_layout!(::AbstractZXCircuit) = error("generate_layout! not implemented")
spider_sequence(::AbstractZXCircuit) = error("spider_sequence not implemented")
