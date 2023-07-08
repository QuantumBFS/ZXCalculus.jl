@testset "matching" begin
    zxwd = ZXWDiagram(4)

    # s1
    push_gate!(zxwd, Val(:X), 1, 0.5)
    push_gate!(zxwd, Val(:X), 1, 0.7)

    # s2
    push_gate!(zxwd, Val(:Z), 2, 0)

    @test match(s1, zxwd) == Match{Int64}([9, 10])
    @test match(s2, zxwd) == Match{Int64}([11])
end
