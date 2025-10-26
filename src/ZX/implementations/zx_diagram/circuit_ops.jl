# Circuit Interface Implementation for ZXDiagram

"""
    nqubits(zxd)

Returns the qubit number of a ZX-diagram.
"""
nqubits(zxd::ZXDiagram) = zxd.layout.nbits

"""
    get_inputs(zxd)

Returns a vector of input ids.
"""
get_inputs(zxd::ZXDiagram) = zxd.inputs

"""
    get_outputs(zxd)

Returns a vector of output ids.
"""
get_outputs(zxd::ZXDiagram) = zxd.outputs

"""
    push_gate!(zxd, ::Val{M}, locs...[, phase]; autoconvert=true)

Push an `M` gate to the end of qubit `loc` where `M` can be `:Z`, `:X`, `:H`, `:SWAP`, `:CNOT` and `:CZ`.
If `M` is `:Z` or `:X`, `phase` will be available and it will push a
rotation `M` gate with angle `phase * π`.
If `autoconvert` is `false`, the input `phase` should be a rational numbers.
"""
function push_gate!(zxd::ZXDiagram{T, P}, ::Val{:Z}, loc::T, phase=zero(P); autoconvert::Bool=true) where {T, P}
    @inbounds out_id = get_outputs(zxd)[loc]
    @inbounds bound_id = neighbors(zxd, out_id)[1]
    rphase = autoconvert ? safe_convert(P, phase) : phase
    insert_spider!(zxd, bound_id, out_id, SpiderType.Z, rphase)
    return zxd
end

function push_gate!(zxd::ZXDiagram{T, P}, ::Val{:X}, loc::T, phase=zero(P); autoconvert::Bool=true) where {T, P}
    @inbounds out_id = get_outputs(zxd)[loc]
    @inbounds bound_id = neighbors(zxd, out_id)[1]
    rphase = autoconvert ? safe_convert(P, phase) : phase
    insert_spider!(zxd, bound_id, out_id, SpiderType.X, rphase)
    return zxd
end

function push_gate!(zxd::ZXDiagram{T, P}, ::Val{:H}, loc::T) where {T, P}
    @inbounds out_id = get_outputs(zxd)[loc]
    @inbounds bound_id = neighbors(zxd, out_id)[1]
    insert_spider!(zxd, bound_id, out_id, SpiderType.H)
    return zxd
end

function push_gate!(zxd::ZXDiagram{T, P}, ::Val{:SWAP}, locs::Vector{T}) where {T, P}
    q1, q2 = locs
    push_gate!(zxd, Val{:Z}(), q1)
    push_gate!(zxd, Val{:Z}(), q2)
    push_gate!(zxd, Val{:Z}(), q1)
    push_gate!(zxd, Val{:Z}(), q2)
    v1, v2, bound_id1, bound_id2 = (sort!(spiders(zxd)))[(end - 3):end]
    rem_edge!(zxd, v1, bound_id1)
    rem_edge!(zxd, v2, bound_id2)
    add_edge!(zxd, v1, bound_id2)
    add_edge!(zxd, v2, bound_id1)
    return zxd
end

function push_gate!(zxd::ZXDiagram{T, P}, ::Val{:CNOT}, loc::T, ctrl::T) where {T, P}
    push_gate!(zxd, Val{:Z}(), ctrl)
    push_gate!(zxd, Val{:X}(), loc)
    @inbounds v1, v2 = (sort!(spiders(zxd)))[(end - 1):end]
    add_edge!(zxd, v1, v2)
    add_power!(zxd, 1)
    return zxd
end

function push_gate!(zxd::ZXDiagram{T, P}, ::Val{:CZ}, loc::T, ctrl::T) where {T, P}
    push_gate!(zxd, Val{:Z}(), ctrl)
    push_gate!(zxd, Val{:Z}(), loc)
    @inbounds v1, v2 = (sort!(spiders(zxd)))[(end - 1):end]
    add_edge!(zxd, v1, v2)
    insert_spider!(zxd, v1, v2, SpiderType.H)
    add_power!(zxd, 1)
    return zxd
