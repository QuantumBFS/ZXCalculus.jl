using ZXCalculus: insert_spider!
using ZXCalculus: symbol_vertices, diff_diagram, dagger, concat!, diff_expval!, integrate!

@testset "diff" begin
    zxwd = ZXWDiagram(3)
    insert_spider!(zxwd, 1, 2, Z(Parameter(Val(:PiUnit), :a)))
    insert_spider!(zxwd, 7, 2, Z(Parameter(Val(:PiUnit), :a)))
    insert_spider!(zxwd, 3, 4, X(Parameter(Val(:PiUnit), :b)))
    insert_spider!(zxwd, 5, 6, Z(Parameter(Val(:PiUnit), 0.3)))
    insert_spider!(zxwd, 8, 2, Z(Parameter(Val(:PiUnit), Expr(:call, :-, :a))))

    @test sort!(symbol_vertices(zxwd, :a)) == [7, 8]
    @test symbol_vertices(zxwd, :a; neg = true) == [11]
    @test symbol_vertices(zxwd, :b) == [9]
    @test symbol_vertices(zxwd, :c) == []

    diff_expval!(copy(zxwd), "ZZZ", :a)

    diff_zxwd = diff_diagram(copy(zxwd), :a)
    # originally 11 spiders, plus 12 spiders from differentiation
    @test length(vertices(diff_zxwd.mg)) == 23

    zxwd_dg = dagger(zxwd)
    @test spider_type(zxwd_dg, 7).p.pu == Expr(:call, :-, :a)
    @test sort!(symbol_vertices(zxwd_dg, :a; neg = true)) == [7, 8]

    concat!(zxwd, zxwd_dg)

    @test length(vertices(zxwd.mg)) == 16

    integrate!(zxwd, [7, 11])
    @test length(vertices(zxwd.mg)) == 16

    # abuse, cann't actually integrate like this
    integrate!(zxwd, [7, 8, 11, 9])
    @test length(vertices(zxwd.mg)) == 25

end

@testset "Example 27 - 30" begin
    zxwd = ZXWDiagram(2)
    push_gate!(zxwd, Val(:H), 1)
    push_gate!(zxwd, Val(:H), 2)

    push_gate!(zxwd, Val(:CZ), 1, 2)
    push_gate!(zxwd, Val(:X), 1, Parameter(Val(:PiUnit), :a); autoconvert = false)
    push_gate!(zxwd, Val(:X), 2, Parameter(Val(:PiUnit), :b); autoconvert = false)

    zxwd_sub = substitute_variables!(copy(zxwd), Dict(:a => 0.1, :b => 0.2))
    mtx = Matrix(zxwd_sub)
    mtx_standard = [
        0.497502-0.14776im 0.477668-0.0499167im 0.477668+0.0499167im 0.497502+0.14776im
        0.477668+0.0499167im -0.497502-0.14776im 0.497502-0.14776im -0.477668+0.0499167im
        0.477668-0.0499167im 0.497502-0.14776im -0.497502-0.14776im -0.477668-0.0499167im
        -0.497502-0.14776im 0.477668+0.0499167im 0.477668-0.0499167im -0.497502+0.14776im
    ]
    # @test mtx ≈ mtx_standard

    # zxwd_diff_a = diff_diagram(copy(zxwd), :a)

end
