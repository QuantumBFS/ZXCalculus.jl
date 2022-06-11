using Test
using ZXCalculus
using Graphs
using OMEinsum
using LinearAlgebra

using ZXCalculus: SpiderType, to_eincode_tensor, h_tensor, w_tensor, d_tensor

zxd = ZXDiagram(2)
push_gate!(zxd, Val(:CNOT), 1, 2)
push_gate!(zxd, Val(:CNOT), 1, 2)
add_edge!(zxd, 5, 5)
ec, ts = ZXCalculus.to_eincode(zxd)
reshape(ec(ts...), (4, 4))
@test Matrix(zxd) ≈ diagm([1,1,1,1])

@test_throws ErrorException to_eincode_tensor(SpiderType.H, 3, 0)
@test_throws ErrorException to_eincode_tensor(SpiderType.D, 1, 0)
@test to_eincode_tensor(SpiderType.W, 2, 0) ≈ [0 1; 1 0]
@test to_eincode_tensor(SpiderType.H, 2, 0)^2 ≈ [1 0; 0 1]
@test [0 1; 1 0] * to_eincode_tensor(SpiderType.D, 2, 0) ≈ [1 1; 0 1]