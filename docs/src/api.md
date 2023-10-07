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
spider_type(zxd::ZXDiagram{T, P}, v::T) where {T<:Integer, P}
ZXCalculus.phase(zxd::ZXDiagram{T, P}, v::T) where {T<:Integer, P}
Graphs.nv(zxd::ZXDiagram)
Graphs.ne(::ZXDiagram)
Graphs.neighbors(::ZXDiagram, v)
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

## ZXW-diagram
```@docs
ZXCalculus.ZXW.add_inout!
ZXCalculus.ZXW.substitute_variables!
ZXCalculus.biadjacency
ZXCalculus.ZXW.rem_spider!
ZXCalculus.continued_fraction
ZXCalculus.ZXW.symbol_vertices
ZXCalculus.ZXW.dagger
ZXCalculus.ZXW.add_spider!
ZXCalculus.tcount
ZXCalculus.Phase
ZXCalculus.round_phases!
ZXCalculus.gaussian_elimination
ZXCalculus.Scalar
ZXCalculus.ZXW.expval_circ!
Graphs.SimpleGraphs.rem_edge!
ZXCalculus.ZXW.parameter
ZXCalculus.ZXW.int_prep!
ZXCalculus.update_frontier!
ZXCalculus.ZXW.integrate!
ZXCalculus.set_column!
ZXCalculus.set_phase!
ZXCalculus.prev
ZXCalculus.ancilla_extraction
Graphs.SimpleGraphs.add_edge!
ZXCalculus.ZXW.stack_zxwd!
ZXCalculus.ZXW.get_outputs
ZXCalculus.scalar
ZXCalculus.get_inputs
ZXCalculus.ZW.get_inputs
ZXCalculus.column_loc
ZXCalculus.GEStep
ZXCalculus.ZXW.spider_type
ZXCalculus.ZXW.print_spider
ZXCalculus.ZXW.Parameter
ZXCalculus.ZXW.nqubits
ZXCalculus.set_qubit!
ZXCalculus.ZXW.insert_wtrig!
ZXCalculus.ZXW.concat!
ZXCalculus.ZXW.rem_spiders!
ZXCalculus.ZXW.insert_spider!
ZXCalculus.set_loc!
ZXCalculus.spiders
ZXCalculus.split_edge!
ZXCalculus.ZXW.import_edges!
ZXCalculus.get_outputs
ZXCalculus.ZXW.get_inputs
ZXCalculus.ZXW.import_non_in_out!
ZXCalculus.ZXW.set_phase!
ZXCalculus.ZXW.nout
```

# Planar Multigraph
```@docs
ZXCalculus.PlanarMultigraph
ZXCalculus.is_boundary
ZXCalculus.trace_face
ZXCalculus.new_edge
ZXCalculus.ϕ
ZXCalculus.nqubits
ZXCalculus.erase_facet!
ZXCalculus.create_face!
ZXCalculus.surrounding_half_edge
ZXCalculus.add_facet_to_boarder!
ZXCalculus.split_facet!
ZXCalculus.split_vertex!
ZXCalculus.add_vertex_and_facet_to_boarder!
ZXCalculus.create_edge!
ZXCalculus.join_facet!
ZXCalculus.create_vertex!
ZXCalculus.σ_inv
ZXCalculus.σ
ZXCalculus.make_hole!
ZXCalculus.gc_vertex!
ZXCalculus.HalfEdge
ZXCalculus.out_half_edge
ZXCalculus.n_conn_comp
ZXCalculus.join_vertex!
```

# ZW-diagrams
```@docs
ZXCalculus.ZW.ZWDiagram
ZXCalculus.ZW.insert_spider!
ZXCalculus.ZW.get_output_idx
ZXCalculus.ZW.nqubits
ZXCalculus.ZW.round_phases!
ZXCalculus.ZW.nout
ZXCalculus.ZW.get_input_idx
ZXCalculus.ZW.set_phase!
ZXCalculus.ZW.get_outputs
ZXCalculus.ZW.add_spider!
ZXCalculus.ZW.parameter
ZXCalculus.ZW.print_spider
ZXCalculus.ZW.spider_type
```

