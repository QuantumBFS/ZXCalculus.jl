@testset "ZXWSpiderType" begin
    spider_vec =
        [Z(PiUnit(3, Int64)) Z(Factor(10)) X(PiUnit(3, Int64)) X(Factor(10)) W H D Input(10) Output(
            2,
        )]

    @test spider_vec[1].p == PiUnit(3, Int64)
    @test spider_vec[2].p == Factor(10)
    @test spider_vec[3].p == PiUnit(3, Int64)
    @test spider_vec[4].p == Factor(10)
    @test spider_vec[end-1].qubit == 10
    @test spider_vec[end].qubit == 2

end
# @testset "ZXWDiagram Constructors" begin

#     g = Multigraph([0 1 0; 1 0 1; 0 1 0])
#     ps = [Rational(-10 * i + 1, 2) for i = 1:3]
#     v_t = [ZXWSpiderType.W, ZXWSpiderType.Z, ZXWSpiderType.X]

#     @test_throws ErrorException("There should be a type for each spider!") ZXWDiagram(
#         g,
#         v_t[1:2],
#         ps,
#     )
#     @test_throws ErrorException("There should be a phase for each spider!") ZXWDiagram(
#         g,
#         v_t,
#         ps[1:2],
#     )

#     zxwd_vec = ZXWDiagram(g, v_t, ps)
#     zxwd_ps = [zxwd_vec.ps[v] for v in sort!(vertices(g))]
#     @test all(pp -> (exp(im * pp[1] * π) ≈ exp(im * pp[2] * π)), zip(ps, zxwd_ps))

#     zxwd_dic = ZXWDiagram(g, Dict(zip(1:3, v_t)), Dict(zip(1:3, ps)))

#     @test zxwd_vec.mg == zxwd_dic.mg &&
#           zxwd_vec.st == zxwd_dic.st &&
#           zxwd_vec.ps == zxwd_dic.ps

#     g = Multigraph([0 1 0 0; 1 0 0 0; 0 0 0 1; 0 0 1 0])
#     v_t = [ZXWSpiderType.In ZXWSpiderType.Out ZXWSpiderType.In ZXWSpiderType.Out]
#     ps = [0 // 1 for _ = 1:4]

#     zxwd_empty = ZXWDiagram(2)
#     @test zxwd_empty.mg.adjlist == g.adjlist &&
#           zxwd_empty.st == Dict(zip(1:4, v_t)) &&
#           zxwd_empty.ps == Dict(zip(1:4, ps))

#     zxwd_copy = copy(zxwd_vec)

#     @test zxwd_copy.mg.adjlist == zxwd_vec.mg.adjlist &&
#           zxwd_copy.st == zxwd_vec.st &&
#           zxwd_copy.ps == zxwd_vec.ps

# end
