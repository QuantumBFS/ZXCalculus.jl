@testset "Half edge constructor" begin

    he1 = HalfEdge(1, 2)
    ophe1 = HalfEdge(2, 1)

    @test opposite(he1) == ophe1
    @test_throws ErrorException("src and dst cannot be the same vertex") HalfEdge(1, 1)

end
