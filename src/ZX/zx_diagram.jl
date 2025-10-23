module SpiderType
@enum SType Z X H In Out
end  # module SpiderType

"""
    ZXDiagram{T, P}

This is the type for representing ZX-diagrams.
"""
struct ZXDiagram{T <: Integer, P <: AbstractPhase} <: AbstractZXDiagram{T, P}
    mg::Multigraph{T}

    st::Dict{T, SpiderType.SType}
    ps::Dict{T, P}

    layout::ZXLayout{T}
    phase_ids::Dict{T, Tuple{T, Int}}

    scalar::Scalar{P}
    inputs::Vector{T}
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

Construct a ZXDiagram of a empty circuit with qubit number `nbit`

```jldoctest; setup = :(using ZXCalculus.ZX)
julia> zxd = ZXDiagram(3)
ZX-diagram with 6 vertices and 3 multiple edges:
(S_1{input} <-1-> S_2{output})
(S_3{input} <-1-> S_4{output})
(S_5{input} <-1-> S_6{output})
```
"""
function ZXDiagram(nbits::T) where {T <: Integer}
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

"""
    spider_type(zxd, v)

Returns the spider type of a spider.
"""
spider_type(zxd::ZXDiagram{T, P}, v::T) where {T <: Integer, P} = zxd.st[v]

"""
    phase(zxd, v)

Returns the phase of a spider. If the spider is not a Z or X spider, then return 0.
"""
phase(zxd::ZXDiagram{T, P}, v::T) where {T <: Integer, P} = zxd.ps[v]

"""
    set_phase!(zxd, v, p)

Set the phase of `v` in `zxd` to `p`.
"""
function set_phase!(zxd::ZXDiagram{T, P}, v::T, p::P) where {T, P}
    if has_vertex(zxd.mg, v)
        while p < 0
            p += 2
        end
        zxd.ps[v] = round_phase(p)
        return true
    end
    return false
end

"""
    nqubits(zxd)

Returns the qubit number of a ZX-diagram.
"""
nqubits(zxd::ZXDiagram) = zxd.layout.nbits

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

"""
    nv(zxd)

Returns the number of vertices (spiders) of a ZX-diagram.
"""
Graphs.nv(zxd::ZXDiagram) = nv(zxd.mg)

"""
    ne(zxd; count_mul = false)

Returns the number of edges of a ZX-diagram. If `count_mul`, it will return the
sum of multiplicities of all multiple edges. Otherwise, it will return the
number of multiple edges.
"""
Graphs.ne(zxd::ZXDiagram; count_mul::Bool=false) = ne(zxd.mg, count_mul=count_mul)

Graphs.outneighbors(zxd::ZXDiagram, v; count_mul::Bool=false) = outneighbors(zxd.mg, v, count_mul=count_mul)
Graphs.inneighbors(zxd::ZXDiagram, v; count_mul::Bool=false) = inneighbors(zxd.mg, v, count_mul=count_mul)

Graphs.degree(zxd::ZXDiagram, v::Integer) = degree(zxd.mg, v)
Graphs.indegree(zxd::ZXDiagram, v::Integer) = degree(zxd, v)
Graphs.outdegree(zxd::ZXDiagram, v::Integer) = degree(zxd, v)

"""
    neighbors(zxd, v; count_mul = false)

Returns a vector of vertices connected to `v`. If `count_mul`, there will be
multiple copy for each vertex. Otherwise, each vertex will only appear once.
"""
Graphs.neighbors(zxd::ZXDiagram, v; count_mul::Bool=false) = neighbors(zxd.mg, v, count_mul=count_mul)
function Graphs.rem_edge!(zxd::ZXDiagram, x...)
    return rem_edge!(zxd.mg, x...)
end
function Graphs.add_edge!(zxd::ZXDiagram, x...)
    return add_edge!(zxd.mg, x...)
end

"""
    rem_spiders!(zxd, vs)

Remove spiders indexed by `vs`.
"""
function rem_spiders!(zxd::ZXDiagram{T, P}, vs::Vector{T}) where {T <: Integer, P}
    if rem_vertices!(zxd.mg, vs)
        for v in vs
            delete!(zxd.ps, v)
            delete!(zxd.st, v)
            delete!(zxd.phase_ids, v)
            rem_vertex!(zxd.layout, v)
        end
        return true
    end
    return false
end

"""
    rem_spider!(zxd, v)

