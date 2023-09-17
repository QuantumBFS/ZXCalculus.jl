using ZXCalculus.ZXW:
    Parameter,
    _round_phase,
    round_phases!,
    print_spider,
    push_gate!,
    pushfirst_gate!,
    add_spider!,
    insert_wtrig!,
    expval_circ!,
    substitute_variables!,
    add_spider!,
    rem_spiders!,
    add_inout!



using MLStyle: @match

@testset "Phase rounding" begin
    st = Dict(
        1 => Z(Parameter(Val(:PiUnit), -1)),
        2 => Z(Parameter(Val(:PiUnit), -100 // 3)),
        3 => X(Parameter(Val(:PiUnit), 1.5)),
        4 => X(Parameter(Val(:PiUnit), 2 // 3)),
    )

    zxwd = ZXWDiagram(Multigraph(zeros(Int, 4, 4)), st)


    st_rounded = Dict(
        1 => Z(Parameter(Val(:PiUnit), 1)),
        2 => Z(Parameter(Val(:PiUnit), 2 // 3)),
        3 => X(Parameter(Val(:PiUnit), 1.5)),
        4 => X(Parameter(Val(:PiUnit), 2 // 3)),
    )

    round_phases!(zxwd)
    @test zxwd.st == st_rounded
    @test _round_phase(Parameter(Val(:PiUnit), -7)) == Parameter(Val(:PiUnit), 1)
    @test _round_phase(Parameter(Val(:PiUnit), 1)) == Parameter(Val(:PiUnit), 1)
    @test _round_phase(Parameter(Val(:PiUnit), 2)) == Parameter(Val(:PiUnit), 0)
    @test _round_phase(Parameter(Val(:Factor), exp(im * 1.5 * π))) ==
          Parameter(Val(:Factor), exp(im * 1.5 * π))
    @test _round_phase(Parameter(Val(:PiUnit), :a)) == Parameter(Val(:PiUnit), :a)
    @test _round_phase(Parameter(Val(:PiUnit), Expr(:call, :-, :a))) ==
          Parameter(Val(:PiUnit), Expr(:call, :-, :a))
end

@testset "ZXWDiagram Utilities" begin

    zxwd = ZXWDiagram(3)

    @test @match ZXW.spider_type(zxwd, 1) begin
        ZXW.Input(_) => true
        _ => false
    end

    @test_throws ErrorException("Spider 10 does not exist!") ZXW.spider_type(zxwd, 10)

    @test ZXW.parameter(zxwd, 1) == 1
    @test ZXW.set_phase!(zxwd, 1, Parameter(Val(:PiUnit), 2 // 3))
    @test !ZXW.set_phase!(zxwd, 10, Parameter(Val(:PiUnit), 2 // 3))

    @test ZXW.nqubits(zxwd) == 3
    @test ZXW.nin(zxwd) == 3 && ZXW.nout(zxwd) == 3
    @test ZXW.scalar(zxwd) == Scalar{Number}()
    @test nv(zxwd) == 6 && ne(zxwd) == 3

    @test rem_edge!(zxwd, 5, 6)
    @test outneighbors(zxwd, 5) == inneighbors(zxwd, 5)


    @test add_edge!(zxwd, 5, 6)
    @test neighbors(zxwd, 5) == [6]


    @test_throws ErrorException("The vertex to connect does not exist.") add_spider!(
        zxwd,
        W,
        [10, 15],
    )

    new_v = add_spider!(zxwd, W, [2, 3])


    @test @match zxwd.st[new_v] begin
        W => true
        _ => false
    end
    @test ZXW.parameter(zxwd, new_v) == Parameter(Val(:PiUnit), 0)

    new_v2 = add_spider!(zxwd, Z(Parameter(Val(:PiUnit), 1 // 2)), [2, 3])

    @test @match zxwd.st[new_v] begin
        Z => true
        _ => false
    end
    @test ZXW.set_phase!(zxwd, new_v2, Parameter(Val(:PiUnit), 3 // 2)) &&
          ZXW.parameter(zxwd, new_v2) == Parameter(Val(:PiUnit), 3 // 2)

    io = IOBuffer()

    print_spider(io, zxwd, new_v)
    @test String(take!(io)) == "S_7{W}"

    print_spider(io, zxwd, new_v2)
    @test String(take!(io)) ==
          "S_8{phase = Parameter.PiUnit(pu=3//2, pu_type=Rational{Int64})}"

    new_v3 = add_spider!(zxwd, Z(Parameter(Val(:Factor), 1)), [2, 3])
    print_spider(io, zxwd, new_v3)
    @test String(take!(io)) == "S_9{phase = Parameter.Factor(f=1, f_type=Int64)}"

    print_spider(io, zxwd, 2)
    @test String(take!(io)) == "S_2{output = 1}"

    rem_spiders!(zxwd, [2, 3, new_v])
    @test nv(zxwd) == 6 && ne(zxwd) == 1

    zxwd = ZXWDiagram(3)
    nqubits_prior = ZXW.nqubits(zxwd)
    add_inout!(zxwd, 3)
    @test ZXW.nqubits(zxwd) == nqubits_prior + 3
    @test ZXW.nin(zxwd) == nqubits_prior + 3
    @test ZXW.nout(zxwd) == nqubits_prior + 3
    nspiders = nv(zxwd)
    @test sort!([ZXW.get_inputs(zxwd)[end-2:end]; ZXW.get_outputs(zxwd)[end-2:end]]) ==
          collect(nspiders-5:nspiders)



end

@testset "gate insertion" begin

    zxwd = ZXWDiagram(2)

    pushfirst_gate!(zxwd, Val(:X), 1)
    pushfirst_gate!(zxwd, Val(:H), 1)
    pushfirst_gate!(zxwd, Val(:CNOT), 2, 1)
    pushfirst_gate!(zxwd, Val(:CZ), 1, 2)
    pushfirst_gate!(zxwd, Val(:SWAP), [2, 1])

    push_gate!(zxwd, Val(:X), 1, 0.5)
    @test zxwd.st[16] == X(Parameter(Val(:PiUnit), 1 // 2))
    push_gate!(zxwd, Val(:Z), 2, -0.5)
    @test zxwd.st[17] == Z(Parameter(Val(:PiUnit), -1 // 2))
    push_gate!(zxwd, Val(:Z), 1)
    @test zxwd.st[18] == Z(Parameter(Val(:PiUnit), 0 // 1))
    push_gate!(zxwd, Val(:H), 2)
    @test zxwd.st[19] == H

    @test insert_wtrig!(zxwd, [1, 2, 3, 4]) == 25
end


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
