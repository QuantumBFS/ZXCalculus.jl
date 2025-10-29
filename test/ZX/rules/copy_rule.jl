using Test
using ZXCalculus, Multigraphs, ZXCalculus.ZX, ZXCalculus.Utils, Graphs
using ZXCalculus: ZX
using ZXCalculus.Utils: Phase

@testset "CopyRule" begin
    @testset "Basic copy rule" begin
        g = Multigraph(5)
        add_edge!(g, 1, 2)
        add_edge!(g, 2, 3, 2)
        add_edge!(g, 2, 4)
        add_edge!(g, 2, 5)
        ps = [Phase(0), Phase(1 // 2), Phase(0), Phase(0), Phase(0)]
        v_t = [SpiderType.X, SpiderType.Z, SpiderType.Out, SpiderType.Out, SpiderType.Out]
        zxd = ZXDiagram(g, v_t, ps)
        matches = match(CopyRule(), zxd)
        rewrite!(CopyRule(), zxd, matches)
        @test nv(zxd) == 7 && ne(zxd) == 4
        @test zxd.scalar == Scalar(-3, 0 // 1)
        # FIXME generate layout does not terminate
        # @test !isnothing(zxd)
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
