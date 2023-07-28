using ZXCalculus: insert_spider!
using ZXCalculus: symbol_vertices, diff_diagram!, dagger, concat!, expval_circ!, integrate!

@testset "Example 28" begin
    zxwd = ZXWDiagram(2)
    push_gate!(zxwd, Val(:H), 1)
    push_gate!(zxwd, Val(:H), 2)

    push_gate!(zxwd, Val(:CZ), 1, 2)
    push_gate!(zxwd, Val(:X), 1, :a; autoconvert = false)
    push_gate!(zxwd, Val(:X), 2, :b; autoconvert = false)

    exp_zxwd = expval_circ!(copy(zxwd), "ZZ")

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

@testset "Parameter Shift" begin

    zxwd = ZXWDiagram(2)


    a = 0.3
    b = 0.5

    push_gate!(zxwd, Val(:X), 1, :a; autoconvert = false)
    push_gate!(zxwd, Val(:X), 2, :b; autoconvert = false)
    exp_zxwd = expval_circ!(copy(zxwd), "ZZ")

    exp_pluspihf = substitute_variables!(copy(exp_zxwd), Dict(:a => a, :b => b + 1 / 2))
    exp_mnuspihf = substitute_variables!(copy(exp_zxwd), Dict(:a => a, :b => b - 1 / 2))


    # should be around -1.8465
    gradient_parameter_shift =
        real(π / 2 * (Matrix(exp_pluspihf)[1, 1] - Matrix(exp_mnuspihf)[1, 1]))

    diff_zxwd = diff_diagram!(exp_zxwd, :b)

    diff_zxwd = substitute_variables!(diff_zxwd, Dict(:a => a, :b => b))

    diff_mtx = Matrix(diff_zxwd)
    # need to adjust for pi since our parameter is in unit of pi
    gradient = real(diff_mtx[1, 1]) * π

    @test gradient ≈ gradient_parameter_shift
end

@testset "Proposition 20" begin


    zxwd = ZXWDiagram(1)
    push_gate!(zxwd, Val(:X), 1, :a; autoconvert = false)
    exp_zxwd = expval_circ!(copy(zxwd), "Z")

    int_zxwd = integrate!(exp_zxwd, [3, 5])

    int_val = real(Matrix(int_zxwd)[1, 1])
    # plot the exp val and you should see a sin curve
    # should integrate to zero
    @test isapprox(int_val, 0.0; atol = 1e-10)


    zxwd = ZXWDiagram(1)
    push_gate!(zxwd, Val(:X), 1, :a; autoconvert = false)
    exp_zxwd = expval_circ!(copy(zxwd), "I")

    int_zxwd = integrate!(exp_zxwd, [3, 4])

    int_val = real(Matrix(int_zxwd)[1, 1])
    # constant, should be 1.0
    @test isapprox(int_val, 1.0; atol = 1e-10)
end

@testset "Lemma 30" begin
    # to calculate variance, we double the circuit
    zxwd = ZXWDiagram(4)

    push_gate!(zxwd, Val(:H), 1)
    push_gate!(zxwd, Val(:H), 2)
    push_gate!(zxwd, Val(:CZ), 1, 2)
    push_gate!(zxwd, Val(:X), 1, :a; autoconvert = false)
    push_gate!(zxwd, Val(:X), 2, :b; autoconvert = false)

    exp_zxwd = expval_circ!(copy(zxwd), "ZZZZ")
    exp_zxwd = diff_diagram!(exp_zxwd, :b)
    exp_zxwd = diff_diagram!(exp_zxwd, :c)


    posb = ZXCalculus.symbol_vertices(exp_zxwd, :b; neg = false)[1]
    posbminus = ZXCalculus.symbol_vertices(exp_zxwd, :b; neg = true)[1]

    posc = ZXCalculus.symbol_vertices(exp_zxwd, :c; neg = false)[1]
    poscminus = ZXCalculus.symbol_vertices(exp_zxwd, :c; neg = true)[1]

    integrated_zxwd = ZXCalculus.integrate!(exp_zxwd, [posb, posbminus, posc, poscminus])


    integrated_zxwd = substitute_variables!(integrated_zxwd, Dict(:a => 0.0))

    integrated_mtx = Matrix(integrated_zxwd)

end