Remove a spider indexed by `v`.
"""
rem_spider!(zxd::ZXDiagram{T, P}, v::T) where {T <: Integer, P} = rem_spiders!(zxd, [v])

"""
    add_spider!(zxd, spider_type, phase = 0, connect = [])

Add a new spider which is of the type `spider_type` with phase `phase` and
connected to the vertices `connect`.
"""
function add_spider!(zxd::ZXDiagram{T, P}, st::SpiderType.SType, phase::P=zero(P), connect::Vector{T}=T[]) where {
        T <: Integer, P}
    v = add_vertex!(zxd.mg)[1]
    set_phase!(zxd, v, phase)
    zxd.st[v] = st
    if st in (SpiderType.Z, SpiderType.X)
        zxd.phase_ids[v] = (v, 1)
    end
    if all(has_vertex(zxd.mg, c) for c in connect)
        for c in connect
            add_edge!(zxd.mg, v, c)
        end
    end
    return v
end

"""
    insert_spider!(zxd, v1, v2, spider_type, phase = 0)

Insert a spider of the type `spider_type` with phase = `phase`, between two
vertices `v1` and `v2`. It will insert multiple times if the edge between
`v1` and `v2` is a multiple edge. Also it will remove the original edge between
`v1` and `v2`.
"""
function insert_spider!(
        zxd::ZXDiagram{T, P}, v1::T, v2::T, st::SpiderType.SType, phase::P=zero(P)) where {T <: Integer, P}
    mt = mul(zxd.mg, v1, v2)
    vs = Vector{T}(undef, mt)
    for i in 1:mt
        v = add_spider!(zxd, st, phase, [v1, v2])
        @inbounds vs[i] = v
        rem_edge!(zxd, v1, v2)
    end
    return vs
end

"""
    round_phases!(zxd)

Round phases between [0, 2π).
"""
function round_phases!(zxd::ZXDiagram{T, P}) where {T <: Integer, P}
    ps = zxd.ps
    for v in keys(ps)
        while ps[v] < 0
            ps[v] += 2
        end
        ps[v] = round_phase(ps[v])
    end
    return
end

spiders(zxd::ZXDiagram) = vertices(zxd.mg)
qubit_loc(zxd::ZXDiagram{T, P}, v::T) where {T, P} = qubit_loc(zxd.layout, v)
function column_loc(zxd::ZXDiagram{T, P}, v::T) where {T, P}
    c_loc = column_loc(zxd.layout, v)
    return c_loc
end

"""
    push_gate!(zxd, ::Val{M}, locs...[, phase]; autoconvert=true)

Push an `M` gate to the end of qubit `loc` where `M` can be `:Z`, `:X`, `:H`, `:SWAP`, `:CNOT` and `:CZ`.
If `M` is `:Z` or `:X`, `phase` will be available and it will push a
rotation `M` gate with angle `phase * π`.
If `autoconvert` is `false`, the input `phase` should be a rational numbers.
"""
function push_gate!(zxd::ZXDiagram{T, P}, ::Val{:Z}, loc::T, phase=zero(P); autoconvert::Bool=true) where {T, P}
    @inbounds out_id = get_outputs(zxd)[loc]
    @inbounds bound_id = neighbors(zxd, out_id)[1]
    rphase = autoconvert ? safe_convert(P, phase) : phase
    insert_spider!(zxd, bound_id, out_id, SpiderType.Z, rphase)
    return zxd
end

function push_gate!(zxd::ZXDiagram{T, P}, ::Val{:X}, loc::T, phase=zero(P); autoconvert::Bool=true) where {T, P}
    @inbounds out_id = get_outputs(zxd)[loc]
    @inbounds bound_id = neighbors(zxd, out_id)[1]
    rphase = autoconvert ? safe_convert(P, phase) : phase
    insert_spider!(zxd, bound_id, out_id, SpiderType.X, rphase)
    return zxd
end

function push_gate!(zxd::ZXDiagram{T, P}, ::Val{:H}, loc::T) where {T, P}
    @inbounds out_id = get_outputs(zxd)[loc]
    @inbounds bound_id = neighbors(zxd, out_id)[1]
    insert_spider!(zxd, bound_id, out_id, SpiderType.H)
    return zxd
end

function push_gate!(zxd::ZXDiagram{T, P}, ::Val{:SWAP}, locs::Vector{T}) where {T, P}
    q1, q2 = locs
    push_gate!(zxd, Val{:Z}(), q1)
    push_gate!(zxd, Val{:Z}(), q2)
    push_gate!(zxd, Val{:Z}(), q1)
    push_gate!(zxd, Val{:Z}(), q2)
    v1, v2, bound_id1, bound_id2 = (sort!(spiders(zxd)))[(end - 3):end]
    rem_edge!(zxd, v1, bound_id1)
    rem_edge!(zxd, v2, bound_id2)
    add_edge!(zxd, v1, bound_id2)
    add_edge!(zxd, v2, bound_id1)
    return zxd
end

function push_gate!(zxd::ZXDiagram{T, P}, ::Val{:CNOT}, loc::T, ctrl::T) where {T, P}
    push_gate!(zxd, Val{:Z}(), ctrl)
    push_gate!(zxd, Val{:X}(), loc)
    @inbounds v1, v2 = (sort!(spiders(zxd)))[(end - 1):end]
    add_edge!(zxd, v1, v2)
    add_power!(zxd, 1)
    return zxd
end

function push_gate!(zxd::ZXDiagram{T, P}, ::Val{:CZ}, loc::T, ctrl::T) where {T, P}
    push_gate!(zxd, Val{:Z}(), ctrl)
    push_gate!(zxd, Val{:Z}(), loc)
    @inbounds v1, v2 = (sort!(spiders(zxd)))[(end - 1):end]
    add_edge!(zxd, v1, v2)
    insert_spider!(zxd, v1, v2, SpiderType.H)
    add_power!(zxd, 1)
    return zxd
end

"""
    pushfirst_gate!(zxd, ::Val{M}, loc[, phase])

