using DocStringExtensions

"""
$(TYPEDEF)

This is the type for representing ZX-diagrams.

!!! warning "Deprecated"

    `ZXDiagram` is deprecated and will be removed in a future version.
    Please use `ZXCircuit` instead for circuit representations.

    `ZXCircuit` provides the same functionality with better separation of concerns
    and more efficient graph-based simplification algorithms.

# Fields

$(TYPEDFIELDS)
"""
struct ZXDiagram{T <: Integer, P <: AbstractPhase} <: AbstractZXCircuit{T, P}
    "The underlying multigraph structure"
    mg::Multigraph{T}

    "Spider types indexed by vertex"
    st::Dict{T, SpiderType.SType}
    "Phases of spiders indexed by vertex"
    ps::Dict{T, P}

    "Layout information for visualization"
    layout::ZXLayout{T}
    "Maps vertex id to its master id and scalar multiplier"
    phase_ids::Dict{T, Tuple{T, Int}}

    "Global scalar factor"
    scalar::Scalar{P}
    "Ordered input spider vertices"
    inputs::Vector{T}
    "Ordered output spider vertices"
    outputs::Vector{T}

    function ZXDiagram{T, P}(
            mg::Multigraph{T},
            st::Dict{T, SpiderType.SType},
            ps::Dict{T, P},
            layout::ZXLayout{T},
            phase_ids::Dict{T, Tuple{T, Int}}=Dict{T, Tuple{T, Int}}(),
            s::Scalar{P}=Scalar{P}(),
            inputs::Vector{T}=Vector{T}(),
            outputs::Vector{T}=Vector{T}(),
            round_phases::Bool=true
    ) where {T <: Integer, P}
        if nv(mg) == length(ps) && nv(mg) == length(st)
            if length(phase_ids) == 0
                for v in vertices(mg)
                    if st[v] in (SpiderType.Z, SpiderType.X)
                        phase_ids[v] = (v, 1)
                    end
                end
            end
            if length(inputs) == 0
                for v in vertices(mg)
                    if st[v] == SpiderType.In
                        push!(inputs, v)
                    end
                end
                if layout.nbits > 0
                    sort!(inputs, by=(v -> qubit_loc(layout, v)))
                end
            end
            if length(outputs) == 0
                for v in vertices(mg)
                    if st[v] == SpiderType.Out
                        push!(outputs, v)
                    end
                end
                if layout.nbits > 0
                    sort!(outputs, by=(v -> qubit_loc(layout, v)))
                end
            end
            zxd = new{T, P}(mg, st, ps, layout, phase_ids, s, inputs, outputs)
            if round_phases
                round_phases!(zxd)
            end
            return zxd
        else
            error("There should be a phase and a type for each spider!")
        end
    end
end

"""
    ZXDiagram(mg::Multigraph{T}, st::Dict{T, SpiderType.SType}, ps::Dict{T, P},
        layout::ZXLayout{T} = ZXLayout{T}(),
        phase_ids::Dict{T,Tuple{T, Int}} = Dict{T,Tuple{T,Int}}()) where {T, P}
    ZXDiagram(mg::Multigraph{T}, st::Vector{SpiderType.SType}, ps::Vector{P},
        layout::ZXLayout{T} = ZXLayout{T}()) where {T, P}

Construct a ZXDiagram with all information.
"""
function ZXDiagram(mg::Multigraph{T}, st::Dict{T, SpiderType.SType}, ps::Dict{T, P},
        layout::ZXLayout{T}=ZXLayout{T}(),
        phase_ids::Dict{T, Tuple{T, Int}}=Dict{T, Tuple{T, Int}}()) where {T, P}
    return ZXDiagram{T, P}(mg, st, ps, layout, phase_ids)
end

function ZXDiagram(mg::Multigraph{T}, st::Vector{SpiderType.SType}, ps::Vector{P},
        layout::ZXLayout{T}=ZXLayout{T}()) where {T, P}
    return ZXDiagram(mg, Dict(zip(sort!(vertices(mg)), st)), Dict(zip(sort!(vertices(mg)), ps)), layout)
