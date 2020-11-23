using ZXCalculus
using ZXCalculus: Phase

qc = QCircuit(4)
push_gate!(qc, Val(:shift), 1, 1)
push_gate!(qc, Val(:Rz), 1, Phase(:a, Int))

zxd = ZXCalculus.ZXDiagram(qc)
QCircuit(phase_teleportation(zxd))
