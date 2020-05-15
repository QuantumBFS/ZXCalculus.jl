using ZX
using Multigraphs
using LightGraphs
using GraphPlot: gplot
using Colors

function Multigraph2Graph(mg::Multigraph)
    g = SimpleGraph(nv(mg))
    for me in edges(mg)
        add_edge!(g, src(me), dst(me))
    end
    # multiplicities = ["$(mul(mg, src(e), dst(e)))" for e in edges(g)]
    multiplicities = ["$(mg.adjmx[src(e), dst(e)])" for e in edges(g)]
    return g, multiplicities
end

ZX2Graph(zxd::ZXDiagram) = Multigraph2Graph(zxd.g)

function st2color(S::SType)
    S == Z && return colorant"green"
    S == X && return colorant"red"
    S == H && return colorant"yellow"
    S == In && return colorant"lightblue"
    S == Out && return colorant"gray"
end

ZX2nodefillc(zxd::ZXDiagram) = [st2color(zxd.st[v]) for v = 1:nv(zxd)]

function ZX2nodelabel(zxd::ZXDiagram)
    nodelabel = String[]
    for v = 1:nv(zxd)
        zxd.st[v] == Z && push!(nodelabel, "$(zxd.ps[v]) π")
        zxd.st[v] == X && push!(nodelabel, "$(zxd.ps[v]) π")
        zxd.st[v] == H && push!(nodelabel, "H")
        zxd.st[v] == In && push!(nodelabel, "In")
        zxd.st[v] == Out && push!(nodelabel, "Out")
    end
    return nodelabel
end

function ZXplot(zxd::ZXDiagram)
    g, edgelabel = ZX2Graph(zxd)
    nodelabel = ZX2nodelabel(zxd)
    nodefillc = ZX2nodefillc(zxd)
    edgelabelc = colorant"black"
    gplot(g, nodelabel = nodelabel, edgelabel = edgelabel, edgelabelc = edgelabelc, nodefillc = nodefillc)
end

g = Multigraph(6)
for e in [[1,3],[2,3],[3,4],[4,5],[4,6]]
    add_edge!(g, e)
end
ps = [0, 0, 0//1, 0//1, 0, 0]
v_t = [In, Out, X, Z, Out, In]
zxd = ZXDiagram(g, v_t, ps)
ZXplot(zxd)

rule_b!(zxd, 4, 3)
ZXplot(zxd)
