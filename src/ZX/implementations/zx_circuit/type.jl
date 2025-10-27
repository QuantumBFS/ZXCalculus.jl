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

"""
    $(TYPEDSIGNATURES)

Construct an empty ZX-circuit with `nbits` qubits.

Each qubit is represented by a pair of In/Out spiders connected by a simple edge.
This creates a minimal circuit structure ready for gate insertion.

# Example
```julia
julia> circ = ZXCircuit(3)
ZXCircuit with 3 inputs and 3 outputs...
```
"""
function ZXCircuit(nbits::T) where {T <: Integer}
    mg = Multigraph(2*nbits)
    st = Dict{T, SpiderType.SType}()
    ps = Dict{T, Phase}()
    et = Dict{Tuple{T, T}, EdgeType.EType}()
    spider_q = Dict{T, Rational{Int}}()
    spider_col = Dict{T, Rational{Int}}()

    inputs = Vector{T}()
    outputs = Vector{T}()

    for i in 1:nbits
        in_id = T(2*i-1)
        out_id = T(2*i)
        add_edge!(mg, in_id, out_id)

        st[in_id] = SpiderType.In
        st[out_id] = SpiderType.Out
        ps[in_id] = Phase(0//1)
        ps[out_id] = Phase(0//1)
        et[(in_id, out_id)] = EdgeType.SIM

        spider_q[in_id] = i
        spider_col[in_id] = 0
        spider_q[out_id] = i
        spider_col[out_id] = 1

        push!(inputs, in_id)
        push!(outputs, out_id)
    end

    layout = ZXLayout(nbits, spider_q, spider_col)
    zxg = ZXGraph{T, Phase}(mg, ps, st, et, Scalar{Phase}())
    phase_ids = Dict{T, Tuple{T, Int}}()

    return ZXCircuit(zxg, inputs, outputs, layout, phase_ids)
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
