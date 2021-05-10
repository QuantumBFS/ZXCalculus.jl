using Test
using YaoHIR
using YaoLocations
using ZXCalculus
using ZXCalculus: Phase
using YaoHIR: Chain, Gate, Ctrl, shift, Rz

qc = Chain(
    Gate(shift(1.0), Locations(1)),
    Gate(Rz(Phase(:a, Int)), Locations(1)),
)

zxd = convert_to_zxd(qc, 4)
qc_tl = convert_to_block_ir(phase_teleportation(zxd))
@test length(qc_tl) == 1
