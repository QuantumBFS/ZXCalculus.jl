"""
    phase_teleportation(zxd)

Reducing T-count of `zxd` with the algorithms in [arXiv:1903.10477](https://arxiv.org/abs/1903.10477).
"""
function phase_teleportation(cir::ZXDiagram{T, P}) where {T, P}
    zxg = ZXGraph(cir)
    ncir = zxg.master

    simplify!(LocalCompRule(), zxg)
    simplify!(Pivot1Rule(), zxg)
    simplify!(Pivot2Rule(), zxg)
    simplify!(Pivot3Rule(), zxg)
    simplify!(Pivot1Rule(), zxg)
    match_id = match(IdentityRemovalRule(), zxg)
    match_gf = match(GadgetFusionRule(), zxg)
    while length(match_id) + length(match_gf) > 0
        rewrite!(IdentityRemovalRule(), zxg, match_id)
        rewrite!(GadgetFusionRule(), zxg, match_gf)
        simplify!(LocalCompRule(), zxg)
        simplify!(Pivot1Rule(), zxg)
        simplify!(Pivot2Rule(), zxg)
        simplify!(Pivot3Rule(), zxg)
        simplify!(Pivot1Rule(), zxg)
        match_id = match(IdentityRemovalRule(), zxg)
        match_gf = match(GadgetFusionRule(), zxg)
    end

    simplify!(Identity1Rule(), ncir)
    simplify!(HBoxRule(), ncir)
    return ncir
end

function phase_teleportation(bir::BlockIR)
    zxd = convert_to_zxd(bir)
    nzxd = phase_teleportation(zxd)
    chain = convert_to_chain(nzxd)
    return BlockIR(bir.parent, bir.nqubits, chain)
end