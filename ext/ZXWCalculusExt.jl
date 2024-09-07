module ZXWCalculusExt

using WGLMakie, GraphMakie
using WGLMakie.Colors
using MLStyle
using ZXCalculus: ZXW
using ZXCalculus, ZXCalculus.ZXW
using ZXCalculus.ZXW: Z,X
using ZXCalculus.ZX.Graphs

function edge_click_action(idx, args...)
    red_green_blk = [RGB(1.,0.,0.), RGB(0.,1.,0.), RGB(0.,0.,0.)]
    which_color = findfirst(x -> x == p.edge_color[][idx], red_green_blk)
    p.edge_color[][idx] = red_green_blk[mod1(which_color+1,length(red_green_blk))]
    p.edge_color[] = p.edge_color[]
end

function ZXCalculus.ZXW.plot(zxwd::ZXWDiagram{T,P}; kwargs...) where {T,P}
    g = zxwd.mg
    f, ax, p = graphplot(g,
        edge_width=[2.0 for i in 1:ne(g)],
        edge_color=[colorant"black" for i in 1:ne(g)],
        node_size=[10 for i in 1:nv(g)],
        node_color=[
            @match spider_type(zxwd, i) begin
                Z(p) => colorant"red"
                X(p) => colorant"green"
                _ => colorant"yellow"
            end for i in 1:nv(g)])

    hidedecorations!(ax)
    hidespines!(ax)
    deregister_interaction!(ax, :rectanglezoom)
    register_interaction!(ax, :nhover, NodeHoverHighlight(p))
    register_interaction!(ax, :ehover, EdgeHoverHighlight(p))
    register_interaction!(ax, :ndrag, NodeDrag(p))
    eclick = EdgeClickHandler(edge_click_action)
    register_interaction!(ax, :eclick, eclick)
    f
end

end