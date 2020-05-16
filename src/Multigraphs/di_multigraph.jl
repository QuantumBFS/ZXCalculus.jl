using SparseArrays, LinearAlgebra

import Base: copy
import LightGraphs: ne, is_directed, add_edge!, rem_edge!, nv, vertices, adjacency_matrix,
    is_directed, indegree, outdegree, degree, rem_vertices!, add_vertices!,
    outneighbors, inneighbors

export DiMultigraph, mul, multype

"""
    DiMultigraph{T,U} <: AbstractMultigraph{T}

A struct for directed multigraph with index type `T`
and the multiplicity type `U`.
"""
mutable struct DiMultigraph{T<:Integer, U<:Integer} <: AbstractMultigraph{T}
    adjmx::SparseMatrixCSC{U, T}
    function DiMultigraph{T, U}(adjmx::SparseMatrixCSC{U, T}) where {T<:Integer, U<:Integer}
        m, n = size(adjmx)
        if m != n
            error("Adjacency matrices should be square!")
        end
        if nnz(adjmx .!= 0) != nnz(adjmx .> 0)
            error("All elements in adjacency matrices should be non-negative!")
        end
        new{T, U}(dropzeros(adjmx))
    end
end

"""
    DiMultigraph(adjmx::SparseMatrixCSC{U, T})

Construct a `DiMultigraph{T,U}` whose adjacency matrix is `adjmx`.

## Examples
```jldoctest
julia> using LightGraphs, Multigraphs, SparseArrays

julia> DiMultigraph(spzeros(Int, 3, 3))
{3, 0} directed $(Int) multigraph with $(Int) multiplicities
```
"""
DiMultigraph(adjmx::SparseMatrixCSC{U, T}) where {U<:Integer, T<:Integer} = DiMultigraph{T, U}(adjmx)

"""
    DiMultigraph(m::AbstractMatrix{U})

Construct a `DiMultigraph{Int,U}` whose adjacency matrix is `m`.

## Examples
```jldoctest
julia> using LightGraphs, Multigraphs

julia> DiMultigraph(zeros(Int, 4, 4))
{4, 0} directed $(Int) multigraph with $(Int) multiplicities
```
"""
DiMultigraph(m::AbstractMatrix{U}) where {U<:Integer} = DiMultigraph{Int, U}(SparseMatrixCSC{U, Int}(m))

"""
    DiMultigraph(n::T) where {T<:Integer}

Construct a `DiMultigraph{T,Int}` with `n` vertices and 0 multiple edges.

## Examples
```jldoctest
julia> using LightGraphs, Multigraphs

julia> DiMultigraph(5)
{5, 0} directed $(Int) multigraph with $(Int) multiplicities
```
"""
DiMultigraph(n::T) where {T<:Integer} = DiMultigraph(spzeros(Int, n, n))

"""
    DiMultigraph(g::SimpleDiGraph)

Convert a `SimpleDiGraph{T}` to a `DiMultigraph{T,Int}`.

## Examples
```jldoctest
julia> using LightGraphs, Multigraphs

julia> DiMultigraph(path_digraph(5))
{5, 4} directed $(Int) multigraph with $(Int) multiplicities
```
"""
DiMultigraph(g::SimpleDiGraph) = DiMultigraph(adjacency_matrix(g))

copy(mg::DiMultigraph) = DiMultigraph(copy(mg.adjmx))
multype(mg::DiMultigraph{T, U}) where {T<:Integer, U<:Integer} = U

ne(g::DiMultigraph, count_mul::Bool = false) = (count_mul ? sum(g.adjmx) : nnz(g.adjmx))
nv(mg::DiMultigraph) = size(mg.adjmx, 1)
vertices(mg::DiMultigraph{T, U}) where {T<:Integer, U<:Integer} = one(T):nv(mg)

adjacency_matrix(mg::DiMultigraph) = mg.adjmx

is_directed(g::DiMultigraph{T, U}) where {T<:Integer, U<:Integer} = true
mul(mg::DiMultigraph, s::Integer, d::Integer) = mg.adjmx[s, d]

function add_edge!(g::DiMultigraph{T, U}, e::AbstractMultipleEdge{T, U}) where {T<:Integer, U<:Integer}
    if src(e) in vertices(g) && dst(e) in vertices(g)
        g.adjmx[src(e), dst(e)] += mul(e)
        return true
    else
        return false
    end
end

function rem_edge!(g::DiMultigraph{T, U}, e::AbstractMultipleEdge{T, U}) where {T<:Integer, U<:Integer}
    if has_edge(g, e)
        g.adjmx[src(e), dst(e)] -= mul(e)
        dropzeros!(g.adjmx)
        return true
    else
        return false
    end
end

indegree(g::DiMultigraph) = [sum(g.adjmx[:,v]) for v in 1:nv(g)]
outdegree(g::DiMultigraph) = [sum(g.adjmx[v,:]) for v in 1:nv(g)]
degree(g::DiMultigraph) = indegree(g) + outdegree(g)
indegree(g::DiMultigraph{T,U}, v::T) where {T<:Integer, U<:Integer} = sum(g.adjmx[:,v])
outdegree(g::DiMultigraph{T,U}, v::T) where {T<:Integer, U<:Integer} = sum(g.adjmx[v,:])
degree(g::DiMultigraph{T,U}, v::T) where {T<:Integer, U<:Integer} = indegree(g, v) + outdegree(g, v)

function rem_vertices!(mg::DiMultigraph, vs::Vector{T}) where {T<:Integer}
    vsg = vertices(mg)
    vmap = collect(vsg)
    for v in sort(vs, rev = true)
        if v in vsg
            mg.adjmx = mg.adjmx[vertices(mg) .!= v, vertices(mg) .!= v]
            deleteat!(vmap, v)
            dropzeros!(mg.adjmx)
        end
    end
    return vmap
end

function add_vertices!(mg::DiMultigraph{T, U}, n::Integer) where {T<:Integer, U<:Integer}
    mat = mg.adjmx
    mat = SparseMatrixCSC(mat.m+n, mat.n+n, [mat.colptr; [mat.colptr[end] for i = one(T):n]], mat.rowval, mat.nzval)
    mg.adjmx = mat
    mg
end

function outneighbors(mg::DiMultigraph, v::Integer)
    if v in vertices(mg)
        mat = mg.adjmx
        return mat[v, :].nzind
    end
end

function inneighbors(mg::DiMultigraph, v::Integer)
    if v in vertices(mg)
        mat = mg.adjmx
        return mat[:, v].nzind
    end
end
