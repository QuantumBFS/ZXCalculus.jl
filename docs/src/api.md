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

## ZXW and ZW Diagram
```@docs
ZXCalculus.ZXW.add_inout!
ZXCalculus.ZW.add_spider!
ZXCalculus.ZW.parameter
ZXCalculus.tcount
ZXCalculus.ZXW.substitute_variables!
ZXCalculus.biadjacency
ZXCalculus.ZXW.rem_spider!
ZXCalculus.new_edge
ZXCalculus.ZW.print_spider
ZXCalculus.ZW.spider_type
ZXCalculus.continued_fraction
ZXCalculus.is_boundary
ZXCalculus.trace_face
ZXCalculus.ZXW.symbol_vertices
ZXCalculus.ZXW.dagger
ZXCalculus.ZW.get_outputs
ZXCalculus.ZXW.add_spider!
ZXCalculus.Phase
ZXCalculus.erase_facet!
ZXCalculus.round_phases!
ZXCalculus.gaussian_elimination
ZXCalculus.Scalar
ZXCalculus.ϕ
ZXCalculus.nqubits
ZXCalculus.ZW.set_phase!
ZXCalculus.ZXW.expval_circ!
Graphs.SimpleGraphs.rem_edge!
ZXCalculus.ZW.get_input_idx
ZXCalculus.ZXW.parameter
ZXCalculus.ZXW.int_prep!
ZXCalculus.create_face!
ZXCalculus.ZW.nout
ZXCalculus.surrounding_half_edge
ZXCalculus.add_facet_to_boarder!
ZXCalculus.ZW.nqubits
ZXCalculus.ZW.round_phases!
ZXCalculus.split_facet!
ZXCalculus.ZW.get_output_idx
ZXCalculus.update_frontier!
ZXCalculus.PlanarMultigraph
ZXCalculus.ZXW.integrate!
ZXCalculus.set_column!
ZXCalculus.set_phase!
ZXCalculus.prev
ZXCalculus.ancilla_extraction
ZXCalculus.split_vertex!
Graphs.SimpleGraphs.add_edge!
ZXCalculus.ZXW.stack_zxwd!
ZXCalculus.ZXW.get_outputs
ZXCalculus.scalar
ZXCalculus.get_inputs
ZXCalculus.add_vertex_and_facet_to_boarder!
ZXCalculus.create_edge!
ZXCalculus.ZW.get_inputs
ZXCalculus.column_loc
ZXCalculus.join_facet!
ZXCalculus.create_vertex!
ZXCalculus.GEStep
ZXCalculus.ZXW.spider_type
ZXCalculus.ZW.insert_spider!
ZXCalculus.ZXW.print_spider
ZXCalculus.ZXW.Parameter
ZXCalculus.σ_inv
ZXCalculus.ZXW.nqubits
ZXCalculus.set_qubit!
ZXCalculus.σ
ZXCalculus.make_hole!
ZXCalculus.ZXW.insert_wtrig!
ZXCalculus.ZXW.concat!
ZXCalculus.gc_vertex!
ZXCalculus.out_half_edge
ZXCalculus.ZXW.rem_spiders!
ZXCalculus.HalfEdge
ZXCalculus.ZXW.insert_spider!
ZXCalculus.set_loc!
ZXCalculus.spiders
ZXCalculus.split_edge!
ZXCalculus.ZXW.import_edges!
ZXCalculus.get_outputs
ZXCalculus.ZXW.get_inputs
ZXCalculus.n_conn_comp
ZXCalculus.ZXW.import_non_in_out!
ZXCalculus.ZXW.set_phase!
ZXCalculus.join_vertex!
ZXCalculus.ZXW.nout
```
