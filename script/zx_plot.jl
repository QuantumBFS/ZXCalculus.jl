using ZXCalculus
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
ZX2Graph(zxg::ZXGraph) = Multigraph2Graph(zxg.mg)

function et2color(et::String)
    et == "1" && return colorant"black"
    et == "2" && return colorant"blue"
end

function st2color(S::SType)
    S == Z && return colorant"green"
    S == X && return colorant"red"
    S == H && return colorant"yellow"
    S == In && return colorant"lightblue"
    S == Out && return colorant"gray"
end

ZX2nodefillc(zxd) = [st2color(zxd.st[v]) for v in vertices(zxd.mg)]

function ZX2nodelabel(zxd)
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
function ZXplot(zxd::ZXGraph)
    g, edge_types = ZX2Graph(zxd)
    println(edge_types)

    nodelabel = ZX2nodelabel(zxd)
    nodefillc = ZX2nodefillc(zxd)
    edgestrokec = et2color.(edge_types)
    gplot(g, nodelabel = nodelabel, edgestrokec = edgestrokec, nodefillc = nodefillc,
        # NODESIZE = 0.35 / sqrt(nv(g)), EDGELINEWIDTH = 8.0 / sqrt(nv(g))
        )
end
