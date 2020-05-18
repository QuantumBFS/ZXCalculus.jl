using ZX
using Test
using LightGraphs

# @testset "ZX.jl" begin
#     # Write your own tests here.
# end

@testset "zx_plot.jl" begin
    include("../script/zx_plot.jl")
    g = Multigraph(6)
    for e in [[1,3],[2,3],[3,4],[4,5],[4,6]]
        add_edge!(g, e)
    end
    ps = [0, 0, 0//1, 2//1, 0, 0]
    v_t = [In, Out, X, Z, Out, In]
    zxd = ZXDiagram(g, v_t, ps)
    ZXplot(zxd)

    # rule_b!(zxd, 4, 3)
    # ZXplot(zxd)
end

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
