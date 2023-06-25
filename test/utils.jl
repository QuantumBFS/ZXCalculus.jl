using .ZXCalculus: Parameter, _round_phase, round_phases!

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
    @test _round_phase(Z(Parameter(-7, "PiUnit"))) == Z(Parameter(1, "PiUnit"))
    @test _round_phase(Z(Parameter(1, "PiUnit"))) == Z(Parameter(1, "PiUnit"))
    @test _round_phase(X(Parameter(2, "PiUnit"))) == X(Parameter(0, "PiUnit"))
    @test _round_phase(X(Parameter(1.5, "Factor"))) == X(Parameter(1.5, "Factor"))
    @test _round_phase(W) == W
end

# @testset "ZXWDiagram Utilities" begin

#     zxwd = ZXWDiagram(3)

#     @test spider_type(zxwd, 1) == ZXWSpiderType.In
#     @test_throws ErrorException("Spider 10 does not exist!") spider_type(zxwd, 10)

#     @test phase(zxwd, 1) == Phase(0)
#     @test ZXCalculus.set_phase!(zxwd, 1, Phase(2 // 3)) && (phase(zxwd, 1) == Phase(0))
#     @test !ZXCalculus.set_phase!(zxwd, 10, Phase(2 // 3))


#     @test ZXCalculus.nqubits(zxwd) == 3
#     @test nv(zxwd) == 6 && ne(zxwd) == 3

#     @test rem_edge!(zxwd, 5, 6)
#     @test outneighbors(zxwd, 5) == inneighbors(zxwd, 5)

#     @test add_edge!(zxwd, 5, 6)
#     @test neighbors(zxwd, 5) == [6]

#     @test_throws ErrorException("The vertex to connect does not exist.") ZXCalculus.add_spider!(
#         zxwd,
#         ZXWSpiderType.W,
#         Phase(1 // 2),
#         [10, 15],
#     )

#     new_v = ZXCalculus.add_spider!(zxwd, ZXWSpiderType.W, Phase(1 // 2), [2, 3])
#     @test spider_type(zxwd, new_v) == ZXWSpiderType.W
#     @test phase(zxwd, new_v) == Rational(0)

#     rem_spiders!(zxwd, [2, 3, new_v])
#     @test nv(zxwd) == 4 && ne(zxwd) == 1


#     #TODO: Add test for construction of ZXWDiagram with empty circuit
#     # einsum contraction should return all zero


#     #TODO: Add test for printing of ZXWDiagram
# end
