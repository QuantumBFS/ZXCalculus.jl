"""
Layout Interface for AbstractZXCircuit

This file declares layout information for visualization and analysis of ZX-circuits.
All concrete implementations of AbstractZXCircuit must implement these methods.

# Layout Coordinates
- Qubit location: Integer representing which qubit wire (1 to nqubits)
- Column location: Rational representing time/depth in the circuit
- Spider sequence: Vector of vectors, one per qubit, ordered by column
"""

# Layout queries

"""
    $(TYPEDSIGNATURES)

Get the qubit (row) location of spider `v` in the circuit layout.

Returns an integer representing the qubit wire index (1 to nqubits), or `nothing` if not in layout.
"""
qubit_loc(::AbstractZXCircuit, v) = error("qubit_loc not implemented")

"""
    $(TYPEDSIGNATURES)

Get the column (time/depth) location of spider `v` in the circuit layout.

Returns a rational number representing the position along the circuit, or `nothing` if not in layout.
"""
column_loc(::AbstractZXCircuit, v) = error("column_loc not implemented")

# Layout generation

"""
    $(TYPEDSIGNATURES)

Generate or update the layout for the circuit.

This computes the spatial positioning (qubit and column locations) of all spiders
for visualization and analysis purposes.

Returns a `ZXLayout` object containing the layout information.
"""
generate_layout!(::AbstractZXCircuit) = error("generate_layout! not implemented")

"""
    $(TYPEDSIGNATURES)

Get the ordered sequence of spiders for each qubit.

Returns a vector of vectors, where each inner vector contains the spider vertices
on a particular qubit wire, ordered by their column position.
"""
spider_sequence(::AbstractZXCircuit) = error("spider_sequence not implemented")
