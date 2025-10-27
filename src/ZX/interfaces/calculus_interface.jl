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

"""
    $(TYPEDSIGNATURES)

Get the type of spider `v` in the ZX-diagram.

Returns a `SpiderType.SType` value (Z, X, H, In, or Out).
"""
spider_type(::AbstractZXDiagram, v) = error("spider_type not implemented")

"""
    $(TYPEDSIGNATURES)

Get all spider types in the ZX-diagram.

Returns a dictionary mapping vertex identifiers to their spider types.
"""
spider_types(::AbstractZXDiagram) = error("spider_types not implemented")

"""
    $(TYPEDSIGNATURES)

Get the phase of spider `v` in the ZX-diagram.

Returns a phase value (typically `AbstractPhase`).
"""
phase(::AbstractZXDiagram, v) = error("phase not implemented")

"""
    $(TYPEDSIGNATURES)

Get all spider phases in the ZX-diagram.

Returns a dictionary mapping vertex identifiers to their phases.
"""
phases(::AbstractZXDiagram) = error("phases not implemented")

# Spider manipulation

"""
    $(TYPEDSIGNATURES)

Set the phase of spider `v` to `p` in the ZX-diagram.
"""
set_phase!(::AbstractZXDiagram, v, p) = error("set_phase! not implemented")

"""
    $(TYPEDSIGNATURES)

Add a new spider with spider type `st` and phase `p` to the ZX-diagram.

Returns the vertex identifier of the newly added spider.
"""
add_spider!(::AbstractZXDiagram, st, p) = error("add_spider! not implemented")

"""
    $(TYPEDSIGNATURES)

Remove spider `v` from the ZX-diagram.
"""
rem_spider!(::AbstractZXDiagram, v) = error("rem_spider! not implemented")

"""
    $(TYPEDSIGNATURES)

Remove multiple spiders `vs` from the ZX-diagram.
"""
rem_spiders!(::AbstractZXDiagram, vs) = error("rem_spiders! not implemented")

"""
    $(TYPEDSIGNATURES)

Insert a new spider on the edge between vertices `v1` and `v2`.

Returns the vertex identifier of the newly inserted spider.
"""
insert_spider!(::AbstractZXDiagram, v1, v2) = error("insert_spider! not implemented")

# Global properties and scalar

"""
    $(TYPEDSIGNATURES)

Get the global scalar of the ZX-diagram.

Returns a `Scalar` object containing the phase and power of √2.
"""
scalar(::AbstractZXDiagram) = error("scalar not implemented")

"""
    $(TYPEDSIGNATURES)

Add phase `p` to the global phase of the ZX-diagram.
"""
add_global_phase!(::AbstractZXDiagram, p) = error("add_global_phase! not implemented")

"""
    $(TYPEDSIGNATURES)

Add `n` to the power of √2 in the global scalar.
"""
add_power!(::AbstractZXDiagram, n) = error("add_power! not implemented")

"""
    $(TYPEDSIGNATURES)

Count the number of non-Clifford phases (T-gates) in the ZX-diagram.

Returns an integer count.
"""
tcount(::AbstractZXDiagram) = error("tcount not implemented")

"""
    $(TYPEDSIGNATURES)

Round all phases in the ZX-diagram to the range [0, 2π).
"""
round_phases!(::AbstractZXDiagram) = error("round_phases! not implemented")

# Base methods are typically not declared here since they're defined in Base
# Concrete implementations should extend Base.show and Base.copy directly

"""
    $(TYPEDSIGNATURES)

Plot the ZX-diagram.
"""
plot(zxd::AbstractZXDiagram; kwargs...) = error("missing extension, please use Vega with 'using Vega, DataFrames'")