Push an `M` gate to the beginning of qubit `loc` where `M` can be `:Z`, `:X`, `:H`, `:SWAP`, `:CNOT` and `:CZ`.
If `M` is `:Z` or `:X`, `phase` will be available and it will push a
rotation `M` gate with angle `phase * π`.
"""
function pushfirst_gate!(zxd::ZXDiagram{T, P}, ::Val{:Z}, loc::T, phase::P=zero(P)) where {T, P}
    @inbounds in_id = get_inputs(zxd)[loc]
    @inbounds bound_id = neighbors(zxd, in_id)[1]
    insert_spider!(zxd, in_id, bound_id, SpiderType.Z, phase)
    return zxd
end

function pushfirst_gate!(zxd::ZXDiagram{T, P}, ::Val{:X}, loc::T, phase::P=zero(P)) where {T, P}
    @inbounds in_id = get_inputs(zxd)[loc]
    @inbounds bound_id = neighbors(zxd, in_id)[1]
    insert_spider!(zxd, in_id, bound_id, SpiderType.X, phase)
    return zxd
end

function pushfirst_gate!(zxd::ZXDiagram{T, P}, ::Val{:H}, loc::T) where {T, P}
    @inbounds in_id = get_inputs(zxd)[loc]
    @inbounds bound_id = neighbors(zxd, in_id)[1]
    insert_spider!(zxd, in_id, bound_id, SpiderType.H)
    return zxd
end

function pushfirst_gate!(zxd::ZXDiagram{T, P}, ::Val{:SWAP}, locs::Vector{T}) where {T, P}
    q1, q2 = locs
    pushfirst_gate!(zxd, Val{:Z}(), q1)
    pushfirst_gate!(zxd, Val{:Z}(), q2)
    pushfirst_gate!(zxd, Val{:Z}(), q1)
    pushfirst_gate!(zxd, Val{:Z}(), q2)
    @inbounds v1, v2, bound_id1, bound_id2 = (sort!(spiders(zxd)))[(end - 3):end]
    rem_edge!(zxd, v1, bound_id1)
    rem_edge!(zxd, v2, bound_id2)
    add_edge!(zxd, v1, bound_id2)
    add_edge!(zxd, v2, bound_id1)
    return zxd
end

function pushfirst_gate!(zxd::ZXDiagram{T, P}, ::Val{:CNOT}, loc::T, ctrl::T) where {T, P}
    pushfirst_gate!(zxd, Val{:Z}(), ctrl)
    pushfirst_gate!(zxd, Val{:X}(), loc)
    @inbounds v1, v2 = (sort!(spiders(zxd)))[(end - 1):end]
    add_edge!(zxd, v1, v2)
    add_power!(zxd, 1)
    return zxd
end

function pushfirst_gate!(zxd::ZXDiagram{T, P}, ::Val{:CZ}, loc::T, ctrl::T) where {T, P}
    pushfirst_gate!(zxd, Val{:Z}(), ctrl)
    pushfirst_gate!(zxd, Val{:Z}(), loc)
    @inbounds v1, v2 = (sort!(spiders(zxd)))[(end - 1):end]
    add_edge!(zxd, v1, v2)
    insert_spider!(zxd, v1, v2, SpiderType.H)
    add_power!(zxd, 1)
    return zxd
end

function add_ancilla!(zxd::ZXDiagram, in_stype::SpiderType.SType, out_stype::SpiderType.SType;
        register_as_input::Bool=false, register_as_output::Bool=false)
    v_in = add_spider!(zxd, in_stype)
    v_out = add_spider!(zxd, out_stype)
    (register_as_input || in_stype === SpiderType.In) && push!(zxd.inputs, v_in)
    (register_as_output || out_stype === SpiderType.Out) && push!(zxd.outputs, v_out)
    add_edge!(zxd, v_in, v_out)
    return zxd
end

"""
    tcount(zxd)

