"""
    $(TYPEDSIGNATURES)

Simplify `zxd` with the Clifford simplification algorithms in [arXiv:1902.03178](https://arxiv.org/abs/1902.03178).

This applies a sequence of local complementation and pivot rules to simplify the ZX-diagram
while preserving Clifford structure.

Returns the simplified ZX-diagram.
"""
function clifford_simplification(circ::ZXDiagram)
    zxg = ZXCircuit(circ; track_phase=true, normalize=true)
    zxg = clifford_simplification!(zxg)
    return zxg
end

function clifford_simplification(zxg::Union{ZXCircuit, ZXGraph})
    zxg = copy(zxg)
    return clifford_simplification!(zxg)
end

function clifford_simplification!(zxg::Union{ZXCircuit, ZXGraph})
    to_z_form!(zxg)
    simplify!(LocalCompRule(), zxg)
    simplify!(Pivot1Rule(), zxg)
    match_id = match(IdentityRemovalRule(), zxg)
    while length(match_id) > 0
        rewrite!(IdentityRemovalRule(), zxg, match_id)
        simplify!(LocalCompRule(), zxg)
        simplify!(Pivot1Rule(), zxg)
        match_id = match(IdentityRemovalRule(), zxg)
    end
    replace!(PivotBoundaryRule(), zxg)
    return zxg
end

function clifford_simplification(bir::BlockIR)
    circ = convert_to_zx_circuit(bir)
    zxg = clifford_simplification!(circ)
    chain = circuit_extraction(zxg)
    return BlockIR(bir.parent, bir.nqubits, chain)
end
