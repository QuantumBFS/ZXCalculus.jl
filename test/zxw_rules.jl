@testset "Calculus Rule" begin
    deri_rule = CalcRule(:deri, :p)
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

    push_gate!(zxwd, Val(:X), 1, :a; autoconvert = false)
    push_gate!(zxwd, Val(:X), 2, :b; autoconvert = false)
    exp_zxwd = expval_circ!(copy(zxwd), "ZZ")

    exp_pluspihf = substitute_variables!(copy(exp_zxwd), Dict(:a => a, :b => b + 1 / 2))
    exp_mnuspihf = substitute_variables!(copy(exp_zxwd), Dict(:a => a, :b => b - 1 / 2))

    # should be around -1.8465
    gradient_parameter_shift =
        real(π / 2 * (Matrix(exp_pluspihf)[1, 1] - Matrix(exp_mnuspihf)[1, 1]))


    matches = match(CalcRule(:deri, :b), exp_zxwd)
    diff_zxwd = rewrite!(CalcRule(:deri, :b), exp_zxwd, matches)

    diff_zxwd = substitute_variables!(diff_zxwd, Dict(:a => a, :b => b))

    diff_mtx = Matrix(diff_zxwd)
    # our parameter is in unit of pi
    # during derivation, dummy variable will have extra factor of pi
    gradient = real(diff_mtx[1, 1]) * π

    @test gradient ≈ gradient_parameter_shift
end
