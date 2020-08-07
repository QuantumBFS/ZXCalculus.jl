export phase_teleportation

"""
    phase_teleportation(zxd)
Reducing T-count of `zxd` with the algorithms in [arXiv:1903.10477](https://arxiv.org/abs/1903.10477).
"""
function phase_teleportation(cir::ZXDiagram{T, P}) where {T, P}
    zxg = ZXGraph(cir)
    ncir = zxg.master

    simplify!(Rule{:lc}(), zxg)
    simplify!(Rule{:p1}(), zxg)
    simplify!(Rule{:p2}(), zxg)
    simplify!(Rule{:p3}(), zxg)
    simplify!(Rule{:lc}(), zxg)
    simplify!(Rule{:p1}(), zxg)
    match_id = match(Rule{:id}(), zxg)
    match_gf = match(Rule{:gf}(), zxg)
    while length(match_id) + length(match_gf) > 0
        rewrite!(Rule{:id}(), zxg, match_id)
        rewrite!(Rule{:gf}(), zxg, match_gf)
        simplify!(Rule{:lc}(), zxg)
        simplify!(Rule{:p1}(), zxg)
        simplify!(Rule{:p2}(), zxg)
        simplify!(Rule{:p3}(), zxg)
        simplify!(Rule{:lc}(), zxg)
        simplify!(Rule{:p1}(), zxg)
        match_id = match(Rule{:id}(), zxg)
        match_gf = match(Rule{:gf}(), zxg)
    end

    simplify!(Rule{:i1}(), ncir)
    simplify!(Rule{:i2}(), ncir)
    return ncir
end
