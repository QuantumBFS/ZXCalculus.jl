using Test
using ZXCalculus, Multigraphs, ZXCalculus.ZX, ZXCalculus.Utils, Graphs
using ZXCalculus: ZX
using ZXCalculus.Utils: Phase

@testset "CopyRule" begin
    @testset "Basic copy rule" begin
        g = Multigraph(5)
        add_edge!(g, 1, 2)
        add_edge!(g, 2, 3)
        add_edge!(g, 2, 4)
        add_edge!(g, 2, 5)
        ps = [Phase(0), Phase(1 // 2), Phase(0), Phase(0), Phase(0)]
        v_t = [SpiderType.X, SpiderType.Z, SpiderType.Out, SpiderType.Out, SpiderType.Out]
        zxd = ZXDiagram(g, v_t, ps)
        zxd_before = copy(zxd)
        matches = match(CopyRule(), zxd)
        rewrite!(CopyRule(), zxd, matches)
        @test nv(zxd) == 6 && ne(zxd) == 3
        @test scalar(zxd) == Scalar(-2, 0 // 1)
        @test check_equivalence(zxd_before, zxd)
    end

    @testset "Copy with different multiplicities" begin
        # TODO: Test copy rule with different edge multiplicities
    end

    @testset "Scalar updates" begin
        # TODO: Test scalar factor updates during copy rule application
    end

    @testset "Layout generation" begin
        # TODO: Fix and test layout generation after copy rule
    end
end