Returns the T-count of a ZX-diagram.
"""
tcount(cir::ZXDiagram) = sum(!is_clifford_phase(phase(cir, v)) for v in spiders(cir))

"""
    get_inputs(zxd)

Returns a vector of input ids.
"""
get_inputs(zxd::ZXDiagram) = zxd.inputs

"""
    get_outputs(zxd)

Returns a vector of output ids.
"""
get_outputs(zxd::ZXDiagram) = zxd.outputs

"""
    scalar(zxd)

Returns the scalar of `zxd`.
"""
scalar(zxd::ZXDiagram) = zxd.scalar

function add_global_phase!(zxd::ZXDiagram{T, P}, p::P) where {T, P}
    add_phase!(zxd.scalar, p)
    return zxd
end

function add_power!(zxd::ZXDiagram, n)
    add_power!(zxd.scalar, n)
    return zxd
end

function spider_sequence(zxd::ZXDiagram{T, P}) where {T, P}
    seq = []
    generate_layout!(zxd, seq)
    return seq
end

function generate_layout!(zxd::ZXDiagram{T, P}, seq::Vector{Any}=[]) where {T, P}
    layout = zxd.layout
    nbits = length(zxd.inputs)
    vs_frontier = copy(zxd.inputs)
    vs_generated = Set(vs_frontier)
    frontier_col = [1//1 for _ in 1:nbits]
    frontier_active = [true for _ in 1:nbits]
    for i in 1:nbits
        set_qubit!(layout, vs_frontier[i], i)
        set_column!(layout, vs_frontier[i], 1//1)
    end

    while !(zxd.outputs ⊆ vs_frontier)
        while any(frontier_active)
            for q in 1:nbits
                if frontier_active[q]
                    v = vs_frontier[q]
                    nb = neighbors(zxd, v)
                    if length(nb) <= 2
                        set_loc!(layout, v, q, frontier_col[q])
                        push!(seq, v)
                        push!(vs_generated, v)
                        q_active = false
                        for v1 in nb
                            if !(v1 in vs_generated)
                                vs_frontier[q] = v1
                                frontier_col[q] += 1
                                q_active = true
                                break
                            end
                        end
                        frontier_active[q] = q_active
                    else
                        frontier_active[q] = false
                    end
                end
            end
        end
        for q in 1:nbits
            v = vs_frontier[q]
            nb = neighbors(zxd, v)
            isupdated = false
            for v1 in nb
                if !(v1 in vs_generated)
                    q1 = findfirst(isequal(v1), vs_frontier)
                    if !isnothing(q1)
                        col = maximum(frontier_col[min(q, q1):max(q, q1)])
                        set_loc!(layout, v, q, col)
                        set_loc!(layout, v1, q1, col)
                        push!(vs_generated, v, v1)
                        push!(seq, (v, v1))
                        nb_v1 = neighbors(zxd, v1)
                        new_v1 = nb_v1[findfirst(v -> !(v in vs_generated), nb_v1)]
                        new_v = nb[findfirst(v -> !(v in vs_generated), nb)]
                        vs_frontier[q] = new_v
                        vs_frontier[q1] = new_v1
                        for i in min(q, q1):max(q, q1)
                            frontier_col[i] = col + 1
                        end
                        frontier_active[q] = true
                        frontier_active[q1] = true
                        isupdated = true
                        break
                    elseif spider_type(zxd, v1) == SpiderType.H && degree(zxd, v1) == 2
                        nb_v1 = neighbors(zxd, v1)
                        v2 = nb_v1[findfirst(!isequal(v), nb_v1)]
                        q2 = findfirst(isequal(v2), vs_frontier)
                        if !isnothing(q2)
                            col = maximum(frontier_col[min(q, q2):max(q, q2)])
                            set_loc!(layout, v, q, col)
                            set_loc!(layout, v2, q2, col)
                            q1 = (q + q2)//2
                            denominator(q1) == 1 && (q1 += 1//2)
                            set_loc!(layout, v1, q1, col)
                            push!(vs_generated, v, v1, v2)
                            push!(seq, (v, v1, v2))
                            nb_v2 = neighbors(zxd, v2)
                            new_v = nb[findfirst(v -> !(v in vs_generated), nb)]
                            new_v2 = nb_v2[findfirst(v -> !(v in vs_generated), nb_v2)]
                            vs_frontier[q] = new_v
                            vs_frontier[q2] = new_v2
                            for i in min(q, q2):max(q, q2)
                                frontier_col[i] = col + 1
                            end
                            frontier_active[q] = true
                            frontier_active[q2] = true
                            isupdated = true
                            break
                        end
                    end
                end
                isupdated && break
            end
        end
    end
    for q in 1:length(zxd.outputs)
        set_loc!(layout, zxd.outputs[q], q, maximum(frontier_col))
    end
    return layout
end

"""
    continued_fraction(ϕ, n::Int) -> Rational

