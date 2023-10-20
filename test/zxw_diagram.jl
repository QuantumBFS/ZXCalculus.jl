using Test, ZXCalculus, Multigraphs, Graphs, ZXCalculus.ZXW
using ZXCalculus.ZXW: ZXWSpiderType, Input, Output, W, H, D, Z, X
using ZXCalculus.Utils: Parameter, PiUnit, Factor
using ZXCalculus: ZXW

@testset "ZXWSpiderType" begin

    spider_vec =
        [Z(Parameter(Val(:PiUnit), 3)) Z(Parameter(Val(:Factor), exp(im * 1.5 * π))) X(
            Parameter(Val(:PiUnit), 3),
        ) X(Parameter(Val(:Factor), exp(im * 0.5 * π))) W H D Input(10) Output(2)]

    @test spider_vec[1].p == Parameter(Val(:PiUnit), 3)
    @test spider_vec[2].p == Parameter(Val(:Factor), exp(im * 1.5 * π))
    @test spider_vec[3].p == Parameter(Val(:PiUnit), 3)
    @test spider_vec[4].p == Parameter(Val(:Factor), exp(im * 0.5 * π))
    @test spider_vec[end-1].qubit == 10
    @test spider_vec[end].qubit == 2

end

@testset "ZXWDiagram Constructors" begin

    g = Multigraph([0 1 0; 1 0 1; 0 1 0])
    st = [Z(Parameter(Val(:PiUnit), (-10 * i + 1) // 2)) for i = 1:3]

    @test_throws ErrorException("There should be a type for each spider!") ZXWDiagram(
        g,
        st[1:2],
    )

    zxwd_vec = ZXWDiagram(g, st)
    zxwd_st = [zxwd_vec.st[v] for v in sort!(vertices(g))]
    @test all(pp -> (exp(im * pp[1].p.pu * π) ≈ exp(im * pp[2].p.pu * π)), zip(st, zxwd_st))

    zxwd_dic = ZXWDiagram(g, Dict(zip(1:3, st)))

    @test zxwd_vec.mg == zxwd_dic.mg && zxwd_vec.st == zxwd_dic.st

    g = Multigraph([0 1 0 0; 1 0 0 0; 0 0 0 1; 0 0 1 0])
    v_t = [ZXW.Input(1) ZXW.Output(1) ZXW.Input(2) ZXW.Output(2)]

    zxwd_empty = ZXWDiagram(2)
    @test zxwd_empty.mg.adjlist == g.adjlist && zxwd_empty.st == Dict(zip(1:4, v_t))

    zxwd_copy = copy(zxwd_vec)

    @test zxwd_copy.mg.adjlist == zxwd_vec.mg.adjlist && zxwd_copy.st == zxwd_vec.st

end
