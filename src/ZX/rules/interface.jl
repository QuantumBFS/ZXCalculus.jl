abstract type AbstractRule end

"""
    Rule{L}

The struct for identifying different rules.

Rule for `ZXDiagram`s:

  - `FusionRule()`: fusion rule (also available as `Rule{:f}()`)
  - `XToZRule()`: hadamard rule (also available as `Rule{:h}()`)
  - `Identity1Rule()`: identity rule 1 (also available as `Rule{:i1}()`)
  - `HBoxRule()`: identity rule 2 (also available as `Rule{:i2}()`)
  - `PiRule()`: π rule (also available as `Rule{:pi}()`)
  - `CopyRule()`: copy rule (also available as `Rule{:c}()`)
  - `BialgebraRule()`: bialgebra rule (also available as `Rule{:b}()`)
  - `ScalarRule()`: scalar rule (also available as `Rule{:scalar}()`)

Rule for `ZXGraph`s:

  - `LocalCompRule()`: local complementary rule (also available as `Rule{:lc}()`)
  - `Pivot1Rule()`: pivoting rule (also available as `Rule{:p1}()`)
  - `PivotBoundaryRule()`: rule for removing Pauli spiders adjacent to boundary spiders (also available as `Rule{:pab}()`)
  - `Pivot2Rule()`: pivot rule 2 (also available as `Rule{:p2}()`)
  - `Pivot3Rule()`: pivot rule 3 (also available as `Rule{:p3}()`)
  - `IdentityRemovalRule()`: identity removal rule (also available as `Rule{:id}()`)
  - `GadgetFusionRule()`: gadget fusion rule (also available as `Rule{:gf}()`)
  - `PivotGadgetRule()`: pivot gadget rule (also available as `Rule{:pivot}()`)
  - `ScalarRule()`: scalar rule (also available as `Rule{:scalar}()`)
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

Returns all matched vertices, which will be stored in struct `Match`, for rule `r`
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

Base.match(r::AbstractRule, zxc::ZXCircuit{T, P}) where {T, P} = match(r, zxc.zx_graph)
rewrite!(r::AbstractRule, zxc::ZXCircuit{T, P}, vs::Vector{T}) where {T, P} = rewrite!(r, zxc.zx_graph, vs)
check_rule(r::AbstractRule, zxc::ZXCircuit{T, P}, vs::Vector{T}) where {T, P} = check_rule(r, zxc.zx_graph, vs)
