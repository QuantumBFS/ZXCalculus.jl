import Base: +, -, *, ==, isless, rem, convert, zero, one, iseven
import Base: show

"""
    Phase
The type supports manipulating phases as expressions.
"""
struct Phase
    ex
    val
end

Phase(p::Real) = Phase(nothing, p)
Phase(p::Expr) = Phase(p, 0//1)
Phase(p::Symbol) = Phase(p, 0//1)
Phase(p::Phase) = p

function show(io::IO, p::Phase)
    if isnothing(p.ex)
        print(io, p.val)
    else
        print(io, p.ex, " + ", p.val)
    end
end

function +(p1::Phase, p2::Phase)
    if isnothing(p1.ex)
        return Phase(p2.ex, p1.val + p2.val)
    elseif isnothing(p2.ex)
        return Phase(p1.ex, p1.val + p2.val)
    else
        return Phase(:($(p1.ex) + $(p2.ex)), p1.val + p2.val)
    end
end
+(p1::Phase, p2::Real) = Phase(p1.ex, p1.val + p2)
+(p1::Real, p2::Phase) = Phase(p1.val + p2, p2.ex)

function -(p::Phase)
    if isnothing(p.ex)
        return Phase(nothing, -p.val)
    else
        return Phase(:(-$(p.ex)), -p.val)
    end
end
-(p1::Phase, p2::Phase) = p1 + (-p2)
-(p1::Phase, p2) = p1 + (-p2)
-(p1, p2::Phase) = p1 + (-p2)

function *(p1::Phase, p2::Real)
    if isnothing(p1.ex)
        return Phase(p1.val * p2)
    else
        return Phase(:($(p1.ex) * $p2), p1.val * p2)
    end
end
function *(p1::Real, p2::Phase)
    if isnothing(p2.ex)
        return Phase(p2.val * p1)
    else
        return Phase(:($(p2.ex) * $p1), p2.val * p1)
    end
end

==(p1::Phase, p2::Phase) = p1.ex == p2.ex && p1.val == p2.val
==(p1::Phase, p2::Real) = isnothing(p1.ex) && p1.val == p2
==(p1::Real, p2::Phase) = isnothing(p2.ex) && p2.val == p1

isless(p1::Phase, p2::Real) = isnothing(p1.ex) && p1.val < p2
rem(p::Phase, d::Real) = Phase(p.ex, rem(p.val, d))

convert(::Type{Phase}, p) = Phase(p)
convert(::Type{Phase}, p::Phase) = p

zero(::Phase) = Phase(0//1)
zero(::Type{Phase}) = Phase(0//1)
one(::Phase) = Phase(1//1)
one(::Type{Phase}) = Phase(1//1)

iseven(p::Phase) = isnothing(p.ex) && (-1)^p.val > 0

# p1+p2+p1-p1-p1
