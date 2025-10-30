using Test
using ZXCalculus, Multigraphs, ZXCalculus.ZX, ZXCalculus.Utils, Graphs
using ZXCalculus: ZX
using ZXCalculus.Utils: Phase

@testset "PivotBoundaryRule" begin
    @testset "Basic boundary pivot" begin
        g = Multigraph(6)
        for e in [[2, 6]]
            add_edge!(g, e[1], e[2])
        end
        ps = [Phase(1 // 1), Phase(1 // 4), Phase(1 // 2), Phase(3 // 4), Phase(1), Phase(0)]
        st = [SpiderType.Z, SpiderType.Z, SpiderType.Z, SpiderType.Z, SpiderType.Z, SpiderType.In]
        zxg = ZXCircuit(ZXDiagram(g, st, ps))
        for e in [[1, 2], [2, 3], [1, 4], [1, 5]]
            add_edge!(zxg, e[1], e[2])
        end
        zxg_before = copy(zxg)

        @test length(match(Pivot1Rule(), zxg)) == 1
        replace!(PivotBoundaryRule(), zxg)
        @test nv(zxg) == 6 && ne(zxg) == 6
        @test check_equivalence(zxg_before, zxg)
    end

    @testset "Boundary spider handling" begin
        # TODO: Test interaction with different boundary spider types
    end

    @testset "Phase propagation" begin
        # TODO: Test phase propagation during boundary pivot
    end

    @testset "Edge preservation" begin
        # TODO: Test proper edge preservation at boundaries
    end
end
