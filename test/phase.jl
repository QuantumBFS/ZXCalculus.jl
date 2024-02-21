using Test
using ZXCalculus.Utils: Phase

chain = Chain()
push_gate!(chain, Val(:shift), 1, Phase(1 // 1))
push_gate!(chain, Val(:Rz), 1, Phase(2 // 1))

bir = BlockIR(IRCode(), 4, chain)

zxd = convert_to_zxd(bir)
c = clifford_simplification(zxd)
ZX.generate_layout!(zxd)
qc_tl = convert_to_chain(phase_teleportation(zxd))
@test length(qc_tl) == 1

p = Phase(1 // 1)

@test p + 1 == 1 + p == p + p
@test p - 1 == 1 - p == p - p
@test p / 1 == 1 / p == p / p
@test zero(Phase) == zero(p) && one(Phase) == one(p)
