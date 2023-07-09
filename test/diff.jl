@testset "get vertices" begin
    zxwd = ZXWDiagram(3)

    pushfirst_gate!(zxwd, Val(:Z), 1, phase = Parameter(Val(:PiUnit), :a))
    pushfirst_gate!(zxwd, Val(:Z), 1, phase = Parameter(Val(:PiUnit), :a))
    pushfirst_gate!(zxwd, Val(:X), 2, phase = Parameter(Val(:PiUnit), :b))
    pushfirst_gate!(zxwd, Val(:Z), 3, phase = 0.3)

    @test symbol_vertices(zxwd, :a) == [1, 2]
    @test symbol_vertices(zxwd, :b) == [2]
    @test symbol_vertices(zxwd, :c) == []

end
