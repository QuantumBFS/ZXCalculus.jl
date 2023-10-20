abstract type AbstractZXDiagram{T,P} end

Graphs.nv(zxd::AbstractZXDiagram) = throw(MethodError(Graphs.nv, zxd))
Graphs.ne(zxd::AbstractZXDiagram) = throw(MethodError(Graphs.ne, zxd))
Graphs.degree(zxd::AbstractZXDiagram, v) = throw(MethodError(Graphs.degree, (zxd, v)))
Graphs.indegree(zxd::AbstractZXDiagram, v) = throw(MethodError(Graphs.indegree, (zxd, v)))
Graphs.outdegree(zxd::AbstractZXDiagram, v) = throw(MethodError(Graphs.outdegree, (zxd, v)))
Graphs.neighbors(zxd::AbstractZXDiagram, v) = throw(MethodError(Graphs.neighbors, (zxd, v)))
Graphs.outneighbors(zxd::AbstractZXDiagram, v) =
    throw(MethodError(Graphs.outneighbors, (zxd, v)))
Graphs.inneighbors(zxd::AbstractZXDiagram, v) =
    throw(MethodError(Graphs.inneighbors, (zxd, v)))
Graphs.rem_edge!(zxd::AbstractZXDiagram, args...) =
    throw(MethodError(Graphs.rem_edge!, (zxd, args...)))
Graphs.add_edge!(zxd::AbstractZXDiagram, args...) =
    throw(MethodError(Graphs.add_edge!, (zxd, args...)))
Graphs.has_edge(zxd::AbstractZXDiagram, args...) =
    throw(MethodError(Graphs.has_edge, (zxd, args...)))

Base.show(io::IO, zxd::AbstractZXDiagram) = throw(MethodError(Base.show, io, zxd))
Base.copy(zxd::AbstractZXDiagram) = throw(MethodError(Base.copy, zxd))

nqubits(zxd::AbstractZXDiagram) = throw(MethodError(ZX.nqubits, zxd))
spiders(zxd::AbstractZXDiagram) = throw(MethodError(ZX.spiders, zxd))
tcount(zxd::AbstractZXDiagram) = throw(MethodError(ZX.tcount, zxd))
get_inputs(zxd::AbstractZXDiagram) = throw(MethodError(ZX.get_inputs, zxd))
get_outputs(zxd::AbstractZXDiagram) = throw(MethodError(ZX.get_outputs, zxd))
scalar(zxd::AbstractZXDiagram) = throw(MethodError(ZX.scalar, zxd))
spider_sequence(zxd::AbstractZXDiagram) = throw(MethodError(ZX.spider_sequence, zxd))
round_phases!(zxd::AbstractZXDiagram) = throw(MethodError(ZX.round_phases!, zxd))

spider_type(zxd::AbstractZXDiagram, v) = throw(MethodError(ZX.spider_type, (zxd, v)))
phase(zxd::AbstractZXDiagram, v) = throw(MethodError(ZX.phase, (zxd, v)))
rem_spider!(zxd::AbstractZXDiagram, v) = throw(MethodError(ZX.rem_spider!, (zxd, v)))
rem_spiders!(zxd::AbstractZXDiagram, vs) = throw(MethodError(ZX.rem_spiders!, (zxd, vs)))
qubit_loc(zxd::AbstractZXDiagram, v) = throw(MethodError(ZX.qubit_loc, (zxd, v)))
column_loc(zxd::AbstractZXDiagram, v) = throw(MethodError(ZX.column_loc, (zxd, v)))
add_global_phase!(zxd::AbstractZXDiagram, p) =
    throw(MethodError(ZX.add_global_phase!, (zxd, p)))
add_power!(zxd::AbstractZXDiagram, n) = throw(MethodError(ZX.add_power!, (zxd, n)))
generate_layout!(zxd::AbstractZXDiagram, seq) =
    throw(MethodError(ZX.generate_layout!, (zxd, seq)))

set_phase!(zxd::AbstractZXDiagram, args...) =
    throw(MethodError(ZX.set_phase!, (zxd, args...)))
push_gate!(zxd::AbstractZXDiagram, args...) =
    throw(MethodError(ZX.push_gate!, (zxd, args...)))
pushfirst_gate!(zxd::AbstractZXDiagram, args...) =
    throw(MethodError(ZX.pushfirst_gate!, (zxd, args...)))
add_spider!(zxd::AbstractZXDiagram, args...) =
    throw(MethodError(ZX.add_spider!, (zxd, args...)))
insert_spider!(zxd::AbstractZXDiagram, args...) =
    throw(MethodError(ZX.insert_spider!, (zxd, args...)))
plot(zxd::Any; kwargs...) =
     error("missing extension, please use Vega with 'using Vega' and 'using DataFrames'")
