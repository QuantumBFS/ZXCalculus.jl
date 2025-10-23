abstract type AbstractPhase end

Base.zero(p::AbstractPhase) = throw(MethodError(Base.zero, p))
Base.zero(p::Type{<:AbstractPhase}) = throw(MethodError(Base.zero, typeof(p)))
Base.one(p::AbstractPhase) = throw(MethodError(Base.one, p))
Base.one(p::Type{<:AbstractPhase}) = throw(MethodError(Base.one, typeof(p)))

is_zero_phase(p::AbstractPhase)::Bool = throw(MethodError(is_zero_phase, p))
is_one_phase(p::AbstractPhase)::Bool = throw(MethodError(is_one_phase, p))
is_pauli_phase(p::AbstractPhase)::Bool = is_zero_phase(p) || is_one_phase(p)
is_clifford_phase(p::AbstractPhase)::Bool = throw(MethodError(is_clifford_phase, p))
function round_phase(p::P)::P where {P <: AbstractPhase}
    throw(MethodError(round_phase, p))
end

"""
    Phase

The type supports manipulating phases as expressions.
`Phase(x)` represents the number `x⋅π`.
"""
struct Phase <: AbstractPhase
    ex::Any
    type::Type
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

Base.convert(::Type{Phase}, p) = Phase(p)
Base.convert(::Type{Phase}, p::Phase) = p

Base.zero(::Phase) = Phase(0//1)
Base.zero(::Type{Phase}) = Phase(0//1)
Base.one(::Phase) = Phase(1//1)
Base.one(::Type{Phase}) = Phase(1//1)

is_zero_phase(p::Phase) = (p.ex isa Number) && iszero(rem(p.ex, 2, RoundDown))
is_one_phase(p::Phase) = (p.ex isa Number) && isone(rem(p.ex, 2, RoundDown))
is_pauli_phase(p::Phase) = is_zero_phase(p) || is_one_phase(p) || (p.type <: Integer)
is_clifford_phase(p::Phase) = (p.ex isa Number) && (rem(p.ex, 1//2, RoundDown) == 0)
function round_phase(p::Phase)
    if p.ex isa Number
        return Phase(rem(p.ex, 2, RoundDown))
    end
    return p
end

unwrap_phase(p::Phase) = p.ex * π
unwrap_phase(p::Number) = p
