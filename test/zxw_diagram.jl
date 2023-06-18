g = Multigraph([0 1 0; 1 0 1; 0 1 0])
ps = [Rational(-10 * i + 1, 2) for i = 1:3]
v_t = [SpiderType.W, SpiderType.Z, SpiderType.X]

@test_throws ErrorException("There should be a type for each spider!") ZXWDiagram(
    g,
    v_t[1:2],
    ps,
)
@test_throws ErrorException("There should be a phase for each spider!") ZXWDiagram(
    g,
    v_t,
    ps[1:2],
)

zxwd_vec = ZXWDiagram(g, v_t, ps)
zxwd_ps = [zxwd_vec.ps[v] for v in sort!(vertices(g))]
@test all(pp -> (exp(im * pp[1] * π) ≈ exp(im * pp[2] * π)), zip(ps, zxwd_ps))

zxwd_dic = ZXWDiagram(g, Dict(zip(1:3, v_t)), Dict(zip(1:3, ps)))

@test zxwd_vec.mg == zxwd_dic.mg && zxwd_vec.st == zxwd_dic.st && zxwd_vec.ps == zxwd_dic.ps


@test spider_type(zxwd_vec, 1) == SpiderType.W
@test phase(zxwd_vec, 1) == Rational(0)

@test ZXCalculus.set_phase!(zxwd_vec, 1, 2 // 3) && (phase(zxwd_vec, 1) == Rational(0))
@test !(ZXCalculus.set_phase!(zxwd_vec, 10, 2 // 3))

@test nv(zxwd_vec) == 3 && ne(zxwd_vec) == 2
@test rem_edge!(zxwd_vec, 2, 3)
@test outneighbors(zxwd_vec, 2) == inneighbors(zxwd_vec, 2)

@test add_edge!(zxwd_vec, 2, 3)
@test neighbors(zxwd_vec, 2) == [1, 3]

new_v = ZXCalculus.add_spider!(zxwd_vec, SpiderType.W, 1 // 2, [2, 3])
@test phase(zxwd_vec, new_v) == Rational(0)

@test_throws ErrorException("The vertex to connect does not exist.") ZXCalculus.add_spider!(
    zxwd_vec,
    SpiderType.W,
    1 // 2,
    [8, 7, 4],
)

# TODO: defer testing until layout is migrated
# rem_spiders!(zxwd_vec, [1, 2, 3])
# @test nv(zxwd_vec) == 0 && ne(zxwd_vec) == 0



#TODO: Add test for construction of ZXWDiagram with empty circuit
# einsum contraction should return all zero

g = Multigraph([0 1 0 0; 1 0 0 0; 0 0 0 1; 0 0 1 0])
v_t = [SpiderType.In SpiderType.Out SpiderType.In SpiderType.Out]
ps = [0 // 1 for _ = 1:4]

zxwd_empty = ZXWDiagram(2)
@test zxwd_empty.mg.adjlist == g.adjlist &&
      zxwd_empty.st == Dict(zip(1:4, v_t)) &&
      zxwd_empty.ps == Dict(zip(1:4, ps))

zxwd_copy = copy(zxwd_vec)

@test zxwd_copy.mg.adjlist == zxwd_vec.mg.adjlist &&
      zxwd_copy.st == zxwd_vec.st &&
      zxwd_copy.ps == zxwd_vec.ps

#TODO: Add test for printing of ZXWDiagram
