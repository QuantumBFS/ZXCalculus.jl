using LightGraphs, SparseArrays, LinearAlgebra

import Base: copy
import LightGraphs: nv, has_edge, add_edge!, rem_edge!, rem_vertex!,
    rem_vertices!, add_vertex!, add_vertices!, outneighbors, inneighbors, neighbors,
    vertices, adjacency_matrix, ne, is_directed, degree, indegree, outdegree, edges,
    has_vertex

export Multigraph

struct Multigraph{T<:Integer} <: AbstractMultigraph{T}
    adjlist::Dict{T, Vector{T}}
    function Multigraph{T}(d::Dict{T, Vector{T}}) where {T<:Integer}
        adjlist = deepcopy(d)
        vs = keys(adjlist)
        for (v, l) in adjlist
            if l ⊆ vs
                sort!(l)
            else
                error("Some vertices connected to $v is not in the multigraph!")
            end
        end
        new{T}(adjlist)
    end
end

Multigraph(adjlist::Dict{T, Vector{T}}) where {T<:Integer} = Multigraph{T}(adjlist)
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
    adjlist = Dict(zip((1:m), [Int[] for _ = 1:m]))
    @simd for v1 = 1:m
        @simd for v2 = 1:m
            @simd for i = 1:adjmx[v1, v2]
                push!(adjlist[v1], v2)
            end
        end
    end
    Multigraph(adjlist)
end
Multigraph(n::T) where {T<:Integer} = Multigraph(Dict(zip(T(1):n, [T[] for _ = 1:n])))
Multigraph(g::SimpleGraph{T}) where {T<:Integer} = Multigraph(Dict(zip(T(1):nv(g), LightGraphs.SimpleGraphs.fadj(g))))

copy(mg::Multigraph) = Multigraph(deepcopy(mg.adjlist))

nv(mg::Multigraph{T}) where {T<:Integer} = T(length(mg.adjlist))
vertices(mg::Multigraph) = collect(keys(mg.adjlist))
has_vertex(mg::Multigraph, v::Integer) = haskey(mg.adjlist, v)

function adjacency_matrix(mg::Multigraph)
    adjmx = spzeros(Int, nv(mg), nv(mg))

    ids = sort!(vertices(mg))
    @simd for id1 in ids
        v1 = searchsortedfirst(ids, id1)
        @simd for id2 in mg.adjlist[id1]
            v2 = searchsortedfirst(ids, id2)
            @inbounds adjmx[v1, v2] += 1
            @inbounds adjmx[v2, v1] += 1
        end
    end
    adjmx
end

function add_edge!(mg::Multigraph, me::AbstractMultipleEdge)
    s = src(me)
    d = dst(me)
    m = mul(me)
    if has_vertex(mg, s) && has_vertex(mg, d)
        @simd for i = 1:m
            @inbounds insert!(mg.adjlist[s], searchsortedfirst(mg.adjlist[s], d), d)
            @inbounds insert!(mg.adjlist[d], searchsortedfirst(mg.adjlist[d], s), s)
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
        for i = 1:m
            @inbounds deleteat!(mg.adjlist[s], searchsortedfirst(mg.adjlist[s], d))
            @inbounds deleteat!(mg.adjlist[d], searchsortedfirst(mg.adjlist[d], s))
        end
        return true
    else
        return false
    end
end

function rem_vertices!(mg::Multigraph{T}, vs::Vector{T}) where {T<:Integer}
    if all([has_vertex(mg, v) for v in vs])
        @simd for v in vs
            delete!(mg.adjlist, v)
            for l in values(mg.adjlist)
                deleteat!(l, searchsorted(l, v))
            end
        end
        return true
    end
    return false
end

function add_vertices!(mg::Multigraph{T}, n::Integer) where {T<:Integer}
    idmax = maximum(vertices(mg))
    new_ids = collect((idmax+1):(idmax+n))
    @simd for i in new_ids
        mg.adjlist[i] = T[]
    end
    return new_ids
end

function outneighbors(mg::Multigraph, v::Integer; count_mul::Bool = false)
    has_vertex(mg, v) || error("Vertex not found!")
    if count_mul
        return copy(mg.adjlist[v])
    else
        return sort!(collect(Set(mg.adjlist[v])))
    end
end
neighbors(mg::Multigraph, v::Integer; count_mul::Bool = false) = outneighbors(mg, v, count_mul = count_mul)
inneighbors(mg::Multigraph, v::Integer; count_mul::Bool = false) = outneighbors(mg, v, count_mul = count_mul)

function mul(mg::Multigraph, s::Integer, d::Integer)
    (has_vertex(mg, s) && has_vertex(mg, d)) || error("Vertices not found!")
    @inbounds return length(searchsorted(mg.adjlist[s], d))
end

is_directed(mg::Multigraph) = false
function ne(mg::Multigraph; count_mul::Bool = false)
    if count_mul
        return sum([sum(mg.adjlist[v] .>= v) for v in vertices(mg)])
    else
        return sum([sum(Set(mg.adjlist[v]) .>= v) for v in vertices(mg)])
    end
end

degree(mg::Multigraph) = Dict(zip(vertices(mg), [length(mg.adjlist[v]) for v in vertices(mg)]))
indegree(mg::Multigraph) = degree(mg)
outdegree(mg::Multigraph) = degree(mg)
degree(mg::Multigraph, v::Integer) = length(mg.adjlist[v])
indegree(mg::Multigraph, v::Integer) = degree(mg, v)
outdegree(mg::Multigraph, v::Integer) = degree(mg, v)
