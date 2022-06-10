using Test
using ZXCalculus
using Graphs
using OMEinsum
using LinearAlgebra

zxd = ZXDiagram(2)
push_gate!(zxd, Val(:CNOT), 1, 2)
push_gate!(zxd, Val(:CNOT), 1, 2)

add_edge!(zxd, 5, 5)

ec, ts = ZXCalculus.to_eincode(zxd)
reshape(ec(ts...), (4, 4))

@test Matrix(zxd) ≈ diagm([1,1,1,1])