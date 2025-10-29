using Test
using ZXCalculus, Multigraphs, ZXCalculus.ZX, ZXCalculus.Utils, Graphs
using ZXCalculus: ZX
using ZXCalculus.Utils: Phase

function xtoz_rule_test()
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

@testset "XToZRule" begin
    @testset "ZXDiagram" begin
        g = Multigraph([0 2 0; 2 0 1; 0 1 0])
        ps = [Phase(i // 4) for i in 1:3]
        v_t = [SpiderType.X, SpiderType.X, SpiderType.Z]
        zxd = ZXDiagram(g, v_t, ps)
        matches = match(XToZRule(), zxd)
        rewrite!(XToZRule(), zxd, matches)
        @test nv(zxd) == 8 && ne(zxd) == 8
        @test !isnothing(zxd)
    end

    @testset "ZXGraph" begin
        zxg = xtoz_rule_test()
        add_edge!(zxg, 8, 5, EdgeType.HAD)
        matches_x2z = match(XToZRule(), zxg)
        @test length(matches_x2z) == 1
        rewrite!(XToZRule(), zxg, matches_x2z)
        @test nv(zxg) == 8 && ne(zxg) == 9
    end

    @testset "Multiple X spiders" begin
        # TODO: Test edge cases with multiple X spiders
    end

    @testset "Different edge types" begin
        # TODO: Test interaction with different edge types
    end

    @testset "Phase preservation" begin
        # TODO: Test phase preservation during conversion
    end
end