Obtain `s` and `r` from `ϕ` that satisfies `|s//r - ϕ| ≦ 1/2r²`
"""
function continued_fraction(fl, n::Int)
    if n == 1 || abs(mod(fl, 1)) < 1e-10
        Rational(floor(Int, fl), 1)
    else
        floor(Int, fl) + 1//continued_fraction(1/mod(fl, 1), n-1)
    end
end

safe_convert(::Type{T}, x) where T = convert(T, x)
safe_convert(::Type{T}, x::T) where T <: Rational = x
function safe_convert(::Type{T}, x::Real) where T <: Rational
    local fr
    for n in 1:16 # at most 20 steps, otherwise the number may overflow.
        fr = continued_fraction(x, n)
        abs(fr - x) < 1e-12 && return fr
    end
    @warn "converting phase to rational, but with rounding error $(abs(fr-x))."
    return fr
end

"""
    plot(zxd::ZXDiagram{T, P}; kwargs...) where {T, P}

Plots a ZXDiagram using Vega.

If called from the REPL it will open in the Browser.
Please remeber to run "using Vega, DataFrames" before, as this uses an extension
"""
function plot(zxd::ZXDiagram{T, P}; kwargs...) where {T, P}
    return error("missing extension, please use Vega with 'using Vega, DataFrames'")
end

"""
    get_output_idx(zxd::ZXDiagram{T,P}, q::T) where {T,P}

Get spider index of output qubit q. Returns -1 is non-existant
"""
function get_output_idx(zxd::ZXDiagram{T, P}, q::T) where {T, P}
    for v in get_outputs(zxd)
        if spider_type(zxd, v) == SpiderType.Out && Int(qubit_loc(zxd, v)) == q
            res = v
        else
            res = nothing
        end

        !isnothing(res) && return res
    end
    return -1
end

"""
    import_non_in_out!(d1::ZXDiagram{T,P}, d2::ZXDiagram{T,P}, v2tov1::Dict{T,T}) where {T,P}

Add non input and output spiders of d2 to d1, modify d1. Record the mapping of vertex indices.
"""
function import_non_in_out!(
        d1::ZXDiagram{T, P},
        d2::ZXDiagram{T, P},
        v2tov1::Dict{T, T}
) where {T, P}
    for v2 in vertices(d2.mg)
        st = spider_type(d2, v2)
        if st == SpiderType.In || st == SpiderType.Out
            new_v = nothing
            # FIXME why is Out = H ?
        elseif st == SpiderType.Z || st == SpiderType.X || st == SpiderType.H
            new_v = add_vertex!(d1.mg)[1]
        else
            throw(ArgumentError("Unknown spider type $(d2.st[v2])"))
        end
        if !isnothing(new_v)
            v2tov1[v2] = new_v
            d1.st[new_v] = spider_type(d2, v2)
            d1.ps[new_v] = d2.ps[v2]
            d1.phase_ids[new_v] = (v2, 1)
        end
    end
end

nout(zxd::ZXDiagram) = length(zxd.outputs)
nin(zxd::ZXDiagram) = length(zxd.inputs)

"""
    get_input_idx(zwd::ZXDiagram{T,P}, q::T) where {T,P}

