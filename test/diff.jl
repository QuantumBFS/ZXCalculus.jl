using ZXCalculus: insert_spider!
using ZXCalculus: symbol_vertices, dagger, concat!, expval_circ!, integrate!

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

    exp_yao = 0.7694208842938131

    @test exp_val ≈ exp_yao

end


@testset "Proposition 20" begin

    # standard value of integration obtained from
    # doing Riemann sum and extrapolating
    # the sum will differ to the integrated value
    # provided by the ZXWDiagram by a factor of 2
    # since we are using a dummy variable k pi = alpha
    # where k goes from 0 to 2, hence the factor 2 in test

    zxwd = ZXWDiagram(1)
    push_gate!(zxwd, Val(:X), 1, :a; autoconvert = false)
    exp_zxwd = expval_circ!(copy(zxwd), "Z")

    int_zxwd = integrate!(exp_zxwd, [3, 5])

    int_val = real(Matrix(int_zxwd)[1, 1])

    @test isapprox(2 * int_val, 0.0; atol = 1e-10)


    zxwd = ZXWDiagram(2)
    push_gate!(zxwd, Val(:X), 1, :a; autoconvert = false)
    push_gate!(zxwd, Val(:X), 2, :b; autoconvert = false)
    exp_zxwd = expval_circ!(copy(zxwd), "IZ")

    int_zxwd = integrate!(exp_zxwd, [5, 8])
    int_zxwd = substitute_variables!(int_zxwd, Dict(:a => 0.3, :b => 0.0))
    int_val = real(Matrix(int_zxwd)[1, 1])
    # constant, should be 2.0
    @test isapprox(2 * int_val, 2.0; atol = 1e-10)
end


@testset "Theorem 23" begin


    zxwd = ZXWDiagram(2)
    push_gate!(zxwd, Val(:X), 1, :a; autoconvert = false)
    push_gate!(zxwd, Val(:X), 2, :a; autoconvert = false)
    exp_zxwd = expval_circ!(copy(zxwd), "ZZ")

    int_zxwd = integrate!(exp_zxwd, [5, 9, 6, 10])

    int_val = real(Matrix(int_zxwd)[1, 1])
    # By thm 23, and change of dummy variable, k * pi = alpha
    # we get 1/2 \int_{-1}^{1} ... dk = ZXWDiagram
    # hence the factor of two here
    @test isapprox(2 * int_val, 1.0; atol = 1e-10)
end

@testset "Lemma 30 - a" begin

    # first part of integration
    a = 0.3
    b = 0.0

    zxwd = ZXWDiagram(2)
    push_gate!(zxwd, Val(:H), 1)
    push_gate!(zxwd, Val(:H), 2)
    push_gate!(zxwd, Val(:CZ), 1, 2)
    push_gate!(zxwd, Val(:X), 1, :a; autoconvert = false)
    push_gate!(zxwd, Val(:X), 2, :b; autoconvert = false)

    exp_zxwd = expval_circ!(copy(zxwd), "ZZ")
    # essential to take diff here first, not stack then diff
    # otherwise value may not be strictly positive

    matches = match(CalcRule(:deri, :b), exp_zxwd)
    diff_exp = rewrite!(CalcRule(:deri, :b), copy(exp_zxwd), matches)
    dbdiff_zxwd = stack_zxwd(diff_exp, copy(diff_exp))
    # order of spider idx also matters, needs to be + - + -
    int_dbdiff = integrate!(copy(dbdiff_zxwd), [22, 16, 48, 42])
    int_subb = substitute_variables!(copy(int_dbdiff), Dict(:a => a, :b => b))
    int_valb = real(Matrix(int_subb)[1, 1])

    # standard value obtained from doing Riemann sum, observe it's some sort of
    # cos function with all positive values, it's integral will be just the amplitude
    # which is calculated by A

    # rng = 0.0:0.001:2.0
    # val_vec = Float64[]
    # for c in rng
    #     sig_zxwd = substitute_variables!(copy(dbdiff_zxwd), Dict(:a => a, :b => c))
    #     push!(val_vec, real(Matrix(sig_zxwd)[1, 1]))
    # end
    # plot(rng, val_vec)

    A = real(
        Matrix(substitute_variables!(copy(dbdiff_zxwd), Dict(:a => a, :b => 0.0)))[1, 1],
    )
    @test isapprox(int_valb, A / 2; atol = 1e-10)
end

@testset "Lemma 30 - b" begin
    # do two integration
    # we verify by doing Riemann sum with integrated value w.r.t
    # :b and sweep across :a from 0 to 2, observe it's still
    # some sort of cos function with all positive values
    # integral of it will be just the amplitude halfed

    zxwd = ZXWDiagram(2)

    push_gate!(zxwd, Val(:H), 1)
    push_gate!(zxwd, Val(:H), 2)
    push_gate!(zxwd, Val(:CZ), 1, 2)
    push_gate!(zxwd, Val(:X), 1, :a; autoconvert = false)
    push_gate!(zxwd, Val(:X), 2, :b; autoconvert = false)

    exp_zxwd = expval_circ!(copy(zxwd), "ZZ")
    # essential to take diff here first, not stack then diff
    # otherwise value may not be strictly positive
    matches = match(CalcRule(:deri, :b), exp_zxwd)
    diff_exp = rewrite!(CalcRule(:deri, :b), exp_zxwd, matches)
    # need to take derivative here, otherwise the value is not strictly positive
    # after the two ZXDiagram are stacked
    matches = match(CalcRule(:deri, :a), diff_exp)
    diff_exp = rewrite!(CalcRule(:deri, :a), diff_exp, matches)
    dbdiff_zxwd = stack_zxwd(diff_exp, copy(diff_exp))
    # integrate away b first
    # this step is assumed to be correct since we tested it in step a above
    int_dbdiff = integrate!(copy(dbdiff_zxwd), [24, 17, 60, 53])
    int_dadiff = integrate!(copy(int_dbdiff), [39, 11, 75, 47])
    int_vala = real(Matrix(int_dadiff)[1, 1])

    A = real(Matrix(substitute_variables!(copy(int_dbdiff), Dict(:a => 0.0)))[1, 1])
    @test isapprox(int_vala, A / 2; atol = 1e-10)
end
