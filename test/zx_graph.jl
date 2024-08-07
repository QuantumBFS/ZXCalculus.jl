using Test, Multigraphs, ZXCalculus, ZXCalculus.ZX, ZXCalculus.Utils, Graphs
using ZXCalculus: ZX

g = Multigraph(6)
add_edge!(g, 1, 3)
add_edge!(g, 2, 4)
add_edge!(g, 3, 4)
add_edge!(g, 3, 5)
add_edge!(g, 4, 6)
ps = [0 // 1 for i = 1:6]
v_t = [SpiderType.In, SpiderType.In, SpiderType.X, SpiderType.Z, SpiderType.Out, SpiderType.Out]
zxd = ZXDiagram(g, v_t, ps)
zxg1 = ZXGraph(zxd)
@test !isnothing(zxg1)
@test outneighbors(zxg1, 1) == inneighbors(zxg1, 1)
@test !ZX.is_hadamard(zxg1, 2, 4) && !ZX.is_hadamard(zxg1, 4, 6)
@test add_edge!(zxg1, 1, 1)
@test !add_edge!(zxg1, 2, 4)
@test !add_edge!(zxg1, 7, 8)
@test sum([ZX.is_hadamard(zxg1, src(e), dst(e)) for e in edges(zxg1.mg)]) == 3
replace!(Rule{:b}(), zxd)
zxg2 = ZXGraph(zxd)
@test !ZX.is_hadamard(zxg2, 5, 8) && !ZX.is_hadamard(zxg2, 1, 7)


@testset "push gates into Diagram then plot ZXGraph" begin
    zxd = ZXDiagram(2)
    push_gate!(zxd, Val(:H), 1)
    push_gate!(zxd, Val(:CNOT), 2, 1)
    zxg = ZXGraph(zxd)
    @test !isnothing(zxg)

    zxg3 = ZXGraph(ZXDiagram(3))
    ZX.add_global_phase!(zxg3, ZXCalculus.Utils.Phase(1 // 4))
    ZX.add_power!(zxg3, 3)
    @test ZX.scalar(zxg3) == Scalar(3, 1 // 4)
    @test degree(zxg3, 1) == indegree(zxg3, 1) == outdegree(zxg3, 1)
    @test ZX.qubit_loc(zxg3, 1) == ZX.qubit_loc(zxg3, 2)
    @test ZX.column_loc(zxg3, 1) == 1 // 1
    @test ZX.column_loc(zxg3, 2) == 3 // 1
end
