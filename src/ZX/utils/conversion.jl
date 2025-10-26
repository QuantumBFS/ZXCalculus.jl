"""
    continued_fraction(ϕ, n::Int) -> Rational

Obtain `s` and `r` from `ϕ` that satisfies `|s//r - ϕ| ≦ 1/2r²`
"""
function continued_fraction(fl, n::Int)
    if n == 1 || abs(mod(fl, 1)) < 1e-10
        Rational(floor(Int, fl), 1)
    else
        floor(Int, fl) + 1//continued_fraction(1/mod(fl, 1), n-1)
    end
end

safe_convert(::Type{T}, x) where T = convert(T, x)
safe_convert(::Type{T}, x::T) where T <: Rational = x
function safe_convert(::Type{T}, x::Real) where T <: Rational
    local fr
    for n in 1:16 # at most 20 steps, otherwise the number may overflow.
        fr = continued_fraction(x, n)
        abs(fr - x) < 1e-12 && return fr
    end
    @warn "converting phase to rational, but with rounding error $(abs(fr-x))."
    return fr
end
