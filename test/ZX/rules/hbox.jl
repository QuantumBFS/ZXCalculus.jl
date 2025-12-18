using Test
using ZXCalculus, Multigraphs, ZXCalculus.ZX, ZXCalculus.Utils, Graphs
using ZXCalculus: ZX
using ZXCalculus.Utils: Phase

function hbox_rule_test()
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

@testset "HBoxRule" begin
    @testset "ZXDiagram after XToZ" begin
        g = Multigraph([0 2 0; 2 0 1; 0 1 0])
        ps = [Phase(i // 4) for i in 1:3]
        v_t = [SpiderType.X, SpiderType.X, SpiderType.Z]
        zxd = ZXDiagram(g, v_t, ps)
        zxd_before = copy(zxd)

        # First apply XToZRule to create Hadamard boxes
        matches = match(XToZRule(), zxd)
        rewrite!(XToZRule(), zxd, matches)

        # Now apply HBoxRule
        matches = match(HBoxRule(), zxd)
        rewrite!(HBoxRule(), zxd, matches)
        @test nv(zxd) == 4 && ne(zxd, count_mul=true) == 4 && ne(zxd) == 3
        @test check_equivalence(zxd_before, zxd)
    end

    @testset "ZXGraph" begin
        zxg = hbox_rule_test()
        add_edge!(zxg, 8, 5, EdgeType.HAD)

        # Apply XToZRule first
        matches_x2z = match(XToZRule(), zxg)
        zxg_before = copy(zxg)
        rewrite!(XToZRule(), zxg, matches_x2z)
        @test check_equivalence(zxg_before, zxg)

        # Add H-box spider and test HBoxRule
        v = ZX.add_spider!(zxg, SpiderType.H, Phase(0//1), [8, 5])
        zxg_before = copy(zxg)
        matches_box = match(HBoxRule(), zxg)
        @test length(matches_box) == 1
        rewrite!(HBoxRule(), zxg, matches_box)

        @test nv(zxg) == 8 && ne(zxg) == 9
        @test ZX.edge_type(zxg, 7, 8) === EdgeType.HAD
        @test ZX.edge_type(zxg, 8, 5) === EdgeType.SIM
        @test ZX.is_one_phase(phase(zxg, 5)) || ZX.is_one_phase(phase(zxg, 8))
        @test check_equivalence(zxg_before, zxg)
    end
end
