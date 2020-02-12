using LinearAlgebra

export Graph
export find_nbhd, add_edge!, add_vertex!

mutable struct Graph{T<:Integer}
    nv::T
    ne::T
    adjmat::Array{T,2}
end

function Graph(m::Array{T,2}) where {T<:Integer}
    n1, n2 = size(m)
    if issymmetric(m) && n1 == n2
        for i = 1:n1 m[i,i] = 0 end
        # m = T.(m.!=0)
        ne = sum(m) ÷ 2
        return Graph{T}(n1,ne,m)
    else
        return nothing
    end
end

function find_nbhd(g::Graph{T}, v::T) where {T<:Integer}
    nbhd = T[]
    vs = g.adjmat[v,:]
    for i = 1:size(vs,1)
        if vs[i] != zero(T)
            push!(nbhd, i)
        end
    end
    return nbhd
end

function add_edge!(g::Graph{T}, e::Vector{T}) where {T<:Integer}
    v1 = e[1]
    v2 = e[2]
    g.adjmat[v1, v2] += 1
    g.adjmat[v2, v1] += 1
    g.ne += 1
end

function add_edge!(g::Graph{T}, es::Vector{Vector{T}}) where {T<:Integer}
    for e in es
        add_edge!(g, e)
    end
end

add_edge!(g::Graph{T}, v1::T, v2::T) where {T<:Integer} = add_edge!(g, [v1, v2])

function add_vertex!(g::Graph{T}) where {T<:Integer}
    # add a new vertex to graph g
    g.adjmat = [[g.adjmat zeros(T, g.nv, 1)]; zeros(T, 1, g.nv+1)]
    g.nv += 1
end

function add_vertex!(g::Graph{T}, n::T) where {T<:Integer}
    for i = 1:n
        add_vertex!(g)
    end
end

function remove_vertex!(g::Graph{T}, v::T) where {T<:Integer}
    g.adjmat = g.adjmat[1:g.nv .!= v, 1:g.nv .!= v]
    g.nv -= 1
    g.ne = sum(g.adjmat) ÷ 2
end

function remove_vertex!(g::Graph{T}, vs::Vector{T}) where {T<:Integer}
    for v in sort(vs, rev=true)
        remove_vertex!(g, v)
    end
end

function remove_edge!(g::Graph{T}, e::Vector{T}) where {T<:Integer}
    v1 = e[1]
    v2 = e[2]
    if g.adjmat[v1,v2] > 0
        g.adjmat[v1,v2] -= 1
        g.adjmat[v2,v1] -= 1
        g.ne -= 1
    end
end

function remove_edge!(g::Graph{T}, es::Vector{Vector{T}}) where {T<:Integer}
    for e in es
        remove_edge!(g, es)
    end
end
