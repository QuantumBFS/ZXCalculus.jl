using ZXCalculus
using LightGraphs, SparseArrays
using Test

@testset "multiple_edge.jl" begin
    me = MultipleEdge(1, 2, 3)
    try
        MultipleEdge(1, 2, 0)
    catch err
        @test err != nothing
    end
    @test src(me) == 1 && dst(me) == 2 && mul(me) == 3
    e0 = LightGraphs.SimpleEdge(me)
    MultipleEdge(e0)
    @test MultipleEdge(1, 2) == e0
    @test e0 == MultipleEdge(1, 2)
    @test e0 == MultipleEdge([1, 2])
    @test e0 == MultipleEdge([1, 2, 1])
    @test e0 == MultipleEdge((1, 2))
    @test e0 == MultipleEdge((1, 2, 1))
    @test e0 == MultipleEdge(1 => 2)
    @test reverse(me) == MultipleEdge(2, 1, 3)
    @test eltype(me) == Int

    @test iterate(me)[2] == 2
    @test [e0 == e for e in me] == [true for i = 1:mul(me)]
    @test Tuple(me) == (1,2,3)
    length(me) == mul(me)
end

@testset "multigraph_adjlist.jl" begin
    try
        m2 = spzeros(Int, 2, 3)
        dg = Multigraph(m2)
    catch e
        @test e != nothing
    end
    try
        m2 = spzeros(Int, 2, 2)
        m2[1, 2] = 2
        dg = Multigraph(m2)
    catch e
        @test e != nothing
    end
    try
        m2 = spzeros(Int, 2, 2)
        m2[1, 2] = -1
        m2[2, 1] = -1
        dg = Multigraph(m2)
    catch e
        @test e != nothing
    end

    m = spzeros(Int, 4, 4)
    m
    m[1,2] = 2
    m[2,1] = 2
    m[2,3] = 2
    m[3,2] = 2
    m[3,4] += 1
    m[3,4] = 0
    m[4,3] += 1
    m[4,3] = 0
    g = Multigraph(m)
    g = Multigraph(Matrix(m))

    g0 = Multigraph(2)
    @test !add_edge!(g0, 2, 3) && !rem_edge!(g0, 1, 2)
    g1 = Multigraph(path_graph(3))

    @test !is_directed(g)
    @test edgetype(g) == MultipleEdge{Int, Int}
    @test size(adjacency_matrix(g), 1) == 4

    @test nv(g) == 4 && ne(g, count_mul = true) == 4 && ne(g) == 2

    add_vertices!(g, 3)
    @test nv(g) == 7

    @test has_edge(g, 1, 2, 2)
    @test rem_vertices!(g, [7, 5, 4, 6])
    add_edge!(g, [2, 3, 2])
    rem_edge!(g, [2, 3, 2])
    add_edge!(g, 2, 3)
    rem_edge!(g, 2, 3)
    add_edge!(g, 2, 3, 2)
    rem_edge!(g, 2, 3, 1)

    @test has_edge(g, 2, 3) && has_edge(g, [2, 3])
    @test has_edge(g, 2, 3, 2) && has_edge(g, (2, 3, 2))
    @test !has_edge(g, 2, 2) && !has_edge(g, 2, 5)
    @test has_vertex(g, 1) && !has_vertex(g, 5)
    for v in vertices(g)
        @test inneighbors(g, v) == outneighbors(g, v)
        @test degree(g, v) == indegree(g, v) && indegree(g, v) == outdegree(g, v)
    end
    add_vertex!(g)
    @test indegree(g) == outdegree(g)
end

@testset "multiple_edge_iter.jl" begin
    mg = Multigraph(3)
    add_vertices!(mg, 3)
    rem_vertices!(mg, [1, 3])
    add_edge!(mg, 2, 5)
    add_edge!(mg, 2, 4, 2)

    @test outneighbors(mg, 2) == [4, 5]
    eit = edges(mg)
    @test iterate(eit)[2] == (1, 2)
    mes = [me for me in edges(mg)]
    @test length(mes) == length(eit)
end

# include("../script/zx_plot.jl")

# @testset "zx_plot.jl" begin
#     include("../script/zx_plot.jl")
#     g = Multigraph(6)
#     for e in [[1,3],[2,3],[3,4],[4,5],[4,6]]
#         add_edge!(g, e)
#     end
#     ps = [0, 0, 0//1, 2//1, 0, 0]
#     v_t = [SpiderType.In, SpiderType.Out, SpiderType.X, SpiderType.Z, SpiderType.Out, SpiderType.In]
#     zxd = ZXDiagram(g, v_t, ps)
#     ZXplot(zxd)
#
#     # Rule{:b}!(zxd, 4, 3)
#     # ZXplot(zxd)
# end

