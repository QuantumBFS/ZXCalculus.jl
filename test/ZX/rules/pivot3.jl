using Test
using ZXCalculus, Multigraphs, ZXCalculus.ZX, ZXCalculus.Utils, Graphs
using ZXCalculus: ZX
using ZXCalculus.Utils: Phase

@testset "Pivot3Rule" begin
    g = Multigraph(15)
    for e in [[3, 9], [4, 10], [5, 11], [6, 12], [7, 13], [8, 14], [2, 15]]
        add_edge!(g, e[1], e[2])
    end
    ps = [Phase(1 // 1), Phase(1 // 4), Phase(1 // 2), Phase(1 // 2), Phase(3 // 2), Phase(1), Phase(1 // 2),
        Phase(3 // 2), Phase(0), Phase(0), Phase(0), Phase(0), Phase(0), Phase(0), Phase(0), Phase(0)]
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
        SpiderType.Out,
        SpiderType.Out
    ]
    zxg = ZXCircuit(ZXDiagram(g, st, ps))
    for e in [[1, 2], [1, 3], [1, 4], [1, 5], [1, 6], [2, 5], [2, 6], [2, 7], [2, 8]]
        add_edge!(zxg, e[1], e[2])
    end
    zxg_before = copy(zxg)

    replace!(Pivot3Rule(), zxg)
    @test nv(zxg) == 16 && ne(zxg) == 28
    @test ZXCalculus.ZX.is_hadamard(zxg, 2, 15) && ZXCalculus.ZX.is_hadamard(zxg, 1, 16)
    @test check_equivalence(zxg_before, zxg; ignore_phase=true)
end
