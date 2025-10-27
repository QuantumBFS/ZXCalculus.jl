# Calculus Interface Implementation for ZXCircuit
# Most operations delegate to the underlying ZXGraph

# Spider queries
spiders(circ::ZXCircuit) = spiders(circ.zx_graph)
spider_type(circ::ZXCircuit, v::Integer) = spider_type(circ.zx_graph, v)
spider_types(circ::ZXCircuit) = spider_types(circ.zx_graph)
phase(circ::ZXCircuit, v::Integer) = phase(circ.zx_graph, v)
phases(circ::ZXCircuit) = phases(circ.zx_graph)

edge_type(circ::ZXCircuit, v1::Integer, v2::Integer) = edge_type(circ.zx_graph, v1, v2)
set_edge_type!(circ::ZXCircuit{T, P}, args...) where {T, P} = set_edge_type!(circ.zx_graph, args...)
is_zx_spider(circ::ZXCircuit, v::Integer) = is_zx_spider(circ.zx_graph, v)

# Spider manipulation
set_phase!(circ::ZXCircuit{T, P}, args...) where {T, P} = set_phase!(circ.zx_graph, args...)

function add_spider!(circ::ZXCircuit{T, P}, st::SpiderType.SType, p::P=zero(P), connect::Vector{T}=T[]) where {
        T, P}
    v = add_spider!(circ.zx_graph, st, p, connect)
    if st in (SpiderType.Z, SpiderType.X)
        circ.phase_ids[v] = (v, 1)
    end
    return v
end

function rem_spiders!(circ::ZXCircuit{T, P}, vs::Vector{T}) where {T, P}
    rem_spiders!(circ.zx_graph, vs)
    for v in vs
        delete!(circ.phase_ids, v)
    end
    return circ
end

rem_spider!(circ::ZXCircuit{T, P}, v::T) where {T, P} = rem_spiders!(circ, [v])

insert_spider!(circ::ZXCircuit{T, P}, args...) where {T, P} = insert_spider!(circ.zx_graph, args...)

# Delegated add_spider! without phase tracking
add_spider!(circ::ZXCircuit, args...) = add_spider!(circ.zx_graph, args...)

# Global properties
scalar(circ::ZXCircuit) = scalar(circ.zx_graph)
tcount(circ::ZXCircuit) = tcount(circ.zx_graph)

add_global_phase!(circ::ZXCircuit{T, P}, p::P) where {T, P} = add_global_phase!(circ.zx_graph, p)
add_power!(circ::ZXCircuit, n::Integer) = add_power!(circ.zx_graph, n)

# Note: round_phases! is inherited via delegation
# No explicit implementation needed since it operates on the zx_graph
