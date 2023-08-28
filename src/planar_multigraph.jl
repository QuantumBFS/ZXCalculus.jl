import Graphs: AbstractEdge, src, dst
export HalfEdge, src, dst, mul, opposite

struct HalfEdge{T<:Integer,U<:Integer} <: AbstractEdge{T}
    src::T
    dst::T
    mul::U

    function HalfEdge(src::T, dst::T, mul::U) where {T<:Integer,U<:Integer}
        src == dst && error("src and dst cannot be the same vertex")
        return new{T,U}(src, dst, mul)
    end
end

src(he::HalfEdge) = he.src
dst(he::HalfEdge) = he.dst
mul(he::HalfEdge) = he.mul

opposite(he::HalfEdge) = HalfEdge(he.dst, he.src, he.mul)

function Base.:(==)(he1::HalfEdge, he2::HalfEdge)
    src(he1) == src(he2) && dst(he1) == dst(he2) && mul(he1) == mul(he2)
end

mutable struct PlanarMultiGraph{T<:Integer,U<:Integer}
    v2he::Dict{T,T}  # v_id -> he_id
    half_edges::Dict{T,HalfEdge{T,U}} # he_id -> he

    f2he::Dict{T,T}  # f_id -> he_id
    he2f::Dict{T,T}    # he_id -> f_id

    next::Dict{T,T}    # he_id -> he_id
    twin::Dict{T,T}    # he_id -> he_id

    v_max::T
    he_max::T
    f_max::T
end

Base.copy(g::PlanarMultiGraph) = PlanarMultiGraph(
    copy(g.v2he),
    copy(g.half_edges),
    copy(g.f2he),
    copy(g.he2f),
    copy(g.next),
    copy(g.twin),
    g.v_max,
    g.he_max,
    g.f_max,
)

vertices(g::PlanarMultiGraph) = collect(keys(g.v2he))

faces(g::PlanarMultiGraph) = sort!(collect(keys(g.f2he)))
half_edges(g::PlanarMultiGraph) = sort!(collect(keys(g.half_edges)))

src(g::PlanarMultiGraph{T,U}, he_id::T) where {T,U} = src(g.half_edges[he_id])
dst(g::PlanarMultiGraph{T,U}, he_id::T) where {T,U} = dst(g.half_edges[he_id])
half_edge(g::PlanarMultigraph{T,U}, he_id::T) where {T,U} = g.half_edges[he_id]
face(g::PlanarMultiGraph{T,U}, he_id::T) where {T,U} = g.he2f[he_id]

α(g::PlanarMultiGraph{T,U}, he_id::T) where {T,U} = g.next[he_id]
next(g::PlanarMultiGraph{T,U}, he_id::T) where {T,U} = α(g, he_id)

function prev(g::PlanarMultiGraph{T,U}, he_id::T) where {T<:Integer,U<:Integer}
    nxt_he_id = next(g, he_id)
    nn_he_id = next(g, nxt_he_id)
    while nn_he_id != he_id
        nxt_he_id = nn_he_id
        nn_he_id = next(g, nxt_he_id)
    end
    return nxt_he_id
end

ϕ(g::PlanarMultiGraph{T,U}, he_id::T) where {T,U} = g.twin[he_id]
twin(g::PlanarMultigraph{T,U}, he_id::T) where {T,U} = ϕ(g, he_id)

σ(g::PlanarMultigraph{T,U}, he_id::T) where {T,U} = twin(g, prev(g, he_id))
σ_inv(g::PlanarMultigraph{T,U}, he_id::T) where {T,U} = next(g, twin(g, he_id))

nv(g::PlanarMultigraph) = length(g.v2he)
nf(g::PlanarMultigraph) = length(g.f2he)
nhe(g::PlanarMultigraph) = length(g.half_edges)
ne(g::PlanarMultigraph) = nhe(g) ÷ 2

out_half_edge(g::PlanarMultigraph{T,U}, v::T) where {T,U} = g.v2he[v]

surrounding_half_edge(g::PlanarMultigraph{T,U}, f::T) where {T,U} = g.f2he[f]

function trace_orbit(f::Function, a::T; rev::Bool = false) where {T}
    next = f(a)
    perm = T[a]
    while next != a
        if rev
            pushfirst!(perm, next)
        else
            push!(perm, next)
        end
        next = f(next)
    end
    return perm
end

function trace_face(g::PlanarMultigraph{T,U}, f::T; safe_trace = false) where {T,U}
    !safe_trace && return trace_orbit(h -> g.next[h], surrounding_half_edge(g, f))
    hes_f = T[]
    for (he, f_he) in g.he2f
        f_he == f && push!(hes_f, he)
    end
    return hes_f
end

function trace_vertex(g::PlanarMultigraph{T,U}, v::T) where {T,U}
    return trace_orbit(h -> σ_inv(g, h), out_half_edge(g, v); rev = true)
end
