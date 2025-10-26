"""
Calculus Interface for AbstractZXDiagram

This file documents and declares the ZX-calculus-specific operations for spider and scalar manipulation.
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

# Declare interface functions
function spiders end
function spider_type end
function spider_types end
function phase end
function phases end
function set_phase! end
function add_spider! end
function rem_spider! end
function rem_spiders! end
function insert_spider! end
function scalar end
function add_global_phase! end
function add_power! end
function tcount end
function round_phases! end
