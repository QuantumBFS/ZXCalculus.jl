using ZX
using Test
using LightGraphs

# include("../script/zx_plot.jl")

# @testset "zx_plot.jl" begin
#     include("../script/zx_plot.jl")
#     g = Multigraph(6)
#     for e in [[1,3],[2,3],[3,4],[4,5],[4,6]]
#         add_edge!(g, e)
#     end
#     ps = [0, 0, 0//1, 2//1, 0, 0]
#     v_t = [In, Out, X, Z, Out, In]
#     zxd = ZXDiagram(g, v_t, ps)
#     ZXplot(zxd)
#
#     # Rule{:b}!(zxd, 4, 3)
#     # ZXplot(zxd)
# end

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

@testset "rules.jl" begin
    g = Multigraph([0 2 0; 2 0 1; 0 1 0])
    collect(edges(g))
    ps = [i//4 for i = 1:3]
    v_t = [Z, Z, X]
    zxd = ZXDiagram(g, v_t, ps)
    matches = match(Rule{:f}(), zxd)
    rewrite!(Rule{:f}(), zxd, matches)
    @test spiders(zxd) == [1, 3]
    @test phase(zxd, 1) == phase(zxd, 3) == 3//4

    g = Multigraph(path_graph(5))
    add_edge!(g, 1, 2)
    ps = [1, 0//1, 0, 0, 1]
    v_t = [X, X, Z, Z, Z]
    zxd = ZXDiagram(g, v_t, ps)
    matches = match(Rule{:i1}(), zxd)
    rewrite!(Rule{:i1}(), zxd, matches)
    @test nv(zxd) == 3 && ne(zxd, count_mul = true) == 3 && ne(zxd) == 2

    g = Multigraph([0 2 0; 2 0 1; 0 1 0])
    ps = [i//4 for i = 1:3]
    v_t = [X, X, Z]
    zxd = ZXDiagram(g, v_t, ps)
    matches = match(Rule{:h}(), zxd)
    rewrite!(Rule{:h}(), zxd, matches)
    @test nv(zxd) == 8 && ne(zxd) == 8

    matches = match(Rule{:i2}(), zxd)
    rewrite!(Rule{:i2}(), zxd, matches)
    @test nv(zxd) == 4 && ne(zxd, count_mul = true) == 4 && ne(zxd) == 3

    g = Multigraph(6)
    add_edge!(g, 1, 2)
    add_edge!(g, 2, 3)
    add_edge!(g, 3, 4)
    add_edge!(g, 3, 5)
    add_edge!(g, 3, 6)
    ps = [0, 1, 1//2, 0, 0, 0]
    v_t = [In, X, Z, Out, Out, Out]
    zxd = ZXDiagram(g, v_t, ps)
    matches = match(Rule{:pi}(), zxd)
    rewrite!(Rule{:pi}(), zxd, matches)
    @test nv(zxd) == 8 && ne(zxd) == 7

    g = Multigraph([0 2 0; 2 0 1; 0 1 0])
    ps = [1, 1//2, 0]
    v_t = [X, Z, In]
    zxd = ZXDiagram(g, v_t, ps)
    matches = match(Rule{:pi}(), zxd)
    rewrite!(Rule{:pi}(), zxd, matches)
    @test nv(zxd) == 4 && ne(zxd) == 3 && ne(zxd, count_mul = true) == 4

    g = Multigraph(5)
    add_edge!(g, 1, 2)
    add_edge!(g, 2, 3, 2)
    add_edge!(g, 2, 4)
    add_edge!(g, 2, 5)
    ps = [0, 1//2, 0, 0, 0]
    v_t = [X, Z, Out, Out, Out]
    zxd = ZXDiagram(g, v_t, ps)
    matches = match(Rule{:c}(), zxd)
    rewrite!(Rule{:c}(), zxd, matches)
    @test nv(zxd) == 7 && ne(zxd) == 4

    g = Multigraph(6)
    add_edge!(g, 1, 3)
    add_edge!(g, 2, 4)
    add_edge!(g, 3, 4)
    add_edge!(g, 3, 5)
    add_edge!(g, 4, 6)
    ps = [0//1 for i = 1:6]
    v_t = [In, In, X, Z, Out, Out]
    zxd = ZXDiagram(g, v_t, ps)
    matches = match(Rule{:b}(), zxd)
    rewrite!(Rule{:b}(), zxd, matches)
    @test nv(zxd) == 8 && ne(zxd) == 8
end

@testset "zx_graph.jl" begin
    g = Multigraph(6)
    add_edge!(g, 1, 3)
    add_edge!(g, 2, 4)
    add_edge!(g, 3, 4)
    add_edge!(g, 3, 5)
    add_edge!(g, 4, 6)
    ps = [0//1 for i = 1:6]
    v_t = [In, In, X, Z, Out, Out]
    zxd = ZXDiagram(g, v_t, ps)
    zxg1 = ZXGraph(zxd)
    @test !ZX.is_hadamard(zxg1, 2, 4) && !ZX.is_hadamard(zxg1, 4, 6)
    matches = match(Rule{:b}(), zxd)
    rewrite!(Rule{:b}(), zxd, matches)
    zxg2 = ZXGraph(zxd)
    @test !ZX.is_hadamard(zxg2, 5, 8) && !ZX.is_hadamard(zxg2, 1, 7)
end
