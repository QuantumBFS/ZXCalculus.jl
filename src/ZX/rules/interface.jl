using DocStringExtensions

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
$(TYPEDEF)

A struct for saving matched vertices from rule matching.

# Fields

$(TYPEDFIELDS)
"""
struct Match{T <: Integer}
    "Vector of vertex identifiers that match a rule pattern"
    vertices::Vector{T}
end

"""
    $(TYPEDSIGNATURES)

Find all vertices in ZX-diagram `zxd` that match the pattern of rule `r`.

Returns a vector of `Match` objects containing the matched vertex sets.
"""
Base.match(r::AbstractRule, ::AbstractZXDiagram{T, P}) where {T, P} = error("match not implemented for rule $(r)")

"""
    $(TYPEDSIGNATURES)

Rewrite a ZX-diagram `zxd` with rule `r` for all vertices in `matches`.

The `matches` parameter can be a vector of `Match` objects or a single `Match` instance.

Returns the modified ZX-diagram.
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
    $(TYPEDSIGNATURES)

Rewrite a ZX-diagram `zxd` with rule `r` for the specific vertices `vs`.

This is the core rewriting function that must be implemented for each rule.

Returns the modified ZX-diagram.
"""
function rewrite!(r::AbstractRule, ::AbstractZXDiagram{T, P}, ::Vector{T}) where {T, P}
    return error("rewrite! not implemented for rule $(r)!")
end

"""
    $(TYPEDSIGNATURES)

Check whether the vertices `vs` in ZX-diagram `zxd` still match the rule `r`.

This is used to verify that a previously matched pattern is still valid before rewriting,
as the diagram may have changed since the match was found.

Returns `true` if the vertices still match the rule pattern, `false` otherwise.
"""
function check_rule(r::AbstractRule, ::AbstractZXDiagram{T, P}, ::Vector{T}) where {T, P}
    return error("check_rule not implemented for rule $(r)!")
end

Base.match(r::AbstractRule, zxc::AbstractZXCircuit{T, P}) where {T, P} = match(r, base_zx_graph(zxc))
function rewrite!(r::AbstractRule, zxc::AbstractZXCircuit{T, P}, vs::Vector{T}) where {T, P}
    return rewrite!(r, base_zx_graph(zxc), vs)
end
function check_rule(r::AbstractRule, zxc::AbstractZXCircuit{T, P}, vs::Vector{T}) where {T, P}
    return check_rule(r, base_zx_graph(zxc), vs)
end
