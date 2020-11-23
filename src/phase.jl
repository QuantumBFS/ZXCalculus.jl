import Base: +, -, *, /, ==, isless, rem, convert, zero, one, iseven
import Base: show

"""
    Phase
The type supports manipulating phases as expressions.
"""
struct Phase
    ex
    type
end

Phase(p::T) where {T} = Phase(p, T)

Phase(p::Phase) = p

function show(io::IO, p::Phase)
    if p.ex isa Number
        print(io, p.ex)
    else
        print(io, "($(p.ex))")
    end
end

function +(p1::Phase, p2::Phase)
    T1 = p1.type
    T2 = p2.type
    if p1.ex isa Number && p2.ex isa Number
        return Phase(p1.ex + p2.ex)
    end

    T = Base.promote_op(+, T1, T2)
    return Phase(Expr(:call, :+, p1.ex, p2.ex), T)
end
+(p1::Phase, p2::Number) = p1 + Phase(p2)
+(p1::Number, p2::Phase) = Phase(p1) + p2

function -(p1::Phase, p2::Phase)
    T1 = p1.type
    T2 = p2.type
    if p1.ex isa Number && p2.ex isa Number
        return Phase(p1.ex - p2.ex)
    end

    T = Base.promote_op(-, T1, T2)
    return Phase(Expr(:call, :-, p1.ex, p2.ex), T)
end
-(p1::Phase, p2::Number) = p1 - Phase(p2)
-(p1::Number, p2::Phase) = Phase(p1) - p2

function *(p1::Phase, p2::Phase)
    T1 = p1.type
    T2 = p2.type
    if p1.ex isa Number && p2.ex isa Number
        return Phase(p1.ex * p2.ex)
    end

    T = Base.promote_op(*, T1, T2)
    return Phase(Expr(:call, :*, p1.ex, p2.ex), T)
end
*(p1::Phase, p2::Number) = p1 * Phase(p2)
*(p1::Number, p2::Phase) = Phase(p1) * p2

function /(p1::Phase, p2::Phase)
    T1 = p1.type
    T2 = p2.type
    if p1.ex isa Number && p2.ex isa Number
        return Phase(p1.ex / p2.ex)
    end

    T = Base.promote_op(/, T1, T2)
    return Phase(Expr(:call, :/, p1.ex, p2.ex), T)
end
/(p1::Phase, p2::Number) = p1 / Phase(p2)
/(p1::Number, p2::Phase) = Phase(p1) / p2


function -(p::Phase)
    T0 = p.type
    if p.ex isa Number
        return Phase(-p.ex)
    end

    T = Base.promote_op(-, T0)
    return Phase(Expr(:call, :-, p.ex), T)
end

==(p1::Phase, p2::Phase) = p1.ex == p2.ex
==(p1::Phase, p2::Number) = (p1 == Phase(p2))
==(p1::Number, p2::Phase) = (Phase(p1) == p2)

isless(p1::Phase, p2::Number) = (p1.ex isa Number) && p1.ex < p2
function rem(p::Phase, d::Number)
    if p.ex isa Number
        return Phase(rem(p.ex, d))
    end
    return p
end

convert(::Type{Phase}, p) = Phase(p)
convert(::Type{Phase}, p::Phase) = p

zero(::Phase) = Phase(0//1)
zero(::Type{Phase}) = Phase(0//1)
one(::Phase) = Phase(1//1)
one(::Type{Phase}) = Phase(1//1)

iseven(p::Phase) = (p.ex isa Number) && (-1)^p.ex > 0

# p1+p2+p1-p1-p1
