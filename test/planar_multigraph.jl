@testset "Half edge constructor" begin

    he1 = HalfEdge(1, 2)
    ophe1 = HalfEdge(2, 1)

    @test maketwin(he1) == ophe1
    @test_throws ErrorException("src and dst cannot be the same vertex") HalfEdge(1, 1)

    he2, ophe2 = makepair(1, 2)
    @test he2 == he1
    @test ophe2 == ophe1

end

@testset "PlanarMultigraph Constructor" begin
    g = PlanarMultigraph{Int64}()

    add_vertex!(g, 1)
    add_vertex!(g, 2)
    add_edge!(g, 1, 2, 1)
end
