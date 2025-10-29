using Test
using ZXCalculus, Multigraphs, ZXCalculus.ZX, ZXCalculus.Utils, Graphs
using ZXCalculus: ZX
using ZXCalculus.Utils: Phase

@testset "PiRule" begin
    g = Multigraph(6)
    add_edge!(g, 1, 2)
    add_edge!(g, 2, 3)
    add_edge!(g, 3, 4)
    add_edge!(g, 3, 5)
    add_edge!(g, 3, 6)
    ps = [Phase(0), Phase(1), Phase(1 // 2), Phase(0), Phase(0), Phase(0)]
    v_t = [
        SpiderType.In,
        SpiderType.X,
        SpiderType.Z,
        SpiderType.Out,
        SpiderType.Out,
        SpiderType.Out
    ]
    zxd = ZXDiagram(g, v_t, ps)
    matches = match(PiRule(), zxd)
    rewrite!(PiRule(), zxd, matches)
    @test nv(zxd) == 8 && ne(zxd) == 7
    @test zxd.scalar == Scalar(0, 1 // 2)

    g = Multigraph([0 2 0; 2 0 1; 0 1 0])
    ps = [Phase(1), Phase(1 // 2), Phase(0)]
    v_t = [SpiderType.X, SpiderType.Z, SpiderType.In]
    zxd = ZXDiagram(g, v_t, ps)
    matches = match(PiRule(), zxd)
    rewrite!(PiRule(), zxd, matches)
    @test nv(zxd) == 4 && ne(zxd) == 3 && ne(zxd, count_mul=true) == 4
    @test zxd.scalar == Scalar(0, 1 // 2)
end
