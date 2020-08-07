g = Multigraph(6)
add_edge!(g, 1, 3)
add_edge!(g, 2, 4)
add_edge!(g, 3, 4)
add_edge!(g, 3, 5)
add_edge!(g, 4, 6)
ps = [0//1 for i = 1:6]
v_t = [SpiderType.In, SpiderType.In, SpiderType.X, SpiderType.Z, SpiderType.Out, SpiderType.Out]
zxd = ZXDiagram(g, v_t, ps)
zxg1 = ZXGraph(zxd)
@test outneighbors(zxg1, 1) == inneighbors(zxg1, 1)
@test !ZXCalculus.is_hadamard(zxg1, 2, 4) && !ZXCalculus.is_hadamard(zxg1, 4, 6)
@test add_edge!(zxg1, 1, 1)
@test !add_edge!(zxg1, 2, 4)
@test !add_edge!(zxg1, 7, 8)
@test sum([ZXCalculus.is_hadamard(zxg1, src(e), dst(e)) for e in edges(zxg1.mg)]) == 3
replace!(Rule{:b}(), zxd)
zxg2 = ZXGraph(zxd)
@test !ZXCalculus.is_hadamard(zxg2, 5, 8) && !ZXCalculus.is_hadamard(zxg2, 1, 7)
