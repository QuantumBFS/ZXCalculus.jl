"""
    Parameter
The Algebraic Data Type for representing parameter related to spider.
`PiUnit(x)` represents the the phase of a number `exp(im*x*π)`.
`Factor(x)` represents a number `x`.
"""
@adt public Parameter begin

    struct PiUnit
        pu = 0.0
        pu_type::Type = typeof(pu)
    end

    struct Factor
        f::Number = 1.0
    end

end

"""
   Parameter
Universal constructor for ADT
"""
function Parameter(x, type::String="Factor")
    @match (x, type) begin
        if type == "PiUnit" end => PiUnit(x, typeof(x))
        (f::Number, "Factor") => Factor(f)
        (PiUnit(_...), _) => PiUnit(x.pu, x.pu_type)
        (Factor(_...), _) => Factor(x.f)
        _ => error("Invalid input '$(x)' of type $(typeof(x)) for ADT: $(type)")

    end
end

function Base.show(io::IO, p::Parameter)
    @match p begin
        PiUnit(pu, _) && if pu isa Number
        end => print(io, "$(pu)⋅π")
        PiUnit(pu, pu_type) && if !(pu isa Number)
        end => print(io, "PiUnit(($(pu))::$(pu_type))")
        Factor(f) => print(io, "$(f)")
    end
end

function eqeq(p1,p2)
    @match (p1, p2) begin
        (PiUnit(pu1, _), PiUnit(pu2, _)) => pu1 == pu2
        (Factor(f1), Factor(f2)) => f1 == f2
        (PiUnit(pu1, _), Factor(f2)) => exp(im*pu1*π) == f2
        (Factor(f1), PiUnit(pu2, _)) => f1 == exp(im*pu2*π)
        (PiUnit(_...), _ ) => p1.pu == p2
        (Factor(f1), ::Number) => f1 == p2
        _ => error("Invalid input '$(p1)' of type $(typeof(p1)) and '$(p2)' of type $(typeof(p2)) for ADT: ==")
    end
end

Base.:(==)(p1::Parameter, p2::Parameter) = eqeq(p1,p2)
Base.:(==)(p1::Parameter, p2::Number) = eqeq(p1,p2)
Base.:(==)(p1::Number, p2::Parameter) = eqeq(p2,p1)

Base.isless(p1::Parameter, p2::Number) = p1.pu isa Number && p1.pu < p2

Base.convert(::Type{Parameter}, p::T) where T = @match p begin
    (pu, type::String) => Parameter(pu, type)
    PiUnit(_...) => p
    Factor(_...) => p
    _ => error("Invalid input '$(p)' of type $(typeof(p)) for ADT converter")
end

Base.zero(p::Parameter) = @match p begin
    PiUnit(_...) => Parameter(0.0, "PiUnit")
    Factor(_...) => Parameter(0.0)
end

Base.one(p::Parameter) = @match p begin
    PiUnit(_...) => Parameter(1.0, "PiUnit")
    Factor(_...) => Parameter(1.0)
end

# Base.zero(::Type{Parameter.PiUnit}) = Parameter(0.0, "PiUnit")
# Base.zero(::Type{Parameter.Factor}) = Parameter(0.0)

# Base.one(::Type{Parameter.PiUnit}) = Parameter(1.0, "PiUnit")
# Base.one(::Type{Parameter.Factor}) = Parameter(1.0)

Base.iseven(p::Parameter) = @match p begin
    PiUnit(_...) => (p.pu isa Number) && (-1)^p.pu > 0
    Factor(_...) => (-1)^p.f > 0
end

function add_param(p1, p2)
    @match (p1, p2) begin
        (PiUnit(pu1, pu_t1), PiUnit(pu2, pu_t2)) && if pu1 isa Number && pu2 isa Number end => PiUnit(pu1 + pu2, pu_t1)
        (PiUnit(pu1, pu_t1), PiUnit(pu2, pu_t2)) && if !(pu1 isa Number) ||  !(pu2 isa Number) end => PiUnit(Expr(:call, :+, pu1, pu2), Expr)
        (Factor(f1), Factor(f2)) => Factor(f1 + f2)
        (PiUnit(_...), Factor(_...)) => Parameter(exp(im*p1.pu*π)+p2, "Factor")
        (Factor(_...), PiUnit(_...)) => Parameter(exp(im*p2.pu*π)+p1, "Factor")
        (PiUnit(_...), _ ) => p1 + Parameter(p2, "PiUnit")
        (Factor(_...), ::Number) => p1 + Parameter(p2, "Factor")
        _ => error("Invalid input '$(p1)' of type $(typeof(p1)) and '$(p2)' of type $(typeof(p2)) for ADT: +")

    end
end

