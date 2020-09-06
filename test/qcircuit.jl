using ZXCalculus

qc = random_circuit(5, 80)
circ = ZXDiagram(qc)
@test global_phase(circ) == 0
pt_circ = phase_teleportation(circ)
@test tcount(pt_circ) <= tcount(circ)
pt_qc = QCircuit(pt_circ)
@test gate_count(pt_qc) <= gate_count(qc)

zxg = clifford_simplification(circ)
ex_circ = circuit_extraction(zxg)
ex_qc = QCircuit(ex_circ)