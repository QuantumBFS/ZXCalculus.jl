# APIs

```@meta
CurrentModule = ZXCalculus
```

## ZX-diagrams

```@docs
ZXCalculus.ZXDiagram
ZXDiagram(nbit::Int)
ZXCalculus.ZXGraph
ZXCalculus.ZXGraph(::ZXDiagram)
ZXCalculus.ZXLayout
ZXCalculus.qubit_loc
ZXCalculus.tcount(zxd::AbstractZXDiagram)
spider_type(zxd::ZXDiagram{T, P}, v::T) where {T<:Integer, P}
ZXCalculus.phase(zxd::ZXDiagram{T, P}, v::T) where {T<:Integer, P}
LightGraphs.nv(zxd::ZXDiagram)
LightGraphs.ne(::ZXDiagram)
LightGraphs.neighbors(::ZXDiagram, v)
ZXCalculus.is_interior(zxg::ZXGraph{T, P}, v::T) where {T, P}
ZXCalculus.add_spider!
ZXCalculus.insert_spider!
ZXCalculus.rem_spiders!
ZXCalculus.rem_spider!
```

## Pushing gates
```@docs
ZXCalculus.push_gate!
ZXCalculus.pushfirst_gate!
```

## Simplification
```@docs
ZXCalculus.phase_teleportation
ZXCalculus.clifford_simplification
Rule{L} where L
ZXCalculus.simplify!
ZXCalculus.replace!
ZXCalculus.match
ZXCalculus.rewrite!
ZXCalculus.Match
```

## Circuit extraction
```@docs
ZXCalculus.circuit_extraction(zxg::ZXGraph{T, P}) where {T, P}
```
