using ZXCalculus, LightGraphs

include("../script/zx_plot.jl")

function generate_example()
    zxd = ZXDiagram(4)
    push_gate!(zxd, Val{:Z}(), 1, 3//2)
    push_gate!(zxd, Val{:H}(), 1)
    push_gate!(zxd, Val{:Z}(), 1, 1//2)
    push_gate!(zxd, Val{:Z}(), 2, 1//2)
    push_gate!(zxd, Val{:H}(), 4)
    push_ctrl_gate!(zxd, Val{:CNOT}(), 3, 2)
    push_ctrl_gate!(zxd, Val{:CZ}(), 4, 1)
    push_gate!(zxd, Val{:H}(), 2)
    push_ctrl_gate!(zxd, Val{:CNOT}(), 3, 2)
    push_ctrl_gate!(zxd, Val{:CNOT}(), 1, 4)
    push_gate!(zxd, Val{:H}(), 1)
    push_gate!(zxd, Val{:Z}(), 2, 1//4)
    push_gate!(zxd, Val{:Z}(), 3, 1//2)
    push_gate!(zxd, Val{:H}(), 4)
    push_gate!(zxd, Val{:Z}(), 1, 1//4)
    push_gate!(zxd, Val{:H}(), 2)
    push_gate!(zxd, Val{:H}(), 3)
    push_gate!(zxd, Val{:Z}(), 4, 3//2)
    push_gate!(zxd, Val{:Z}(), 3, 1//2)
    push_gate!(zxd, Val{:X}(), 4, 1//1)
    push_ctrl_gate!(zxd, Val{:CNOT}(), 3, 2)
    push_gate!(zxd, Val{:H}(), 1)
    push_gate!(zxd, Val{:Z}(), 4, 1//2)
    push_gate!(zxd, Val{:X}(), 4, 1//1)

    zxd
end

zxd = generate_example()
ZXplot(zxd)

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

cir = circuit_extraction(zxg)
ZXplot(cir)
