using Test
using ZXCalculus
using ZXCalculus: PiUnit

zxd = ZXDiagram(4)
push_gate!(zxd, Val{:Z}(), 1, PiUnit(3//2))
push_gate!(zxd, Val{:H}(), 1)
push_gate!(zxd, Val{:Z}(), 1, PiUnit(1//2))
push_gate!(zxd, Val{:Z}(), 2, PiUnit(1//2))
push_gate!(zxd, Val{:H}(), 4)
push_gate!(zxd, Val{:CNOT}(), 3, 2)
push_gate!(zxd, Val{:CZ}(), 4, 1)
push_gate!(zxd, Val{:H}(), 2)
push_gate!(zxd, Val{:CNOT}(), 3, 2)
push_gate!(zxd, Val{:CNOT}(), 1, 4)
push_gate!(zxd, Val{:H}(), 1)
push_gate!(zxd, Val{:Z}(), 2, PiUnit(1//4))
push_gate!(zxd, Val{:Z}(), 3, PiUnit(1//2))
push_gate!(zxd, Val{:H}(), 4)
push_gate!(zxd, Val{:Z}(), 1, PiUnit(1//4))
push_gate!(zxd, Val{:H}(), 2)
push_gate!(zxd, Val{:H}(), 3)
push_gate!(zxd, Val{:Z}(), 4, PiUnit(3//2))
push_gate!(zxd, Val{:Z}(), 3, PiUnit(1//2))
push_gate!(zxd, Val{:X}(), 4, PiUnit(1//1))
push_gate!(zxd, Val{:CNOT}(), 3, 2)
push_gate!(zxd, Val{:H}(), 1)
push_gate!(zxd, Val{:Z}(), 4, PiUnit(1//2))
push_gate!(zxd, Val{:X}(), 4, PiUnit(1//1))

zxg = ZXGraph(zxd)
replace!(Rule{:lc}(), zxg)
replace!(Rule{:pab}(), zxg)

cir = circuit_extraction(zxg)

zxg2 = clifford_simplification(zxd)
@test nv(zxg2) <= nv(zxg)
@test ne(zxg2) <= ne(zxg)

zxg3 = full_reduction(zxd)
cir = circuit_extraction(zxg3)