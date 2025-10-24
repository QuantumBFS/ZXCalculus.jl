using Test
using ZXCalculus, Multigraphs, ZXCalculus.ZX, ZXCalculus.Utils, Graphs
using ZXCalculus: ZX
using ZXCalculus.Utils: Phase

function test_graph()
    zxg = ZXGraph()
    v1 = ZX.add_spider!(zxg, SpiderType.In)
    v2 = ZX.add_spider!(zxg, SpiderType.Out)
    v3 = ZX.add_spider!(zxg, SpiderType.In)
    v4 = ZX.add_spider!(zxg, SpiderType.Out)
    v5 = ZX.add_spider!(zxg, SpiderType.Z, Phase(0//1), [v1])
    v6 = ZX.add_spider!(zxg, SpiderType.Z, Phase(0//1), [v2])
    v7 = ZX.add_spider!(zxg, SpiderType.Z, Phase(0//1), [v3, v4])
    v8 = ZX.add_spider!(zxg, SpiderType.X, Phase(0//1))
    ZX.add_edge!(zxg, v5, v6, EdgeType.SIM)
    ZX.add_edge!(zxg, v5, v7, EdgeType.HAD)
    ZX.add_edge!(zxg, v6, v7, EdgeType.HAD)
    ZX.add_edge!(zxg, v7, v8, EdgeType.SIM)
    return zxg
end

@testset "FusionRule" begin
    @testset "ZXDiagram" begin
        g = Multigraph([0 2 0; 2 0 1; 0 1 0])
        collect(edges(g))
        ps = [Phase(i // 4) for i in 1:3]
        v_t = [SpiderType.Z, SpiderType.Z, SpiderType.X]
        zxd = ZXDiagram(g, v_t, ps)
        matches = match(FusionRule(), zxd)
        rewrite!(FusionRule(), zxd, matches)
        @test sort!(spiders(zxd)) == [1, 3]
        @test phase(zxd, 1) == phase(zxd, 3) == 3 // 4
        @test !isnothing(zxd)
    end

    @testset "ZXGraph" begin
        zxg = test_graph()
        ZX.add_edge!(zxg, 7, 8, EdgeType.SIM)
        @test zxg.scalar == Scalar(-2, 0 // 1)
        matches = match(FusionRule(), zxg)
        rewrite!(FusionRule(), zxg, matches)
        @test zxg.scalar == Scalar(-4, 0 // 1)
        @test nv(zxg) == 7 && ne(zxg) == 4
    end
end

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

@testset "XToZRule and HBoxRule" begin
    @testset "ZXDiagram" begin
        g = Multigraph([0 2 0; 2 0 1; 0 1 0])
        ps = [Phase(i // 4) for i in 1:3]
        v_t = [SpiderType.X, SpiderType.X, SpiderType.Z]
        zxd = ZXDiagram(g, v_t, ps)
        matches = match(XToZRule(), zxd)
        rewrite!(XToZRule(), zxd, matches)
        @test nv(zxd) == 8 && ne(zxd) == 8
        @test !isnothing(zxd)

        matches = match(HBoxRule(), zxd)
        rewrite!(HBoxRule(), zxd, matches)
        @test nv(zxd) == 4 && ne(zxd, count_mul=true) == 4 && ne(zxd) == 3
    end
    @testset "ZXGraph" begin
        zxg = test_graph()
        add_edge!(zxg, 8, 5, EdgeType.HAD)
        matches = match(XToZRule(), zxg)
        rewrite!(XToZRule(), zxg, matches)
        @test nv(zxg) == 8 && ne(zxg) == 9
        @test ZX.edge_type(zxg, 7, 8) === EdgeType.HAD
        @test ZX.edge_type(zxg, 8, 5) === EdgeType.SIM
    end
end

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
    # FIXME generate layout does not terminate
    # @test !isnothing(zxd)

    g = Multigraph([0 2 0; 2 0 1; 0 1 0])
    ps = [Phase(1), Phase(1 // 2), Phase(0)]
    v_t = [SpiderType.X, SpiderType.Z, SpiderType.In]
    zxd = ZXDiagram(g, v_t, ps)
    matches = match(PiRule(), zxd)
    rewrite!(PiRule(), zxd, matches)
    @test nv(zxd) == 4 && ne(zxd) == 3 && ne(zxd, count_mul=true) == 4
    @test zxd.scalar == Scalar(0, 1 // 2)
    @test !isnothing(zxd)
end

@testset "CopyRule" begin
    g = Multigraph(5)
    add_edge!(g, 1, 2)
    add_edge!(g, 2, 3, 2)
    add_edge!(g, 2, 4)
    add_edge!(g, 2, 5)
    ps = [Phase(0), Phase(1 // 2), Phase(0), Phase(0), Phase(0)]
    v_t = [SpiderType.X, SpiderType.Z, SpiderType.Out, SpiderType.Out, SpiderType.Out]
    zxd = ZXDiagram(g, v_t, ps)
    matches = match(CopyRule(), zxd)
    rewrite!(CopyRule(), zxd, matches)
    @test nv(zxd) == 7 && ne(zxd) == 4
    @test zxd.scalar == Scalar(-3, 0 // 1)
    # FIXME generate layout does not terminate
    # @test !isnothing(zxd)
end

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
    matches = match(BialgebraRule(), zxd)
    rewrite!(BialgebraRule(), zxd, matches)
    @test nv(zxd) == 8 && ne(zxd) == 8
    @test zxd.scalar == Scalar(1, 0 // 1)
    @test !isnothing(zxd)
end

@testset "LocalCompRule" begin
    g = Multigraph(9)
    for e in [[2, 6], [3, 7], [4, 8], [5, 9]]
        add_edge!(g, e[1], e[2])
    end
    ps = [Phase(1 // 2), Phase(0), Phase(1 // 4), Phase(1 // 2), Phase(3 // 4), Phase(0), Phase(0), Phase(0), Phase(0)]
    st = [
        SpiderType.Z,
        SpiderType.Z,
        SpiderType.Z,
        SpiderType.Z,
        SpiderType.Z,
        SpiderType.In,
        SpiderType.In,
        SpiderType.Out,
        SpiderType.Out
    ]
    zxg = ZXGraph(ZXDiagram(g, st, ps))
    for e in [[1, 2], [1, 3], [1, 4], [1, 5], [2, 3]]
        add_edge!(zxg, e[1], e[2])
    end
    replace!(LocalCompRule(), zxg)
    @test !has_edge(zxg, 2, 3) && ne(zxg) == 9
    @test phase(zxg, 2) == 3 // 2 &&
          phase(zxg, 3) == 7 // 4 &&
          phase(zxg, 4) == 0 // 1 &&
          phase(zxg, 5) == 1 // 4
    @test !isnothing(zxg)

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
    zxg = ZXGraph(ZXDiagram(g, st, ps))
    for e in [[1, 2], [1, 3], [1, 4], [1, 5], [1, 6], [2, 5], [2, 6], [2, 7], [2, 8]]
        add_edge!(zxg, e[1], e[2])
    end

    replace!(Pivot1Rule(), zxg)
    @test !has_edge(zxg, 3, 4) && !has_edge(zxg, 5, 6) && !has_edge(zxg, 7, 8)
    @test nv(zxg) == 12 && ne(zxg) == 18
    @test phase(zxg, 3) == 1 // 4 &&
          phase(zxg, 4) == 1 // 2 &&
          phase(zxg, 5) == 3 // 4 &&
          phase(zxg, 6) == 1 // 1 &&
          phase(zxg, 7) == 1 // 4 &&
          phase(zxg, 8) == 1 // 2
end

@testset "PivotBoundaryRule" begin
    g = Multigraph(6)
    for e in [[2, 6]]
        add_edge!(g, e[1], e[2])
    end
    ps = [Phase(1 // 1), Phase(1 // 4), Phase(1 // 2), Phase(3 // 4), Phase(1), Phase(0)]
    st = [SpiderType.Z, SpiderType.Z, SpiderType.Z, SpiderType.Z, SpiderType.Z, SpiderType.In]
    zxg = ZXGraph(ZXDiagram(g, st, ps))
    for e in [[1, 2], [2, 3], [1, 4], [1, 5]]
        add_edge!(zxg, e[1], e[2])
    end

    @test length(match(Pivot1Rule(), zxg)) == 1
    replace!(PivotBoundaryRule(), zxg)
    @test nv(zxg) == 7 && ne(zxg) == 6
    @test !isnothing(zxg)

    g = Multigraph(14)
    for e in [[3, 9], [4, 10], [5, 11], [6, 12], [7, 13], [8, 14]]
        add_edge!(g, e[1], e[2])
    end
    ps = [Phase(1 // 1), Phase(1 // 4), Phase(1 // 4), Phase(1 // 2), Phase(3 // 4), Phase(1),
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
    zxg = ZXGraph(ZXDiagram(g, st, ps))
    for e in [[1, 2], [1, 3], [1, 4], [1, 5], [1, 6], [2, 5], [2, 6], [2, 7], [2, 8]]
        add_edge!(zxg, e[1], e[2])
    end
    match(Pivot2Rule(), zxg)
    replace!(Pivot2Rule(), zxg)
    @test zxg.phase_ids[15] == (2, -1)
    @test !isnothing(zxg)
end

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
    zxg = ZXGraph(ZXDiagram(g, st, ps))
    for e in [[1, 2], [1, 3], [1, 4], [1, 5], [1, 6], [2, 5], [2, 6], [2, 7], [2, 8]]
        add_edge!(zxg, e[1], e[2])
    end
    replace!(Pivot3Rule(), zxg)

    @test nv(zxg) == 16 && ne(zxg) == 28
    @test ZXCalculus.ZX.is_hadamard(zxg, 2, 15) && ZXCalculus.ZX.is_hadamard(zxg, 1, 16)
    @test !isnothing(zxg)
end
