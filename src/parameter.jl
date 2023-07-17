"""
    Parameter
The Algebraic Data Type for representing parameter related to spider.
`PiUnit(x)` represents the the phase of a number `exp(im*x*π)`.
`Factor(x)` represents a number `x`.
"""
@adt public Parameter begin

    struct PiUnit
        pu
        pu_type::Type
    end

    struct Factor
        f::Number
        f_type::Type
    end

end

"""
   Parameter
Constructors for `Parameter` type.
"""
function Parameter(::Val{:PiUnit}, pu::T = 0.0) where {T}
    return PiUnit(pu, T)
end

function Parameter(::Val{:Factor}, f::T = 1.0) where {T<:Number}
    return Factor(f, T)
end

function Parameter(p::Parameter)
    @match p begin
        PiUnit(pu, _) => Parameter(Val(:PiUnit), pu)
        Factor(f, _) => Parameter(Val(:Factor), f)
    end
end

Base.copy(p::Parameter) = @match p begin
    PiUnit(pu, _) => Parameter(Val(:PiUnit), pu)
    Factor(f, _) => Parameter(Val(:Factor), f)
end

function Base.show(io::IO, p::Parameter)
    @match p begin
        PiUnit(pu, _) && if pu isa Number
        end => print(io, "$(pu)⋅π")
        PiUnit(pu, pu_type) && if !(pu isa Number)
        end => print(io, "PiUnit(($(pu))::$(pu_type))")
        Factor(f, _) => print(io, "$(f)")
    end
end

function eqeq(p1, p2)
    @match (p1, p2) begin
        (PiUnit(pu1, _), PiUnit(pu2, _)) => pu1 == pu2
        (Factor(f1, _), Factor(f2, _)) => f1 == f2
        (PiUnit(pu1, _), Factor(f2, _)) => exp(im * pu1 * π) == f2
        (Factor(f1, _), PiUnit(pu2, _)) => f1 == exp(im * pu2 * π)
        (PiUnit(_...), _) => eqeq(p1, Parameter(Val(:PiUnit), p2))
        (Factor(f1, _), ::Number) => f1 == p2
        _ => error(
            "Invalid input '$(p1)' of type $(typeof(p1)) and '$(p2)' of type $(typeof(p2)) for ADT: ==",
        )
    end
end

Base.:(==)(p1::Parameter, p2::Parameter) = eqeq(p1, p2)
Base.:(==)(p1::Parameter, p2::Number) = eqeq(p1, p2)
Base.:(==)(p1::Number, p2::Parameter) = eqeq(p2, p1)

# following the same convention in Phase.jl implementation
# comparison have inconsistent, we are comparing phases to numbers
# if cause trouble, will change
#
function Base.contains(p::Parameter, θ::Symbol)
    @match p begin
        PiUnit(pu, pt) && if !(pt <: Number)
        end => Base.contains(repr(pu), string(θ))
        _ => false
    end
end

Base.isless(p1::Parameter, p2::Number) = @match p1 begin
    PiUnit(_...) => p1.pu isa Number && p1.pu < p2
    _ => p1.f < p2
end

Base.convert(::Type{Parameter}, p::T) where {T} = @match p begin
    ("PiUnit", pu) => Parameter(Val(:PiUnit), pu)
    ("Factor", f) => Parameter(Val(:Factor), f)
    PiUnit(_...) => p
    Factor(_...) => p
    _ => error("Invalid input '$(p)' of type $(typeof(p)) for ADT: Parameter")
end

Base.zero(p::Parameter) = @match p begin
    PiUnit(_...) => Parameter(Val(:PiUnit), zero(Float64))
    Factor(_...) => Parameter(Val(:Factor), one(ComplexF64))
end

Base.one(p::Parameter) = @match p begin
    PiUnit(_...) => Parameter(Val(:PiUnit), 1.0)
    Factor(_...) => Parameter(Val(:Factor), exp(im * 1.0 * π))
end

Base.zero(::Type{Parameter}) = Parameter(Val(:PiUnit), 0.0)

Base.one(::Type{Parameter}) = Parameter(Val(:PiUnit), 1.0)

Base.iseven(p::Parameter) = @match p begin
    PiUnit(_...) => (p.pu isa Number) && (-1)^p.pu > 0
    Factor(_...) => p.f ≈ 1.0 # making meaning the same, upto machine precision
