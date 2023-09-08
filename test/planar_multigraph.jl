using ZXCalculus:
    create_vertex!, create_edge!, split_vertex!, split_facet!, join_facet!, join_vertex!

@testset "Half edge constructor" begin

    he1 = HalfEdge(1, 2)
    ophe1 = HalfEdge(2, 1)

    he2, ophe2 = new_edge(1, 2)
    @test he2 == he1
    @test ophe2 == ophe1
end

@testset "Facet Split/Join" begin
    pmg1 = PlanarMultigraph(
        # v2he
        Dict(1 => 1, 2 => 3, 3 => 5, 4 => 7, 5 => 9, 6 => 11),
        # hes
        Dict(
            1 => HalfEdge(1, 2),
            2 => HalfEdge(2, 1),
            3 => HalfEdge(2, 3),
            4 => HalfEdge(3, 2),
            5 => HalfEdge(3, 4),
            6 => HalfEdge(4, 3),
            7 => HalfEdge(4, 5),
            8 => HalfEdge(5, 4),
            9 => HalfEdge(5, 6),
            10 => HalfEdge(6, 5),
            11 => HalfEdge(6, 1),
            12 => HalfEdge(1, 6),
        ),
        # f2he
        Dict(1 => 1),
        # he2f
        Dict(
            1 => 1,
            2 => 0,
            3 => 1,
            4 => 0,
            5 => 1,
            6 => 0,
            7 => 1,
            8 => 0,
            9 => 1,
            10 => 0,
            11 => 1,
            12 => 0,
        ),
        # next
        Dict(
            1 => 3,
            3 => 5,
            5 => 7,
            7 => 9,
            9 => 11,
            11 => 1,
            2 => 4,
            4 => 6,
            6 => 8,
            8 => 10,
            10 => 12,
            12 => 2,
        ),
        # twin
        Dict(
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
        ),
        6, # v_max
        12, # he_max
        1, # f_max
    )
    pmg2 = PlanarMultigraph(
        # v2he
        Dict(1 => 13, 2 => 3, 3 => 5, 4 => 14, 5 => 9, 6 => 11),
        # hes
        Dict(
            1 => HalfEdge(1, 2),
            2 => HalfEdge(2, 1),
            3 => HalfEdge(2, 3),
            4 => HalfEdge(3, 2),
            5 => HalfEdge(3, 4),
            6 => HalfEdge(4, 3),
            7 => HalfEdge(4, 5),
            8 => HalfEdge(5, 4),
            9 => HalfEdge(5, 6),
            10 => HalfEdge(6, 5),
            11 => HalfEdge(6, 1),
            12 => HalfEdge(1, 6),
            13 => HalfEdge(1, 4),
            14 => HalfEdge(4, 1),
        ),
        # f2he
        Dict(1 => 14, 2 => 13),
        #he2f
        Dict(
            1 => 1,
            2 => 0,
            3 => 1,
            4 => 0,
            5 => 1,
            6 => 0,
            7 => 2,
            8 => 0,
            9 => 2,
            10 => 0,
            11 => 2,
            12 => 0,
            13 => 2,
            14 => 1,
        ),
        #next
        Dict(
            1 => 3,
            3 => 5,
            5 => 14,
            14 => 1,
            7 => 9,
            9 => 11,
            11 => 13,
            13 => 7,
            2 => 4,
            4 => 6,
            6 => 8,
            8 => 10,
            10 => 12,
            12 => 2,
        ),
        # twin
        Dict(
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
        ),
        6, # v_max
        14, # he_max
        2, # f_max
    )
    pmg3 = copy(pmg1)
    @test split_facet!(pmg3, 11, 5) == 13
    @test pmg3 == pmg2
    pmg4 = copy(pmg2)
    @test join_facet!(pmg4, 13) == 11
    @test pmg4 == pmg1
end

@testset "Split Vertex fail" begin
    pmg1 = PlanarMultigraph(
        Dict(
            1 => HalfEdge(1, 2),
            2 => HalfEdge(2, 1),
            3 => HalfEdge(1, 2),
            4 => HalfEdge(2, 1),
        ),
        Dict(1 => 1, 0 => 2),
        Dict(1 => 1, 4 => 1, 3 => 0, 2 => 0),
        Dict(1 => 4, 4 => 1, 3 => 2, 2 => 3),
        Dict(1 => 2, 2 => 1, 4 => 3, 3 => 4),
        2,
        4,
        1,
    )
    @test_throws "Should use #TODO to add multiedge and split facet!" split_facet!(
        pmg1,
        1,
        4,
    )
end

@testset "Join/Split Vertex" begin
    pmg1 = PlanarMultigraph(
        Dict(1 => 1, 2 => 3, 3 => 4, 4 => 6, 5 => 8),
        Dict(
            1 => HalfEdge(1, 2),
            2 => HalfEdge(2, 1),
            3 => HalfEdge(2, 3),
            4 => HalfEdge(3, 2),
            5 => HalfEdge(2, 4),
            6 => HalfEdge(4, 2),
            7 => HalfEdge(2, 5),
            8 => HalfEdge(5, 2),
        ),
        Dict{Int64,Int64}(),
        Dict(1 => 0, 2 => 0, 3 => 0, 4 => 0, 5 => 0, 6 => 0, 7 => 0, 8 => 0),
        Dict(1 => 3, 3 => 4, 4 => 5, 5 => 6, 6 => 7, 7 => 8, 8 => 2, 2 => 1),
        Dict(1 => 2, 2 => 1, 3 => 4, 4 => 3, 5 => 6, 6 => 5, 7 => 8, 8 => 7),
        5,
        8,
        0,
    )
    pmg2 = PlanarMultigraph(
        Dict(1 => 1, 2 => 3, 3 => 4, 4 => 6, 6 => 9, 5 => 8),
        Dict(
            1 => HalfEdge(1, 6),
            2 => HalfEdge(6, 1),
            3 => HalfEdge(2, 3),
            4 => HalfEdge(3, 2),
            5 => HalfEdge(2, 4),
            6 => HalfEdge(4, 2),
            7 => HalfEdge(6, 5),
            8 => HalfEdge(5, 6),
            9 => HalfEdge(6, 2),
            10 => HalfEdge(2, 6),
        ),
        Dict{Int64,Int64}(),
        Dict(
            1 => 0,
            2 => 0,
            3 => 0,
            4 => 0,
            5 => 0,
            6 => 0,
            7 => 0,
            8 => 0,
            9 => 0,
            10 => 0,
        ),
        Dict(
            1 => 9,
            9 => 3,
            3 => 4,
            4 => 5,
            5 => 6,
            6 => 10,
            10 => 7,
            7 => 8,
            8 => 2,
            2 => 1,
        ),
        Dict(
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
        ),
        6,
        10,
        0,
    )
    pmg3 = copy(pmg1)
    pmg4 = copy(pmg2)
    @test split_vertex!(pmg3, 6, 1) == 9
    @test pmg3 == pmg2
    @test join_vertex!(pmg4, 9) == 5
    @test pmg4 == pmg1
end
