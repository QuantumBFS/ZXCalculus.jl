using Test
using ZXCalculus.ZX: AbstractZXDiagram

function check_equivalence(g1::AbstractZXDiagram, g2::AbstractZXDiagram;
        ignore_amplitude::Bool=false, ignore_phase::Bool=false, atol::Float64=1e-9)
    m1 = Matrix(g1)
    m2 = Matrix(g2)
    if ignore_amplitude || ignore_phase
        id = findfirst(x -> abs(x) > atol, m1)
        abs(m2[id]) > atol || return false
        z = m1[id] / m2[id]
        phi = angle(z)
        amplitude = abs(z)
        ignore_phase || isapprox(phi, 0.0; atol=atol) || return false
        ignore_amplitude || isapprox(amplitude, 1.0; atol=atol) || return false
        m2 .*= z
    end
    return size(m1) == size(m2) && all(isapprox.(m1, m2, atol=atol))
end
