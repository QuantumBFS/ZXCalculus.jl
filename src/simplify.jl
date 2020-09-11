export replace!, simplify!, clifford_simplification

"""
    replace!(r, zxd)
Match and replace with the rule `r`.
"""
function replace!(r::AbstractRule, zxd::AbstractZXDiagram)
    matches = match(r, zxd)
    rewrite!(r, zxd, matches)
    return zxd
end

"""
    simplify!(r, zxd)
Simplify `zxd` with the rule `r`.
"""
function simplify!(r::AbstractRule, zxd::AbstractZXDiagram)
    max_iter = 20
    i = 1
    matches = match(r, zxd)
    while length(matches) > 0 && (i <= max_iter || r ∉ (Rule{:p2}(), Rule{:p3}()))
        rewrite!(r, zxd, matches)
        matches = match(r, zxd)
        i += 1
    end
    if i > max_iter && r in (Rule{:p2}(), Rule{:p3}())
        @warn "Try to simplify this ZX-diagram with rule $r more than $max_iter iterarions"
    end
    return zxd
end

"""
    clifford_simplification(zxd)
Simplify `zxd` with the algorithms in [arXiv:1902.03178](https://arxiv.org/abs/1902.03178).
"""
function clifford_simplification(circ::ZXDiagram)
    zxg = ZXGraph(circ)
    simplify!(Rule{:lc}(), zxg)
    simplify!(Rule{:p1}(), zxg)
    replace!(Rule{:pab}(), zxg)

    return circuit_extraction(zxg)
end
