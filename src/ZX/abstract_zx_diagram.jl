abstract type AbstractZXDiagram{T <: Integer, P <: AbstractPhase} end

Graphs.nv(zxd::AbstractZXDiagram) = throw(MethodError(Graphs.nv, zxd))
Graphs.ne(zxd::AbstractZXDiagram) = throw(MethodError(Graphs.ne, zxd))
Graphs.degree(zxd::AbstractZXDiagram, v) = throw(MethodError(Graphs.degree, (zxd, v)))
Graphs.indegree(zxd::AbstractZXDiagram, v) = throw(MethodError(Graphs.indegree, (zxd, v)))
Graphs.outdegree(zxd::AbstractZXDiagram, v) = throw(MethodError(Graphs.outdegree, (zxd, v)))
Graphs.neighbors(zxd::AbstractZXDiagram, v) = throw(MethodError(Graphs.neighbors, (zxd, v)))
Graphs.outneighbors(zxd::AbstractZXDiagram, v) = throw(MethodError(Graphs.outneighbors, (zxd, v)))
Graphs.inneighbors(zxd::AbstractZXDiagram, v) = throw(MethodError(Graphs.inneighbors, (zxd, v)))
Graphs.rem_edge!(zxd::AbstractZXDiagram, args...) = throw(MethodError(Graphs.rem_edge!, (zxd, args...)))
Graphs.add_edge!(zxd::AbstractZXDiagram, args...) = throw(MethodError(Graphs.add_edge!, (zxd, args...)))
Graphs.has_edge(zxd::AbstractZXDiagram, args...) = throw(MethodError(Graphs.has_edge, (zxd, args...)))

Base.show(io::IO, zxd::AbstractZXDiagram) = throw(MethodError(Base.show, io, zxd))
Base.copy(zxd::AbstractZXDiagram) = throw(MethodError(Base.copy, zxd))

# Graph-level interface (applicable to all ZX-diagrams)
spiders(zxd::AbstractZXDiagram) = throw(MethodError(ZX.spiders, zxd))
tcount(zxd::AbstractZXDiagram) = throw(MethodError(ZX.tcount, zxd))
scalar(zxd::AbstractZXDiagram) = throw(MethodError(ZX.scalar, zxd))
round_phases!(zxd::AbstractZXDiagram) = throw(MethodError(ZX.round_phases!, zxd))

spider_type(zxd::AbstractZXDiagram, v) = throw(MethodError(ZX.spider_type, (zxd, v)))
spider_types(zxd::AbstractZXDiagram) = throw(MethodError(ZX.spider_types, zxd))
phase(zxd::AbstractZXDiagram, v) = throw(MethodError(ZX.phase, (zxd, v)))
phases(zxd::AbstractZXDiagram) = throw(MethodError(ZX.phases, zxd))
rem_spider!(zxd::AbstractZXDiagram, v) = throw(MethodError(ZX.rem_spider!, (zxd, v)))
rem_spiders!(zxd::AbstractZXDiagram, vs) = throw(MethodError(ZX.rem_spiders!, (zxd, vs)))
add_global_phase!(zxd::AbstractZXDiagram, p) = throw(MethodError(ZX.add_global_phase!, (zxd, p)))
add_power!(zxd::AbstractZXDiagram, n) = throw(MethodError(ZX.add_power!, (zxd, n)))

set_phase!(zxd::AbstractZXDiagram, args...) = throw(MethodError(ZX.set_phase!, (zxd, args...)))
add_spider!(zxd::AbstractZXDiagram, args...) = throw(MethodError(ZX.add_spider!, (zxd, args...)))
insert_spider!(zxd::AbstractZXDiagram, args...) = throw(MethodError(ZX.insert_spider!, (zxd, args...)))

# Note: Circuit-specific methods (nqubits, get_inputs, get_outputs, qubit_loc, column_loc,
# generate_layout!, spider_sequence, push_gate!, pushfirst_gate!) have been moved to
# AbstractZXCircuit interface
