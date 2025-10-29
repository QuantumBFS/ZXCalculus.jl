module ZXGraphTests

using Test
using Multigraphs, Graphs
using ZXCalculus, ZXCalculus.ZX, ZXCalculus.Utils
using ZXCalculus.ZX: is_hadamard, is_zx_spider
using ZXCalculus.Utils: Phase, is_clifford_phase

@testset "Graph interface" begin
    zxg = ZXGraph()
    v1 = add_spider!(zxg, SpiderType.In)
    v2 = add_spider!(zxg, SpiderType.Out)
    @test has_vertex(zxg, v1) && has_vertex(zxg, v2)
    add_edge!(zxg, v1, v2, EdgeType.HAD)
    @test has_vertex(zxg, v1)
    @test nv(zxg) == 2
    @test ne(zxg) == 1
    @test neighbors(zxg, v1) == inneighbors(zxg, v1) == outneighbors(zxg, v1) == [v2]
    @test degree(zxg, v1) == indegree(zxg, v1) == outdegree(zxg, v1) == 1
    @test length(edges(zxg)) == 1
    @test rem_edge!(zxg, v1, v2)
end

@testset "Calculus interface" begin
    zxg = ZXGraph()

    # Construction
    v_in = add_spider!(zxg, SpiderType.In)
    v_out = add_spider!(zxg, SpiderType.Out)
    add_edge!(zxg, v_in, v_out, EdgeType.SIM)
    @test !is_hadamard(zxg, v_in, v_out)
    v_z = insert_spider!(zxg, v_in, v_out, SpiderType.Z, Phase(1 // 2))
    v_x = insert_spider!(zxg, v_z, v_out, SpiderType.X, Phase(1 // 4))
    v_h = insert_spider!(zxg, v_z, v_x, SpiderType.H)
    round_phases!(zxg)

    # Properties
    @test length(spiders(zxg)) == length(spider_types(zxg)) == length(phases(zxg)) == 5
    @test spider_type(zxg, v_z) == SpiderType.Z
    @test phase(zxg, v_x) == Phase(1 // 4)
    @test is_zx_spider(zxg, v_z) && is_zx_spider(zxg, v_x)
    @test !is_zx_spider(zxg, v_in) && !is_zx_spider(zxg, v_out) && !is_zx_spider(zxg, v_h)
    @test is_hadamard(zxg, v_z, v_h) && is_hadamard(zxg, v_x, v_h)
    @test_throws AssertionError is_hadamard(zxg, v_in, v_out)
    @test is_clifford_phase(phase(zxg, v_z))
    @test tcount(zxg) == 1

    # Modification
    add_edge!(zxg, v_z, v_z, EdgeType.HAD)
    @test phase(zxg, v_z) == Phase(3//2) && scalar(zxg) == Scalar(-1, 0//1)
    add_edge!(zxg, v_x, v_x, EdgeType.SIM)
    @test phase(zxg, v_x) == Phase(1//4) && scalar(zxg) == Scalar(-1, 0//1)
    @test_throws AssertionError add_edge!(zxg, v_z, v_h, EdgeType.HAD)
    @test add_edge!(zxg, v_z, v_x, EdgeType.SIM)
    @test add_edge!(zxg, v_z, v_x, EdgeType.SIM)
    @test scalar(zxg) == Scalar(-3, 0//1)

    add_edge!(zxg, v_z, v_x, EdgeType.HAD)
    add_edge!(zxg, v_z, v_x, EdgeType.HAD)
    @test is_hadamard(zxg, v_z, v_x)
    @test scalar(zxg) == Scalar(-3, 0//1)
    add_edge!(zxg, v_z, v_x, EdgeType.SIM)
    @test is_hadamard(zxg, v_z, v_x)
    @test scalar(zxg) == Scalar(-4, 0//1)
    @test phase(zxg, v_z) == Phase(1//2)

    str = repr(zxg)
    @test contains(str, "ZX-graph with $(nv(zxg)) vertices and $(ne(zxg)) edges")
    @test contains(str, "Z_$(v_z)")
    @test contains(str, "X_$(v_x)")
    @test contains(str, "H_$(v_h)")
    @test contains(str, "In_$(v_in)")
    @test contains(str, "Out_$(v_out)")
end

@testset "From ZXDiagram" begin
    g = Multigraph(6)
    add_edge!(g, 1, 3)
    add_edge!(g, 2, 4)
    add_edge!(g, 3, 4)
    add_edge!(g, 3, 5)
    add_edge!(g, 4, 6)
    ps = [Phase(0 // 1) for i in 1:6]
    v_t = [SpiderType.In, SpiderType.In, SpiderType.X, SpiderType.Z, SpiderType.Out, SpiderType.Out]
    zxd = ZXDiagram(g, v_t, ps)
    zxg1 = ZXGraph(zxd)
    @test outneighbors(zxg1, 1) == inneighbors(zxg1, 1)
    @test !ZX.is_hadamard(zxg1, 2, 4) && !ZX.is_hadamard(zxg1, 4, 6)
    @test_throws AssertionError add_edge!(zxg1, 2, 4)
    @test_throws AssertionError add_edge!(zxg1, 7, 8)
    @test sum(ZX.is_hadamard(zxg1, src(e), dst(e)) for e in edges(zxg1)) == 0
    replace!(BialgebraRule(), zxd)
    zxg2 = ZXGraph(zxd)
    @test !ZX.is_hadamard(zxg2, 5, 8) && !ZX.is_hadamard(zxg2, 1, 7)
end

end