using ZXCalculus
using LightGraphs
using GraphPlot: gplot
using Colors
using ZXCalculus: qubit_loc

function Multigraph2Graph(mg::Multigraph)
    g = SimpleGraph(nv(mg))
    vs = vertices(mg)
    for me in edges(mg)
        add_edge!(g, searchsortedfirst(vs, src(me)), searchsortedfirst(vs, dst(me)))
    end
    # multiplicities = ["$(mul(mg, src(e), dst(e)))" for e in edges(g)]
    multiplicities = ["×$(mul(mg, vs[src(e)], vs[dst(e)]))" for e in edges(g)]
    for i = 1:length(multiplicities)
        if multiplicities[i] == "×1"
            multiplicities[i] = ""
        end
    end
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

function layout2locs(zxd::AbstractZXDiagram)
    lo = zxd.layout
    vs = spiders(zxd)
    locs = Dict()
    for v in vs
        if qubit_loc(lo, v) != nothing
            y = qubit_loc(lo, v)
            x = findfirst(isequal(v), lo.spider_seq[y])
            locs[v] = (Float64(x)*10, Float64(y))
        else
            locs[v] = nothing
        end
    end
    for v in vs
        if locs[v] == nothing
            v1, v2 = neighbors(zxd, v)
            x1, y1 = locs[v1]
            x2, y2 = locs[v2]
            locs[v] = ((x1+x2)/2, (y1+y2)/2)
        end
    end
    locs_x = [locs[v][1] for v in vs]
    locs_y = [locs[v][2] for v in vs]
    return locs_x, locs_y
end

function ZXplot(zxd::ZXDiagram)
    g, edgelabel = ZX2Graph(zxd)
    nodelabel = ZX2nodelabel(zxd)
    nodefillc = ZX2nodefillc(zxd)
    edgelabelc = colorant"black"
    locs_x, locs_y = layout2locs(zxd)
    gplot(g,
        locs_x, locs_y,
        nodelabel = nodelabel, edgelabel = edgelabel, edgelabelc = edgelabelc, nodefillc = nodefillc,
        linetype = "curve",
        # NODESIZE = 0.35 / sqrt(nv(g)), EDGELINEWIDTH = 8.0 / sqrt(nv(g))
        )
end
function ZXplot(zxd::ZXGraph)
    g, edge_types = ZX2Graph(zxd)

    nodelabel = ZX2nodelabel(zxd)
    nodefillc = ZX2nodefillc(zxd)
    edgestrokec = et2color.(edge_types)
    locs_x, locs_y = layout2locs(zxd)
    gplot(g,
        locs_x, locs_y,
        nodelabel = nodelabel, edgestrokec = edgestrokec, nodefillc = nodefillc,
        linetype = "curve",
        # NODESIZE = 0.35 / sqrt(nv(g)), EDGELINEWIDTH = 8.0 / sqrt(nv(g))
        )
end
