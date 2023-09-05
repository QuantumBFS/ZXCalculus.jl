using ZXCalculus: create_vertex!, create_edge!, split_vertex!, split_facet!

@testset "Half edge constructor" begin

    he1 = HalfEdge(1, 2)
    ophe1 = HalfEdge(2, 1)

    he2, ophe2 = new_edge(1, 2)
    @test he2 == he1
    @test ophe2 == ophe1
end

@testset "Facet Split/Join" begin
    pmg1 = PlanarMultigraph{Int64}(
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
    pmg2 = PlanarMultigraph{Int64}(
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
end

# @testset "PlanarMultigraph Utils" begin
#     g = PlanarMultigraph{Int64}()

#     vtx_ids = create_vertex!(g; mul = 1)
#     @test vtx_ids == [1]
#     vtx_ids = create_vertex!(g; mul = 2)
#     @test vtx_ids == [2, 3]

#     hes_id, hes = create_edge!(g, 1, 2)

#     @test hes_id == [1, 2]
#     @test hes[1] == HalfEdge(1, 2)
#     @test hes[2] == HalfEdge(2, 1)

#     @test check_vertices(g)
#     @test check_faces(g)
#     @test check_combinatorial_maps(g)
# end

# @testset "PlanarMultigraph Constructor" begin
#     g = PlanarMultigraph{Int64}(3)

#     # split_facet!(g, )
#     @test check_vertices(g)
#     @test check_faces(g)
#     @test check_combinatorial_maps(g)
# end
