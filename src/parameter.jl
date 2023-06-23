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
