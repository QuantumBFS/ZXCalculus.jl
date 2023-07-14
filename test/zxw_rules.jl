@testset "matching" begin
    zxwd = ZXWDiagram(4)

    # s1
    push_gate!(zxwd, Val(:X), 1, 0.5)
    push_gate!(zxwd, Val(:X), 1, 0.7)

    # s2
    push_gate!(zxwd, Val(:Z), 2, 0)

    vs1 = match(Rule(:s1), zxwd)[1]
    vs2 = match(Rule(:s2), zxwd)[1]
    @test vs1.vertices == [9, 10]
    @test vs2.vertices == [11]

    rewrite!(Rule(:s1), zxwd, vs1)
    @test !has_vertex(zxwd.mg, 10)
    rewrite!(Rule(:s2), zxwd, vs2)
    @test !has_vertex(zxwd.mg, 11)

end
