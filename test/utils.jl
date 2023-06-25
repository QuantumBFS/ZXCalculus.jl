using .ZXCalculus: Parameter, _round_phase, round_phases!, print_spider
using MLStyle: @match

@testset "Phase rounding" begin
    st = Dict(
        1 => Z(Parameter(-1, "PiUnit")),
        2 => Z(Parameter(-100 // 3, "PiUnit")),
        3 => X(Parameter(1.5, "PiUnit")),
        4 => X(Parameter(2 // 3, "PiUnit")),
    )

    zxwd = ZXWDiagram(Multigraph(zeros(Int, 4, 4)), st)


    st_rounded = Dict(
        1 => Z(Parameter(1, "PiUnit")),
        2 => Z(Parameter(2 // 3, "PiUnit")),
        3 => X(Parameter(1.5, "PiUnit")),
        4 => X(Parameter(2 // 3, "PiUnit")),
    )

    round_phases!(zxwd)
    @test zxwd.st == st_rounded
    @test _round_phase(Parameter(-7, "PiUnit")) == Parameter(1, "PiUnit")
    @test _round_phase(Parameter(1, "PiUnit")) == Parameter(1, "PiUnit")
    @test _round_phase(Parameter(2, "PiUnit")) == Parameter(0, "PiUnit")
    @test _round_phase(Parameter(1.5, "Factor")) == Parameter(1.5, "Factor")
end

@testset "ZXWDiagram Utilities" begin

    zxwd = ZXWDiagram(3)

    @test @match spider_type(zxwd, 1) begin
        Input(_) => true
        _ => false
    end

    @test_throws ErrorException("Spider 10 does not exist!") spider_type(zxwd, 10)

    @test_throws ErrorException parameter(zxwd, 1)
    @test ZXCalculus.set_phase!(zxwd, 1, PiUnit(2 // 3, Rational))
    @test !ZXCalculus.set_phase!(zxwd, 10, PiUnit(2 // 3, Rational))

    @test ZXCalculus.nqubits(zxwd) == 3
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
    @test parameter(zxwd, new_v) == PiUnit(0, Int64)

    new_v2 = ZXCalculus.add_spider!(zxwd, Z(PiUnit(1 // 2, Rational)), [2, 3])

    @test @match zxwd.st[new_v] begin
        Z => true
        _ => false
    end
    @test ZXCalculus.set_phase!(zxwd, new_v2, PiUnit(3 // 2, Rational)) &&
          parameter(zxwd, new_v2) == PiUnit(3 // 2, Rational)

    io = IOBuffer()

    print_spider(io, zxwd, new_v)
    @test String(take!(io)) == "S_7{W}"

    print_spider(io, zxwd, new_v2)
    @test String(take!(io)) == "S_8{phase = 3//2⋅π}"

    new_v3 = ZXCalculus.add_spider!(zxwd, Z(Parameter(1, "Factor")), [2, 3])
    print_spider(io, zxwd, new_v3)
    @test String(take!(io)) == "S_9{phase = 1}"

    print_spider(io, zxwd, 2)
    @test String(take!(io)) == "S_2{output = 1}"

    rem_spiders!(zxwd, [2, 3, new_v])
    @test nv(zxwd) == 6 && ne(zxwd) == 1


    #TODO: Add test for construction of ZXWDiagram with empty circuit
    # einsum contraction should return all zero

end
