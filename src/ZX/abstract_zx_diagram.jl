using Interfaces

"""
    AbstractZXDiagram{T, P}

Abstract type for ZX-diagrams, representing graph-like quantum circuit diagrams.

This type defines the base interface for all ZX-diagram representations, providing
graph operations and spider (vertex) manipulation methods.

# Interface Requirements

Concrete subtypes must implement the interface defined by `@interface`.
Use `Interfaces.test` to verify implementations.

See also: [`AbstractZXCircuit`](@ref), [`ZXGraph`](@ref), [`ZXCircuit`](@ref)
"""
abstract type AbstractZXDiagram{T <: Integer, P <: AbstractPhase} end

# Define the interface using Interfaces.jl
_components_zxdiagram = (
    mandatory=(
        # Graphs.jl interface - provide signatures and tests
        nv=x -> Graphs.nv(x)::Int,
        ne=x -> Graphs.ne(x)::Int,
        degree=(x, v) -> Graphs.degree(x, v)::Int,
        indegree=(x, v) -> Graphs.indegree(x, v)::Int,
        outdegree=(x, v) -> Graphs.outdegree(x, v)::Int,
        neighbors=(x, v) -> Graphs.neighbors(x, v)::Vector,
        outneighbors=(x, v) -> Graphs.outneighbors(x, v)::Vector,
        inneighbors=(x, v) -> Graphs.inneighbors(x, v)::Vector,
        has_edge=(x, v1, v2) -> Graphs.has_edge(x, v1, v2)::Bool,
        (add_edge!)=(x, v1, v2) -> Graphs.add_edge!(x, v1, v2),
        (rem_edge!)=(x, v1, v2) -> Graphs.rem_edge!(x, v1, v2),

        # Base methods
        show = (io, x) -> Base.show(io, x),
        copy = x -> Base.copy(x),

        # ZX-specific spider operations
        spiders=x -> spiders(x)::Vector,
        spider_type=(x, v) -> spider_type(x, v),
        spider_types=x -> spider_types(x)::Dict,
        phase=(x, v) -> phase(x, v),
        phases=x -> phases(x)::Dict,
        (set_phase!)=(x, v, p) -> set_phase!(x, v, p),

        # Spider manipulation
        (add_spider!)=(x, st, p) -> add_spider!(x, st, p),
        (rem_spider!)=(x, v) -> rem_spider!(x, v),
        (rem_spiders!)=(x, vs) -> rem_spiders!(x, vs),
        (insert_spider!)=(x, v1, v2) -> insert_spider!(x, v1, v2),

        # Global properties
        scalar=x -> scalar(x),
        (add_global_phase!)=(x, p) -> add_global_phase!(x, p),
        (add_power!)=(x, n) -> add_power!(x, n),
        tcount=x -> tcount(x)::Int,
        (round_phases!)=x -> round_phases!(x)
    ),
    optional=(;)
)

@interface AbstractZXDiagramInterface AbstractZXDiagram _components_zxdiagram "Interface for ZX-diagram graph operations"
