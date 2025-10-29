using Test
using ZXCalculus, Multigraphs, ZXCalculus.ZX, ZXCalculus.Utils, Graphs
using ZXCalculus: ZX
using ZXCalculus.Utils: Phase

@testset "Identity1Rule" begin
    g = Multigraph(path_graph(5))
    add_edge!(g, 1, 2)
    ps = [Phase(1), Phase(3 // 1), Phase(0), Phase(0), Phase(1)]
    v_t = [SpiderType.X, SpiderType.X, SpiderType.Z, SpiderType.Z, SpiderType.Z]
    zxd = ZXDiagram(g, v_t, ps)
    matches = match(Identity1Rule(), zxd)
    rewrite!(Identity1Rule(), zxd, matches)
    @test nv(zxd) == 3 && ne(zxd, count_mul=true) == 3 && ne(zxd) == 2
    @test !isnothing(zxd)
end
