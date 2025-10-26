using Interfaces

"""
Calculus Interface for AbstractZXDiagram

This interface defines ZX-calculus-specific operations for spider and scalar manipulation.
It covers queries, modifications, and global properties of ZX-diagrams.

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
_components_calculus = (
    mandatory=(
        # Spider queries
        spiders=x -> spiders(x)::Vector,
        spider_type=(x, v) -> spider_type(x, v),
        spider_types=x -> spider_types(x)::Dict,
        phase=(x, v) -> phase(x, v),
        phases=x -> phases(x)::Dict,

        # Spider manipulation
        (set_phase!)=(x, v, p) -> set_phase!(x, v, p),
        (add_spider!)=(x, st, p) -> add_spider!(x, st, p),
        (rem_spider!)=(x, v) -> rem_spider!(x, v),
        (rem_spiders!)=(x, vs) -> rem_spiders!(x, vs),
        (insert_spider!)=(x, v1, v2) -> insert_spider!(x, v1, v2),

        # Global properties
        scalar=x -> scalar(x),
        (add_global_phase!)=(x, p) -> add_global_phase!(x, p),
        (add_power!)=(x, n) -> add_power!(x, n),
        tcount=x -> tcount(x)::Int,
        (round_phases!)=x -> round_phases!(x),

        # Base methods
        show = (io, x) -> Base.show(io, x),
        copy = x -> Base.copy(x),
    ),
    optional=(;)
)

# Combine graph and calculus components into AbstractZXDiagramInterface for compatibility
_components_zxdiagram = (
    mandatory=merge(
        _components_graph.mandatory,
        _components_calculus.mandatory
    ),
    optional=(;)
)

@interface AbstractZXDiagramInterface AbstractZXDiagram _components_zxdiagram "Interface for ZX-diagram graph operations and calculus"
