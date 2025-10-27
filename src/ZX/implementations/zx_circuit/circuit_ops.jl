# Circuit Interface Implementation for ZXCircuit

nqubits(circ::ZXCircuit) = circ.layout.nbits
get_inputs(circ::ZXCircuit) = circ.inputs
get_outputs(circ::ZXCircuit) = circ.outputs

# Gate operations for ZXCircuit
# These operate on the underlying ZXGraph

function push_gate!(circ::ZXCircuit{T, P}, ::Val{:Z}, loc::T, phase=zero(P); autoconvert::Bool=true) where {T, P}
    @inbounds out_id = get_outputs(circ)[loc]
    @assert spider_type(circ, out_id) === SpiderType.Out "Output spider at location $loc is not of type Out."
    @inbounds bound_id = neighbors(circ, out_id)[1]
    et = edge_type(circ, bound_id, out_id)
    rphase = autoconvert ? safe_convert(P, phase) : phase
    v = insert_spider!(circ, bound_id, out_id, SpiderType.Z, rphase)
    set_edge_type!(circ, v, bound_id, et)
    set_edge_type!(circ, v, out_id, EdgeType.SIM)
    return circ
end

function push_gate!(circ::ZXCircuit{T, P}, ::Val{:X}, loc::T, phase=zero(P); autoconvert::Bool=true) where {T, P}
    @inbounds out_id = get_outputs(circ)[loc]
    @assert spider_type(circ, out_id) === SpiderType.Out "Output spider at location $loc is not of type Out."
    @inbounds bound_id = neighbors(circ, out_id)[1]
    et = edge_type(circ, bound_id, out_id)
    rphase = autoconvert ? safe_convert(P, phase) : phase
    v = insert_spider!(circ, bound_id, out_id, SpiderType.X, rphase)
    set_edge_type!(circ, v, bound_id, et)
    set_edge_type!(circ, v, out_id, EdgeType.SIM)
    return circ
end

function push_gate!(circ::ZXCircuit{T, P}, ::Val{:H}, loc::T) where {T, P}
    @inbounds out_id = get_outputs(circ)[loc]
    @assert spider_type(circ, out_id) === SpiderType.Out "Output spider at location $loc is not of type Out."
    @inbounds bound_id = neighbors(circ, out_id)[1]
    et = edge_type(circ, bound_id, out_id)
    v = insert_spider!(circ, bound_id, out_id, SpiderType.H)
    set_edge_type!(circ, v, bound_id, et)
    set_edge_type!(circ, v, out_id, EdgeType.SIM)
    return circ
end

function push_gate!(circ::ZXCircuit{T, P}, ::Val{:SWAP}, locs::Vector{T}) where {T, P}
    q1, q2 = locs
    push_gate!(circ, Val{:Z}(), q1)
    push_gate!(circ, Val{:Z}(), q2)
    push_gate!(circ, Val{:Z}(), q1)
    push_gate!(circ, Val{:Z}(), q2)
    v1, v2, bound_id1, bound_id2 = (sort!(spiders(circ)))[(end - 3):end]
    rem_edge!(circ, v1, bound_id1)
    rem_edge!(circ, v2, bound_id2)
    add_edge!(circ, v1, bound_id2, EdgeType.SIM)
    add_edge!(circ, v2, bound_id1, EdgeType.SIM)
    return circ
end

function push_gate!(circ::ZXCircuit{T, P}, ::Val{:CNOT}, loc::T, ctrl::T) where {T, P}
    push_gate!(circ, Val{:Z}(), ctrl)
    push_gate!(circ, Val{:X}(), loc)
    @inbounds v1, v2 = (sort!(spiders(circ)))[(end - 1):end]
    add_edge!(circ, v1, v2, EdgeType.SIM)
    add_power!(circ, 1)
    return circ
end

function push_gate!(circ::ZXCircuit{T, P}, ::Val{:CZ}, loc::T, ctrl::T) where {T, P}
    push_gate!(circ, Val{:Z}(), ctrl)
    push_gate!(circ, Val{:Z}(), loc)
    @inbounds v1, v2 = (sort!(spiders(circ)))[(end - 1):end]
    add_edge!(circ, v1, v2, EdgeType.HAD)
    add_power!(circ, 1)
    return circ
end

function pushfirst_gate!(circ::ZXCircuit{T, P}, ::Val{:Z}, loc::T, phase::P=zero(P)) where {T, P}
    @inbounds in_id = get_inputs(circ)[loc]
    @inbounds bound_id = neighbors(circ, in_id)[1]
    insert_spider!(circ, in_id, bound_id, SpiderType.Z, phase)
    return circ
end

function pushfirst_gate!(circ::ZXCircuit{T, P}, ::Val{:X}, loc::T, phase::P=zero(P)) where {T, P}
    @inbounds in_id = get_inputs(circ)[loc]
    @inbounds bound_id = neighbors(circ, in_id)[1]
    insert_spider!(circ, in_id, bound_id, SpiderType.X, phase)
    return circ
end

function pushfirst_gate!(circ::ZXCircuit{T, P}, ::Val{:H}, loc::T) where {T, P}
    @inbounds in_id = get_inputs(circ)[loc]
    @inbounds bound_id = neighbors(circ, in_id)[1]
    insert_spider!(circ, in_id, bound_id, SpiderType.H)
    return circ
end

function pushfirst_gate!(circ::ZXCircuit{T, P}, ::Val{:SWAP}, locs::Vector{T}) where {T, P}
    q1, q2 = locs
    pushfirst_gate!(circ, Val{:Z}(), q1)
    pushfirst_gate!(circ, Val{:Z}(), q2)
    pushfirst_gate!(circ, Val{:Z}(), q1)
    pushfirst_gate!(circ, Val{:Z}(), q2)
    v1, v2, bound_id1, bound_id2 = (sort!(spiders(circ)))[1:4]
    rem_edge!(circ, v1, bound_id1)
    rem_edge!(circ, v2, bound_id2)
    add_edge!(circ, v1, bound_id2)
    add_edge!(circ, v2, bound_id1)
    return circ
end

function pushfirst_gate!(circ::ZXCircuit{T, P}, ::Val{:CNOT}, loc::T, ctrl::T) where {T, P}
    pushfirst_gate!(circ, Val{:X}(), loc)
    pushfirst_gate!(circ, Val{:Z}(), ctrl)
    @inbounds v1, v2 = (sort!(spiders(circ)))[1:2]
    add_edge!(circ, v1, v2)
    add_power!(circ, 1)
    return circ
end

function pushfirst_gate!(circ::ZXCircuit{T, P}, ::Val{:CZ}, loc::T, ctrl::T) where {T, P}
    pushfirst_gate!(circ, Val{:Z}(), loc)
    pushfirst_gate!(circ, Val{:Z}(), ctrl)
    @inbounds v1, v2 = (sort!(spiders(circ)))[1:2]
    add_edge!(circ, v1, v2)
    insert_spider!(circ, v1, v2, SpiderType.H)
    add_power!(circ, 1)
    return circ
end
