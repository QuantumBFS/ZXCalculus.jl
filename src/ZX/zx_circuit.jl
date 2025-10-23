struct ZXCircuit{T, P} <: AbstractZXDiagram{T, P}
    zx_graph::ZXGraph{T, P}
    inputs::Vector{T}
    outputs::Vector{T}
    layout::ZXLayout{T}
end

function generate_layout!(circ::ZXCircuit{T, P}) where {T, P}
    zxg = circ.zx_graph
    layout = circ.layout
    inputs = circ.inputs
    outputs = circ.outputs

    nbits = length(inputs)
    vs_frontier = copy(inputs)
    vs_generated = Set(vs_frontier)
    for i in 1:nbits
        set_qubit!(layout, vs_frontier[i], i)
        set_column!(layout, vs_frontier[i], 1//1)
    end

    curr_col = 1//1

    while !(isempty(vs_frontier))
        vs_after = Set{Int}()
        for v in vs_frontier
            nb_v = neighbors(zxg, v)
            for v1 in nb_v
                if !(v1 in vs_generated) && !(v1 in vs_frontier)
                    push!(vs_after, v1)
                end
            end
        end
        for i in 1:length(vs_frontier)
            v = vs_frontier[i]
            set_loc!(layout, v, i, curr_col)
            push!(vs_generated, v)
        end
        vs_frontier = collect(vs_after)
        curr_col += 1
    end
    gad_col = 2//1
    for v in spiders(zxg)
        if degree(zxg, v) == 1 && spider_type(zxg, v) == SpiderType.Z
            v1 = neighbors(zxg, v)[1]
            set_loc!(layout, v, -1//1, gad_col)
            set_loc!(layout, v1, 0//1, gad_col)
            push!(vs_generated, v, v1)
            gad_col += 1
        elseif degree(zxg, v) == 0
            set_loc!(layout, v, 0//1, gad_col)
            gad_col += 1
            push!(vs_generated, v)
        end
    end
    for q in 1:length(outputs)
        set_loc!(layout, outputs[q], q, curr_col + 1)
        set_loc!(layout, neighbors(zxg, outputs[q])[1], q, curr_col)
    end
    for q in 1:length(inputs)
        set_qubit!(layout, neighbors(zxg, inputs[q])[1], q)
    end
    return layout
end