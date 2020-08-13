using ZXCalculus

function mod_5_4()
    qc = QCircuit(5)
    push_gate!(qc, Val{:X}(), 5)
    push_ctrl_gate!(qc, Val{:TOF}(), 5, 1, 4)
    push_ctrl_gate!(qc, Val{:TOF}(), 5, 3, 4)
    push_ctrl_gate!(qc, Val{:CNOT}(), 5, 4)
    push_ctrl_gate!(qc, Val{:TOF}(), 5, 2, 3)
    push_ctrl_gate!(qc, Val{:CNOT}(), 5, 3)
    push_ctrl_gate!(qc, Val{:TOF}(), 5, 1, 2)
    push_ctrl_gate!(qc, Val{:CNOT}(), 5, 2)
    push_ctrl_gate!(qc, Val{:CNOT}(), 5, 1)

    return qc
end

qc = mod_5_4()
circ = ZXDiagram(qc)
pt_circ = phase_teleportation(circ)
tcount(pt_circ)
pt_qc = QCircuit(pt_circ)
length(pt_qc.gates)

zxg = clifford_simplification(circ)
ZXCalculus.gates_count(circuit_extraction(zxg))