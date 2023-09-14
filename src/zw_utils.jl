"""
    round_phases!(zwd)

Round phases between [0, 2π).
"""
function round_phases!(zwd::ZWDiagram{T,P}) where {T<:Integer,P}
    st = zwd.st
    for v in keys(st)
        st[v] = @match st[v] begin
            binZ(p) => binZ(_round_phase(p))
            monoZ(p) => monoZ(_round_phase(p))
            _ => st[v]
        end
    end
    return
end
