using ZX
using Test
using LightGraphs

@testset "zx_diagram.jl" begin
    g = Multigraph([0 1 0; 1 0 1; 0 1 0])
    ps = [Rational(0) for i = 1:3]
    v_t = [X, Z, X]
    zxd = ZXDiagram(g, v_t, ps)
    zxd2 = ZXDiagram(g, Dict(zip(1:3,v_t)), Dict(zip(1:3,ps)))
    @test zxd.mg == zxd2.mg && zxd.st == zxd2.st && zxd.ps == zxd2.ps

    zxd2 = copy(zxd)
    @test zxd.st == zxd2.st && zxd.ps == zxd2.ps
    @test ZX.spider_type(zxd, 1) == X
    @test nv(zxd) == 3 && ne(zxd) == 2

    @test rem_edge!(zxd, 2, 3)
    @test outneighbors(zxd, 2) == [1]

    ZX.add_spider!(zxd, H, 0//1, [2, 3])
    ZX.insert_spider!(zxd, 2, 4, H)
    @test nv(zxd) == 5 && ne(zxd) == 4
end