end

"""
    pushfirst_gate!(zxd, ::Val{M}, loc[, phase])

Push an `M` gate to the beginning of qubit `loc` where `M` can be `:Z`, `:X`, `:H`, `:SWAP`, `:CNOT` and `:CZ`.
If `M` is `:Z` or `:X`, `phase` will be available and it will push a
rotation `M` gate with angle `phase * π`.
"""
function pushfirst_gate!(zxd::ZXDiagram{T, P}, ::Val{:Z}, loc::T, phase::P=zero(P)) where {T, P}
    @inbounds in_id = get_inputs(zxd)[loc]
    @inbounds bound_id = neighbors(zxd, in_id)[1]
    insert_spider!(zxd, in_id, bound_id, SpiderType.Z, phase)
    return zxd
end

function pushfirst_gate!(zxd::ZXDiagram{T, P}, ::Val{:X}, loc::T, phase::P=zero(P)) where {T, P}
    @inbounds in_id = get_inputs(zxd)[loc]
    @inbounds bound_id = neighbors(zxd, in_id)[1]
    insert_spider!(zxd, in_id, bound_id, SpiderType.X, phase)
    return zxd
end

function pushfirst_gate!(zxd::ZXDiagram{T, P}, ::Val{:H}, loc::T) where {T, P}
    @inbounds in_id = get_inputs(zxd)[loc]
    @inbounds bound_id = neighbors(zxd, in_id)[1]
    insert_spider!(zxd, in_id, bound_id, SpiderType.H)
    return zxd
end

function pushfirst_gate!(zxd::ZXDiagram{T, P}, ::Val{:SWAP}, locs::Vector{T}) where {T, P}
    q1, q2 = locs
    pushfirst_gate!(zxd, Val{:Z}(), q1)
    pushfirst_gate!(zxd, Val{:Z}(), q2)
    pushfirst_gate!(zxd, Val{:Z}(), q1)
    pushfirst_gate!(zxd, Val{:Z}(), q2)
    @inbounds v1, v2, bound_id1, bound_id2 = (sort!(spiders(zxd)))[(end - 3):end]
    rem_edge!(zxd, v1, bound_id1)
    rem_edge!(zxd, v2, bound_id2)
    add_edge!(zxd, v1, bound_id2)
    add_edge!(zxd, v2, bound_id1)
    return zxd
end

function pushfirst_gate!(zxd::ZXDiagram{T, P}, ::Val{:CNOT}, loc::T, ctrl::T) where {T, P}
    pushfirst_gate!(zxd, Val{:Z}(), ctrl)
    pushfirst_gate!(zxd, Val{:X}(), loc)
    @inbounds v1, v2 = (sort!(spiders(zxd)))[(end - 1):end]
    add_edge!(zxd, v1, v2)
    add_power!(zxd, 1)
    return zxd
end

function pushfirst_gate!(zxd::ZXDiagram{T, P}, ::Val{:CZ}, loc::T, ctrl::T) where {T, P}
    pushfirst_gate!(zxd, Val{:Z}(), ctrl)
    pushfirst_gate!(zxd, Val{:Z}(), loc)
    @inbounds v1, v2 = (sort!(spiders(zxd)))[(end - 1):end]
    add_edge!(zxd, v1, v2)
    insert_spider!(zxd, v1, v2, SpiderType.H)
    add_power!(zxd, 1)
    return zxd
end

function add_ancilla!(zxd::ZXDiagram, in_stype::SpiderType.SType, out_stype::SpiderType.SType;
        register_as_input::Bool=false, register_as_output::Bool=false)
    v_in = add_spider!(zxd, in_stype)
    v_out = add_spider!(zxd, out_stype)
    (register_as_input || in_stype === SpiderType.In) && push!(zxd.inputs, v_in)
    (register_as_output || out_stype === SpiderType.Out) && push!(zxd.outputs, v_out)
    add_edge!(zxd, v_in, v_out)
    return zxd
end
