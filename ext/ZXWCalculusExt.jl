module ZXWCalculusExt

using WGLMakie, GraphMakie
using WGLMakie.Colors
using MLStyle
using ZXCalculus: ZXW
using ZXCalculus, ZXCalculus.ZXW
using ZXCalculus.ZXW: Z, X, Input, Output, spider_type
using ZXCalculus.ZX.Graphs


function ZXCalculus.ZXW.plot(zxwd::ZXWDiagram{T,P}; kwargs...) where {T,P}
    g = zxwd.mg

    f, ax, p = graphplot(g,
        edge_width=[2.0 for i in 1:ne(g)],
        edge_color=[colorant"black" for i in 1:ne(g)],
        node_size=[15 for i in 1:nv(g)],
        node_color=[
            @match spider_type(zxwd, i) begin
                Z(p) => colorant"red"
                X(p) => colorant"green"
                Input(q) => colorant"orange"
                Output(q) => colorant"magenta"
                _ => colorant"black"
            end for i in 1:nv(g)],kwargs...)

    hidedecorations!(ax)
    hidespines!(ax)
    deregister_interaction!(ax, :rectanglezoom)

    function edge_click_action(idx, args...)
        print("Enter the color: ")
        which_color = readline()
        p.edge_color[][idx] = parse(Colorant, which_color) 
        p.edge_color[] = p.edge_color[]
    end

    register_interaction!(ax, :nhover, NodeHoverHighlight(p))
    register_interaction!(ax, :ehover, EdgeHoverHighlight(p))
    register_interaction!(ax, :ndrag, NodeDrag(p))
    eclick = EdgeClickHandler(edge_click_action)
    register_interaction!(ax, :eclick, eclick)
    f
end

end