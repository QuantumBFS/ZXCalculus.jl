using LightGraphs, SparseArrays, LinearAlgebra

import Base: copy
import LightGraphs: nv, has_edge, add_edge!, rem_edge!, rem_vertex!,
    rem_vertices!, add_vertex!, add_vertices!, outneighbors, inneighbors, neighbors,
    vertices, adjacency_matrix, ne, is_directed, degree, indegree, outdegree, edges,
    has_vertex

export Multigraph

mutable struct Multigraph{T<:Integer} <: AbstractMultigraph{T}
    adjlist::Dict{T, Dict{T, Int}}
    _idmax::T
    function Multigraph{T}(d::Dict{T, Dict{T, Int}}, _idmax::T) where {T<:Integer}
        adjlist = deepcopy(d)
        vs = keys(adjlist)
        for (v1, l) in adjlist
            if keys(l) ⊆ vs
                for (v2, mt) in l
                    mt > 0 || error("Edge from $v1 to $v2 have non-negative multiplicity!")
                    mt == adjlist[v2][v1] || error("Not symmetric!")
                end
            else
                error("Some vertices connected to $v1 is not in the multigraph!")
            end
        end
        return new{T}(adjlist, _idmax)
    end
end

Multigraph(adjlist::Dict{T, Dict{T, Int}}) where {T<:Integer} = Multigraph{T}(adjlist, maximum(keys(adjlist)))
function Multigraph(adjmx::AbstractMatrix{U}) where {U<:Integer}
    m, n = size(adjmx)
    if m != n
        error("Adjacency matrices should be square!")
    end
    if !issymmetric(adjmx)
        error("Adjacency matrices should be symmetric!")
    end
    if sum(adjmx .!= 0) != sum(adjmx .> 0)
        error("All elements in adjacency matrices should be non-negative!")
    end
    adjlist = Dict{Int, Dict{Int, Int}}()
    for v1 = 1:m
        adjlist[v1] = Dict{Int, Int}()
        for v2 = 1:m
            if adjmx[v1, v2] > 0
                adjlist[v1][v2] = adjmx[v1, v2]
            end
        end
    end
    return Multigraph{Int}(adjlist, m)
end
Multigraph(n::T) where {T<:Integer} = Multigraph(Dict(zip(T(1):n, [Dict{T, Int}() for _ = 1:n])))
Multigraph(g::SimpleGraph{T}) where {T<:Integer} = Multigraph(LightGraphs.SimpleGraphs.adjacency_matrix(g))

copy(mg::Multigraph{T}) where {T} = Multigraph{T}(deepcopy(mg.adjlist), mg._idmax)

nv(mg::Multigraph{T}) where {T<:Integer} = length(mg.adjlist)
vertices(mg::Multigraph) = collect(keys(mg.adjlist))
has_vertex(mg::Multigraph, v::Integer) = haskey(mg.adjlist, v)

function adjacency_matrix(mg::Multigraph)
    adjmx = spzeros(Int, nv(mg), nv(mg))

    ids = sort!(vertices(mg))
    for id1 in ids
        v1 = searchsortedfirst(ids, id1)
        for id2 in keys(mg.adjlist[id1])
            v2 = searchsortedfirst(ids, id2)
            @inbounds adjmx[v1, v2] = mg.adjlist[id1][id2]
            @inbounds adjmx[v2, v1] = mg.adjlist[id1][id2]
        end
    end
    return adjmx
end

function add_edge!(mg::Multigraph, me::AbstractMultipleEdge)
    s = src(me)
    d = dst(me)
    m = mul(me)
    if has_vertex(mg, s) && has_vertex(mg, d)
        if haskey(mg.adjlist[s], d)
            mg.adjlist[s][d] += m
            mg.adjlist[d][s] += m
        else
            mg.adjlist[s][d] = m
            mg.adjlist[d][s] = m
        end
        return true
    end
    return false
end

function rem_edge!(mg::Multigraph, me::AbstractMultipleEdge)
    if has_edge(mg, me)
        s = src(me)
        d = dst(me)
        m = mul(me)

        new_mul = mul(mg, s, d) - m
        if new_mul > 0
            mg.adjlist[s][d] = new_mul
            mg.adjlist[d][s] = new_mul
        else
            delete!(mg.adjlist[s], d)
            delete!(mg.adjlist[d], s)
        end
        return true
    else
        return false
    end
end

function rem_vertices!(mg::Multigraph{T}, vs::Vector{T}) where {T<:Integer}
    if all(has_vertex(mg, v) for v in vs)
        for v in vs
            delete!(mg.adjlist, v)
        end
        for l in values(mg.adjlist)
            for v in vs
                delete!(l, v)
            end
        end
        if mg._idmax in vs
            mg._idmax = maximum(keys(mg.adjlist))
        end
        return true
    end
    return false
end

function add_vertices!(mg::Multigraph{T}, n::Integer) where {T<:Integer}
    idmax = mg._idmax
    mg._idmax += n
    new_ids = collect((idmax+1):(idmax+n))
    for i in new_ids
        mg.adjlist[i] = Dict{T, Int}()
    end
    return new_ids
end

function outneighbors(mg::Multigraph{T}, v::Integer; count_mul::Bool = false) where {T}
    has_vertex(mg, v) || error("Vertex not found!")
    if count_mul
        nb = T[]
        for (u, m) in mg.adjlist[v]
            for _ = 1:m
                push!(nb, u)
            end
        end
        return nb
    else
        return collect(keys(mg.adjlist[v]))
    end
end
neighbors(mg::Multigraph, v::Integer; count_mul::Bool = false) = outneighbors(mg, v, count_mul = count_mul)
inneighbors(mg::Multigraph, v::Integer; count_mul::Bool = false) = outneighbors(mg, v, count_mul = count_mul)

function mul(mg::Multigraph, s::Integer, d::Integer)
    (has_vertex(mg, s) && has_vertex(mg, d)) || error("Vertices not found!")
    if haskey(mg.adjlist[s], d)
        return mg.adjlist[s][d]
    end
    return 0
end

is_directed(mg::Multigraph) = false
function ne(mg::Multigraph; count_mul::Bool = false)
    return sum([sum(neighbors(mg, v, count_mul = count_mul) .>= v) for v in vertices(mg)])
end

degree(mg::Multigraph) = Dict(zip(vertices(mg), [sum(values(mg.adjlist[v])) for v in vertices(mg)]))
indegree(mg::Multigraph) = degree(mg)
outdegree(mg::Multigraph) = degree(mg)
degree(mg::Multigraph, v::Integer) = sum(values(mg.adjlist[v]))
indegree(mg::Multigraph, v::Integer) = degree(mg, v)
outdegree(mg::Multigraph, v::Integer) = degree(mg, v)