end

"""
    ZXDiagram(nbits)

!!! warning "Deprecated"

    `ZXDiagram` is deprecated. Use `ZXCircuit` instead.

Construct a ZXDiagram of a empty circuit with qubit number `nbit`

```
julia> zxd = ZXDiagram(3)
ZX-diagram with 6 vertices and 3 multiple edges:
(S_1{input} <-1-> S_2{output})
(S_3{input} <-1-> S_4{output})
(S_5{input} <-1-> S_6{output})
```
"""
function ZXDiagram(nbits::T) where {T <: Integer}
    Base.depwarn("ZXDiagram is deprecated, use ZXCircuit instead", :ZXDiagram)
    mg = Multigraph(2*nbits)
    st = [SpiderType.In for _ in 1:(2 * nbits)]
    ps = [Phase(0//1) for _ in 1:(2 * nbits)]
    spider_q = Dict{T, Rational{Int}}()
    spider_col = Dict{T, Rational{Int}}()
    for i in 1:nbits
        add_edge!(mg, 2*i-1, 2*i)
        @inbounds st[2 * i] = SpiderType.Out
        spider_q[2 * i - 1] = i
        spider_col[2 * i - 1] = 2
        spider_q[2 * i] = i
        spider_col[2 * i] = 1
    end
    layout = ZXLayout(nbits, spider_q, spider_col)
    return ZXDiagram(mg, st, ps, layout)
end

function Base.copy(zxd::ZXDiagram{T, P}) where {T, P}
    return ZXDiagram{T, P}(copy(zxd.mg), copy(zxd.st), copy(zxd.ps), copy(zxd.layout),
        deepcopy(zxd.phase_ids), copy(zxd.scalar), copy(zxd.inputs), copy(zxd.outputs))
end

function print_spider(io::IO, zxd::ZXDiagram{T, P}, v::T) where {T <: Integer, P}
    st_v = spider_type(zxd, v)
    if st_v == SpiderType.Z
        printstyled(io, "S_$(v){phase = $(zxd.ps[v])"*(zxd.ps[v] isa Phase ? "}" : "⋅π}"); color=:green)
    elseif st_v == SpiderType.X
        printstyled(io, "S_$(v){phase = $(zxd.ps[v])"*(zxd.ps[v] isa Phase ? "}" : "⋅π}"); color=:red)
    elseif st_v == SpiderType.H
        printstyled(io, "S_$(v){H}"; color=:yellow)
    elseif st_v == SpiderType.In
        print(io, "S_$(v){input}")
    elseif st_v == SpiderType.Out
        print(io, "S_$(v){output}")
    end
end

function Base.show(io::IO, zxd::ZXDiagram{T, P}) where {T <: Integer, P}
    println(io, "ZX-diagram with $(nv(zxd.mg)) vertices and $(ne(zxd.mg)) multiple edges:")
    for v1 in sort!(vertices(zxd.mg))
        for v2 in neighbors(zxd.mg, v1)
            if v2 >= v1
                print(io, "(")
                print_spider(io, zxd, v1)
                print(io, " <-$(mul(zxd.mg, v1, v2))-> ")
                print_spider(io, zxd, v2)
                print(io, ")\n")
            end
        end
    end
end

nout(zxd::ZXDiagram) = length(zxd.outputs)
nin(zxd::ZXDiagram) = length(zxd.inputs)

function ZXGraph(zxd::ZXDiagram{T, P}) where {T, P}
    zxd = copy(zxd)
    simplify!(ParallelEdgeRemovalRule(), zxd)
    et = Dict{Tuple{T, T}, EdgeType.EType}()
    for e in edges(zxd)
        @assert mul(zxd, src(e), dst(e)) == 1 "ZXCircuit: multiple edges should have been removed."
        s, d = src(e), dst(e)
        et[(min(s, d), max(s, d))] = EdgeType.SIM
    end
    return ZXGraph{T, P}(zxd.mg, zxd.ps, zxd.st, et, zxd.scalar)
end
