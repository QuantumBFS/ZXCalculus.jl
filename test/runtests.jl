using ZX
using Test
using LightGraphs, Multigraphs

@testset "ZX.jl" begin
    # Write your own tests here.
end

@testset "zx_diagram.jl" begin
    g = Multigraph([0 1 0; 1 0 1; 0 1 0])
    ps = [Rational(0) for i = 1:3]
    v_t = [X, Z, X]
    zxd = ZXDiagram(g, v_t, ps)
    rule_i1!(zxd, 2)
    @test nv(zxd.g) == 2 && ne(zxd, true) == 1

    rule_h!(zxd, 1)
    @test nv(zxd.g) == 3 && ne(zxd, true) == 2 && zxd.st[3] == H

    rule_h!(zxd, 2)
    @test nv(zxd) == 4 && ne(zxd, true) == 3 && zxd.st[2] == Z && zxd.st[4] == H

    add_edge!(zxd.g, [1, 2])
    zxd
    rule_f!(zxd, 1, 2)
    @test nv(zxd) == 3 && ne(zxd, true) == 3

    rule_i2!(zxd, 2, 3)
    @test nv(zxd) == 1 && ne(zxd, true) == 0

    g = Multigraph(6)
    for e in [[1,2], [2,3], [3,4], [3,5], [3,6]]
        add_edge!(g, e)
    end
    ps = [0, 1, 1//4, 0, 0, 0]
    v_t = [In, X, Z, Out, Out, Out]
    zxd = ZXDiagram(g, v_t, ps)
    rule_pi!(zxd, 2, 3)
    @test nv(zxd) == 8 && ne(zxd, true) == 7 && zxd.ps[2] == -1//4

    g = Multigraph(5)
    for e in [[1,2], [2,3], [2,4], [2,5]]
        add_edge!(g, e)
    end
    ps = [0, 1//4, 0, 0, 0]
    v_t = [X, Z, Out, Out, Out]
    zxd = ZXDiagram(g, v_t, ps)
    rule_c!(zxd, 1, 2)
    @test nv(zxd) == 6 && ne(zxd, true) == 3

    g = Multigraph(6)
    for e in [[1,3],[2,3],[3,4],[4,5],[4,6]]
        add_edge!(g, e)
    end
    ps = [0, 0, 0//1, 0//1, 0, 0]
    v_t = [In, In, X, Z, Out, Out]
    zxd = ZXDiagram(g, v_t, ps)
    rule_b!(zxd, 4, 3)
    @test nv(zxd) == 8 && ne(zxd, true) == 8 && zxd.st[5] == X && zxd.st[7] == Z
end

@testset "zx_graph.jl" begin
    g = Multigraph([0 1 0; 1 0 1; 0 1 0])
    ps = [Rational(0) for i = 1:3]
    v_t = [X, Z, X]
    zxd = ZXDiagram(g, v_t, ps)

    zxd1 = ZXGraph(zxd)

    rule_i1!(zxd, 2)
    @test nv(zxd.g) == 2 && ne(zxd, true) == 1

    rule_h!(zxd, 1)
    @test nv(zxd.g) == 3 && ne(zxd, true) == 2 && zxd.st[3] == H

    rule_h!(zxd, 2)
    @test nv(zxd) == 4 && ne(zxd, true) == 3 && zxd.st[2] == Z && zxd.st[4] == H

    zxd2 = ZXGraph(zxd)

    add_edge!(zxd.g, [1, 2])
    zxd
    ZXGraph(zxd)
    rule_f!(zxd, 1, 2)
    @test nv(zxd) == 3 && ne(zxd, true) == 3

    rule_i2!(zxd, 2, 3)
    @test nv(zxd) == 1 && ne(zxd, true) == 0
    ZXGraph(zxd)

    g = Multigraph(6)
    for e in [[1,2], [2,3], [3,4], [3,5], [3,6]]
        add_edge!(g, e)
    end
    ps = [0, 1, 1//4, 0, 0, 0]
    v_t = [In, X, Z, Out, Out, Out]
    zxd = ZXDiagram(g, v_t, ps)
    ZXGraph(zxd)
    rule_pi!(zxd, 2, 3)
    @test nv(zxd) == 8 && ne(zxd, true) == 7 && zxd.ps[2] == -1//4
    ZXGraph(zxd)

    g = Multigraph(5)
    for e in [[1,2], [2,3], [2,4], [2,5]]
        add_edge!(g, e)
    end
    ps = [0, 1//4, 0, 0, 0]
    v_t = [X, Z, Out, Out, Out]
    zxd = ZXDiagram(g, v_t, ps)
    rule_c!(zxd, 1, 2)
    @test nv(zxd) == 6 && ne(zxd, true) == 3

    g = Multigraph(6)
    for e in [[1,3],[2,3],[3,4],[4,5],[4,6]]
        add_edge!(g, e)
    end
    ps = [0, 0, 0//1, 0//1, 0, 0]
    v_t = [In, In, X, Z, Out, Out]
    zxd = ZXDiagram(g, v_t, ps)
    rule_b!(zxd, 4, 3)
    @test nv(zxd) == 8 && ne(zxd, true) == 8 && zxd.st[5] == X && zxd.st[7] == Z

    zxd
    ZXGraph(zxd)

    g = Multigraph(5)
    for e in [[1,2],[2,3],[2,4],[3,4],[4,3],[4,5]]
        add_edge!(g, e)
    end
    ps = [0, 1//2, 1//4, 1//4, 0]
    v_t = [In, X, Z, Z, Out]
    zxd = ZXDiagram(g, v_t, ps)

    zxg = ZXGraph(zxd)

    zxg.mg
    mg.eprops

    d = mg.vprops[1]
end
