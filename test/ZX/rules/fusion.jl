using Test
using ZXCalculus, Multigraphs, ZXCalculus.ZX, ZXCalculus.Utils, Graphs
using ZXCalculus: ZX
using ZXCalculus.Utils: Phase

function fusion_rule_test()
    zxg = ZXGraph()
    v1 = ZX.add_spider!(zxg, SpiderType.In)
    v2 = ZX.add_spider!(zxg, SpiderType.Out)
    v3 = ZX.add_spider!(zxg, SpiderType.In)
    v4 = ZX.add_spider!(zxg, SpiderType.Out)
    v5 = ZX.add_spider!(zxg, SpiderType.Z, Phase(0//1), [v1])
    v6 = ZX.add_spider!(zxg, SpiderType.Z, Phase(0//1), [v2])
    v7 = ZX.add_spider!(zxg, SpiderType.Z, Phase(0//1), [v3, v4])
    v8 = ZX.add_spider!(zxg, SpiderType.X, Phase(0//1))
    ZX.add_edge!(zxg, v5, v6, EdgeType.SIM)
    ZX.add_edge!(zxg, v5, v7, EdgeType.HAD)
    ZX.add_edge!(zxg, v6, v7, EdgeType.HAD)
    ZX.add_edge!(zxg, v7, v8, EdgeType.SIM)
    return zxg
end

@testset "FusionRule" begin
    @testset "ZXDiagram" begin
        g = Multigraph([0 2 0; 2 0 1; 0 1 0])
        collect(edges(g))
        ps = [Phase(i // 4) for i in 1:3]
        v_t = [SpiderType.Z, SpiderType.Z, SpiderType.X]
        zxd = ZXDiagram(g, v_t, ps)
        zxd_before = copy(zxd)
        matches = match(FusionRule(), zxd)
        rewrite!(FusionRule(), zxd, matches)
        @test sort!(spiders(zxd)) == [1, 3]
        @test phase(zxd, 1) == phase(zxd, 3) == 3 // 4
        @test check_equivalence(zxd_before, zxd)
    end

    @testset "ZXGraph" begin
        zxg = fusion_rule_test()
        ZX.add_edge!(zxg, 7, 8, EdgeType.SIM)
        zxg_before = copy(zxg)
        @test zxg.scalar == Scalar(-2, 0 // 1)
        matches = match(FusionRule(), zxg)
        rewrite!(FusionRule(), zxg, matches)
        @test zxg.scalar == Scalar(-4, 0 // 1)
        @test nv(zxg) == 7 && ne(zxg) == 4
        @test check_equivalence(zxg_before, zxg)
    end
end
