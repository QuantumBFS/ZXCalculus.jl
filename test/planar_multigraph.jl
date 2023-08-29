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
    g = PlanarMultigraph({}, {}, {}, {}, {}, {}, {}, 0, 0, 0)

end
