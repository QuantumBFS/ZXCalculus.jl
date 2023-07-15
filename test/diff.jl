using ZXCalculus: insert_spider!
using ZXCalculus: symbol_vertices, diff_diagram

@testset "diff" begin
    zxwd = ZXWDiagram(3)
    insert_spider!(zxwd, 1, 2, Z(Parameter(Val(:PiUnit), :a)))
    insert_spider!(zxwd, 7, 2, Z(Parameter(Val(:PiUnit), :a)))
    insert_spider!(zxwd, 3, 4, X(Parameter(Val(:PiUnit), :b)))
    insert_spider!(zxwd, 5, 6, Z(Parameter(Val(:PiUnit), 0.3)))
    insert_spider!(zxwd, 8, 2, Z(Parameter(Val(:PiUnit), Expr(:call, :-, :a))))

    @test sort!(symbol_vertices(zxwd, :a)) == [7, 8, 11]
    @test symbol_vertices(zxwd, :b) == [9]
    @test symbol_vertices(zxwd, :c) == []

    diff_diagram(zxwd, :a)
    @test length(vertices(zxwd.mg)) == 25

end
