using ZXCalculus: insert_spider!
using ZXCalculus: symbol_vertices
using Symbolics

@testset "get vertices" begin
    zxwd = ZXWDiagram(3)
    @variables x
    insert_spider!(zxwd, 1, 2, Z(Parameter(Val(:PiUnit), :a)))
    insert_spider!(zxwd, 7, 2, Z(Parameter(Val(:PiUnit), :a)))
    insert_spider!(zxwd, 3, 4, X(Parameter(Val(:PiUnit), :b)))
    insert_spider!(zxwd, 5, 6, Z(Parameter(Val(:PiUnit), 0.3)))
    insert_spider!(zxwd, 8, 2, Z(Parameter(Val(:PiUnit), x)))

    @test sort!(symbol_vertices(zxwd, :a)) == [7, 8]
    @test symbol_vertices(zxwd, :b) == [9]
    # @test symbol_vertices(zxwd, x) == [10]
    @test symbol_vertices(zxwd, :c) == []

end
