using ZXCalculus: insert_spider!
using ZXCalculus: symbol_vertices, diff_diagram!, dagger, concat!, expval_circ!, integrate!

@testset "Example 28" begin
    zxwd = ZXWDiagram(2)
    push_gate!(zxwd, Val(:H), 1)
    push_gate!(zxwd, Val(:H), 2)

    push_gate!(zxwd, Val(:CZ), 1, 2)
    push_gate!(zxwd, Val(:X), 1, :a; autoconvert=false)
    push_gate!(zxwd, Val(:X), 2, :b; autoconvert=false)

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

@testset "Lemma 30" begin
    # to calculate variance, we double the circuit
    zxwd = ZXWDiagram(4)

    push_gate!(zxwd, Val(:H), 1)
    push_gate!(zxwd, Val(:H), 2)
    push_gate!(zxwd, Val(:H), 3)
    push_gate!(zxwd, Val(:H), 4)
    push_gate!(zxwd, Val(:CZ), 1, 2)
    push_gate!(zxwd, Val(:CZ), 3, 4)
    push_gate!(zxwd, Val(:X), 1, :a; autoconvert=false)
    push_gate!(zxwd, Val(:X), 2, :b; autoconvert=false)
    push_gate!(zxwd, Val(:X), 3, :a; autoconvert=false)
    push_gate!(zxwd, Val(:X), 4, :c; autoconvert=false)

    exp_zxwd = expval_circ!(copy(zxwd), "ZZZZ")
    exp_zxwd = diff_diagram!(exp_zxwd, :b)
    exp_zxwd = diff_diagram!(exp_zxwd, :c)


    posb = ZXCalculus.symbol_vertices(exp_zxwd, :b; neg=false)[1]
    posbminus = ZXCalculus.symbol_vertices(exp_zxwd, :b; neg=true)[1]

    posc = ZXCalculus.symbol_vertices(exp_zxwd, :c; neg=false)[1]
    poscminus = ZXCalculus.symbol_vertices(exp_zxwd, :c; neg=true)[1]

    integrated_zxwd = ZXCalculus.integrate!(exp_zxwd, [posb, posbminus, posc, poscminus])


    integrated_zxwd = substitute_variables!(integrated_zxwd, Dict(:a => 0.0))

    integrated_mtx = Matrix(integrated_zxwd)

end
