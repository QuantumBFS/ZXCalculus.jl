struct ZXCircuit{T, P} <: AbstractZXDiagram{T, P}
    zx_graph::ZXGraph{T, P}
    inputs::Vector{T}
    outputs::Vector{T}
    layout::ZXLayout{T}

    # maps a vertex id to its master id and scalar multiplier
    phase_ids::Dict{T, Tuple{T, Int}}
    master::ZXDiagram{T, P}
end

function Base.show(io::IO, circ::ZXCircuit)
    println(io, "ZXCircuit with $(length(circ.inputs)) inputs and $(length(circ.outputs)) outputs and the following ZXGraph:")
    return show(io, circ.zx_graph)
end

function Base.copy(circ::ZXCircuit{T, P}) where {T, P}
    return ZXCircuit{T, P}(
        copy(circ.zx_graph),
        copy(circ.inputs),
        copy(circ.outputs),
        copy(circ.layout),
        copy(circ.phase_ids),
        copy(circ.master))
end

function ZXCircuit(zxd::ZXDiagram{T, P}) where {T, P}
    zxd = copy(zxd)
    nzxd = copy(zxd)
    inputs = zxd.inputs
    outputs = zxd.outputs
    layout = zxd.layout

    simplify!(Identity1Rule(), nzxd)
    simplify!(XToZRule(), nzxd)
    simplify!(HBoxRule(), nzxd)
    match_f = match(FusionRule(), nzxd)
    while length(match_f) > 0
        for m in match_f
            vs = m.vertices
            if check_rule(FusionRule(), nzxd, vs)
                rewrite!(FusionRule(), nzxd, vs)
                v1, v2 = vs
                set_phase!(zxd, v1, phase(zxd, v1) + phase(zxd, v2))
                set_phase!(zxd, v2, zero(P))
            end
        end
        match_f = match(FusionRule(), nzxd)
    end

    vs = spiders(nzxd)
    vH = T[]
    vZ = T[]
    vB = T[]
    for v in vs
        if spider_type(nzxd, v) == SpiderType.H
            push!(vH, v)
        elseif spider_type(nzxd, v) == SpiderType.Z
            push!(vZ, v)
        else
            push!(vB, v)
        end
    end
    eH = [(neighbors(nzxd, v, count_mul=true)[1], neighbors(nzxd, v, count_mul=true)[2]) for v in vH]

    rem_spiders!(nzxd, vH)
    et = Dict{Tuple{T, T}, EdgeType.EType}()
    for e in edges(nzxd.mg)
        et[(src(e), dst(e))] = EdgeType.SIM
    end
    zxg = ZXGraph{T, P}(
        nzxd.mg, nzxd.ps, nzxd.st, et, nzxd.scalar)

    for e in eH
        v1, v2 = e
        add_edge!(zxg, v1, v2)
    end

    return ZXCircuit(zxg, inputs, outputs, layout, nzxd.phase_ids, zxd)
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

nqubits(circ::ZXCircuit) = max(length(circ.inputs), length(circ.outputs))
spiders(circ::ZXCircuit) = spiders(circ.zx_graph)
spider_type(circ::ZXCircuit, v::Integer) = spider_type(circ.zx_graph, v)
spider_types(circ::ZXCircuit) = spider_types(circ.zx_graph)
phase(circ::ZXCircuit, v::Integer) = phase(circ.zx_graph, v)
phases(circ::ZXCircuit) = phases(circ.zx_graph)
set_phase!(circ::ZXCircuit{T, P}, args...) where {T, P} = set_phase!(circ.zx_graph, args...)
scalar(circ::ZXCircuit) = scalar(circ.zx_graph)

get_inputs(circ::ZXCircuit) = circ.inputs
get_outputs(circ::ZXCircuit) = circ.outputs

Graphs.has_edge(zxg::ZXCircuit, vs...) = has_edge(zxg.zx_graph, vs...)
Graphs.nv(zxg::ZXCircuit) = Graphs.nv(zxg.zx_graph)
Graphs.ne(zxg::ZXCircuit) = Graphs.ne(zxg.zx_graph)
Graphs.neighbors(zxg::ZXCircuit, v::Integer) = Graphs.neighbors(zxg.zx_graph, v)
Graphs.outneighbors(zxg::ZXCircuit, v::Integer) = Graphs.outneighbors(zxg.zx_graph, v)
Graphs.inneighbors(zxg::ZXCircuit, v::Integer) = Graphs.inneighbors(zxg.zx_graph, v)
Graphs.degree(zxg::ZXCircuit, v::Integer) = Graphs.degree(zxg.zx_graph, v)
Graphs.indegree(zxg::ZXCircuit, v::Integer) = Graphs.indegree(zxg.zx_graph, v)
Graphs.outdegree(zxg::ZXCircuit, v::Integer) = Graphs.outdegree(zxg.zx_graph, v)
Graphs.edges(zxg::ZXCircuit) = Graphs.edges(zxg.zx_graph)
function Graphs.add_edge!(zxg::ZXCircuit, v1::Integer, v2::Integer, etype::EdgeType.EType=EdgeType.HAD)
    return add_edge!(zxg.zx_graph, v1, v2, etype)
end
Graphs.rem_edge!(zxg::ZXCircuit, args...) = rem_edge!(zxg.zx_graph, args...)

is_hadamard(circ::ZXCircuit, v1::Integer, v2::Integer) = is_hadamard(circ.zx_graph, v1, v2)
add_global_phase!(circ::ZXCircuit{T, P}, p::P) where {T, P} = add_global_phase!(circ.zx_graph, p)
add_power!(circ::ZXCircuit, n::Integer) = add_power!(circ.zx_graph, n)
insert_spider!(circ::ZXCircuit{T, P}, args...) where {T, P} = insert_spider!(circ.zx_graph, args...)