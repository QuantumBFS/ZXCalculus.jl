abstract type AbstractRule end

"""
    Rule{L}

The struct for identifying different rules.

Rule for `ZXDiagram`s:

  - `Rule{:f}()`: rule f
  - `Rule{:h}()`: rule h
  - `Rule{:i1}()`: rule i1
  - `Rule{:i2}()`: rule i2
  - `Rule{:pi}()`: rule π
  - `Rule{:c}()`: rule c

Rule for `ZXGraph`s:

  - `Rule{:lc}()`: local complementary rule
  - `Rule{:p1}()`: pivoting rule
  - `Rule{:pab}()`: rule for removing Pauli spiders adjancent to boundary spiders
  - `Rule{:p2}()`: rule p2
  - `Rule{:p3}()`: rule p3
  - `Rule{:id}()`: rule id
  - `Rule{:gf}()`: gadget fushion rule
"""
struct Rule{L} <: AbstractRule end
Rule(r::Symbol) = Rule{r}()

"""
    Match{T<:Integer}

A struct for saving matched vertices.
"""
struct Match{T <: Integer}
    vertices::Vector{T}
end

"""
    match(r, zxd)

Returns all matched vertices, which will be store in sturct `Match`, for rule `r`
in a ZX-diagram `zxd`.
"""
Base.match(r::AbstractRule, ::AbstractZXDiagram{T, P}) where {T, P} = error("match not implemented for rule $(r)")

"""
    rewrite!(r, zxd, matches)

Rewrite a ZX-diagram `zxd` with rule `r` for all vertices in `matches`. `matches`
can be a vector of `Match` or just an instance of `Match`.
"""
function rewrite!(r::AbstractRule, zxd::AbstractZXDiagram{T, P}, matches::Vector{Match{T}}) where {T, P}
    for each in matches
        rewrite!(r, zxd, each)
    end
    return zxd
end

function rewrite!(r::AbstractRule, zxd::AbstractZXDiagram{T, P}, matched::Match{T}) where {T, P}
    vs = matched.vertices
    if check_rule(r, zxd, vs)
        rewrite!(r, zxd, vs)
    end
    return zxd
end

"""
    rewrite!(r, zxd, vs)

Rewrite a ZX-diagram `zxd` with rule `r` for vertices `vs`.
"""
function rewrite!(r::AbstractRule, ::AbstractZXDiagram{T, P}, ::Vector{T}) where {T, P}
    return error("rewrite! not implemented for rule $(r)!")
end

"""
    check_rule(r, zxd, vs)

Check whether the vertices `vs` in ZX-diagram `zxd` still match the rule `r`.
"""
function check_rule(r::AbstractRule, ::AbstractZXDiagram{T, P}, ::Vector{T}) where {T, P}
    return error("check_rule not implemented for rule $(r)!")
end
