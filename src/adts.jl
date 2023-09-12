"""
    Parameter
The Algebraic Data Type for representing parameter related to spider.
`PiUnit(x)` represents the the phase of a number `exp(im*x*π)`.
`Factor(x)` represents a number `x`.
"""
@adt Parameter begin

    struct PiUnit
        pu
        pu_type::Type
    end

    struct Factor
        f::Number
        f_type::Type
    end

end

@adt ZXWSpiderType begin
    W
    H
    D

    struct Z
        p::Parameter
    end

    struct X
        p::Parameter
    end

    struct Input
        qubit::Int
    end

    struct Output
        qubit::Int
    end
end

@const_use ZXWSpiderType:W, H, D, Z, X, Input, Output
@const_use Parameter:PiUnit, Factor
