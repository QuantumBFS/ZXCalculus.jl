using LightGraphs
import Base: show, copy
import LightGraphs: nv, ne, outneighbors, rem_edge!

export ZXDiagram, SType, Z, X, H, In, Out

@enum SType Z X H In Out

"""
    ZXDiagram{T, P}
This is the type for representing ZX-diagrams.
"""
struct ZXDiagram{T<:Integer, P}
    mg::Multigraph{T}

    st::Dict{T, SType}
    ps::Dict{T, P}

    function ZXDiagram{T, P}(mg::Multigraph{T}, st::Dict{T, SType}, ps::Dict{T, P}) where {T<:Integer, P}
        if nv(mg) == length(ps) && nv(mg) == length(st)
            zxd = new{T, P}(mg, st, ps)
            rounding_phases!(zxd)
            return zxd
        else
            error("There should be a phase and a type for each spider!")
        end
    end
end

ZXDiagram(mg::Multigraph{T}, st::Dict{T, SType},
    ps::Dict{T, P}) where {T, P} = ZXDiagram{T, P}(mg, st, ps)
ZXDiagram(mg::Multigraph{T}, st::Vector{SType},
    ps::Vector{P}) where {T, P} =
    ZXDiagram(mg, Dict(zip(vertices(mg), st)), Dict(zip(vertices(mg), ps)))

copy(zxd::ZXDiagram) = ZXDiagram(copy(zxd.mg), copy(zxd.st), copy(zxd.ps))
spider_type(zxd::ZXDiagram{T, P}, v::T) where {T<:Integer, P} = zxd.st[v]

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
        for v2 in outneighbors(zxd.mg, v1)
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

nv(zxd::ZXDiagram) = nv(zxd.mg)
ne(zxd::ZXDiagram, count_mul::Bool = false) = ne(zxd.mg, count_mul)
outneighbors(zxd::ZXDiagram, v) = outneighbors(zxd.mg, v)
function rem_edge!(zxd::ZXDiagram, x...)
    rem_edge!(zxd.mg, x...)
end

function rem_spiders!(zxd::ZXDiagram{T, P}, vs::Vector{T}) where {T<:Integer, P}
    if rem_vertices!(zxd.mg, vs)
        for v in vs
            delete!(zxd.ps, v)
            delete!(zxd.st, v)
        end
        return true
    end
    return false
end
rem_spider!(zxd::ZXDiagram{T, P}, v::T) where {T<:Integer, P} = rem_spiders!(zxd, [v])

function add_spider!(zxd::ZXDiagram{T, P}, st::SType, phase::P = zero(P), connect::Vector{T}=T[]) where {T<:Integer, P}
    add_vertex!(zxd.mg)
    v = vertices(zxd.mg)[end]
    zxd.ps[v] = phase
    zxd.st[v] = st
    connect ⊆ vertices(zxd.mg)
    for c in connect
        add_edge!(zxd.mg, v, c)
    end
    zxd
end

function insert_spider!(zxd::ZXDiagram{T, P}, v1::T, v2::T, st::SType, phase::P = zero(P)) where {T<:Integer, P}
    for i = 1:mul(zxd.mg, v1, v2)
        add_spider!(zxd, st, phase, [v1, v2])
        rem_edge!(zxd, v1, v2)
    end
    zxd
end

function rounding_phases!(zxd::ZXDiagram{T, P}) where {T<:Integer, P}
    ps = zxd.ps
    for v in keys(ps)
        ps[v] = rem(ps[v], one(P)+one(P))
    end
end

# find_spiders(zxd::ZXDiagram, st::SType) = findall(zxd.st .== st)
