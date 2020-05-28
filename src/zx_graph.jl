using LightGraphs

import Base: show
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
    st::Dict{T, SType}
end

function ZXGraph(zxd::ZXDiagram{T, P}) where {T, P}
    nzxd = copy(zxd)

    replace!(Rule{:i1}(), nzxd)
    replace!(Rule{:h}(), nzxd)
    replace!(Rule{:i2}(), nzxd)
    replace!(Rule{:f}(), nzxd)

    vs = spiders(nzxd)
    vH = T[]
    vZ = T[]
    vB = T[]
    for v in vs
        if spider_type(nzxd, v) == H
            push!(vH, v)
        elseif spider_type(nzxd, v) == Z
            push!(vZ, v)
        else
            push!(vB, v)
        end
    end

    zxg = copy(nzxd)
    rem_spiders!(zxg, vH)
    zxg = ZXGraph{T, P}(zxg.mg, zxg.ps, zxg.st)

    for v in vH
        v1, v2 = neighbors(nzxd, v, count_mul = true)
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
is_hadamard(e::MultipleEdge) = (mul(e) == HADAMARD)
is_hadamard(zxg::ZXGraph, v1::Integer, v2::Integer) = (mul(zxg.mg, v1, v2) == HADAMARD)
spiders(zxg::ZXGraph) = vertices(zxg.mg)

function rem_spiders!(zxg::ZXGraph{T, P}, vs::Vector{T}) where {T, P}
    if rem_vertices!(zxg.mg, vs)
        for v in vs
            delete!(zxg.ps, v)
            delete!(zxg.st, v)
        end
        return true
    end
    return false
end
rem_spider!(zxg::ZXGraph{T, P}, v::T) where {T, P} = rem_spiders!(zxg, [v])

function add_spider!(zxg::ZXGraph{T, P}, st::SType, phase::P = zero(P), connect::Vector{T}=T[]) where {T<:Integer, P}
    add_vertex!(zxg.mg)
    v = vertices(zxg.mg)[end]
    zxg.ps[v] = phase
    zxg.st[v] = st
    if connect ⊆ spiders(zxg)
        for c in connect
            add_edge!(zxg, v, c)
        end
    end
    zxg
end
function insert_spider!(zxg::ZXGraph{T, P}, v1::T, v2::T, phase::P = zero(P)) where {T<:Integer, P}
    add_spider!(zxg, Z, phase, [v1, v2])
    rem_edge!(zxg, v1, v2)
end

function print_spider(io::IO, zxg::ZXGraph{T}, v::T) where {T<:Integer}
    st_v = spider_type(zxg, v)
    if st_v == Z
        printstyled(io, "S_$(v){phase = $(phase(zxg, v))⋅π}"; color = :green)
    elseif st_v == In
        print(io, "S_$(v){input}")
    elseif st_v == Out
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
        if !(In in nb_st || Out in nb_st)
            return true
        end
    end
    return false
end