Get spider index of input qubit q. Returns -1 if non-existant
"""
function get_input_idx(zxd::ZXDiagram{T, P}, q::T) where {T, P}
    for v in get_inputs(zxd)
        if spider_type(zxd, v) == SpiderType.In && Int(qubit_loc(zxd, v)) == q
            res = v
        else
            res = nothing
        end

        !isnothing(res) && return res
    end
    return -1
end

"""
    import_edges!(d1::ZXDiagram{T,P}, d2::ZXDiagram{T,P}, v2tov1::Dict{T,T}) where {T,P}

Import edges of d2 to d1, modify d1
"""
function import_edges!(d1::ZXDiagram{T, P}, d2::ZXDiagram{T, P}, v2tov1::Dict{T, T}) where {T, P}
    for edge in edges(d2.mg)
        src, dst, emul = edge.src, edge.dst, edge.mul
        add_edge!(d1.mg, v2tov1[src], v2tov1[dst], emul)
    end
end

"""
    concat!(zxd_1::ZXDiagram{T,P}, zxd_2::ZXDiagram{T,P})::ZXDiagram{T,P} where {T,P}

Appends two diagrams, where the second diagram is inverted
"""
function concat!(zxd_1::ZXDiagram{T, P}, zxd_2::ZXDiagram{T, P})::ZXDiagram{T, P} where {T, P}
    nqubits(zxd_1) == nqubits(zxd_2) || throw(
        ArgumentError(
        "number of qubits need to be equal, go  $(nqubits(zxd_1)) and $(nqubits(zxd_2))",
    ),
    )

    v2tov1 = Dict{T, T}()
    import_non_in_out!(zxd_1, zxd_2, v2tov1)

    for i in 1:nout(zxd_1)
        out_idx = get_output_idx(zxd_1, i)
        # output spiders cannot be connected to multiple vertices or with multiedge
        prior_vtx = neighbors(zxd_1, out_idx)[1]
        rem_edge!(zxd_1, out_idx, prior_vtx)
        # zxd_2 input vtx idx is mapped to the vtx prior to zxd_1 output
        v2tov1[get_input_idx(zxd_2, i)] = prior_vtx
    end

    for i in 1:nout(zxd_2)
        v2tov1[get_output_idx(zxd_2, i)] = get_output_idx(zxd_1, i)
    end

    import_edges!(zxd_1, zxd_2, v2tov1)
    add_global_phase!(zxd_1, zxd_2.scalar.phase)
    add_power!(zxd_1, zxd_2.scalar.power_of_sqrt_2)

    return zxd_1
end

"""
    stype_to_val(st)::Union{SpiderType,nothing}

Converts SpiderType into Val
"""
function stype_to_val(st)::Val
    if st == SpiderType.Z
        Val{:Z}()
    elseif st == SpiderType.X
        Val{:X}()
    elseif st == SpiderType.H
        Val{:H}()
    else
        throw(ArgumentError("$st has no corresponding SpiderType"))
    end
end

"""
    dagger(zxd::ZXDiagram{T,P})::ZXDiagram{T,P} where {T,P}

Dagger of a ZXDiagram by swapping input and outputs and negating the values of the phases
"""

function dagger(zxd::ZXDiagram{T, P})::ZXDiagram{T, P} where {T, P}
    ps_i = Dict([k => -v for (k, v) in zxd.ps])
    zxd_dg = ZXDiagram{T, P}(
        copy(zxd.mg),
        copy(zxd.st),
        ps_i,
        copy(zxd.layout),
        deepcopy(zxd.phase_ids),
        copy(zxd.scalar),
        copy(zxd.outputs),
        copy(zxd.inputs),
        false
    )
    for v in vertices(zxd_dg.mg)
        value = zxd_dg.st[v]
        if value == SpiderType.In
            zxd_dg.st[v] = SpiderType.Out
        elseif (value == SpiderType.Out)
            zxd_dg.st[v] = SpiderType.In
        end
    end
    return zxd_dg
end
