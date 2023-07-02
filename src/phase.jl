"""
    Phase
The type supports manipulating phases as expressions.
`Phase(x)` represents the number `x⋅π`.
"""
struct Phase
    ex
    type
end

Phase(p::T) where {T} = Phase(p, T)

Phase(p::Phase) = p

function Base.show(io::IO, p::Phase)
    if p.ex isa Number
        print(io, "$(p.ex)⋅π")
    else
        print(io, "Phase(($(p.ex))::$(p.type))")
    end
end

function Base.:(+)(p1::Phase, p2::Phase)
    T1 = p1.type
    T2 = p2.type
    if p1.ex isa Number && p2.ex isa Number
        return Phase(p1.ex + p2.ex)
    end

    T = Base.promote_op(+, T1, T2)
    return Phase(Expr(:call, :+, p1.ex, p2.ex), T)
end
Base.:(+)(p1::Phase, p2::Number) = p1 + Phase(p2)
Base.:(+)(p1::Number, p2::Phase) = Phase(p1) + p2

function Base.:(-)(p1::Phase, p2::Phase)
    T1 = p1.type
    T2 = p2.type
    if p1.ex isa Number && p2.ex isa Number
        return Phase(p1.ex - p2.ex)
    end

    T = Base.promote_op(-, T1, T2)
    return Phase(Expr(:call, :-, p1.ex, p2.ex), T)
end
Base.:(-)(p1::Phase, p2::Number) = p1 - Phase(p2)
Base.:(-)(p1::Number, p2::Phase) = Phase(p1) - p2

function Base.:(*)(p1::Phase, p2::Phase)
    T1 = p1.type
    T2 = p2.type
    if p1.ex isa Number && p2.ex isa Number
        return Phase(p1.ex * p2.ex)
    end

    T = Base.promote_op(*, T1, T2)
    return Phase(Expr(:call, :*, p1.ex, p2.ex), T)
end
Base.:(*)(p1::Phase, p2::Number) = p1 * Phase(p2)
Base.:(*)(p1::Number, p2::Phase) = Phase(p1) * p2

function Base.:(/)(p1::Phase, p2::Phase)
    T1 = p1.type
    T2 = p2.type
    if p1.ex isa Number && p2.ex isa Number
        return Phase(p1.ex / p2.ex)
    end

    T = Base.promote_op(/, T1, T2)
    return Phase(Expr(:call, :/, p1.ex, p2.ex), T)
end
Base.:(/)(p1::Phase, p2::Number) = p1 / Phase(p2)
Base.:(/)(p1::Number, p2::Phase) = Phase(p1) / p2


function Base.:(-)(p::Phase)
    T0 = p.type
    if p.ex isa Number
        return Phase(-p.ex)
    end

    T = Base.promote_op(-, T0)
    return Phase(Expr(:call, :-, p.ex), T)
end

Base.:(==)(p1::Phase, p2::Phase) = p1.ex == p2.ex
Base.:(==)(p1::Phase, p2::Number) = (p1 == Phase(p2))
Base.:(==)(p1::Number, p2::Phase) = (Phase(p1) == p2)

Base.isless(p1::Phase, p2::Number) = (p1.ex isa Number) && p1.ex < p2
function Base.rem(p::Phase, d::Number)
    if p.ex isa Number
        return Phase(rem(p.ex, d))
    end
    return p
end

Base.convert(::Type{Phase}, p) = Phase(p)
Base.convert(::Type{Phase}, p::Phase) = p

Base.zero(::Phase) = Phase(0//1)
Base.zero(::Type{Phase}) = Phase(0//1)
Base.one(::Phase) = Phase(1//1)
Base.one(::Type{Phase}) = Phase(1//1)

Base.iseven(p::Phase) = (p.ex isa Number) && (-1)^p.ex > 0

unwrap_phase(p::Phase) = p.ex * π
unwrap_phase(p::Number) = p
