# Calculus Interface Implementation for ZXCircuit
# Most operations delegate to the underlying ZXGraph

function add_spider!(circ::ZXCircuit{T, P}, st::SpiderType.SType, p::P=zero(P), connect::Vector{T}=T[]) where {
        T, P}
    v = add_spider!(base_zx_graph(circ), st, p, connect)
    if st in (SpiderType.Z, SpiderType.X)
        circ.phase_ids[v] = (v, 1)
    end
    return v
end

function rem_spiders!(circ::ZXCircuit{T, P}, vs::Vector{T}) where {T, P}
    rem_spiders!(base_zx_graph(circ), vs)
    for v in vs
        delete!(circ.phase_ids, v)
    end
    return circ
end
