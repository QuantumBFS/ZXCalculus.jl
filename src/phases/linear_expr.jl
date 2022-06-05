struct LinearExpr{T<:Real} <: Real
    var::Symbol
    coeff::T
    constant::T
end