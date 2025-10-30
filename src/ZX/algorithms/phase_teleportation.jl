using DocStringExtensions

"""
    $(TYPEDSIGNATURES)

Reduce T-count of `zxd` with the phase teleportation algorithms in [arXiv:1903.10477](https://arxiv.org/abs/1903.10477).

This optimization technique reduces the number of non-Clifford (T) gates in the circuit
by teleporting phases through the diagram.

Returns a ZX-diagram with reduced T-count.
"""
function phase_teleportation(cir::ZXDiagram)
    tracker = ZXCircuit(cir; track_phase=true, normalize=true)
    teleport_phase!(tracker)
    return ZXDiagram(tracker.master)
end

function phase_teleportation(circ::ZXCircuit)
    tracker = isnothing(circ.master) ? phase_tracker(circ) : copy(circ)
    teleport_phase!(tracker)
    teleported = tracker.master
    return teleported
end

function teleport_phase!(tracker::ZXCircuit)
    simplify!(LocalCompRule(), tracker)
    simplify!(Pivot1Rule(), tracker)
    simplify!(Pivot2Rule(), tracker)
    simplify!(Pivot3Rule(), tracker)
    simplify!(Pivot1Rule(), tracker)
    match_id = match(IdentityRemovalRule(), tracker)
    match_gf = match(GadgetFusionRule(), tracker)
    while length(match_id) + length(match_gf) > 0
        rewrite!(IdentityRemovalRule(), tracker, match_id)
        rewrite!(GadgetFusionRule(), tracker, match_gf)
        simplify!(LocalCompRule(), tracker)
        simplify!(Pivot1Rule(), tracker)
        simplify!(Pivot2Rule(), tracker)
        simplify!(Pivot3Rule(), tracker)
        simplify!(Pivot1Rule(), tracker)
        match_id = match(IdentityRemovalRule(), tracker)
        match_gf = match(GadgetFusionRule(), tracker)
    end
    return tracker
end

function phase_teleportation(bir::BlockIR)
    circ = convert_to_zx_circuit(bir)
    teleported = phase_teleportation(circ)
    chain = convert_to_chain(teleported)
    return BlockIR(bir.parent, bir.nqubits, chain)
end