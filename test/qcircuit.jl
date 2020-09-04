using ZXCalculus

qc = random_circuit(5, 80)
circ = ZXDiagram(qc)
tcount(circ)
using YaoPlots
plot(circ)
pt_circ = phase_teleportation(circ)
@test tcount(pt_circ) <= tcount(circ)
pt_qc = QCircuit(pt_circ)
@test count_gates(pt_qc) <= count_gates(qc)

zxg = clifford_simplification(circ)
ex_circ = circuit_extraction(zxg)
ex_qc = QCircuit(ex_circ)
length(ex_qc.gates)
