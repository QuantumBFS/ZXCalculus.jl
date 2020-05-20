using ZX
using LightGraphs
using GraphPlot: gplot
using Colors

function Multigraph2Graph(mg::Multigraph)
    g = SimpleGraph(nv(mg))
    vs = vertices(mg)
    for me in edges(mg)
        add_edge!(g, searchsortedfirst(vs, src(me)), searchsortedfirst(vs, dst(me)))
    end
    # multiplicities = ["$(mul(mg, src(e), dst(e)))" for e in edges(g)]
    multiplicities = ["$(mul(mg, vs[src(e)], vs[dst(e)]))" for e in edges(g)]
    return g, multiplicities
end

ZX2Graph(zxd::ZXDiagram) = Multigraph2Graph(zxd.mg)

function st2color(S::SType)
    S == Z && return colorant"green"
    S == X && return colorant"red"
    S == H && return colorant"yellow"
    S == In && return colorant"lightblue"
    S == Out && return colorant"gray"
end

ZX2nodefillc(zxd::ZXDiagram) = [st2color(zxd.st[v]) for v in vertices(zxd.mg)]

function ZX2nodelabel(zxd::ZXDiagram)
    nodelabel = String[]
    for v in vertices(zxd.mg)
        zxd.st[v] == Z && push!(nodelabel, "[$(v)] $(zxd.ps[v]) π")
        zxd.st[v] == X && push!(nodelabel, "[$(v)] $(zxd.ps[v]) π")
        zxd.st[v] == H && push!(nodelabel, "[$(v)] H")
        zxd.st[v] == In && push!(nodelabel, "[$(v)] In")
        zxd.st[v] == Out && push!(nodelabel, "[$(v)] Out")
    end
    return nodelabel
end

function ZXplot(zxd::ZXDiagram)
    g, edgelabel = ZX2Graph(zxd)
    nodelabel = ZX2nodelabel(zxd)
    nodefillc = ZX2nodefillc(zxd)
    edgelabelc = colorant"black"
    gplot(g, nodelabel = nodelabel, edgelabel = edgelabel, edgelabelc = edgelabelc, nodefillc = nodefillc,
        # NODESIZE = 0.35 / sqrt(nv(g)), EDGELINEWIDTH = 8.0 / sqrt(nv(g))
        )
end
