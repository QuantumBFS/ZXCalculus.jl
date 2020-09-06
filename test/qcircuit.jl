using ZXCalculus

qc = random_circuit(5, 80)
circ = ZXDiagram(qc)
@test tcount(qc) == tcount(circ)
@test global_phase(circ) == 0
pt_circ = phase_teleportation(circ)
@test tcount(pt_circ) <= tcount(circ)
pt_qc = QCircuit(pt_circ)
@test tcount(pt_qc) == tcount(pt_circ)
@test gate_count(pt_qc) <= gate_count(qc)

ex_circ = clifford_simplification(circ)
ex_qc = QCircuit(ex_circ)
@test tcount(ex_circ) == tcount(ex_qc)