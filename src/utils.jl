"""
    round_phases!(zxd)

Round phases between [0, 2π).
"""
function round_phases!(
    zx::Union{ZXDiagram{T,P},ZXGraph{T,P},ZXWDiagram{T,P}},
) where {T<:Integer,P}
    _round_phase_dict!(zx.ps)
    return
end

function _round_phase_dict!(ps::Dict{T,P}) where {T<:Integer,P}
    for v in keys(ps)
        ps[v] = rem(rem(ps[v], 2) + 2, 2)
    end
    return
end
