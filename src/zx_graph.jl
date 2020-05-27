using LightGraphs

import Base: show
import LightGraphs: nv, ne, outneighbors, inneighbors, neighbors, rem_edge!,
    add_edge!, has_edge

export ZXGraph, spider_type, phase, mul

const NON_HADAMARD = 1
const HADAMARD = 2

"""
    ZXGraph{T, P}
This is the type for representing the graph-like ZX-diagrams.
"""
struct ZXGraph{T<:Integer, P}
    mg::Multigraph{T}
    ps::Dict{T, P}
    st::Dict{T, SType}
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
