"""
Calculus Interface for AbstractZXDiagram

This file declares the ZX-calculus-specific operations for spider and scalar manipulation.
All concrete implementations of AbstractZXDiagram must implement these methods.

# Methods (17 total):

## Spider Queries (5):
- `spiders(zxd)`: Get all spider vertices
- `spider_type(zxd, v)`: Get type of spider v
- `spider_types(zxd)`: Get all spider types
- `phase(zxd, v)`: Get phase of spider v
- `phases(zxd)`: Get all spider phases

## Spider Manipulation (5):
- `set_phase!(zxd, v, p)`: Set phase of spider v
- `add_spider!(zxd, st, p)`: Add a new spider
- `rem_spider!(zxd, v)`: Remove spider v
- `rem_spiders!(zxd, vs)`: Remove multiple spiders
- `insert_spider!(zxd, v1, v2)`: Insert spider between v1 and v2

## Global Properties and Scalar (5):
- `scalar(zxd)`: Get the global scalar
- `add_global_phase!(zxd, p)`: Add to global phase
- `add_power!(zxd, n)`: Add to power of √2
- `tcount(zxd)`: Count non-Clifford phases
- `round_phases!(zxd)`: Round phases to [0, 2π)

## Base Methods (2):
- `Base.show(io, zxd)`: Display ZX-diagram
- `Base.copy(zxd)`: Create a copy
"""

# Declare interface methods with abstract type signatures

# Spider queries
spiders(::AbstractZXDiagram) = error("spiders not implemented")
spider_type(::AbstractZXDiagram, v) = error("spider_type not implemented")
spider_types(::AbstractZXDiagram) = error("spider_types not implemented")
phase(::AbstractZXDiagram, v) = error("phase not implemented")
phases(::AbstractZXDiagram) = error("phases not implemented")

# Spider manipulation
set_phase!(::AbstractZXDiagram, v, p) = error("set_phase! not implemented")
add_spider!(::AbstractZXDiagram, st, p) = error("add_spider! not implemented")
rem_spider!(::AbstractZXDiagram, v) = error("rem_spider! not implemented")
rem_spiders!(::AbstractZXDiagram, vs) = error("rem_spiders! not implemented")
insert_spider!(::AbstractZXDiagram, v1, v2) = error("insert_spider! not implemented")

# Global properties and scalar
scalar(::AbstractZXDiagram) = error("scalar not implemented")
add_global_phase!(::AbstractZXDiagram, p) = error("add_global_phase! not implemented")
add_power!(::AbstractZXDiagram, n) = error("add_power! not implemented")
tcount(::AbstractZXDiagram) = error("tcount not implemented")
round_phases!(::AbstractZXDiagram) = error("round_phases! not implemented")

# Base methods are typically not declared here since they're defined in Base
# Concrete implementations should extend Base.show and Base.copy directly
