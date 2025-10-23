module EdgeType
@enum EType SIM HAD
end

"""
    ZXGraph{T, P}

This is the type for representing the graph-like ZX-diagrams.
"""
struct ZXGraph{T <: Integer, P <: AbstractPhase} <: AbstractZXDiagram{T, P}
    mg::Multigraph{T}

    ps::Dict{T, P}
    st::Dict{T, SpiderType.SType}
    et::Dict{Tuple{T, T}, EdgeType.EType}

    # TODO: phase ids for phase teleportation only
    # maps a vertex id to its master id and scalar multiplier
    phase_ids::Dict{T, Tuple{T, Int}}

    scalar::Scalar{P}
    master::ZXDiagram{T, P}
end

function Base.copy(zxg::ZXGraph{T, P}) where {T, P}
    return ZXGraph{T, P}(
        copy(zxg.mg), copy(zxg.ps),
        copy(zxg.st), copy(zxg.et),
        deepcopy(zxg.phase_ids), copy(zxg.scalar),
        copy(zxg.master)
    )
end

"""
    ZXGraph(zxd::ZXDiagram)

Convert a ZX-diagram to graph-like ZX-diagram.

```jldoctest
julia> using ZXCalculus.ZX

julia> zxd = ZXDiagram(2);
       push_gate!(zxd, Val{:CNOT}(), 2, 1);

julia> zxg = ZXGraph(zxd)
ZX-graph with 6 vertices and 5 edges:
(S_1{input} <-> S_5{phase = 0//1⋅π})
(S_2{output} <-> S_5{phase = 0//1⋅π})
(S_3{input} <-> S_6{phase = 0//1⋅π})
(S_4{output} <-> S_6{phase = 0//1⋅π})
(S_5{phase = 0//1⋅π} <-> S_6{phase = 0//1⋅π})
```
"""
function ZXGraph(zxd::ZXDiagram{T, P}) where {T, P}
    zxd = copy(zxd)
    nzxd = copy(zxd)

    simplify!(Identity1Rule(), nzxd)
    simplify!(HadamardRule(), nzxd)
    simplify!(Identity2Rule(), nzxd)
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
        nzxd.mg, nzxd.ps, nzxd.st, et,
        nzxd.phase_ids, nzxd.scalar, zxd)

    for e in eH
        v1, v2 = e
        add_edge!(zxg, v1, v2)
    end

    return zxg
end

Graphs.has_edge(zxg::ZXGraph, vs...) = has_edge(zxg.mg, vs...)
Graphs.nv(zxg::ZXGraph) = nv(zxg.mg)
Graphs.ne(zxg::ZXGraph) = ne(zxg.mg)
Graphs.outneighbors(zxg::ZXGraph, v::Integer) = outneighbors(zxg.mg, v)
Graphs.inneighbors(zxg::ZXGraph, v::Integer) = inneighbors(zxg.mg, v)
Graphs.neighbors(zxg::ZXGraph, v::Integer) = neighbors(zxg.mg, v)
Graphs.degree(zxg::ZXGraph, v::Integer) = degree(zxg.mg, v)
Graphs.indegree(zxg::ZXGraph, v::Integer) = degree(zxg, v)
Graphs.outdegree(zxg::ZXGraph, v::Integer) = degree(zxg, v)
function Graphs.rem_edge!(zxg::ZXGraph, v1::Integer, v2::Integer)
    if rem_edge!(zxg.mg, v1, v2)
        delete!(zxg.et, (min(v1, v2), max(v1, v2)))
        return true
    end
    return false
end

function Graphs.add_edge!(zxg::ZXGraph, v1::Integer, v2::Integer, edge_type::EdgeType.EType=EdgeType.HAD)
    if has_vertex(zxg.mg, v1) && has_vertex(zxg.mg, v2)
        if v1 == v2
            if edge_type == EdgeType.HAD
                set_phase!(zxg, v1, phase(zxg, v1)+1)
                add_power!(zxg, -1)
            end
            return true
        else
            if has_edge(zxg, v1, v2)
                if is_hadamard(zxg, v1, v2)
                    add_power!(zxg, -2)
                    return rem_edge!(zxg, v1, v2)
                else
                    return false
                end
            elseif add_edge!(zxg.mg, v1, v2)
                zxg.et[(min(v1, v2), max(v1, v2))] = edge_type
                return true
            end
        end
    end
    return false
end

spider_type(zxg::ZXGraph, v::Integer) = zxg.st[v]
phase(zxg::ZXGraph, v::Integer) = zxg.ps[v]
function set_phase!(zxg::ZXGraph{T, P}, v::T, p::P) where {T, P}
    if has_vertex(zxg.mg, v)
        while p < 0
            p += 2
        end
        zxg.ps[v] = round_phase(p)
        return true
    end
    return false
end

nqubits(zxg::ZXGraph) = nqubits(generate_layout!(zxg))
qubit_loc(zxg::ZXGraph{T, P}, v::T) where {T, P} = qubit_loc(generate_layout!(zxg), v)
function column_loc(zxg::ZXGraph{T, P}, v::T) where {T, P}
    c_loc = column_loc(generate_layout!(zxg), v)
    if !isnothing(c_loc)
        if spider_type(zxg, v) == SpiderType.Out
            nb = neighbors(zxg, v)
            if length(nb) == 1
                nb = nb[1]
                spider_type(zxg, nb) == SpiderType.In && return 3//1
                c_loc = floor(column_loc(zxg, nb) + 2)
            else
                c_loc = 1000
            end
        end
        if spider_type(zxg, v) == SpiderType.In
            nb = neighbors(zxg, v)[1]
            spider_type(zxg, nb) == SpiderType.Out && return 1//1
            c_loc = ceil(column_loc(zxg, nb) - 2)
        end
    end
    !isnothing(c_loc) && return c_loc
    return 0
