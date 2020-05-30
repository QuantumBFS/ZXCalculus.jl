using LightGraphs
import Base: show, copy
import LightGraphs: nv, ne, outneighbors, inneighbors, neighbors, rem_edge!, add_edge!

export ZXDiagram, SType, Z, X, H, In, Out, spiders, spider_type, phase
export push_Z!, push_X!, push_H!, push_CNOT!, push_CZ!

@enum SType Z X H In Out

"""
    ZXDiagram{T, P}
This is the type for representing ZX-diagrams.
"""
struct ZXDiagram{T<:Integer, P} <: AbstractZXDiagram{T, P}
    mg::Multigraph{T}

    st::Dict{T, SType}
    ps::Dict{T, P}

    layout::ZXLayout

    function ZXDiagram{T, P}(mg::Multigraph{T}, st::Dict{T, SType}, ps::Dict{T, P},
        layout::ZXLayout{T}) where {T<:Integer, P}
        if nv(mg) == length(ps) && nv(mg) == length(st)
            zxd = new{T, P}(mg, st, ps, layout)
            rounding_phases!(zxd)
            return zxd
        else
            error("There should be a phase and a type for each spider!")
        end
    end
end

ZXDiagram(mg::Multigraph{T}, st::Dict{T, SType}, ps::Dict{T, P},
    layout::ZXLayout{T} = ZXLayout{T}()) where {T, P} = ZXDiagram{T, P}(mg, st, ps, layout)
ZXDiagram(mg::Multigraph{T}, st::Vector{SType}, ps::Vector{P},
    layout::ZXLayout{T} = ZXLayout{T}()) where {T, P} =
    ZXDiagram(mg, Dict(zip(vertices(mg), st)), Dict(zip(vertices(mg), ps)), layout)