@testset "zx_diagram.jl" begin
    g = Multigraph([0 1 0; 1 0 1; 0 1 0])
    ps = [Rational(0) for i = 1:3]
    v_t = [SpiderType.X, SpiderType.Z, SpiderType.X]
    zxd = ZXDiagram(g, v_t, ps)
    zxd2 = ZXDiagram(g, Dict(zip(1:3,v_t)), Dict(zip(1:3,ps)))
    @test zxd.mg == zxd2.mg && zxd.st == zxd2.st && zxd.ps == zxd2.ps

    zxd2 = copy(zxd)
    @test zxd.st == zxd2.st && zxd.ps == zxd2.ps
    @test ZXCalculus.spider_type(zxd, 1) == SpiderType.X
    @test nv(zxd) == 3 && ne(zxd) == 2

    @test rem_edge!(zxd, 2, 3)
    @test outneighbors(zxd, 2) == inneighbors(zxd, 2)

    ZXCalculus.add_spider!(zxd, SpiderType.H, 0//1, [2, 3])
    ZXCalculus.insert_spider!(zxd, 2, 4, SpiderType.H)
    @test nv(zxd) == 5 && ne(zxd) == 4

    zxd3 = ZXDiagram(3)
    ZXCalculus.insert_spider!(zxd3, 1, 2, SpiderType.H)
    pushfirst_gate!(zxd3, Val{:SWAP}(), [1, 2])
    push_gate!(zxd3, Val{:SWAP}(), [2, 3])
    @test ZXCalculus.qubit_loc(zxd3, 1) == ZXCalculus.qubit_loc(zxd3, 2) == ZXCalculus.qubit_loc(zxd3, 7)
end

@testset "rules.jl" begin
    g = Multigraph([0 2 0; 2 0 1; 0 1 0])
    collect(edges(g))
    ps = [i//4 for i = 1:3]
    v_t = [SpiderType.Z, SpiderType.Z, SpiderType.X]
    zxd = ZXDiagram(g, v_t, ps)
    matches = match(Rule{:f}(), zxd)
    rewrite!(Rule{:f}(), zxd, matches)
    @test spiders(zxd) == [1, 3]
    @test phase(zxd, 1) == phase(zxd, 3) == 3//4

    g = Multigraph(path_graph(5))
    add_edge!(g, 1, 2)
    ps = [1, 0//1, 0, 0, 1]
    v_t = [SpiderType.X, SpiderType.X, SpiderType.Z, SpiderType.Z, SpiderType.Z]
    zxd = ZXDiagram(g, v_t, ps)
    matches = match(Rule{:i1}(), zxd)
    rewrite!(Rule{:i1}(), zxd, matches)
    @test nv(zxd) == 3 && ne(zxd, count_mul = true) == 3 && ne(zxd) == 2

    g = Multigraph([0 2 0; 2 0 1; 0 1 0])
    ps = [i//4 for i = 1:3]
    v_t = [SpiderType.X, SpiderType.X, SpiderType.Z]
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
    v_t = [SpiderType.In, SpiderType.X, SpiderType.Z, SpiderType.Out, SpiderType.Out, SpiderType.Out]
    zxd = ZXDiagram(g, v_t, ps)
    matches = match(Rule{:pi}(), zxd)
    rewrite!(Rule{:pi}(), zxd, matches)
    @test nv(zxd) == 8 && ne(zxd) == 7

    g = Multigraph([0 2 0; 2 0 1; 0 1 0])
    ps = [1, 1//2, 0]
    v_t = [SpiderType.X, SpiderType.Z, SpiderType.In]
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
    v_t = [SpiderType.X, SpiderType.Z, SpiderType.Out, SpiderType.Out, SpiderType.Out]
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
    v_t = [SpiderType.In, SpiderType.In, SpiderType.X, SpiderType.Z, SpiderType.Out, SpiderType.Out]
    layout = ZXCalculus.ZXLayout(2, [[1,3,5],[2,4,6]])
    zxd = ZXDiagram(g, v_t, ps, layout)
    matches = match(Rule{:b}(), zxd)
    rewrite!(Rule{:b}(), zxd, matches)
    @test zxd.layout.spider_seq == [[1, 7, 8, 5], [2, 9, 10, 6]]
    @test nv(zxd) == 8 && ne(zxd) == 8

    g = Multigraph(9)
    for e in [[2,6],[3,7],[4,8],[5,9]]
        add_edge!(g, e[1], e[2])
    end
    ps = [1//2, 0, 1//4, 1//2, 3//4, 0, 0, 0, 0]
    st = [SpiderType.Z, SpiderType.Z, SpiderType.Z, SpiderType.Z, SpiderType.Z, SpiderType.In, SpiderType.In, SpiderType.Out, SpiderType.Out]
    zxg = ZXGraph(ZXDiagram(g, st, ps))
    for e in [[1,2],[1,3],[1,4],[1,5],[2,3]]
        add_edge!(zxg, e[1], e[2])
    end
    replace!(Rule{:lc}(), zxg)
    @test !has_edge(zxg, 2, 3) && ne(zxg) == 9
    @test phase(zxg, 2) == 3//2 && phase(zxg, 3) == 7//4 && phase(zxg, 4) == 0//1 && phase(zxg, 5) == 1//4

    g = Multigraph(14)
    for e in [[3,9],[4,10],[5,11],[6,12],[7,13],[8,14]]
        add_edge!(g, e[1], e[2])
    end
    ps = [1//1, 0, 1//4, 1//2, 3//4, 1, 5//4, 3//2, 0, 0, 0, 0, 0, 0]
    st = [SpiderType.Z, SpiderType.Z, SpiderType.Z, SpiderType.Z, SpiderType.Z, SpiderType.Z, SpiderType.Z, SpiderType.Z, SpiderType.In, SpiderType.Out, SpiderType.In, SpiderType.Out, SpiderType.In, SpiderType.Out]
    zxg = ZXGraph(ZXDiagram(g, st, ps))
    for e in [[1,2],[1,3],[1,4],[1,5],[1,6],[2,5],[2,6],[2,7],[2,8]]
        add_edge!(zxg, e[1], e[2])
    end

    replace!(Rule{:p1}(), zxg)
    @test !has_edge(zxg, 3, 4) && !has_edge(zxg, 5, 6) && !has_edge(zxg, 7, 8)
    @test nv(zxg) == 12 && ne(zxg) == 18
    @test phase(zxg, 3) == 1//4 && phase(zxg, 4) == 1//2 && phase(zxg, 5) == 3//4 && phase(zxg, 6) == 1//1 && phase(zxg, 7) == 1//4 && phase(zxg, 8) == 1//2

    g = Multigraph(6)
    for e in [[2,6]]
        add_edge!(g, e[1], e[2])
    end
    ps = [1//1, 1//4, 1//2, 3//4, 1, 0]
    st = [SpiderType.Z, SpiderType.Z, SpiderType.Z, SpiderType.Z, SpiderType.Z, SpiderType.In]
    zxg = ZXGraph(ZXDiagram(g, st, ps))
    for e in [[1,2],[2,3],[1,4],[1,5]]
        add_edge!(zxg, e[1], e[2])
    end

    @test length(match(Rule{:p1}(), zxg)) == 1
    replace!(Rule{:pab}(), zxg)
    @test nv(zxg) == 6 && ne(zxg) == 6

    g = Multigraph(14)
    for e in [[3,9],[4,10],[5,11],[6,12],[7,13],[8,14]]
        add_edge!(g, e[1], e[2])
    end
    ps = [1//1, 1//4, 1//4, 1//2, 3//4, 1, 5//4, 3//2, 0, 0, 0, 0, 0, 0]
    st = [SpiderType.Z, SpiderType.Z, SpiderType.Z, SpiderType.Z, SpiderType.Z, SpiderType.Z, SpiderType.Z, SpiderType.Z, SpiderType.In, SpiderType.Out, SpiderType.In, SpiderType.Out, SpiderType.In, SpiderType.Out]
    zxg = ZXGraph(ZXDiagram(g, st, ps))
    for e in [[1,2],[1,3],[1,4],[1,5],[1,6],[2,5],[2,6],[2,7],[2,8]]
        add_edge!(zxg, e[1], e[2])
    end
    replace!(Rule{:p2}(), zxg)
    @test zxg.phase_ids[16] == [(2, -1)]

    g = Multigraph(15)
    for e in [[3,9],[4,10],[5,11],[6,12],[7,13],[8,14],[2,15]]
        add_edge!(g, e[1], e[2])
    end
    ps = [1//1, 1//4, 1//2, 1//2, 3//2, 1, 1//2, 3//2, 0, 0, 0, 0, 0, 0, 0, 0]
    st = [SpiderType.Z, SpiderType.Z, SpiderType.Z, SpiderType.Z, SpiderType.Z, SpiderType.Z, SpiderType.Z, SpiderType.Z, SpiderType.In, SpiderType.Out, SpiderType.In, SpiderType.Out, SpiderType.In, SpiderType.Out, SpiderType.Out]
    zxg = ZXGraph(ZXDiagram(g, st, ps))
    for e in [[1,2],[1,3],[1,4],[1,5],[1,6],[2,5],[2,6],[2,7],[2,8]]
        add_edge!(zxg, e[1], e[2])
    end
    replace!(Rule{:p3}(), zxg)

    @test nv(zxg) == 16 && ne(zxg) == 28
    @test ZXCalculus.is_hadamard(zxg, 2, 15) && ZXCalculus.is_hadamard(zxg, 1, 16)
end

@testset "zx_graph.jl" begin
    g = Multigraph(6)
    add_edge!(g, 1, 3)
    add_edge!(g, 2, 4)
    add_edge!(g, 3, 4)
    add_edge!(g, 3, 5)
    add_edge!(g, 4, 6)
    ps = [0//1 for i = 1:6]
    v_t = [SpiderType.In, SpiderType.In, SpiderType.X, SpiderType.Z, SpiderType.Out, SpiderType.Out]
    zxd = ZXDiagram(g, v_t, ps)
    zxg1 = ZXGraph(zxd)
    @test outneighbors(zxg1, 1) == inneighbors(zxg1, 1)
    @test !ZXCalculus.is_hadamard(zxg1, 2, 4) && !ZXCalculus.is_hadamard(zxg1, 4, 6)
    @test add_edge!(zxg1, 1, 1)
    @test !add_edge!(zxg1, 2, 4)
    @test !add_edge!(zxg1, 7, 8)
    @test [ZXCalculus.is_hadamard(e) for e in edges(zxg1.mg)] == [mul(e) == 2 for e in edges(zxg1.mg)]
        ZXplot(zxg1)
        replace!(Rule{:b}(), zxd)
        zxg2 = ZXGraph(zxd)
        @test !ZXCalculus.is_hadamard(zxg2, 5, 8) && !ZXCalculus.is_hadamard(zxg2, 1, 7)
end

@testset "circuit_extraction.jl" begin
    zxd = ZXDiagram(4)
    push_gate!(zxd, Val{:Z}(), 1, 3//2)
    push_gate!(zxd, Val{:H}(), 1)
    push_gate!(zxd, Val{:Z}(), 1, 1//2)
    push_gate!(zxd, Val{:Z}(), 2, 1//2)
    push_gate!(zxd, Val{:H}(), 4)
    push_ctrl_gate!(zxd, Val{:CNOT}(), 3, 2)
    push_ctrl_gate!(zxd, Val{:CZ}(), 4, 1)
    push_gate!(zxd, Val{:H}(), 2)
    push_ctrl_gate!(zxd, Val{:CNOT}(), 3, 2)
    push_ctrl_gate!(zxd, Val{:CNOT}(), 1, 4)
    push_gate!(zxd, Val{:H}(), 1)
    push_gate!(zxd, Val{:Z}(), 2, 1//4)
    push_gate!(zxd, Val{:Z}(), 3, 1//2)
    push_gate!(zxd, Val{:H}(), 4)
    push_gate!(zxd, Val{:Z}(), 1, 1//4)
    push_gate!(zxd, Val{:H}(), 2)
    push_gate!(zxd, Val{:H}(), 3)
    push_gate!(zxd, Val{:Z}(), 4, 3//2)
    push_gate!(zxd, Val{:Z}(), 3, 1//2)
    push_gate!(zxd, Val{:X}(), 4, 1//1)
    push_ctrl_gate!(zxd, Val{:CNOT}(), 3, 2)
    push_gate!(zxd, Val{:H}(), 1)
    push_gate!(zxd, Val{:Z}(), 4, 1//2)
    push_gate!(zxd, Val{:X}(), 4, 1//1)

    zxg = ZXGraph(zxd)
    replace!(Rule{:lc}(), zxg)
    replace!(Rule{:pab}(), zxg)

    cir = circuit_extraction(zxg)
    @test nv(cir) == 31 && ne(cir) == 31
end
