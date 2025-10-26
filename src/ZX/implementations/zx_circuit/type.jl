using DocStringExtensions

"""
$(TYPEDEF)

This is the type for representing ZX-circuits with explicit circuit structure.

ZXCircuit separates the graph representation (ZXGraph) from circuit semantics
(ordered inputs/outputs and layout). This design enables efficient graph-based
simplification while maintaining circuit structure for extraction and visualization.

# Fields
$(TYPEDFIELDS)
"""
struct ZXCircuit{T, P} <: AbstractZXCircuit{T, P}
    "The underlying ZXGraph representation"
    zx_graph::ZXGraph{T, P}
    "Ordered input spider vertices"
    inputs::Vector{T}
    "Ordered output spider vertices"
    outputs::Vector{T}
    "Layout information for visualization"
    layout::ZXLayout{T}

    "Maps vertex id to its master id and scalar multiplier for phase tracking"
    phase_ids::Dict{T, Tuple{T, Int}}
    "Reference to master circuit for phase tracking (optional)"
    master::Union{Nothing, ZXCircuit{T, P}}
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
        isnothing(circ.master) ? nothing : copy(circ.master))
end

# Basic constructor without master
function ZXCircuit(zxg::ZXGraph{T, P}, inputs::Vector{T}, outputs::Vector{T},
        layout::ZXLayout{T}, phase_ids::Dict{T, Tuple{T, Int}}) where {T, P}
    return ZXCircuit{T, P}(zxg, inputs, outputs, layout, phase_ids, nothing)
end

function ZXCircuit(zxd::ZXDiagram{T, P}; track_phase::Bool=true, normalize::Bool=true) where {T, P}
    zxg = ZXGraph(zxd)
    inputs = zxd.inputs
    outputs = zxd.outputs
    layout = zxd.layout
    phase_ids = Dict{T, Tuple{T, Int}}(
        (v, (v, 1)) for v in spiders(zxg) if spider_type(zxg, v) in (SpiderType.Z, SpiderType.X)
    )
    circ = ZXCircuit(zxg, inputs, outputs, layout, phase_ids, nothing)
    track_phase && (circ = phase_tracker(circ))
    normalize && to_z_form!(circ)
    return circ
end

function ZXCircuit(zxg::ZXGraph{T, P}) where {T, P}
    inputs = find_inputs(zxg)
    outputs = find_outputs(zxg)
    layout = ZXLayout{T}()
    phase_ids = Dict{T, Tuple{T, Int}}()
    return ZXCircuit(zxg, inputs, outputs, layout, phase_ids, nothing)
end

function ZXDiagram(circ::ZXCircuit{T, P}) where {T, P}
    layout = circ.layout
    phase_ids = circ.phase_ids
    inputs = circ.inputs
    outputs = circ.outputs

    zxg = copy(circ.zx_graph)
    simplify!(HEdgeRule(), zxg)
    ps = phases(zxg)
    st = spider_types(zxg)
    return ZXDiagram{T, P}(zxg.mg, st, ps, layout, phase_ids, scalar(zxg), inputs, outputs)
end
