function full_reduction(cir::ZXDiagram)
    zxg = ZXCircuit(cir; track_phase=true, normalize=true)
    zxg = full_reduction!(zxg)
    return zxg
end

function full_reduction(zxg::Union{ZXCircuit, ZXGraph})
    zxg = copy(zxg)
    return full_reduction!(zxg)
end

function full_reduction(bir::BlockIR)
    circ = convert_to_zx_circuit(bir)
    full_reduction!(circ)
    chain = circuit_extraction(circ)
    return BlockIR(bir.parent, bir.nqubits, chain)
end

function full_reduction!(zxg::Union{ZXGraph, ZXCircuit})
    to_z_form!(zxg)
    simplify!(LocalCompRule(), zxg)
    simplify!(Pivot1Rule(), zxg)
    simplify!(Pivot2Rule(), zxg)
    simplify!(Pivot3Rule(), zxg)
    replace!(PivotBoundaryRule(), zxg)
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
        replace!(PivotBoundaryRule(), zxg)
        simplify!(Pivot1Rule(), zxg)
        match_id = match(IdentityRemovalRule(), zxg)
        match_gf = match(GadgetFusionRule(), zxg)
    end

    return zxg
end
