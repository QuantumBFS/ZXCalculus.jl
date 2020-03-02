using LightGraphs, Multigraphs
import Base: show, copy
import LightGraphs: nv, ne, outneighbors, rem_edge!

export ZXDiagram, SType, Z, X, H, In, Out

@enum SType Z X H In Out

mutable struct ZXDiagram{T<:Integer, U<:Integer, P}
    g::Multigraph{T,U}

    st::Vector{SType}
    ps::Vector{P}

    function ZXDiagram(g::Multigraph{T, U}, st::Vector{SType}, ps::Vector{P}) where {T<:Integer, U<:Integer, P}
        if nv(g) == length(ps) && nv(g) == length(st)
            zxd = new{T, U, P}(g, st, ps)
            rounding_phases!(zxd)
            return zxd
        else
            error("There should be a phase and a type for each spider!")
        end
    end
end

copy(zxd::ZXDiagram) = ZXDiagram(copy(zxd.g), copy(zxd.st), copy(zxd.ps))

spider_type(zxd::ZXDiagram{T, U, P}, v::T) where {T<:Integer, U<:Integer, P} = zxd.st[v]

function print_spider(io::IO, zxd::ZXDiagram{T, U, P}, v::T) where {T<:Integer, U<:Integer, P}
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

function show(io::IO, zxd::ZXDiagram{T, U, P}) where {T<:Integer, U<:Integer, P}
    println(io, "ZX-diagram with $(nv(zxd.g)) vertices and $(ne(zxd.g)) multiple edges:")
    for v1 in vertices(zxd.g)
        for v2 in outneighbors(zxd.g, v1)
            if v2 >= v1
                print(io, "(")
                print_spider(io, zxd, v1)
                print(io, " <-$(zxd.g.adjmx[v2, v1])-> ")
                print_spider(io, zxd, v2)
                print(io, ")\n")
            end
        end
    end
end

nv(zxd::ZXDiagram) = nv(zxd.g)
ne(zxd::ZXDiagram, count_mul::Bool = false) = ne(zxd.g, count_mul)
outneighbors(zxd::ZXDiagram, v) = outneighbors(zxd.g, v)
function rem_edge!(zxd::ZXDiagram, x...)
    rem_edge!(zxd.g, x...)
    zxd
end

function rem_spiders!(zxd::ZXDiagram{T,U,P}, vs::Vector{T}) where {T<:Integer, U<:Integer, P}
    vmap = rem_vertices!(zxd.g, vs)
    deleteat!(zxd.ps, sort(vs))
    deleteat!(zxd.st, sort(vs))
    return vmap
end
rem_spider!(zxd::ZXDiagram{T,U,P}, v::T) where {T<:Integer, U<:Integer, P} = rem_spiders!(zxd, [v])

function add_spider!(zxd::ZXDiagram{T,U,P}, st::SType, phase::P, connect::Vector{T}=T[]) where {T<:Integer, U<:Integer, P}
    add_vertex!(zxd.g)
    v = nv(zxd.g)
    push!(zxd.ps, phase)
    push!(zxd.st, st)
    for c in connect
        add_edge!(zxd.g, v, c)
    end
    zxd
end

function insert_spider!(zxd::ZXDiagram{T,U,P}, v1::T, v2::T, st::SType, phase::P = zero(P)) where {T<:Integer, U<:Integer, P}
    for i = 1:zxd.g.adjmx[v1,v2]
        add_spider!(zxd, st, phase, [v1, v2])
        rem_edge!(zxd, v1, v2)
    end
    zxd
end

function rounding_phases!(zxd::ZXDiagram{T,U,P}) where {T<:Integer, U<:Integer, P}
    ps = zxd.ps
    ps .+= one(P)
    ps = rem.(ps, one(P)+one(P))
    ps .-= one(P)
    zxd.ps = ps
end

find_spiders(zxd::ZXDiagram, st::SType) = findall(zxd.st .== st)