end

function is_hadamard(zxg::ZXGraph, v1::Integer, v2::Integer)
    if has_edge(zxg, v1, v2)
        src = min(v1, v2)
        dst = max(v1, v2)
        return zxg.et[(src, dst)] == EdgeType.HAD
    end
    return false
end
spiders(zxg::ZXGraph) = vertices(zxg.mg)

function rem_spiders!(zxg::ZXGraph{T, P}, vs::Vector{T}) where {T, P}
    if rem_vertices!(zxg.mg, vs)
        for v in vs
            delete!(zxg.ps, v)
            delete!(zxg.st, v)
            delete!(zxg.phase_ids, v)
        end
        return true
    end
    return false
end
rem_spider!(zxg::ZXGraph{T, P}, v::T) where {T, P} = rem_spiders!(zxg, [v])

function add_spider!(zxg::ZXGraph{T, P}, st::SpiderType.SType, phase::P=zero(P), connect::Vector{T}=T[]) where {
        T <: Integer, P}
    v = add_vertex!(zxg.mg)[1]
    set_phase!(zxg, v, phase)
    zxg.st[v] = st
    if st in (SpiderType.Z, SpiderType.X)
        zxg.phase_ids[v] = (v, 1)
    end
    if all(has_vertex(zxg.mg, c) for c in connect)
        for c in connect
            add_edge!(zxg, v, c)
        end
    end
    return v
end
function insert_spider!(zxg::ZXGraph{T, P}, v1::T, v2::T, phase::P=zero(P)) where {T <: Integer, P}
    v = add_spider!(zxg, SpiderType.Z, phase, [v1, v2])
    rem_edge!(zxg, v1, v2)
    return v
end

tcount(cir::ZXGraph) = sum([phase(cir, v) % 1//2 != 0 for v in spiders(cir)])

function print_spider(io::IO, zxg::ZXGraph{T}, v::T) where {T <: Integer}
    st_v = spider_type(zxg, v)
    if st_v == SpiderType.Z
        printstyled(io, "S_$(v){phase = $(phase(zxg, v))"*(zxg.ps[v] isa Phase ? "}" : "⋅π}"); color=:green)
    elseif st_v == SpiderType.In
        print(io, "S_$(v){input}")
    elseif st_v == SpiderType.Out
        print(io, "S_$(v){output}")
    end
end

function Base.show(io::IO, zxg::ZXGraph{T}) where {T <: Integer}
    println(io, "ZX-graph with $(nv(zxg)) vertices and $(ne(zxg)) edges:")
    vs = sort!(spiders(zxg))
    for i in 1:length(vs)
        for j in (i + 1):length(vs)
            if has_edge(zxg, vs[i], vs[j])
                print(io, "(")
                print_spider(io, zxg, vs[i])
                if is_hadamard(zxg, vs[i], vs[j])
                    printstyled(io, " <-> "; color=:blue)
                else
                    print(io, " <-> ")
                end
                print_spider(io, zxg, vs[j])
                print(io, ")\n")
            end
        end
    end
end

function round_phases!(zxg::ZXGraph{T, P}) where {T <: Integer, P}
    ps = zxg.ps
    for v in keys(ps)
        while ps[v] < 0
            ps[v] += 2
        end
        ps[v] = round_phase(ps[v])
    end
end

"""
    is_interior(zxg::ZXGraph, v)

Return `true` if `v` is a interior spider of `zxg`.
"""
function is_interior(zxg::ZXGraph{T, P}, v::T) where {T, P}
    if has_vertex(zxg.mg, v)
        (spider_type(zxg, v) == SpiderType.In || spider_type(zxg, v) == SpiderType.Out) && return false
        for u in neighbors(zxg, v)
            if spider_type(zxg, u) == SpiderType.In || spider_type(zxg, u) == SpiderType.Out
                return false
            end
        end
        return true
    end
    return false
end

get_inputs(zxg::ZXGraph) = [v for v in spiders(zxg) if spider_type(zxg, v) == SpiderType.In]
get_outputs(zxg::ZXGraph) = [v for v in spiders(zxg) if spider_type(zxg, v) == SpiderType.Out]

# TODO: remove it?
function spider_sequence(zxg::ZXGraph{T, P}) where {T, P}
    nbits = nqubits(zxg)
    if nbits > 0
        vs = spiders(zxg)
        spider_seq = Vector{Vector{T}}(undef, nbits)
        for q in 1:nbits
            spider_seq[q] = Vector{T}()
        end
        for v in vs
            if !isnothing(qubit_loc(zxg, v))
                q_loc = Int(qubit_loc(zxg, v))
                q_loc > 0 && push!(spider_seq[q_loc], v)
            end
        end
        for q in 1:nbits
            sort!(spider_seq[q], by=(v -> column_loc(zxg, v)))
        end
        return spider_seq
    end
end

function generate_layout!(zxg::ZXGraph{T, P}) where {T, P}
    inputs = get_inputs(zxg)
    outputs = get_outputs(zxg)
    nbits = max(length(inputs), length(outputs))
    layout = ZXLayout{T}(nbits)
    circ = ZXCircuit{T, P}(zxg, inputs, outputs, layout)
    return generate_layout!(circ)
end

scalar(zxg::ZXGraph) = zxg.scalar

function add_global_phase!(zxg::ZXGraph{T, P}, p::P) where {T, P}
    add_phase!(zxg.scalar, p)
    return zxg
end

function add_power!(zxg::ZXGraph, n)
    add_power!(zxg.scalar, n)
    return zxg
end

function plot(zxd::ZXGraph{T, P}; kwargs...) where {T, P}
    return error("missing extension, please use Vega with 'using Vega, DataFrames'")
end
