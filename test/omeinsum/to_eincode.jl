using Test
using ZXCalculus
using Graphs
using OMEinsum
using LinearAlgebra

using ZXCalculus: h_tensor, w_tensor, d_tensor

zxd = ZXDiagram(2)
push_gate!(zxd, Val(:CNOT), 1, 2)
push_gate!(zxd, Val(:CNOT), 1, 2)
add_edge!(zxd, 5, 5)
ec, ts = ZXCalculus.to_eincode(zxd)
reshape(ec(ts...), (4, 4))
@test Matrix(zxd) ≈ diagm([1,1,1,1])

@test_throws ErrorException h_tensor(3)
@test_throws ErrorException d_tensor(3)
@test w_tensor(2) ≈ [0 1; 1 0]
@test h_tensor(2)^2 ≈ [1 0; 0 1]
@test [0 1; 1 0] * d_tensor(2) ≈ [1 1; 0 1]