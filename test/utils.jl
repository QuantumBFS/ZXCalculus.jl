using .ZXCalculus: Parameter, _round_phase, round_phases!, print_spider
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

    @test @match spider_type(zxwd, 1) begin
        Input(_) => true
        _ => false
    end

    @test_throws ErrorException("Spider 10 does not exist!") spider_type(zxwd, 10)

    @test_throws ErrorException parameter(zxwd, 1)
    @test ZXCalculus.set_phase!(zxwd, 1, Parameter(Val(:PiUnit), 2 // 3))
    @test !ZXCalculus.set_phase!(zxwd, 10, Parameter(Val(:PiUnit), 2 // 3))

    @test ZXCalculus.nqubits(zxwd) == 3
    @test ZXCalculus.nin(zxwd) == 3 && ZXCalculus.nout(zxwd) == 3
    @test scalar(zxwd) == ZXCalculus.Scalar{Number}()
    @test nv(zxwd) == 6 && ne(zxwd) == 3

    @test rem_edge!(zxwd, 5, 6)
    @test outneighbors(zxwd, 5) == inneighbors(zxwd, 5)


    @test add_edge!(zxwd, 5, 6)
    @test neighbors(zxwd, 5) == [6]


    @test_throws ErrorException("The vertex to connect does not exist.") ZXCalculus.add_spider!(
        zxwd,
        W,
        [10, 15],
    )

    new_v = ZXCalculus.add_spider!(zxwd, W, [2, 3])


    @test @match zxwd.st[new_v] begin
        W => true
        _ => false
    end
    @test parameter(zxwd, new_v) == Parameter(Val(:PiUnit), 0)

    new_v2 = ZXCalculus.add_spider!(zxwd, Z(Parameter(Val(:PiUnit), 1 // 2)), [2, 3])

    @test @match zxwd.st[new_v] begin
        Z => true
        _ => false
    end
    @test ZXCalculus.set_phase!(zxwd, new_v2, Parameter(Val(:PiUnit), 3 // 2)) &&
          parameter(zxwd, new_v2) == Parameter(Val(:PiUnit), 3 // 2)

    io = IOBuffer()

    print_spider(io, zxwd, new_v)
    @test String(take!(io)) == "S_7{W}"

    print_spider(io, zxwd, new_v2)
    @test String(take!(io)) == "S_8{phase = Parameter.PiUnit(pu=3//2, pu_type=Rational{Int64})}"

    new_v3 = ZXCalculus.add_spider!(zxwd, Z(Parameter(Val(:Factor), 1)), [2, 3])
    print_spider(io, zxwd, new_v3)
    @test String(take!(io)) == "S_9{phase = Parameter.Factor(f=1, f_type=Int64)}"

    print_spider(io, zxwd, 2)
    @test String(take!(io)) == "S_2{output = 1}"

    rem_spiders!(zxwd, [2, 3, new_v])
    @test nv(zxwd) == 6 && ne(zxwd) == 1


    #TODO: Add test for construction of ZXWDiagram with empty circuit
    # einsum contraction should return all zero
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
