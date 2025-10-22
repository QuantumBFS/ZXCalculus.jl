using Test, ZXCalculus, ZXCalculus.ZXW, ZXCalculus.ZX, Graphs
using Test: match_logs
using ZXCalculus.ZXW:
                      CalcRule,
                      rewrite!,
                      symbol_vertices,
                      dagger,
                      concat!,
                      expval_circ!,
                      push_gate!,
                      stack_zxwd!,
                      substitute_variables!,
                      insert_spider!

@testset "Calculus Rule" begin
    deri_rule = CalcRule(:diff, :p)
    @test deri_rule.var == :p

    int_rule = CalcRule(:int, :a)
    @test int_rule.var == :a
end

@testset "matching" begin
    zxwd = ZXWDiagram(4)

    # s1
    push_gate!(zxwd, Val(:X), 1, 0.5)
    push_gate!(zxwd, Val(:X), 1, 0.7)

    # s2
    push_gate!(zxwd, Val(:Z), 2, 0)

    vs1 = match(Rule(:s1), zxwd)[1]
    vs2 = match(Rule(:s2), zxwd)[1]
    @test vs1.vertices == [9, 10]
    @test vs2.vertices == [11]

    rewrite!(Rule(:s1), zxwd, vs1)
    @test !has_vertex(zxwd.mg, 10)
    rewrite!(Rule(:s2), zxwd, vs2)
    @test !has_vertex(zxwd.mg, 11)
end

@testset "Parameter Shift" begin
    zxwd = ZXWDiagram(2)

    a = 0.3
    b = 0.5

    push_gate!(zxwd, Val(:X), 1, :a; autoconvert=false)
    push_gate!(zxwd, Val(:X), 2, :b; autoconvert=false)
    exp_zxwd = expval_circ!(copy(zxwd), "ZZ")

    exp_pluspihf = substitute_variables!(copy(exp_zxwd), Dict(:a => a, :b => b + 1 / 2))
    exp_mnuspihf = substitute_variables!(copy(exp_zxwd), Dict(:a => a, :b => b - 1 / 2))

    # should be around -1.8465
    gradient_parameter_shift = real(π / 2 * (Matrix(exp_pluspihf)[1, 1] - Matrix(exp_mnuspihf)[1, 1]))

    matches = match(CalcRule(:diff, :b), exp_zxwd)
    diff_zxwd = rewrite!(CalcRule(:diff, :b), exp_zxwd, matches)

    diff_zxwd = substitute_variables!(diff_zxwd, Dict(:a => a, :b => b))

    diff_mtx = Matrix(diff_zxwd)
    # our parameter is in unit of pi
    # during derivation, dummy variable will have extra factor of pi
    gradient = real(diff_mtx[1, 1]) * π

    @test gradient ≈ gradient_parameter_shift
end

@testset "Proposition 20" begin

    # standard value of integration obtained from
    # doing Riemann sum and extrapolating
    # the sum will differ to the integrated value
    # provided by the ZXWDiagram by a factor of 2
    # since we are using a dummy variable k pi = alpha
    # where k goes from 0 to 2, hence the factor 2 in test

    zxwd = ZXWDiagram(1)
    push_gate!(zxwd, Val(:X), 1, :a; autoconvert=false)
    exp_zxwd = expval_circ!(copy(zxwd), "Z")

    matches = match(CalcRule(:int, :a), exp_zxwd)
    int_zxwd = rewrite!(CalcRule(:int, :a), exp_zxwd, matches)

    int_val = real(Matrix(int_zxwd)[1, 1])

    @test isapprox(2 * int_val, 0.0; atol=1e-10)

    zxwd = ZXWDiagram(2)
    push_gate!(zxwd, Val(:X), 1, :a; autoconvert=false)
    push_gate!(zxwd, Val(:X), 2, :b; autoconvert=false)
    exp_zxwd = expval_circ!(copy(zxwd), "IZ")

    matches = match(CalcRule(:int, :a), exp_zxwd)
    int_zxwd = rewrite!(CalcRule(:int, :a), exp_zxwd, matches)
    int_zxwd = substitute_variables!(int_zxwd, Dict(:a => 0.3, :b => 0.0))
    int_val = real(Matrix(int_zxwd)[1, 1])
    # constant, should be 2.0
    @test isapprox(2 * int_val, 2.0; atol=1e-10)