Base.:(+)(p1::Parameter, p2::Parameter) = add_param(p1, p2)
Base.:(+)(p1::Parameter, p2::Number) = add_param(p1, p2)
Base.:(+)(p1::Number, p2::Parameter) = add_param(p2, p1)

function subt_param(p1,p2)
    @match (p1, p2) begin
        (PiUnit(pu1, pu_t1), PiUnit(pu2, pu_t2)) && if pu1 isa Number && pu2 isa Number end => PiUnit(pu1 - pu2, pu_t1)
        (PiUnit(pu1, pu_t1), PiUnit(pu2, pu_t2)) && if !(pu1 isa Number) ||  !(pu2 isa Number) end => PiUnit(Expr(:call, :-, pu1, pu2), Expr)
        (Factor(f1), Factor(f2)) => Factor(f1 - f2)
        (PiUnit(_...), Factor(_...)) => Parameter(exp(im*p1.pu*π)-p2, "Factor")
        (Factor(_...), PiUnit(_...)) => Parameter(exp(im*p2.pu*π)-p1, "Factor")
        (_, PiUnit(_...)) => Parameter(p1,"PiUnit") - p2
        (::Number, Factor(_...)) => Parameter(p1,"Factor") - p2
        _ => error("Invalid input '$(p1)' of type $(typeof(p1)) and '$(p2)' of type $(typeof(p2)) for ADT: -")

    end
end

Base.:(-)(p1::Parameter, p2::Parameter) = subt_param(p1,p2)
Base.:(-)(p1::Number, p2::Parameter) = subt_param(p1,p2)
Base.:(-)(p1::Parameter, p2::Number) = add_param(p1, -p2)


function mul_param(p1,p2)
    @match (p1, p2) begin
        (PiUnit(pu1, pu_t1), PiUnit(pu2, pu_t2)) && if pu1 isa Number && pu2 isa Number end => PiUnit(pu1 * pu2, pu_t1)
        (PiUnit(pu1, pu_t1), PiUnit(pu2, pu_t2)) && if !(pu1 isa Number) ||  !(pu2 isa Number) end => PiUnit(Expr(:call, :*, pu1, pu2), Expr)
        (Factor(f1), Factor(f2)) => Factor(f1 * f2)
        (PiUnit(_...), Factor(_...)) => Parameter(exp(im*p1.pu*π) * p2, "Factor")
        (Factor(_...), PiUnit(_...)) => Parameter(exp(im*p2.pu*π) * p1, "Factor")
        (PiUnit(_...), _ ) => p1 * Parameter(p2, "PiUnit")
        (Factor(_...), ::Number) => p1 * Parameter(p2, "Factor")
        _ => error("Invalid input '$(p1)' of type $(typeof(p1)) and '$(p2)' of type $(typeof(p2)) for ADT: *")
    end
end

Base.:(*)(p1::Parameter, p2::Parameter) = mul_param(p1,p2)
Base.:(*)(p1::Parameter, p2::Number) = mul_param(p1,p2)
Base.:(*)(p1::Number, p2::Parameter) = mul_param(p2,p1)


function div_param(p1,p2)
    @match (p1, p2) begin
        (PiUnit(pu1, pu_t1), PiUnit(pu2, pu_t2)) && if pu1 isa Number && pu2 isa Number end => PiUnit(pu1 / pu2, pu_t1)
        (PiUnit(pu1, pu_t1), PiUnit(pu2, pu_t2)) && if !(pu1 isa Number) ||  !(pu2 isa Number) end => PiUnit(Expr(:call, :/, pu1, pu2), Expr)
        (Factor(f1), Factor(f2)) => Factor(f1 / f2)
        (PiUnit(_...), Factor(_...)) => Parameter(exp(im*p1.pu*π) / p2, "Factor")
        (Factor(_...), PiUnit(_...)) => Parameter(p1 / exp(im*p2.pu*π), "Factor")
        (_, PiUnit(_...)) => Parameter(p1,"PiUnit") / p2
        (::Number, Factor(_...)) => Parameter(p1,"Factor") / p2
        _ => error("Invalid input '$(p1)' of type $(typeof(p1)) and '$(p2)' of type $(typeof(p2)) for ADT: /")

    end
end

Base.:(/)(p1::Parameter, p2::Parameter) = div_param(p1,p2)
Base.:(/)(p1::Number, p2::Parameter) = div_param(p1,p2)
Base.:(/)(p1::Parameter, p2::Number) = mul_param(p1, 1/p2)

function Base.rem(p::Parameter, d::Number)
    @match p begin
        PiUnit(pu, pu_t) && if pu isa Number end => PiUnit(rem(pu, d), pu_t)
        PiUnit(pu, pu_t) && if !(pu isa Number) end => p
        Factor(f) => Factor(rem(f, d))
        _ => error("Invalid input '$(p)' of type $(typeof(p)) and '$(d)' of type $(typeof(d)) for ADT: rem")
    end
end
