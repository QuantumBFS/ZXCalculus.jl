# Phase Tracking Utilities for ZXCircuit

function phase_tracker(circ::ZXCircuit{T, P}) where {T, P}
    master_circ = circ
    phase_ids = Dict{T, Tuple{T, Int}}(
        (v, (v, 1)) for v in spiders(circ.zx_graph) if spider_type(circ.zx_graph, v) in (SpiderType.Z, SpiderType.X)
    )
    return ZXCircuit{T, P}(copy(circ.zx_graph),
        copy(circ.inputs), copy(circ.outputs), copy(circ.layout),
        phase_ids, master_circ)
end

function flip_phase_tracking_sign!(circ::ZXCircuit, v::Integer)
    if haskey(circ.phase_ids, v)
        id, sign = circ.phase_ids[v]
        circ.phase_ids[v] = (id, -sign)
        return true
    end
    return false
end

function merge_phase_tracking!(circ::ZXCircuit{T, P}, v_from::T, v_to::T) where {T, P}
    if haskey(circ.phase_ids, v_from) && haskey(circ.phase_ids, v_to)
        id_from, sign_from = circ.phase_ids[v_from]
        id_to, sign_to = circ.phase_ids[v_to]
        if !isnothing(circ.master)
            merged_phase = (sign_from * phase(circ.master, id_from) + sign_to * phase(circ.master, id_to)) * sign_to
            set_phase!(circ.master, id_from, zero(P))
            set_phase!(circ.master, id_to, merged_phase)
        end
        return true
    end
    return false
end
