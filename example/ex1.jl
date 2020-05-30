using ZXCalculus, LightGraphs

include("../script/zx_plot.jl")

mg = Multigraph(8)
ps = [0//1 for _ = 1:8]
st = [In, Out, In, Out, In, Out, In, Out]

zxd = ZXDiagram(mg, st, ps)
for e in [[1,2],[3,4],[5,6],[7,8]]
    add_edge!(zxd, e[1], e[2])
end
ZXCalculus.insert_spider!(zxd, 1, 2, Z, 3//2)
ZXCalculus.insert_spider!(zxd, 9, 2, H)
ZXCalculus.insert_spider!(zxd, 10, 2, Z, 1//2)
ZXCalculus.insert_spider!(zxd, 3, 4, Z, 1//2)
ZXCalculus.insert_spider!(zxd, 7, 8, H)

ZXCalculus.insert_spider!(zxd, 12, 4, Z)
ZXCalculus.insert_spider!(zxd, 5, 6, X)
add_edge!(zxd, 14, 15)

ZXCalculus.insert_spider!(zxd, 11, 2, Z)
ZXCalculus.insert_spider!(zxd, 13, 8, Z)
add_edge!(zxd, 16, 17)
ZXCalculus.insert_spider!(zxd, 16, 17, H)

ZXCalculus.insert_spider!(zxd, 14, 4, H)
ZXCalculus.insert_spider!(zxd, 19, 4, Z)
ZXCalculus.insert_spider!(zxd, 15, 6, X)
add_edge!(zxd, 20, 21)

ZXCalculus.insert_spider!(zxd, 16, 2, X)
ZXCalculus.insert_spider!(zxd, 17, 8, Z)
add_edge!(zxd, 22, 23)

ZXCalculus.insert_spider!(zxd, 22, 2, H)
ZXCalculus.insert_spider!(zxd, 24, 2, Z, 1//4)
ZXCalculus.insert_spider!(zxd, 25, 2, H)
ZXCalculus.insert_spider!(zxd, 23, 8, H)
ZXCalculus.insert_spider!(zxd, 27, 8, Z, 3//2)
ZXCalculus.insert_spider!(zxd, 28, 8, X, 1//1)
ZXCalculus.insert_spider!(zxd, 29, 8, Z, 1//2)
ZXCalculus.insert_spider!(zxd, 30, 8, X, 1//1)

ZXCalculus.insert_spider!(zxd, 20, 4, Z, 1//4)
ZXCalculus.insert_spider!(zxd, 32, 4, H)
ZXCalculus.insert_spider!(zxd, 21, 6, Z, 1//2)
ZXCalculus.insert_spider!(zxd, 34, 6, H)
ZXCalculus.insert_spider!(zxd, 35, 6, Z, 1//2)
ZXCalculus.insert_spider!(zxd, 33, 4, Z)
ZXCalculus.insert_spider!(zxd, 36, 6, X)
add_edge!(zxd, 37, 38)

ZXplot(zxd)

zxg = ZXGraph(zxd)
matches = match(Rule{:lc}(), zxg)
rewrite!(Rule{:lc}(), zxg, matches[1])
rewrite!(Rule{:lc}(), zxg, matches[2])
rewrite!(Rule{:lc}(), zxg, matches[4])
rewrite!(Rule{:lc}(), zxg, matches[3])

matches = match(Rule{:pab}(), zxg)
rewrite!(Rule{:pab}(), zxg, matches[2])
rewrite!(Rule{:pab}(), zxg, matches[4])

ZXplot(zxg)
