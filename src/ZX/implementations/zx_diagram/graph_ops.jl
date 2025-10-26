# Graph Interface Implementation for ZXDiagram

"""
    nv(zxd)

Returns the number of vertices (spiders) of a ZX-diagram.
"""
Graphs.nv(zxd::ZXDiagram) = nv(zxd.mg)

"""
    ne(zxd; count_mul = false)

Returns the number of edges of a ZX-diagram. If `count_mul`, it will return the
sum of multiplicities of all multiple edges. Otherwise, it will return the
number of multiple edges.
"""
Graphs.ne(zxd::ZXDiagram; count_mul::Bool=false) = ne(zxd.mg, count_mul=count_mul)
Graphs.edges(zxd::ZXDiagram) = edges(zxd.mg)
Graphs.has_edge(zxd::ZXDiagram, v1::Integer, v2::Integer) = has_edge(zxd.mg, v1, v2)
Multigraphs.mul(zxd::ZXDiagram, v1::Integer, v2::Integer) = mul(zxd.mg, v1, v2)

Graphs.outneighbors(zxd::ZXDiagram, v; count_mul::Bool=false) = outneighbors(zxd.mg, v, count_mul=count_mul)
Graphs.inneighbors(zxd::ZXDiagram, v; count_mul::Bool=false) = inneighbors(zxd.mg, v, count_mul=count_mul)

Graphs.degree(zxd::ZXDiagram, v::Integer) = degree(zxd.mg, v)
Graphs.indegree(zxd::ZXDiagram, v::Integer) = degree(zxd, v)
Graphs.outdegree(zxd::ZXDiagram, v::Integer) = degree(zxd, v)

"""
    neighbors(zxd, v; count_mul = false)

Returns a vector of vertices connected to `v`. If `count_mul`, there will be
multiple copy for each vertex. Otherwise, each vertex will only appear once.
"""
Graphs.neighbors(zxd::ZXDiagram, v; count_mul::Bool=false) = neighbors(zxd.mg, v, count_mul=count_mul)

function Graphs.rem_edge!(zxd::ZXDiagram, x...)
    return rem_edge!(zxd.mg, x...)
end

function Graphs.add_edge!(zxd::ZXDiagram, x...)
    return add_edge!(zxd.mg, x...)
end
