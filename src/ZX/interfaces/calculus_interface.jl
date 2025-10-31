"""
Calculus Interface for AbstractZXDiagram

This file declares the ZX-calculus-specific operations for spider and scalar manipulation.
All concrete implementations of AbstractZXDiagram must implement these methods.
"""

# Spider queries

"""
    $(TYPEDSIGNATURES)

Get all spider vertices in the ZX-diagram.

Returns a vector of vertex identifiers.
"""
spiders(::AbstractZXDiagram) = error("spiders not implemented")
spiders(circ::AbstractZXCircuit) = spiders(base_zx_graph(circ))

"""
    $(TYPEDSIGNATURES)

Get all spider types in the ZX-diagram.

Returns a dictionary mapping vertex identifiers to their spider types.
"""
spider_types(::AbstractZXDiagram) = error("spider_types not implemented")
spider_types(circ::AbstractZXCircuit) = spider_types(base_zx_graph(circ))

"""
    $(TYPEDSIGNATURES)

Get all spider phases in the ZX-diagram.

Returns a dictionary mapping vertex identifiers to their phases.
"""
phases(::AbstractZXDiagram) = error("phases not implemented")
phases(circ::AbstractZXCircuit) = phases(base_zx_graph(circ))

"""
    $(TYPEDSIGNATURES)

Get the type of spider `v` in the ZX-diagram.

Returns a `SpiderType.SType` value (Z, X, H, In, or Out).
"""
spider_type(::AbstractZXDiagram, v) = error("spider_type not implemented")
spider_type(circ::AbstractZXCircuit, v) = spider_type(base_zx_graph(circ), v)

"""
    $(TYPEDSIGNATURES)

Get the phase of spider `v` in the ZX-diagram.

Returns a phase value (typically `AbstractPhase`).
"""
phase(::AbstractZXDiagram, v) = error("phase not implemented")
phase(circ::AbstractZXCircuit, v) = phase(base_zx_graph(circ), v)

# Spider manipulation

"""
    $(TYPEDSIGNATURES)

Set the phase of spider `v` to `p` in the ZX-diagram.
"""
set_phase!(::AbstractZXDiagram, v, p) = error("set_phase! not implemented")
set_phase!(circ::AbstractZXCircuit, v, p) = set_phase!(base_zx_graph(circ), v, p)

"""
    $(TYPEDSIGNATURES)

Add a new spider with spider type `st` and phase `p` to the ZX-diagram.

Returns the vertex identifier of the newly added spider.
"""
add_spider!(::AbstractZXDiagram, stype, args...) = error("add_spider! not implemented")
add_spider!(circ::AbstractZXCircuit, stype, args...) = add_spider!(base_zx_graph(circ), stype, args...)

"""
    $(TYPEDSIGNATURES)

Remove spider `v` from the ZX-diagram.
"""
rem_spider!(zxd::AbstractZXDiagram, v) = rem_spiders!(zxd, [v])
rem_spider!(circ::AbstractZXCircuit, v) = rem_spider!(base_zx_graph(circ), v)

"""
    $(TYPEDSIGNATURES)

Remove multiple spiders `vs` from the ZX-diagram.
"""
rem_spiders!(::AbstractZXDiagram, vs) = error("rem_spiders! not implemented")
rem_spiders!(circ::AbstractZXCircuit, vs) = rem_spiders!(base_zx_graph(circ), vs)

"""
    $(TYPEDSIGNATURES)

Insert a new spider on the edge between vertices `v1` and `v2`.

Returns the vertex identifier of the newly inserted spider.
"""
insert_spider!(::AbstractZXDiagram, v1, v2, stype, args...) = error("insert_spider! not implemented")
function insert_spider!(circ::AbstractZXCircuit, v1, v2, stype, args...)
    return insert_spider!(base_zx_graph(circ), v1, v2, stype, args...)
end

# Global properties and scalar

"""
    $(TYPEDSIGNATURES)

Get the global scalar of the ZX-diagram.

Returns a `Scalar` object containing the phase and power of √2.
"""
scalar(::AbstractZXDiagram) = error("scalar not implemented")
scalar(circ::AbstractZXCircuit) = scalar(base_zx_graph(circ))

"""
    $(TYPEDSIGNATURES)

Add phase `p` to the global phase of the ZX-diagram.
"""
add_global_phase!(::AbstractZXDiagram, p) = error("add_global_phase! not implemented")
add_global_phase!(circ::AbstractZXCircuit, p) = add_global_phase!(base_zx_graph(circ), p)

"""
    $(TYPEDSIGNATURES)

Add `n` to the power of √2 in the global scalar.
"""
add_power!(::AbstractZXDiagram, n) = error("add_power! not implemented")
add_power!(circ::AbstractZXCircuit, n) = add_power!(base_zx_graph(circ), n)

"""
    $(TYPEDSIGNATURES)

Count the number of non-Clifford phases (T-gates) in the ZX-diagram.

Returns an integer count.
"""
tcount(::AbstractZXDiagram) = error("tcount not implemented")
tcount(circ::AbstractZXCircuit) = tcount(base_zx_graph(circ))

"""
    $(TYPEDSIGNATURES)

Round all phases in the ZX-diagram to the range [0, 2π).
"""
round_phases!(::AbstractZXDiagram) = error("round_phases! not implemented")
round_phases!(circ::AbstractZXCircuit) = round_phases!(base_zx_graph(circ))

# Base methods are typically not declared here since they're defined in Base
# Concrete implementations should extend Base.show and Base.copy directly

"""
    $(TYPEDSIGNATURES)

Plot the ZX-diagram.
"""
plot(zxd::AbstractZXDiagram; kwargs...) = error("missing extension, please use Vega with 'using Vega, DataFrames'")

"""
    $(TYPEDSIGNATURES)

Return the edge type between vertices v1 and v2 in the ZX-diagram.
"""
edge_type(::AbstractZXDiagram, v1, v2) = error("edge_type not implemented")
edge_type(circ::AbstractZXCircuit, v1, v2) = edge_type(base_zx_graph(circ), v1, v2)

"""
    $(TYPEDSIGNATURES)

Return `true` if the edge between vertices v1 and v2 is a Hadamard edge in the ZX-diagram.
"""
is_hadamard(zxg::AbstractZXDiagram, v1, v2) = (edge_type(zxg, v1, v2) == EdgeType.HAD)
is_hadamard(circ::AbstractZXCircuit, v1, v2) = is_hadamard(base_zx_graph(circ), v1, v2)

"""
    $(TYPEDSIGNATURES)

Set the edge type between vertices v1 and v2 in the ZX-diagram.
"""
set_edge_type!(::AbstractZXDiagram, v1, v2, etype) = error("set_edge_type! not implemented")
set_edge_type!(circ::AbstractZXCircuit, v1, v2, etype) = set_edge_type!(base_zx_graph(circ), v1, v2, etype)