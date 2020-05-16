using LightGraphs, SparseArrays

import Base: copy
import LightGraphs: nv, has_edge, add_edge!, rem_edge!, rem_vertex!,
    rem_vertices!, add_vertex!, add_vertices!, outneighbors, inneighbors, vertices,
    adjacency_matrix, ne, is_directed, degree, indegree, outdegree, edges

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
    for v1 = 1:m
        for v2 = 1:m
            for i = 1:adjmx[v1, v2]
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
vertices(mg::Multigraph) = sort!(collect(keys(mg.adjlist)))

function adjacency_matrix(mg::Multigraph)
    adjmx = spzeros(Int, nv(mg), nv(mg))

    ids = vertices(mg)
    for id1 in ids
        v1 = searchsortedfirst(ids, id1)
        for id2 in mg.adjlist[id1]
            v2 = searchsortedfirst(ids, id2)
            adjmx[v1, v2] += 1
            adjmx[v2, v1] += 1
        end
    end
    adjmx
end

function add_edge!(mg::Multigraph, me::AbstractMultipleEdge)
    s = src(me)
    d = dst(me)
    m = mul(me)
    vs = vertices(mg)
    if s in vs && d in vs
        for i = 1:m
            insert!(mg.adjlist[s], searchsortedfirst(mg.adjlist[s], d), d)
            insert!(mg.adjlist[d], searchsortedfirst(mg.adjlist[d], s), s)
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
            deleteat!(mg.adjlist[s], searchsortedfirst(mg.adjlist[s], d))
            deleteat!(mg.adjlist[d], searchsortedfirst(mg.adjlist[d], s))
        end
        return true
    else
        return false
    end
end

function rem_vertices!(mg::Multigraph{T}, vs::Vector{T}) where {T<:Integer}
    if vs ⊆ vertices(mg)
        for v in vs
            delete!(mg.adjlist, v)
            for (v2, l) in mg.adjlist
                deleteat!(l, searchsorted(l, v))
            end
        end
        return true
    end
    return false
end

function add_vertices!(mg::Multigraph{T}, n::Integer) where {T<:Integer}
    idmax = vertices(mg)[end]
    for i = (idmax+1):(idmax+n)
        mg.adjlist[i] = T[]
    end
    mg
end

function outneighbors(mg::Multigraph, v::Integer)
    if v in vertices(mg)
        return mg.adjlist[v]
    end
end

inneighbors(mg::Multigraph, v::Integer) = outneighbors(mg, v)
function mul(mg::Multigraph, s::Integer, d::Integer)
    if s in vertices(mg) && d in vertices(mg)
        return length(searchsorted(mg.adjlist[s], d))
    else
        # error
    end
end

is_directed(mg::Multigraph) = false
function ne(mg::Multigraph, count_mul::Bool = false)
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
