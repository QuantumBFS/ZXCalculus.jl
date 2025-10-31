using Test
using ZXCalculus, Multigraphs, ZXCalculus.ZX, ZXCalculus.Utils, Graphs
using ZXCalculus: ZX
using ZXCalculus.Utils: Phase

@testset "BialgebraRule" begin
    g = Multigraph(6)
    add_edge!(g, 1, 3)
    add_edge!(g, 2, 4)
    add_edge!(g, 3, 4)
    add_edge!(g, 3, 5)
    add_edge!(g, 4, 6)
    ps = [Phase(0 // 1) for i in 1:6]
    v_t = [
        SpiderType.In,
        SpiderType.In,
        SpiderType.X,
        SpiderType.Z,
        SpiderType.Out,
        SpiderType.Out
    ]
    layout = ZXCalculus.ZX.ZXLayout(
        2,
        Dict(zip(1:6, [1 // 1, 2, 1, 2, 1, 2])),
        Dict(zip(1:6, [1 // 1, 1, 2, 2, 3, 3]))
    )
    zxd = ZXDiagram(g, v_t, ps, layout)
    zxd_before = copy(zxd)
    matches = match(BialgebraRule(), zxd)
    rewrite!(BialgebraRule(), zxd, matches)
    @test nv(zxd) == 8 && ne(zxd) == 8
    @test zxd.scalar == Scalar(1, 0 // 1)
    @test check_equivalence(zxd_before, zxd)
end
