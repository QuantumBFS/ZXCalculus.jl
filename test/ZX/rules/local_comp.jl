using Test
using ZXCalculus, Multigraphs, ZXCalculus.ZX, ZXCalculus.Utils, Graphs
using ZXCalculus: ZX
using ZXCalculus.Utils: Phase
using Vega, DataFrames

@testset "LocalCompRule" begin
    @testset "Basic local complementation" begin
        g = Multigraph(9)
        for e in [[2, 6], [3, 7], [4, 8], [5, 9]]
            add_edge!(g, e[1], e[2])
        end
        ps = [Phase(1 // 2), Phase(0), Phase(1 // 4), Phase(1 // 2),
            Phase(3 // 4), Phase(0), Phase(0), Phase(0), Phase(0)]
        st = [
            SpiderType.Z,
            SpiderType.Z,
            SpiderType.Z,
            SpiderType.Z,
            SpiderType.Z,
            SpiderType.In,
            SpiderType.In,
            SpiderType.Out,
            SpiderType.Out
        ]
        zxg = ZXCircuit(ZXDiagram(g, st, ps))
        for e in [[1, 2], [1, 3], [1, 4], [1, 5], [2, 3]]
            add_edge!(zxg, e[1], e[2])
        end
        add_spider!(zxg, SpiderType.Z, Phase(1//2), [3, 4])
        ZX.set_edge_type!(zxg, 3, 10, EdgeType.SIM)
        zxg_before = copy(zxg)

        @test length(match(LocalCompRule(), zxg)) == 1
        replace!(LocalCompRule(), zxg)
        @test !has_edge(zxg, 2, 3) && nv(zxg) == 9 && ne(zxg) == 11
        @test phase(zxg, 2) == 3 // 2 &&
              phase(zxg, 3) == 7 // 4 &&
              phase(zxg, 4) == 0 // 1 &&
              phase(zxg, 5) == 1 // 4
        @test check_equivalence(zxg_before, zxg)
    end

    @testset "Different neighborhood structures" begin
        # TODO: Test local complementation with different neighborhood structures
    end

    @testset "Phase updates" begin
        # TODO: Test phase updates during local complementation
    end

    @testset "Circuit semantics preservation" begin
        # TODO: Test preservation of circuit semantics
    end
end
