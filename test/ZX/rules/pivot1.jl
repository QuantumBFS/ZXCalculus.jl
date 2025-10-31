using Test
using ZXCalculus, Multigraphs, ZXCalculus.ZX, ZXCalculus.Utils, Graphs
using ZXCalculus: ZX
using ZXCalculus.Utils: Phase

@testset "Pivot1Rule" begin
    g = Multigraph(14)
    for e in [[3, 9], [4, 10], [5, 11], [6, 12], [7, 13], [8, 14]]
        add_edge!(g, e[1], e[2])
    end
    ps = [Phase(1 // 1), Phase(0), Phase(1 // 4), Phase(1 // 2), Phase(3 // 4), Phase(1),
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
    add_spider!(zxg, SpiderType.Z, Phase(0//1), [1, 7])
    ZX.set_edge_type!(zxg, 7, 15, EdgeType.SIM)
    zxg_before = copy(zxg)

    @test length(match(Pivot1Rule(), zxg)) == 2
    replace!(Pivot1Rule(), zxg)
    @test !has_edge(zxg, 3, 4) && !has_edge(zxg, 5, 6) && !has_edge(zxg, 7, 8)
    @test nv(zxg) == 13 && ne(zxg) == 22
    @test phase(zxg, 3) == 1 // 4 &&
          phase(zxg, 4) == 1 // 2 &&
          phase(zxg, 5) == 3 // 4 &&
          phase(zxg, 6) == 1 // 1 &&
          phase(zxg, 7) == 1 // 4 &&
          phase(zxg, 8) == 1 // 2
    @test check_equivalence(zxg_before, zxg)
end
