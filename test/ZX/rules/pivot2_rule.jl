using Test
using ZXCalculus, Multigraphs, ZXCalculus.ZX, ZXCalculus.Utils, Graphs
using ZXCalculus: ZX
using ZXCalculus.Utils: Phase

@testset "Pivot2Rule" begin
    @testset "Basic Pivot2 rewrite" begin
        g = Multigraph(14)
        for e in [[3, 9], [4, 10], [5, 11], [6, 12], [7, 13], [8, 14]]
            add_edge!(g, e[1], e[2])
        end
        ps = [Phase(1 // 1), Phase(1 // 4), Phase(1 // 4), Phase(1 // 2), Phase(3 // 4), Phase(1),
            Phase(5 // 4), Phase(3 // 2), Phase(0), Phase(0), Phase(0), Phase(0), Phase(0), Phase(0)]
        st = [
            SpiderType.Z,
            SpiderType.Z,
            SpiderType.Z,
            SpiderType.Z,
            SpiderType.Z,
            SpiderType.Z,
            SpiderType.Z,
            SpiderType.Z,
            SpiderType.In,
            SpiderType.Out,
            SpiderType.In,
            SpiderType.Out,
            SpiderType.In,
            SpiderType.Out
        ]
        zxg = ZXCircuit(ZXDiagram(g, st, ps))
        for e in [[1, 2], [1, 3], [1, 4], [1, 5], [1, 6], [2, 5], [2, 6], [2, 7], [2, 8]]
            add_edge!(zxg, e[1], e[2])
        end
        match(Pivot2Rule(), zxg)
        replace!(Pivot2Rule(), zxg)
        @test zxg.phase_ids[15] == (2, -1)
        @test !isnothing(zxg)
    end

    @testset "Phase ID tracking" begin
        # TODO: Test phase ID tracking during Pivot2 rewrite
    end

    @testset "Graph structure after rewrite" begin
        # TODO: Test graph structure changes after Pivot2 application
    end

    @testset "Multiple pivot patterns" begin
        # TODO: Test Pivot2Rule with multiple applicable patterns
    end
end