function ZXDiagram(nbits::T) where {T<:Integer}
    mg = Multigraph(2*nbits)
    st = [In for _ = 1:2*nbits]
    ps = [0//1 for _ = 1:2*nbits]
    layout = ZXLayout(nbits, [[2*i-1, 2*i] for i = 1:nbits])
    for i = 1:nbits
        add_edge!(mg, 2*i-1, 2*i)
        st[2*i] = Out
    end
    ZXDiagram(mg, st, ps, layout)
end

copy(zxd::ZXDiagram) = ZXDiagram(copy(zxd.mg), copy(zxd.st), copy(zxd.ps), copy(zxd.layout))

"""
    spider_type(zxd, v)

Return the spider type of a spider.
"""
spider_type(zxd::ZXDiagram{T, P}, v::T) where {T<:Integer, P} = zxd.st[v]

"""
    phase(zxd, v)

Return the phase of a spider. If the spider is not a Z or X spider, then return 0.
"""
phase(zxd::ZXDiagram{T, P}, v::T) where {T<:Integer, P} = zxd.ps[v]

function print_spider(io::IO, zxd::ZXDiagram{T, P}, v::T) where {T<:Integer, P}
    st_v = spider_type(zxd, v)
    if st_v == Z
        printstyled(io, "S_$(v){phase = $(zxd.ps[v])⋅π}"; color = :green)
    elseif st_v == X
        printstyled(io, "S_$(v){phase = $(zxd.ps[v])⋅π}"; color = :red)
    elseif st_v == H
        printstyled(io, "S_$(v){H}"; color = :yellow)
    elseif st_v == In
        print(io, "S_$(v){input}")
    elseif st_v == Out
        print(io, "S_$(v){output}")
    end
end

function show(io::IO, zxd::ZXDiagram{T, P}) where {T<:Integer, P}
    println(io, "ZX-diagram with $(nv(zxd.mg)) vertices and $(ne(zxd.mg)) multiple edges:")
    for v1 in vertices(zxd.mg)
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

Return the number of vertices (spiders) of a ZX-diagram.
"""
nv(zxd::ZXDiagram) = nv(zxd.mg)

"""
    ne(zxd; count_mul = false)

Return the number of edges of a ZX-diagram. If `count_mul`, it will return the
sum of multiplicities of all multiple edges. Otherwise, it will return the
number of multiple edges.
"""
ne(zxd::ZXDiagram; count_mul::Bool = false) = ne(zxd.mg, count_mul = count_mul)

outneighbors(zxd::ZXDiagram, v; count_mul::Bool = false) = outneighbors(zxd.mg, v, count_mul = count_mul)
inneighbors(zxd::ZXDiagram, v; count_mul::Bool = false) = inneighbors(zxd.mg, v, count_mul = count_mul)

"""
    neighbors(zxd, v; count_mul = false)

Return a vector of vertices connected to `v`. If `count_mul`, there will be
multiple copy for each vertex. Otherwise, each vertex will only appear once.
"""
neighbors(zxd::ZXDiagram, v; count_mul::Bool = false) = neighbors(zxd.mg, v, count_mul = count_mul)
function rem_edge!(zxd::ZXDiagram, x...)
    rem_edge!(zxd.mg, x...)
end
function add_edge!(zxd::ZXDiagram, x...)
    add_edge!(zxd.mg, x...)
end

"""
    rem_spiders!(zxd, vs)

Remove spiders indexed by `vs`.
"""
function rem_spiders!(zxd::ZXDiagram{T, P}, vs::Vector{T}) where {T<:Integer, P}
    if rem_vertices!(zxd.mg, vs)
        for v in vs
            delete!(zxd.ps, v)
            delete!(zxd.st, v)
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
rem_spider!(zxd::ZXDiagram{T, P}, v::T) where {T<:Integer, P} = rem_spiders!(zxd, [v])

"""
    add_spider!(zxd, spider_type, phase = 0, connect = [])

Add a new spider which is of the type `spider_type` with phase `phase` and
connected to the vertices `connect`.
"""
function add_spider!(zxd::ZXDiagram{T, P}, st::SType, phase::P = zero(P), connect::Vector{T}=T[]) where {T<:Integer, P}
    add_vertex!(zxd.mg)
    v = vertices(zxd.mg)[end]
    zxd.ps[v] = phase
    zxd.st[v] = st
    if connect ⊆ vertices(zxd.mg)
        for c in connect
            add_edge!(zxd.mg, v, c)
        end
    end
    zxd
end

"""
    insert_spider!(zxd, v1, v2, spider_type, phase = 0)

Insert a spider of the type `spider_type` with phase = `phase`, between two
vertices `v1` and `v2`. It will insert multiple times if the edge between
`v1` and `v2` is a multiple edge. Also it will remove the original edge between
`v1` and `v2`.
"""
function insert_spider!(zxd::ZXDiagram{T, P}, v1::T, v2::T, st::SType, phase::P = zero(P)) where {T<:Integer, P}
    for i = 1:mul(zxd.mg, v1, v2)
        add_spider!(zxd, st, phase, [v1, v2])
        rem_edge!(zxd, v1, v2)
        l1 = qubit_loc(zxd.layout, v1)
        l2 = qubit_loc(zxd.layout, v2)
        if l1 == l2 && l1 != nothing
            t1 = findfirst(isequal(v1), zxd.layout.spider_seq[l1])
            t2 = findfirst(isequal(v2), zxd.layout.spider_seq[l1])
            t = min(t1, t2) + 1
            insert!(zxd.layout.spider_seq[l1], t, spiders(zxd)[end])
        end
    end
    zxd
end

"""
    rounding_phases!(zxd)

Round phases between [0, 2π).
"""
function rounding_phases!(zxd::ZXDiagram{T, P}) where {T<:Integer, P}
    ps = zxd.ps
    for v in keys(ps)
        while ps[v] < 0
            ps[v] += 2
        end
        ps[v] = rem(ps[v], one(P)+one(P))
    end
end

spiders(zxd::ZXDiagram) = vertices(zxd.mg)
qubit_loc(zxd::ZXDiagram{T, P}, v::T) where {T, P} = qubit_loc(zxd.layout, v)

# TODO: general API for pushing gates
"""
    push_Z!(zxd, loc, phase)

Push a rotation Z gate to the end of qubit `loc`
"""
function push_Z!(zxd::ZXDiagram{T, P}, loc::T, phase::P = P(0)) where {T, P}
    bound_id = zxd.layout.spider_seq[loc][end-1]
    out_id = zxd.layout.spider_seq[loc][end]
    insert_spider!(zxd, bound_id, out_id, Z, phase)
    zxd
end

"""
    push_X!(zxd, loc, phase)

Push a rotation X gate to the end of qubit `loc`
"""
function push_X!(zxd::ZXDiagram{T, P}, loc::T, phase::P = P(0)) where {T, P}
    bound_id = zxd.layout.spider_seq[loc][end-1]
    out_id = zxd.layout.spider_seq[loc][end]
    insert_spider!(zxd, bound_id, out_id, X, phase)
    zxd
end

"""
    push_H!(zxd, loc, phase)

Push H gate to the end of qubit `loc`
"""
function push_H!(zxd::ZXDiagram{T, P}, loc::T) where {T, P}
    bound_id = zxd.layout.spider_seq[loc][end-1]
    out_id = zxd.layout.spider_seq[loc][end]
    insert_spider!(zxd, bound_id, out_id, H)
    zxd
end

"""
    push_CNOT!(zxd, ctrl, loc, phase)

Push a CNOT gate to the end of qubits `ctrl` and `loc`
"""
function push_CNOT!(zxd::ZXDiagram{T, P}, ctrl::T, loc::T) where {T, P}
    push_Z!(zxd, ctrl)
    push_X!(zxd, loc)
    v1, v2 = spiders(zxd)[end-1:end]
    add_edge!(zxd, v1, v2)
    zxd
end

"""
    push_CZ!(zxd, ctrl, loc)

Push a CZ gate to the end of qubits `ctrl` and `loc`
"""
function push_CZ!(zxd::ZXDiagram{T, P}, ctrl::T, loc::T) where {T, P}
    push_Z!(zxd, ctrl)
    push_Z!(zxd, loc)
    v1, v2 = spiders(zxd)[end-1:end]
    add_edge!(zxd, v1, v2)
    insert_spider!(zxd, v1, v2, H)
    zxd
end