end

@testset "Theorem 23" begin
    zxwd = ZXWDiagram(2)
    push_gate!(zxwd, Val(:X), 1, :a; autoconvert=false)
    push_gate!(zxwd, Val(:X), 2, :a; autoconvert=false)
    exp_zxwd = expval_circ!(copy(zxwd), "ZZ")

    matches = match(CalcRule(:int, :a), exp_zxwd)
    int_zxwd = rewrite!(CalcRule(:int, :a), exp_zxwd, matches)

    int_val = real(Matrix(int_zxwd)[1, 1])
    # By thm 23, and change of dummy variable, k * pi = alpha
    # we get 1/2 \int_{-1}^{1} ... dk = ZXWDiagram
    # hence the factor of two here
    @test isapprox(2 * int_val, 1.0; atol=1e-10)
end

@testset "Lemma 30 - a" begin

    # first part of integration
    a = 0.3
    b = 0.0

    zxwd = ZXWDiagram(2)
    push_gate!(zxwd, Val(:H), 1)
    push_gate!(zxwd, Val(:H), 2)
    push_gate!(zxwd, Val(:CZ), 1, 2)
    push_gate!(zxwd, Val(:X), 1, :a; autoconvert=false)
    push_gate!(zxwd, Val(:X), 2, :b; autoconvert=false)

    exp_zxwd = expval_circ!(zxwd, "ZZ")
    # essential to take diff here first, not stack then diff
    # otherwise value may not be strictly positive

    matches = match(CalcRule(:diff, :b), exp_zxwd)
    diff_exp = rewrite!(CalcRule(:diff, :b), exp_zxwd, matches)
    dbdiff_zxwd = stack_zxwd!(diff_exp, copy(diff_exp))

    matches = match(CalcRule(:int, :b), dbdiff_zxwd)
    int_dbdiff = rewrite!(CalcRule(:int, :b), copy(dbdiff_zxwd), matches)
    int_subb = substitute_variables!(int_dbdiff, Dict(:a => a, :b => b))
    int_valb = real(Matrix(int_subb)[1, 1])

    A = real(
        Matrix(substitute_variables!(copy(dbdiff_zxwd), Dict(:a => a, :b => 0.0)))[1, 1],
    )
    @test isapprox(int_valb, A / 2; atol=1e-10)
end

@testset "Lemma 30 - b" begin
    zxwd = ZXWDiagram(2)

    push_gate!(zxwd, Val(:H), 1)
    push_gate!(zxwd, Val(:H), 2)
    push_gate!(zxwd, Val(:CZ), 1, 2)
    push_gate!(zxwd, Val(:X), 1, :a; autoconvert=false)
    push_gate!(zxwd, Val(:X), 2, :b; autoconvert=false)

    exp_zxwd = expval_circ!(zxwd, "ZZ")
    matches = match(CalcRule(:diff, :b), exp_zxwd)
    diff_exp = rewrite!(CalcRule(:diff, :b), exp_zxwd, matches)
    matches = match(CalcRule(:diff, :a), diff_exp)
    diff_exp = rewrite!(CalcRule(:diff, :a), diff_exp, matches)
    dbdiff_zxwd = stack_zxwd!(diff_exp, copy(diff_exp))

    matches = match(CalcRule(:int, :b), dbdiff_zxwd)
    int_dbdiff = rewrite!(CalcRule(:int, :b), dbdiff_zxwd, matches)
    matches = match(CalcRule(:int, :a), int_dbdiff)
    int_dadiff = rewrite!(CalcRule(:int, :a), copy(int_dbdiff), matches)
    int_vala = real(Matrix(int_dadiff)[1, 1])

    A = real(Matrix(substitute_variables!(copy(int_dbdiff), Dict(:a => 0.0)))[1, 1])
    @test isapprox(int_vala, A / 2; atol=1e-10)
end
