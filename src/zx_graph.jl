using LightGraphs

import Base: show, copy
import LightGraphs: nv, ne, outneighbors, inneighbors, neighbors, rem_edge!,
    add_edge!, has_edge

export ZXGraph, spider_type, phase

const NON_HADAMARD = 1
const HADAMARD = 2

"""
    ZXGraph{T, P}

This is the type for representing the graph-like ZX-diagrams.
"""
struct ZXGraph{T<:Integer, P} <: AbstractZXDiagram{T, P}
    mg::Multigraph{T}
    ps::Dict{T, P}
    st::Dict{T, SpiderType.SType}
    layout::ZXLayout{T}
    phase_ids::Dict{T,Tuple{T, Int}}
    master::ZXDiagram{T, P}
end

copy(zxg::ZXGraph{T, P}) where {T, P} = ZXGraph{T, P}(copy(zxg.mg),
    copy(zxg.ps), copy(zxg.st), copy(zxg.layout), deepcopy(zxg.phase_ids), zxg.master)
"""
    ZXGraph(zxd::ZXDiagram)

Convert a ZX-diagram to graph-like ZX-diagram.

```jldoctest
julia> using ZXCalculus

julia> zxd = ZXDiagram(2); push_ctrl_gate!(zxd, Val{:CNOT}(), 2, 1);

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
    nzxd = copy(zxd)

    simplify!(Rule{:i1}(), nzxd)
    simplify!(Rule{:h}(), nzxd)
    simplify!(Rule{:i2}(), nzxd)
    match_f = match(Rule{:f}(), nzxd)
    while length(match_f) > 0
        for m in match_f
            vs = m.vertices
            if check_rule(Rule{:f}(), nzxd, vs)
                rewrite!(Rule{:f}(), nzxd, vs)
                v1, v2 = vs
                zxd.ps[v1] += zxd.ps[v2]
                zxd.ps[v2] = 0
            end
        end
        match_f = match(Rule{:f}(), nzxd)
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

    eH = [(neighbors(nzxd, v, count_mul = true)[1], neighbors(nzxd, v, count_mul = true)[2]) for v in vH]

    rem_spiders!(nzxd, vH)
    zxg = ZXGraph{T, P}(nzxd.mg, nzxd.ps, nzxd.st, nzxd.layout, nzxd.phase_ids, zxd)

    for e in eH
        v1, v2 = e
        add_edge!(zxg, v1, v2)
    end

    return zxg
end

has_edge(zxg::ZXGraph, vs...) = has_edge(zxg.mg, vs...)
nv(zxg::ZXGraph) = nv(zxg.mg)
ne(zxg::ZXGraph) = ne(zxg.mg)
outneighbors(zxg::ZXGraph, v::Integer) = outneighbors(zxg.mg, v)
inneighbors(zxg::ZXGraph, v::Integer) = inneighbors(zxg.mg, v)
neighbors(zxg::ZXGraph, v::Integer) = neighbors(zxg.mg, v)
rem_edge!(zxg::ZXGraph, v1::Integer, v2::Integer) = rem_edge!(zxg.mg, v1, v2, mul(zxg.mg, v1, v2))
function add_edge!(zxg::ZXGraph, v1::Integer, v2::Integer, edge_type::Int = HADAMARD)
    if v1 in vertices(zxg.mg) && v2 in vertices(zxg.mg)
        if v1 == v2
            if edge_type == HADAMARD
                zxg.ps[v1] += 1
            end
            return true
        else
            if has_edge(zxg, v1, v2)
                if is_hadamard(zxg, v1, v2)
                    return rem_edge!(zxg, v1, v2)
                else
                    return false
                end
            else
                return add_edge!(zxg.mg, v1, v2, edge_type)
            end
        end
    else
        return false
    end
end

spider_type(zxg::ZXGraph, v::Integer) = zxg.st[v]
phase(zxg::ZXGraph, v::Integer) = zxg.ps[v]
function set_phase!(zxg::ZXGraph{T, P}, v::T, p::P) where {T, P}
    if v in spiders(zxg)
        zxg.ps[v] = p
    end
end
nqubits(zxg::ZXGraph) = zxg.layout.nbits
is_hadamard(e::MultipleEdge) = (mul(e) == HADAMARD)
is_hadamard(zxg::ZXGraph, v1::Integer, v2::Integer) = (mul(zxg.mg, v1, v2) == HADAMARD)
spiders(zxg::ZXGraph) = vertices(zxg.mg)

function rem_spiders!(zxg::ZXGraph{T, P}, vs::Vector{T}) where {T, P}
    if rem_vertices!(zxg.mg, vs)
        for v in vs
            delete!(zxg.ps, v)
            delete!(zxg.st, v)
            delete!(zxg.phase_ids, v)
            rem_vertex!(zxg.layout, v)
        end
        return true
    end
    return false
end
rem_spider!(zxg::ZXGraph{T, P}, v::T) where {T, P} = rem_spiders!(zxg, [v])

function add_spider!(zxg::ZXGraph{T, P}, st::SpiderType.SType, phase::P = zero(P), connect::Vector{T}=T[]) where {T<:Integer, P}
    add_vertex!(zxg.mg)
    v = vertices(zxg.mg)[end]
    zxg.ps[v] = phase
    zxg.st[v] = st
    if st in [SpiderType.Z, SpiderType.X]
        zxg.phase_ids[v] = (v, 1)
    end
    if connect ⊆ spiders(zxg)
        for c in connect
            add_edge!(zxg, v, c)
        end
    end
    return zxg
end
function insert_spider!(zxg::ZXGraph{T, P}, v1::T, v2::T, phase::P = zero(P)) where {T<:Integer, P}
    add_spider!(zxg, SpiderType.Z, phase, [v1, v2])
    rem_edge!(zxg, v1, v2)
    l1 = qubit_loc(zxg.layout, v1)
    l2 = qubit_loc(zxg.layout, v2)
    if l1 == l2 && l1 != nothing
        t1 = findfirst(isequal(v1), zxg.layout.spider_seq[l1])
        t2 = findfirst(isequal(v2), zxg.layout.spider_seq[l1])
        t = min(t1, t2) + 1
        insert!(zxg.layout.spider_seq[l1], t, spiders(zxg)[end])
    end
end

function print_spider(io::IO, zxg::ZXGraph{T}, v::T) where {T<:Integer}
    st_v = spider_type(zxg, v)
    if st_v == SpiderType.Z
        printstyled(io, "S_$(v){phase = $(phase(zxg, v))⋅π}"; color = :green)
    elseif st_v == SpiderType.In
        print(io, "S_$(v){input}")
    elseif st_v == SpiderType.Out
        print(io, "S_$(v){output}")
    end
end

function show(io::IO, zxg::ZXGraph{T}) where {T<:Integer}
    println(io, "ZX-graph with $(nv(zxg)) vertices and $(ne(zxg)) edges:")
    for e in edges(zxg.mg)
        print(io, "(")
        print_spider(io, zxg, src(e))
        if is_hadamard(e)
            printstyled(io, " <-> "; color = :blue)
        else
            print(io, " <-> ")
        end
        print_spider(io, zxg, dst(e))
        print(io, ")\n")
    end
end

function rounding_phases!(zxg::ZXGraph{T, P}) where {T<:Integer, P}
    ps = zxg.ps
    for v in keys(ps)
        while ps[v] < 0
            ps[v] += 2
        end
        ps[v] = rem(ps[v], one(P)+one(P))
    end
end

"""
    is_interior(zxg::ZXGraph, v)

Return `true` if `v` is a interior spider of `zxg`.
"""
function is_interior(zxg::ZXGraph{T, P}, v::T) where {T, P}
    if v in spiders(zxg)
        nb_st = [spider_type(zxg, u) for u in neighbors(zxg, v)]
        if !(SpiderType.In in nb_st || SpiderType.Out in nb_st)
            return true
        end
    end
    return false
end
