@testset "ZWDiagrm Creation" begin
    zx1 = ZWDiagram(1)
    pmg1 = PlanarMultigraph(
        Dict([1 => 1, 2 => 2]),
        Dict([1 => HalfEdge(1, 2), 2 => HalfEdge(2, 1)]),
        Dict(0 => 1),
        Dict(1 => 0, 2 => 0),
        Dict(1 => 2, 2 => 1),
        Dict(1 => 2, 2 => 1),
        2,
        2,
        0,
        [0],
    )


    @test zx1.st == Dict([1 => ZW.Input(1), 2 => ZW.Output(1)])
    @test zx1.inputs == [1]
    @test zx1.outputs == [2]
    @test zx1.pmg == pmg1
    @test zx1.scalar == Scalar{Rational}()

    zx2 = ZWDiagram(2, Float64)
    pmg2 = PlanarMultigraph(
        Dict([1 => 1, 2 => 2, 3 => 3, 4 => 4]),
        Dict([
            1 => HalfEdge(1, 2),
            2 => HalfEdge(2, 1),
            3 => HalfEdge(3, 4),
            4 => HalfEdge(4, 3),
            5 => HalfEdge(3, 1),
            6 => HalfEdge(1, 3),
            7 => HalfEdge(4, 2),
            8 => HalfEdge(2, 4),
        ]),
        Dict([0 => 2, 1 => 1]),
        Dict([1 => 1, 8 => 1, 4 => 1, 5 => 1, 2 => 0, 3 => 0, 6 => 0, 7 => 0]),
        Dict([1 => 8, 8 => 4, 4 => 5, 5 => 1, 2 => 6, 6 => 3, 3 => 7, 7 => 2]),
        Dict([1 => 2, 2 => 1, 3 => 4, 4 => 3, 5 => 6, 6 => 5, 7 => 8, 8 => 7]),
        4,
        8,
        1,
        [0],
    )

    @test zx2.st == Dict([1 => ZW.Input(1), 2 => ZW.Output(1), 3 => ZW.Input(2), 4 => ZW.Output(2)])
    @test zx2.inputs == [1, 3]
    @test zx2.outputs == [2, 4]
    @test zx2.pmg == pmg2
    @test zx2.pmg.half_edges == pmg2.half_edges
    @test zx2.scalar == Scalar{Float64}()

    zx3 = ZWDiagram(3)

    pmg3 = PlanarMultigraph(
        Dict([1 => 1, 2 => 2, 3 => 3, 4 => 4, 5 => 5, 6 => 6]),
        Dict([
            1 => HalfEdge(1, 2),
            2 => HalfEdge(2, 1),
            3 => HalfEdge(3, 4),
            4 => HalfEdge(4, 3),
            5 => HalfEdge(5, 6),
            6 => HalfEdge(6, 5),
            7 => HalfEdge(3, 1),
            8 => HalfEdge(1, 3),
            9 => HalfEdge(5, 3),
            10 => HalfEdge(3, 5),
            11 => HalfEdge(4, 2),
            12 => HalfEdge(2, 4),
            13 => HalfEdge(6, 4),
            14 => HalfEdge(4, 6),
        ]),
        Dict([0 => 2, 1 => 1, 2 => 3]),
        Dict([
            1 => 1,
            12 => 1,
            4 => 1,
            7 => 1,
            3 => 2,
            14 => 2,
            6 => 2,
            9 => 2,
            2 => 0,
            5 => 0,
            8 => 0,
            11 => 0,
            10 => 0,
            13 => 0,
        ]),
        Dict([
            1 => 12,
            12 => 4,
            4 => 7,
            7 => 1,
            3 => 14,
            14 => 6,
            6 => 9,
            9 => 3,
            2 => 8,
            8 => 10,
            10 => 5,
            5 => 13,
            13 => 11,
            11 => 2,
        ]),
        Dict([
            1 => 2,
            2 => 1,
            3 => 4,
            4 => 3,
            5 => 6,
            6 => 5,
            7 => 8,
            8 => 7,
            9 => 10,
            10 => 9,
            11 => 12,
            12 => 11,
            13 => 14,
            14 => 13,
        ]),
        6,
        14,
        2,
        [0],
    )

    @test zx3.st == Dict([
        1 => ZW.Input(1),
        2 => ZW.Output(1),
        3 => ZW.Input(2),
        4 => ZW.Output(2),
        5 => ZW.Input(3),
        6 => ZW.Output(3),
    ])
    @test zx3.inputs == [1, 3, 5]
    @test zx3.outputs == [2, 4, 6]
    @test zx3.pmg == pmg3
    @test zx3.pmg.half_edges == pmg3.half_edges
end
