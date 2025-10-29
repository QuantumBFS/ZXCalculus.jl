# Graph Interface Implementation for ZXCircuit
# Most operations delegate to the underlying ZXGraph

Graphs.has_edge(zxg::ZXCircuit, vs...) = has_edge(zxg.zx_graph, vs...)
Graphs.nv(zxg::ZXCircuit) = Graphs.nv(zxg.zx_graph)
Graphs.ne(zxg::ZXCircuit) = Graphs.ne(zxg.zx_graph)
Graphs.neighbors(zxg::ZXCircuit, v::Integer) = Graphs.neighbors(zxg.zx_graph, v)
Graphs.outneighbors(zxg::ZXCircuit, v::Integer) = Graphs.outneighbors(zxg.zx_graph, v)
Graphs.inneighbors(zxg::ZXCircuit, v::Integer) = Graphs.inneighbors(zxg.zx_graph, v)
Graphs.degree(zxg::ZXCircuit, v::Integer) = Graphs.degree(zxg.zx_graph, v)
Graphs.indegree(zxg::ZXCircuit, v::Integer) = Graphs.indegree(zxg.zx_graph, v)
Graphs.outdegree(zxg::ZXCircuit, v::Integer) = Graphs.outdegree(zxg.zx_graph, v)
Graphs.edges(zxg::ZXCircuit) = Graphs.edges(zxg.zx_graph)

function Graphs.add_edge!(zxg::ZXCircuit, v1::Integer, v2::Integer, etype::EdgeType.EType=EdgeType.HAD)
    return add_edge!(zxg.zx_graph, v1, v2, etype)
end

Graphs.rem_edge!(zxg::ZXCircuit, args...) = rem_edge!(zxg.zx_graph, args...)

# ZXGraph-specific query
is_hadamard(circ::ZXCircuit, v1::Integer, v2::Integer) = is_hadamard(circ.zx_graph, v1, v2)
