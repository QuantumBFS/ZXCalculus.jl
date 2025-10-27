# Graph Interface Implementation for ZXGraph

Graphs.has_edge(zxg::ZXGraph, vs...) = has_edge(zxg.mg, vs...)
Graphs.has_vertex(zxg::ZXGraph, v::Integer) = has_vertex(zxg.mg, v)
Graphs.nv(zxg::ZXGraph) = nv(zxg.mg)
Graphs.ne(zxg::ZXGraph) = ne(zxg.mg)
Graphs.outneighbors(zxg::ZXGraph, v::Integer) = outneighbors(zxg.mg, v)
Graphs.inneighbors(zxg::ZXGraph, v::Integer) = inneighbors(zxg.mg, v)
Graphs.neighbors(zxg::ZXGraph, v::Integer) = neighbors(zxg.mg, v)
Graphs.degree(zxg::ZXGraph, v::Integer) = degree(zxg.mg, v)
Graphs.indegree(zxg::ZXGraph, v::Integer) = degree(zxg, v)
Graphs.outdegree(zxg::ZXGraph, v::Integer) = degree(zxg, v)
Graphs.edges(zxg::ZXGraph) = Graphs.edges(zxg.mg)

function Graphs.rem_edge!(zxg::ZXGraph, v1::Integer, v2::Integer)
    if rem_edge!(zxg.mg, v1, v2)
        delete!(zxg.et, (min(v1, v2), max(v1, v2)))
        return true
    end
    return false
end

function Graphs.add_edge!(zxg::ZXGraph, v1::Integer, v2::Integer, etype::EdgeType.EType=EdgeType.HAD)
    if has_vertex(zxg, v1) && has_vertex(zxg, v2)
        if v1 == v2
            reduce_self_loop!(zxg, v1, etype)
            return true
        else
            if !has_edge(zxg, v1, v2)
                add_edge!(zxg.mg, v1, v2)
                zxg.et[(min(v1, v2), max(v1, v2))] = etype
            else
                reduce_parallel_edges!(zxg, v1, v2, etype)
            end
            return true
        end
    end
    return false
end
