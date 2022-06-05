"""
    PiUnit
The type supports manipulating phases as expressions.
`PiUnit(x)` represents the number `x⋅π`.
"""
struct PiUnit
    ex
    type
end

PiUnit(p::T) where {T} = PiUnit(p, T)
PiUnit(p::PiUnit) = p

to_pi_unit(p) = PiUnit(p) / one(PiUnit)
to_pi_unit(p::PiUnit) = p

function Base.show(io::IO, p::PiUnit)
    if p.ex isa Number
        print(io, "$(p.ex)⋅π")
    else
        print(io, "PiUnit(($(p.ex))::$(p.type))")
    end
end

function Base.:(+)(p1::PiUnit, p2::PiUnit)
    T1 = p1.type
    T2 = p2.type
    if p1.ex isa Number && p2.ex isa Number
        return PiUnit(p1.ex + p2.ex)
    end

    T = Base.promote_op(+, T1, T2)
    return PiUnit(Expr(:call, :+, p1.ex, p2.ex), T)
end
Base.:(+)(p1::PiUnit, p2::Number) = p1 + to_pi_unit(p2)
Base.:(+)(p1::Number, p2::PiUnit) = to_pi_unit(p1) + p2

function Base.:(-)(p1::PiUnit, p2::PiUnit)
    T1 = p1.type
    T2 = p2.type
    if p1.ex isa Number && p2.ex isa Number
        return PiUnit(p1.ex - p2.ex)
    end

    T = Base.promote_op(-, T1, T2)
    return PiUnit(Expr(:call, :-, p1.ex, p2.ex), T)
end
Base.:(-)(p1::PiUnit, p2::Number) = p1 - to_pi_unit(p2)
Base.:(-)(p1::Number, p2::PiUnit) = to_pi_unit(p1) - p2

function Base.:(*)(p1::PiUnit, p2::PiUnit)
    T1 = p1.type
    T2 = p2.type
    if p1.ex isa Number && p2.ex isa Number
        return PiUnit(p1.ex * p2.ex * π)
    end

    T = Base.promote_op(*, Base.promote_op(*, T1, T2), typeof(π))
    return PiUnit(Expr(:call, :*, p1.ex, p2.ex, π), T)
end
Base.:(*)(p1::PiUnit, p2::Number) = p1 * to_pi_unit(p2)
Base.:(*)(p1::Number, p2::PiUnit) = to_pi_unit(p1) * p2

function Base.:(/)(p1::PiUnit, p2::PiUnit)
    T1 = p1.type
    T2 = p2.type
    if p1.ex isa Number && p2.ex isa Number
        return PiUnit((p1.ex / p2.ex) / π)
    end

    T = Base.promote_op(/, Base.promote_op(/, T1, T2), typeof(π))
    return PiUnit(Expr(:call, :/, Expr(:call, :/, p1.ex, p2.ex), π), T)
end
Base.:(/)(p1::PiUnit, p2::Number) = p1 / to_pi_unit(p2)
Base.:(/)(p1::Number, p2::PiUnit) = to_pi_unit(p1) / p2

function Base.:(-)(p::PiUnit)
    T0 = p.type
    if p.ex isa Number
        return PiUnit(-p.ex)
    end

    T = Base.promote_op(-, T0)
    return PiUnit(Expr(:call, :-, p.ex), T)
end

Base.:(==)(p1::PiUnit, p2::PiUnit) = p1.ex == p2.ex
Base.:(==)(p1::PiUnit, p2::Number) = (p1 == to_pi_unit(p2/π))
Base.:(==)(p1::Number, p2::PiUnit) = (to_pi_unit(p1/π) == p2)
Base.:(==)(p::PiUnit, ::Irrational{:π}) = (p.ex == 1)
Base.:(==)(::Irrational{:π}, p::PiUnit) = (p.ex == 1)

Base.isless(p1::PiUnit, p2::Number) = (p1.ex isa Number) && p1.ex < p2*π
function Base.rem(p1::PiUnit, p2::PiUnit)
    if p1.ex isa Number && p2.ex isa Number
        return PiUnit(rem(p1.ex, p2.ex, RoundToZero))
    end
    T = Base.promote_op(rem, p1.type, p2.type)
    return PiUnit(Expr(:call, :rem, p1.ex, p2.ex), T)
end
function Base.rem2pi(p::PiUnit, r::RoundingMode)
    if p.ex isa Number
        return PiUnit(rem(p.ex, 2, r))
    end
    return p
end

Base.convert(::Type{PiUnit}, p::Number) = PiUnit(p)
Base.convert(::Type{PiUnit}, p::PiUnit) = p

Base.zero(::PiUnit) = PiUnit(0//1)
Base.zero(::Type{PiUnit}) = PiUnit(0//1)
Base.one(::PiUnit) = PiUnit(1//1)
Base.one(::Type{PiUnit}) = PiUnit(1//1)

Base.iseven(p::PiUnit) = (p.ex isa Number) && (-1)^p.ex > 0