# Circuit Interface Implementation for ZXCircuit

nqubits(circ::ZXCircuit) = circ.layout.nbits
get_inputs(circ::ZXCircuit) = circ.inputs
get_outputs(circ::ZXCircuit) = circ.outputs

# Gate operations for ZXCircuit
# These operate on the underlying ZXGraph

function _push_single_qubit_gate!(circ::ZXCircuit{T, P}, loc::T;
        stype::SpiderType.SType, phase=zero(P)) where {T, P}
    @inbounds out_id = get_outputs(circ)[loc]
    @assert spider_type(circ, out_id) === SpiderType.Out "Output spider at location $loc is not of type Out."
    @inbounds bound_id = neighbors(circ, out_id)[1]
    et = edge_type(circ, bound_id, out_id)
    v = insert_spider!(circ, bound_id, out_id, stype, phase)
    set_edge_type!(circ, v, bound_id, et)
    set_edge_type!(circ, v, out_id, EdgeType.SIM)
    return v
end

function _push_first_single_qubit_gate!(circ::ZXCircuit{T, P}, loc::T;
        stype::SpiderType.SType, phase=zero(P)) where {T, P}
    @inbounds in_id = get_inputs(circ)[loc]
    @assert spider_type(circ, in_id) === SpiderType.In "Input spider at location $loc is not of type In."
    @inbounds bound_id = neighbors(circ, in_id)[1]
    et = edge_type(circ, in_id, bound_id)
    v = insert_spider!(circ, in_id, bound_id, stype, phase)
    set_edge_type!(circ, bound_id, v, et)
    set_edge_type!(circ, v, in_id, EdgeType.SIM)
    return v
end

function push_gate!(circ::ZXCircuit{T, P}, ::Val{:Z}, loc::T, phase=zero(P); autoconvert::Bool=true) where {T, P}
    rphase = autoconvert ? safe_convert(P, phase) : phase
    _push_single_qubit_gate!(circ, loc; stype=SpiderType.Z, phase=rphase)
    return circ
end

function push_gate!(circ::ZXCircuit{T, P}, ::Val{:X}, loc::T, phase=zero(P); autoconvert::Bool=true) where {T, P}
    rphase = autoconvert ? safe_convert(P, phase) : phase
    _push_single_qubit_gate!(circ, loc; stype=SpiderType.X, phase=rphase)
    return circ
end

function push_gate!(circ::ZXCircuit{T, P}, ::Val{:H}, loc::T) where {T, P}
    _push_single_qubit_gate!(circ, loc; stype=SpiderType.H)
    return circ
end

function push_gate!(circ::ZXCircuit{T, P}, ::Val{:SWAP}, locs::Vector{T}) where {T, P}
    q1, q2 = locs
    v1 = _push_single_qubit_gate!(circ, q1; stype=SpiderType.Z)
    v2 = _push_single_qubit_gate!(circ, q2; stype=SpiderType.Z)
    bound_id1 = _push_single_qubit_gate!(circ, q1; stype=SpiderType.Z)
    bound_id2 = _push_single_qubit_gate!(circ, q2; stype=SpiderType.Z)
    rem_edge!(circ, v1, bound_id1)
    rem_edge!(circ, v2, bound_id2)
    add_edge!(circ, v1, bound_id2, EdgeType.SIM)
    add_edge!(circ, v2, bound_id1, EdgeType.SIM)
    return circ
end

function push_gate!(circ::ZXCircuit{T, P}, ::Val{:CNOT}, loc::T, ctrl::T) where {T, P}
    v1 = _push_single_qubit_gate!(circ, loc; stype=SpiderType.X)
    v2 = _push_single_qubit_gate!(circ, ctrl; stype=SpiderType.Z)
    add_edge!(circ, v1, v2, EdgeType.SIM)
    add_power!(circ, 1)
    return circ
end

function push_gate!(circ::ZXCircuit{T, P}, ::Val{:CZ}, loc::T, ctrl::T) where {T, P}
    v1 = _push_single_qubit_gate!(circ, loc; stype=SpiderType.Z)
    v2 = _push_single_qubit_gate!(circ, ctrl; stype=SpiderType.Z)
    add_edge!(circ, v1, v2, EdgeType.HAD)
    add_power!(circ, 1)
    return circ
end

function pushfirst_gate!(
        circ::ZXCircuit{T, P}, ::Val{:Z}, loc::T, phase::P=zero(P); autoconvert::Bool=true) where {T, P}
    rphase = autoconvert ? safe_convert(P, phase) : phase
    _push_first_single_qubit_gate!(circ, loc; stype=SpiderType.Z, phase=rphase)
    return circ
end

function pushfirst_gate!(
        circ::ZXCircuit{T, P}, ::Val{:X}, loc::T, phase::P=zero(P); autoconvert::Bool=true) where {T, P}
    rphase = autoconvert ? safe_convert(P, phase) : phase
    _push_first_single_qubit_gate!(circ, loc; stype=SpiderType.X, phase=rphase)
    return circ
end
function pushfirst_gate!(circ::ZXCircuit{T, P}, ::Val{:H}, loc::T) where {T, P}
    _push_first_single_qubit_gate!(circ, loc; stype=SpiderType.H)
    return circ
end

function pushfirst_gate!(circ::ZXCircuit{T, P}, ::Val{:SWAP}, locs::Vector{T}) where {T, P}
    q1, q2 = locs
    v1 = _push_first_single_qubit_gate!(circ, q1; stype=SpiderType.Z)
    v2 = _push_first_single_qubit_gate!(circ, q2; stype=SpiderType.Z)
    bound_id1 = _push_first_single_qubit_gate!(circ, q1; stype=SpiderType.Z)
    bound_id2 = _push_first_single_qubit_gate!(circ, q2; stype=SpiderType.Z)
    rem_edge!(circ, v1, bound_id1)
    rem_edge!(circ, v2, bound_id2)
    add_edge!(circ, v1, bound_id2, EdgeType.SIM)
    add_edge!(circ, v2, bound_id1, EdgeType.SIM)
    return circ
end

function pushfirst_gate!(circ::ZXCircuit{T, P}, ::Val{:CNOT}, loc::T, ctrl::T) where {T, P}
    v1 = _push_first_single_qubit_gate!(circ, loc; stype=SpiderType.X)
    v2 = _push_first_single_qubit_gate!(circ, ctrl; stype=SpiderType.Z)
    add_edge!(circ, v1, v2, EdgeType.SIM)
    add_power!(circ, 1)
    return circ
end

function pushfirst_gate!(circ::ZXCircuit{T, P}, ::Val{:CZ}, loc::T, ctrl::T) where {T, P}
    v1 = _push_first_single_qubit_gate!(circ, loc; stype=SpiderType.Z)
    v2 = _push_first_single_qubit_gate!(circ, ctrl; stype=SpiderType.Z)
    add_edge!(circ, v1, v2, EdgeType.HAD)
    add_power!(circ, 1)
    return circ
end