end

function add_param(p1, p2)
    @match (p1, p2) begin
        (PiUnit(pu1, _), PiUnit(pu2, _)) && if pu1 isa Number && pu2 isa Number
        end => Parameter(Val(:PiUnit), pu1 + pu2)
        (PiUnit(pu1, pu1_t), PiUnit(pu2, pu2_t)) &&
            if !(pu1 isa Number) || !(pu2 isa Number)
            end => PiUnit(Expr(:call, :+, pu1, pu2), Base.promote_op(+, pu1_t, pu2_t))
        (Factor(f1, _), Factor(f2, _)) => Parameter(Val(:Factor), f1 + f2)
        (PiUnit(pu1, _), Factor(f2, _)) => Parameter(Val(:Factor), exp(im * pu1 * π) * f2)
        (Factor(f1, _), PiUnit(pu2, _)) => Parameter(Val(:Factor), exp(im * pu2 * π) * f1)
        (PiUnit(_...), _) => Parameter(Val(:PiUnit), p1.pu + p2)
        (Factor(_...), ::Number) => Parameter(Val(:Factor), p1.f + p2)
        _ => error(
            "Invalid input '$(p1)' of type $(typeof(p1)) and '$(p2)' of type $(typeof(p2)) for ADT: +",
        )


    end
end

Base.:(+)(p1::Parameter, p2::Parameter) = add_param(p1, p2)
Base.:(+)(p1::Parameter, p2::Number) = add_param(p1, p2)
Base.:(+)(p1::Number, p2::Parameter) = add_param(p2, p1)

function subt_param(p1, p2)
    @match (p1, p2) begin
        (PiUnit(pu1, pu_t1), PiUnit(pu2, pu_t2)) && if pu1 isa Number && pu2 isa Number
        end => Parameter(Val(:PiUnit), pu1 - pu2)
        (PiUnit(pu1, pu_t1), PiUnit(pu2, pu_t2)) &&
            if !(pu1 isa Number) || !(pu2 isa Number)
            end => PiUnit(Expr(:call, :-, pu1, pu2), Base.promote_op(-, pu_t1, pu_t2))
        (Factor(f1, _), Factor(f2, _)) => Parameter(Val(:Factor), f1 - f2)
        (PiUnit(_...), Factor(_...)) => Parameter(Val(:Factor), exp(im * p1.pu * π) - p2.f)
        (Factor(_...), PiUnit(_...)) => Parameter(Val(:Factor), p1.f - exp(im * p2.pu * π))
        (_, PiUnit(_...)) => Parameter(Val(:PiUnit), p1 - p2.pu)
        (::Number, Factor(_...)) => Parameter(Val(:Factor), p1 - p2.f)
        _ => error(
            "Invalid input '$(p1)' of type $(typeof(p1)) and '$(p2)' of type $(typeof(p2)) for ADT: -",
        )

    end
end

Base.:(-)(p1::Parameter, p2::Parameter) = subt_param(p1, p2)
Base.:(-)(p1::Number, p2::Parameter) = subt_param(p1, p2)
Base.:(-)(p1::Parameter, p2::Number) = add_param(p1, -p2)

function Base.rem(p::Parameter, d::Number)
    @match p begin
        PiUnit(pu, pu_t) && if pu isa Number
        end => Parameter(Val(:PiUnit), rem(pu, d))
        PiUnit(pu, pu_t) && if !(pu isa Number)
        end => p
        Factor(f, _) => Parameter(Val(:Factor), rem(f, d))
        _ => error(
            "Invalid input '$(p)' of type $(typeof(p)) and '$(d)' of type $(typeof(d)) for ADT: rem",
        )
    end
end

function Base.inv(p::Parameter)
    @match p begin
        PiUnit(pu, pu_t) && if pu isa Number
        end => Parameter(Val(:PiUnit), -pu)
        PiUnit(pu, pu_t) && if !(pu isa Number)
        end => Parameter(Val(:PiUnit), Expr(:call, :-, pu))
        Factor(f, _) => Parameter(Val(:Factor), inv(f))
        _ => error("Invalid input '$(p)' of type $(typeof(p)) for ADT: inv")
    end
end
