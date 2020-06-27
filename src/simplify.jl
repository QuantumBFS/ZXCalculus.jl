export simplify!

"""
    simplify!(r, zxd)
Simplify `zxd` with the rule `r`.
"""
function simplify!(r::AbstractRule, zxd::AbstractZXDiagram)
    matches = match(r, zxd)
    while length(matches) > 0
        rewrite!(r, zxd, matches)
        matches = match(r, zxd)
    end
    return zxd
end
