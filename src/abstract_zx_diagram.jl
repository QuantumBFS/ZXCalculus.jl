abstract type AbstractZXDiagram{T, P} end

LightGraphs.nv(::AbstractZXDiagram) = 0
LightGraphs.ne(::AbstractZXDiagram) = 0
LightGraphs.outneighbors(::AbstractZXDiagram{T, P}, v) where {T, P} = T[]
LightGraphs.inneighbors(::AbstractZXDiagram{T, P}, v) where {T, P} = T[]
LightGraphs.neighbors(::AbstractZXDiagram{T, P}, v) where {T, P} = T[]
LightGraphs.rem_edge!(::AbstractZXDiagram, x...) = false
LightGraphs.rem_edge!(::AbstractZXDiagram, v1, v2) = false
LightGraphs.add_edge!(::AbstractZXDiagram, x...) = false
LightGraphs.add_edge!(::AbstractZXDiagram, v1, v2) = false
LightGraphs.has_edge(::AbstractZXDiagram, vs...) = false

spider_type(::AbstractZXDiagram, v) = nothing
phase(::AbstractZXDiagram, v) = nothing
spiders(::AbstractZXDiagram{T, P}) where {T, P} = T[]
rem_spider!(::AbstractZXDiagram, v) = false
rem_spiders!(::AbstractZXDiagram, vs)= false
