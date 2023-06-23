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
function Parameter(x, type::String = "Factor")
    @match (x, type) begin
        if type == "PiUnit" end => PiUnit(x,typeof(x))
        (f :: Number, "Factor") => Factor(f)
        (PiUnit(_...), _) => PiUnit(x.pu, x.pu_type)
        (Factor(_...), _) => Factor(x.f)
        _ => error("Invalid input '$(x)' of type $(typeof(x)) for ADT: $(type)")

    end
end
