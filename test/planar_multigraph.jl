using ZXCalculus: create_vertex, create_edge

@testset "Half edge constructor" begin

    he1 = HalfEdge(1, 2)
    ophe1 = HalfEdge(2, 1)

    he2, ophe2 = new_edge(1, 2)
    @test he2 == he1
    @test ophe2 == ophe1
end

@testset "PlanarMultigraph Utils" begin
    g = PlanarMultigraph{Int64}()

    vtx_ids = create_vertex(g; mul = 1)
    @test vtx_ids == [1]
    vtx_ids = create_vertex(g; mul = 2)
    @test vtx_ids == [2, 3]

    hes_id, hes = create_edge(g, 1, 2)

    @test hes_id == [1, 2]
    @test hes[1] == HalfEdge(1, 2)
    @test hes[2] == HalfEdge(2, 1)

end

@testset "PlanarMultigraph Constructor" begin
    g = PlanarMultigraph{Int64}(3)
end
