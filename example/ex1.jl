using ZXCalculus, LightGraphs

include("../script/zx_plot.jl")

function generate_example()
    zxd = ZXDiagram(4)
    push_Z!(zxd, 1, 3//2)
    push_H!(zxd, 1)
    push_Z!(zxd, 1, 1//2)
    push_Z!(zxd, 2, 1//2)
    push_H!(zxd, 4)
    push_CNOT!(zxd, 2, 3)
    push_CZ!(zxd, 1, 4)
    push_H!(zxd, 2)
    push_CNOT!(zxd, 2, 3)
    push_CNOT!(zxd, 4, 1)
    push_H!(zxd, 1)
    push_Z!(zxd, 2, 1//4)
    push_Z!(zxd, 3, 1//2)
    push_H!(zxd, 4)
    push_Z!(zxd, 1, 1//4)
    push_H!(zxd, 2)
    push_H!(zxd, 3)
    push_Z!(zxd, 4, 3//2)
    push_Z!(zxd, 3, 1//2)
    push_X!(zxd, 4, 1//1)
    push_CNOT!(zxd, 2, 3)
    push_H!(zxd, 1)
    push_Z!(zxd, 4, 1//2)
    push_X!(zxd, 4, 1//1)

    zxd
end

zxd = generate_example()
ZXplot(zxd)
zxd.layout.spider_seq

zxg = ZXGraph(zxd)
ZXplot(zxg)
matches = match(Rule{:lc}(), zxg)
[matches[i].vertices[1] for i = 1:5]
rewrite!(Rule{:lc}(), zxg, matches[1])
ZXplot(zxg)
rewrite!(Rule{:lc}(), zxg, matches[3])
ZXplot(zxg)
rewrite!(Rule{:lc}(), zxg, matches[2])
ZXplot(zxg)
rewrite!(Rule{:lc}(), zxg, matches[5])
ZXplot(zxg)

matches = match(Rule{:pab}(), zxg)
rewrite!(Rule{:pab}(), zxg, matches[2])
rewrite!(Rule{:pab}(), zxg, matches[4])

ZXplot(zxg)
zxg.layout.spider_seq
