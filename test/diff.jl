using ZXCalculus: insert_spider!
using ZXCalculus: symbol_vertices, diff_diagram, dagger, concat!, diff_expval!, integrate!

# @testset "diff" begin
#     zxwd = ZXWDiagram(3)
#     insert_spider!(zxwd, 1, 2, Z(Parameter(Val(:PiUnit), :a)))
#     insert_spider!(zxwd, 7, 2, Z(Parameter(Val(:PiUnit), :a)))
#     insert_spider!(zxwd, 3, 4, X(Parameter(Val(:PiUnit), :b)))
#     insert_spider!(zxwd, 5, 6, Z(Parameter(Val(:PiUnit), 0.3)))
#     insert_spider!(zxwd, 8, 2, Z(Parameter(Val(:PiUnit), Expr(:call, :-, :a))))

#     @test sort!(symbol_vertices(zxwd, :a)) == [7, 8]
#     @test symbol_vertices(zxwd, :a; neg = true) == [11]
#     @test symbol_vertices(zxwd, :b) == [9]
#     @test symbol_vertices(zxwd, :c) == []

#     diff_expval!(copy(zxwd), "ZZZ", :a)

#     diff_zxwd = diff_diagram(copy(zxwd), :a)
#     # originally 11 spiders, plus 12 spiders from differentiation
#     @test length(vertices(diff_zxwd.mg)) == 23

#     zxwd_dg = dagger(zxwd)
#     @test spider_type(zxwd_dg, 7).p.pu == Expr(:call, :-, :a)
#     @test sort!(symbol_vertices(zxwd_dg, :a; neg = true)) == [7, 8]

#     concat!(zxwd, zxwd_dg)

#     @test length(vertices(zxwd.mg)) == 16

#     integrate!(zxwd, [7, 11])
#     @test length(vertices(zxwd.mg)) == 16

#     # abuse, cann't actually integrate like this
#     integrate!(zxwd, [7, 8, 11, 9])
#     @test length(vertices(zxwd.mg)) == 25

# end

@testset "Example 27 - 30" begin
    zxwd = ZXWDiagram(2)
    push_gate!(zxwd, Val(:H), 1)
    push_gate!(zxwd, Val(:H), 2)

    push_gate!(zxwd, Val(:CZ), 1, 2)
    push_gate!(zxwd, Val(:X), 1, :a; autoconvert = false)
    push_gate!(zxwd, Val(:X), 2, :b; autoconvert = false)

    # since :c is not in the circuit, this will return UHU^\dagger
    exp_zxwd = diff_expval!(copy(zxwd), "ZZ", :c)

    exp_zxwd_sub = substitute_variables!(copy(exp_zxwd), Dict(:a => 0.3, :b => 0.4))
    exp_val = Matrix(exp_zxwd_sub)[1, 1]


    # zxrx1 = GeneralMatrixBlock(
    #     [
    #         (1+exp(im * 0.3 * π))/2 (1-exp(im * 0.3 * π))/2
    #         (1-exp(im * 0.3 * π))/2 (1+exp(im * 0.3 * π))/2
    #     ],
    # )
    # zxrx2 = GeneralMatrixBlock(
    #     [
    #         (1+exp(im * 0.4 * π))/2 (1-exp(im * 0.4 * π))/2
    #         (1-exp(im * 0.4 * π))/2 (1+exp(im * 0.4 * π))/2
    #     ],
    # )
    # yao_circ = chain(
    #     2,
    #     put(2, 1 => Yao.H),
    #     put(2, 2 => Yao.H),
    #     cz(2, 1, 2),
    #     put(2, 1 => zxrx2),
    #     put(2, 2 => zxrx1),
    # )

    # exp_yao = expect(repeat(2, Yao.Z), zero_state(2) => yao_circ)
    exp_yao = 0.7694208842938131

    @test exp_val ≈ exp_yao

end
