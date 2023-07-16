using ZXCalculus: insert_spider!
using ZXCalculus: symbol_vertices, diff_diagram, dagger, concat!, diff_expval!

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

    diff_expval!(copy(zxwd), "ZZZ", :a)

    diff_zxwd = diff_diagram(copy(zxwd), :a)
    # originally 11 spiders, plus 12 spiders from differentiation
    @test length(vertices(diff_zxwd.mg)) == 23

    zxwd_dg = dagger(zxwd)
    @test spider_type(zxwd_dg, 7).p.pu == Expr(:call, :-, :a)
    @test sort!(symbol_vertices(zxwd_dg, :a)) == [7, 8, 11]

    concat!(zxwd, zxwd_dg)

    @test length(vertices(zxwd.mg)) == 16

end
