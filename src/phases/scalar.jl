"""
    Scalar

A struct for recording the scalars when we rewrite ZX-diagrams.
"""
mutable struct Scalar{P}
    power_of_sqrt_2::Int
    phase::P
    function Scalar{P}(n = 0, p = zero(P)) where {P}
        return new{P}(Int(n), P(p))
    end
end

function Scalar(n = 0, p = zero(PiUnit))
    return Scalar{PiUnit}(n, PiUnit(p))
end

function add_power!(s::Scalar, n)
    s.power_of_sqrt_2 += Int(n)
    return s
end

function add_phase!(s::Scalar{P}, p) where {P}
    s.phase += P(p)
    return s
end

Base.:(*)(s1::Scalar, s2::Scalar) = Scalar(s1.power_of_sqrt_2 + s2.power_of_sqrt_2, s1.phase + s2.phase)
Base.:(==)(s1::Scalar, s2::Scalar) = (s1.power_of_sqrt_2 == s2.power_of_sqrt_2 && s1.phase == s2.phase)
Base.copy(s::Scalar{P}) where {P} = Scalar{P}(s.power_of_sqrt_2, s.phase)