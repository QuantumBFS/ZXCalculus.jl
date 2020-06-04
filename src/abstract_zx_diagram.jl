import LightGraphs: nv, ne, outneighbors, inneighbors, neighbors, rem_edge!,
    add_edge!, has_edge

export AbstractZXDiagram
export spider_type, phase, spiders, rem_spider!, rem_spiders!

abstract type AbstractZXDiagram{T, P} end

nv(::AbstractZXDiagram) = 0
ne(::AbstractZXDiagram) = 0
outneighbors(::AbstractZXDiagram{T, P}, v) where {T, P} = T[]
inneighbors(::AbstractZXDiagram{T, P}, v) where {T, P} = T[]
neighbors(::AbstractZXDiagram{T, P}, v) where {T, P} = T[]
rem_edge!(::AbstractZXDiagram, x...) = false
rem_edge!(::AbstractZXDiagram, v1, v2) = false
add_edge!(::AbstractZXDiagram, x...) = false
add_edge!(::AbstractZXDiagram, v1, v2) = false
has_edge(::AbstractZXDiagram, vs...) = false

spider_type(::AbstractZXDiagram, v) = nothing
phase(::AbstractZXDiagram, v) = nothing
spiders(::AbstractZXDiagram{T, P}) where {T, P} = T[]
rem_spider!(::AbstractZXDiagram, v) = false
rem_spiders!(::AbstractZXDiagram, vs)= false
