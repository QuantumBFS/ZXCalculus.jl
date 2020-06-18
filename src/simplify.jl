export simplify!

"""
    simplify!(r, zxd)
Simplify `zxd` with the rule `r`.
"""
function simplify!(r::AbstractRule, zxd::ZXDiagram)
    matches = match(r, zxd)
    while length(matches) > 0
        rewrite!(r, zxd, matches)
        matches = match(r, zxd)
    end
    zxd
end
function simplify!(r::AbstractRule, zxg::ZXGraph)
    matches = match(r, zxg)
    while length(matches) > 0
        rewrite!(r, zxg, matches)
        matches = match(r, zxg)
    end
    zxg
end
