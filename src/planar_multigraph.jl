import Graphs: AbstractEdge, src, dst, nv, ne, neighbors
import Graphs.SimpleGraphs: rem_edge!, rem_vertex!, add_edge!, add_vertex!
export HalfEdge, src, dst, maketwin, makepair

struct HalfEdge{T<:Integer} <: AbstractEdge{T}
    src::T
    dst::T
    function HalfEdge(src::T, dst::T) where {T<:Integer}
        src == dst && error("src and dst cannot be the same vertex")
        return new{T}(src, dst)
    end
end

src(he::HalfEdge) = he.src
dst(he::HalfEdge) = he.dst

"""
    maketwin(he::HalfEdge)

Make the twin half edge
"""
maketwin(he::HalfEdge) = HalfEdge(he.dst, he.src)

"""
    makepair(src::T, dst::T) where {T<:Integer}

Create a half edge and its twin
"""
makepair(src::T, dst::T) where {T<:Integer} = (HalfEdge(src, dst), HalfEdge(dst, src))

function Base.:(==)(he1::HalfEdge, he2::HalfEdge)
    src(he1) == src(he2) && dst(he1) == dst(he2)
end

mutable struct PlanarMultigraph{T<:Integer}
    v2he::Dict{T,T}  # v_id -> he_id
    half_edges::Dict{T,HalfEdge{T}} # he_id -> he

    f2he::Dict{T,T}  # f_id -> he_id
    he2f::Dict{T,T}    # he_id -> f_id

    next::Dict{T,T}    # he_id -> he_id
    twin::Dict{T,T}    # he_id -> he_id

    v_max::T
    he_max::T
    f_max::T
end

Base.copy(g::PlanarMultigraph) = PlanarMultigraph(
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

vertices(g::PlanarMultigraph) = collect(keys(g.v2he))

faces(g::PlanarMultigraph) = sort!(collect(keys(g.f2he)))
half_edges(g::PlanarMultigraph) = sort!(collect(keys(g.half_edges)))

src(g::PlanarMultigraph{T}, he_id::T) where {T} = src(g.half_edges[he_id])
dst(g::PlanarMultigraph{T}, he_id::T) where {T} = dst(g.half_edges[he_id])
half_edge(g::PlanarMultigraph{T}, he_id::T) where {T} = g.half_edges[he_id]
face(g::PlanarMultigraph{T}, he_id::T) where {T} = g.he2f[he_id]

α(g::PlanarMultigraph{T}, he_id::T) where {T} = g.next[he_id]
next(g::PlanarMultigraph{T}, he_id::T) where {T} = α(g, he_id)

"""
    prev(g::PlanarMultigraph{T}, he_id::T) where {T<:Integer}

Provides Previous Half Edge of a facet. HDS is bidi
"""
function prev(g::PlanarMultigraph{T}, he_id::T) where {T<:Integer}
    nxt_he_id = next(g, he_id)
    nn_he_id = next(g, nxt_he_id)
    while nn_he_id != he_id
        nxt_he_id = nn_he_id
        nn_he_id = next(g, nxt_he_id)
    end
    return nxt_he_id
end


"""
    ϕ(g::PlanarMultigraph{T}, he_id::T) where {T}

Get twin half edge id
"""
ϕ(g::PlanarMultigraph{T}, he_id::T) where {T} = g.twin[he_id]

twin(g::PlanarMultigraph{T}, he_id::T) where {T} = ϕ(g, he_id)


"""
    σ(g::PlanarMultigraph{T}, he_id::T) where {T}

Get prev_at_source
"""
σ(g::PlanarMultigraph{T}, he_id::T) where {T} = twin(g, prev(g, he_id))

"""
    σ_inv(g::PlanarMultigraph{T}, he_id::T) where {T}

Get netx_at_source
"""
σ_inv(g::PlanarMultigraph{T}, he_id::T) where {T} = next(g, twin(g, he_id))

nv(g::PlanarMultigraph) = length(g.v2he)
nf(g::PlanarMultigraph) = length(g.f2he)
nhe(g::PlanarMultigraph) = length(g.half_edges)
ne(g::PlanarMultigraph) = nhe(g) ÷ 2

out_half_edge(g::PlanarMultigraph{T}, v::T) where {T} = g.v2he[v]

surrounding_half_edge(g::PlanarMultigraph{T}, f::T) where {T} = g.f2he[f]

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

function trace_face(g::PlanarMultigraph{T}, f::T; safe_trace = false) where {T}
    !safe_trace && return trace_orbit(h -> g.next[h], surrounding_half_edge(g, f))
    hes_f = T[]
    for (he, f_he) in g.he2f
        f_he == f && push!(hes_f, he)
    end
    return hes_f
end

function trace_vertex(g::PlanarMultigraph{T}, v::T) where {T}
    return trace_orbit(h -> σ_inv(g, h), out_half_edge(g, v); rev = true)
end

neighbors(g::PlanarMultigraph{T}, v::T) where {T} =
    [dst(g, he) for he in trace_vertex(g, v)]

"""
    is_boundary(g::PlanarMultigraph{T}, he_id::T) where {T}

If the half edge is on the boundary of entire manifold
"""
is_boundary(g::PlanarMultigraph{T}, he_id::T) where {T} = (face(g, he_id) == 0)

function rem_vertex!(g::PlanarMultigraph{T}, v::T; update::Bool = true) where {T}
    for he_id in trace_vertex(g, v)
        rem_edge!(g, he_id; update = update)
    end
    delete!(g.v2he, v)
    return g
end

function rem_edge!(g::PlanarMultigraph{T}, he_id::T; update::Bool = true) where {T}
    # make sure the face of he_id is an inner face
    if is_boundary(g, he_id)
        he_id = twin(g, he_id)
    end

    # handle self-loop
    if next(g, twin(g, he_id)) == twin(g, he_id)
        if next(g, he_id) == he_id  # isolated self-loop
            v_loop = src(g, he_id)
            twin_id = twin(g, he_id)
            he_in = (surrounding_half_edge(g, face(g, he_id)) == he_id) ? he_id : twin_id
            he_out = twin(g, he_in)
            f_in = face(g, he_in)
            f_out = face(g, he_out)

            hes_f_he = trace_face(g, f_in; safe_trace = true)
            rem_face!(g, f_in)
            for he in hes_f_he
                g.he2f[he] = f_out
            end
            for he_rm in (he_in, he_out)
                delete!(g.he2f, he_rm)
                delete!(g.half_edges, he_rm)
                delete!(g.next, he_rm)
                delete!(g.twin, he_rm)
            end
            if update
                delete!(g.v2he, v_loop)
            end
            return g
        end
        he_id = twin(g, he_id)
        is_boundary(g, he_id) && (he_id = twin(g, he_id))
    end

    twin_id = twin(g, he_id)

    if update
        he_next = next(g, he_id)
        he_prev = prev(g, he_id)
        twin_next = next(g, twin_id)
        twin_prev = prev(g, twin_id)

        face_he = face(g, he_id)
        face_twin = face(g, twin_id)

        # remove a inner face
        if face_he != face_twin
            hes_f_he = trace_face(g, face_he; safe_trace = true)
            rem_face!(g, face_he)
            for he in hes_f_he
                g.he2f[he] = face_twin
            end
        end

        # update f2he
        if surrounding_half_edge(g, face_twin) in (he_id, twin_id)
            new_he = nothing
            for nhe in (he_next, he_prev, twin_next, twin_prev)
                if !(nhe in (he_id, twin_id))
                    g.f2he[face_twin] = nhe
                    new_he = nhe
                    break
                end
            end
            new_he === nothing && error("surrounding half edge not founded")
        end

        # update v2he
        (out_half_edge(g, src(g, he_id)) == he_id) &&
            (g.v2he[src(g, he_id)] = twin(g, he_prev))
        if out_half_edge(g, src(g, twin_id)) in (he_id, twin_id)
            if twin_id == twin_next
                g.v2he[src(g, twin_id)] = he_next
            else
                g.v2he[src(g, twin_id)] = twin(g, twin_prev)
            end
        end

        if he_next == he_id # he_id is the inner half edge of a self-loop
            g.next[twin_prev] = twin_next
        elseif twin_next == twin_id
            g.next[he_prev] = he_next
        else
            g.next[he_prev] = twin_next
            g.next[twin_prev] = he_next
        end

        if he_next == twin_id
            delete!(g.v2he, src(g, he_next))
        end
        if twin_next == he_id
            delete!(g.v2he, src(g, twin_next))
        end
    end
    delete!(g.next, he_id)
    delete!(g.next, twin_id)
    delete!(g.half_edges, he_id)
    delete!(g.half_edges, twin_id)
    delete!(g.twin, he_id)
    delete!(g.twin, twin_id)
    delete!(g.he2f, he_id)
    delete!(g.he2f, twin_id)

    return g
end

function rem_face!(g::PlanarMultigraph{T}, f::T) where {T}
    f == 0 && error("Face 0 is for the boundary. It can not be removed.")
    half_edges_f = trace_face(g, f)
    for he in half_edges_f
        delete!(g.he2f, he)
    end
    delete!(g.f2he, f)
    return g
end

function merge_graph!(A::PlanarMultigraph, B::PlanarMultigraph)
    for (v, he_id) in B.v2he
        A.v2he[v+A.v_max] = he_id + A.he_max
    end
    for (he_id, he) in B.half_edges
        A.half_edges[he_id+A.he_max] = HalfEdge(src(he) + A.v_max, dst(he) + A.v_max)
    end
    for (f, he_id) in B.f2he
        if f != 0
            A.f2he[f+A.f_max] = he_id + A.he_max
        end
    end
    for (he_id, f) in B.he2f
        if f != 0
            A.he2f[he_id+A.he_max] = f + A.f_max
        else
            A.he2f[he_id+A.he_max] = 0
        end
    end
    for (curr, next) in B.next
        A.next[curr+A.he_max] = next + A.he_max
    end
    for (curr, twin) in B.twin
        A.twin[curr+A.he_max] = twin + A.he_max
    end

    A.v_max += B.v_max
    A.he_max += B.he_max
    A.f_max += B.f_max

    return A
end

function check_faces(g::PlanarMultigraph)
    for f in faces(g)
        hes_f = trace_face(g, f)
        for he in hes_f
            face(g, he) == f || return false
        end
    end
    return true
end

function check_vertices(g::PlanarMultigraph)
    for v in vertices(g)
        hes_v = trace_vertex(g, v)
        for he in hes_v
            src(g, he) == v || return false
        end
    end
    return true
end

function check_combinatorial_maps(g::PlanarMultigraph)
    for he in half_edges(g)
        (he == α(g, ϕ(g, σ(g, he)))) || return false
    end
    return true
end

function update_face!(g::PlanarMultigraph{T}, he_id::T) where {T<:Integer}
    face_id = face(g, he_id)
    fs_rm = Int[]
    g.f2he[face_id] = he_id
    curr_he = next(g, he_id)
    while curr_he != he_id
        if g.he2f[curr_he] != face_id
            push!(fs_rm, g.he2f[curr_he])
            g.he2f[curr_he] = face_id
        end
        curr_he = next(g, curr_he)
    end
    return g
end

function add_vertex!(g::PlanarMultigraph{T}, f::T) where {T<:Integer}
    haskey(g.f2he, f) || return 0
    g.v_max += 1
    v = g.v_max
    g.vs_isolated[v] = f
    return v
end

function add_edge!(g::PlanarMultigraph{T}, v1::T, v2::T, f::T) where {T<:Integer}
    hes_f = trace_face(g, f)
    he1_in, he1_out, he2_in, he2_out = (0, 0, 0, 0)
    for he in hes_f
        dst(g, he) == v1 && (he1_in = he; he1_out = next(g, he))
        dst(g, he) == v2 && (he2_in = he; he2_out = next(g, he))
    end
    he1_in * he1_out * he2_in * he2_out != 0 || return (0, 0)
    new_he1 = g.he_max + 1
    new_he2 = g.he_max + 2
    g.he_max += 2
    g.twin[new_he1] = new_he2
    g.twin[new_he2] = new_he1
    g.half_edges[new_he1] = HalfEdge(v1, v2)
    g.half_edges[new_he2] = HalfEdge(v2, v1)
    g.next[he1_in] = new_he1
    g.next[new_he1] = he2_out
    g.next[he2_in] = new_he2
    g.next[new_he2] = he1_out
    g.he2f[new_he1] = f
    g.f2he[f] = new_he1
    g.f_max += 1
    g.he2f[new_he2] = g.f_max
    g.f2he[g.f_max] = new_he2
    update_face!(g, new_he2)
    return (new_he1, new_he2)
end

function contract_edge!(g::PlanarMultigraph, he_id::Integer)
    twin_id = twin(g, he_id)
    he_prev = prev(g, he_id)
    he_next = next(g, he_id)
    twin_prev = prev(g, twin_id)
    twin_next = next(g, twin_id)

    v1 = src(g, he_id)
    v2 = dst(g, he_id)
    if v1 == v2
        rem_edge!(g, he_id; update = true)
        return (v1, v2)
    end
    if length(trace_vertex(g, v1)) == 1
        if length(trace_vertex(g, v2)) > 1
            (v11, v22) = contract_edge!(g, twin_id)
            return (v22, v11)
        else
            # 2 isolated vertices
            error("TODO: fix this")
        end
    end

    # update out half edge of v1
    out_half_edge(g, v1) == he_id && (g.v2he[v1] = twin_next)
    for he in trace_vertex(g, v2)
        v0 = dst(g, he)
        g.half_edges[he] = HalfEdge(v1, v0)
        g.half_edges[twin(g, he)] = HalfEdge(v0, v1)
    end

    if he_next == twin_id
        g.next[he_prev] = twin_next
        g.f2he[face(g, he_id)] = he_prev
    else
        g.next[he_prev] = he_next
        g.next[twin_prev] = twin_next
        g.f2he[face(g, he_id)] = he_prev
        g.f2he[face(g, twin_id)] = twin_prev
    end
    delete!(g.next, he_id)
    delete!(g.next, twin_id)
    delete!(g.half_edges, he_id)
    delete!(g.half_edges, twin_id)
    delete!(g.twin, he_id)
    delete!(g.twin, twin_id)
    delete!(g.he2f, he_id)
    delete!(g.he2f, twin_id)
    delete!(g.v2he, v2)
    # v2 is removed
    return (v1, v2)
end

"""
    split_edge!(g::PlanarMultigraph, he_id)

Split the edge corresponding to `he` into 2 edges.
This is used for creating planar simple graphs from planar multigraphs.
"""
function split_edge!(g::PlanarMultigraph{T}, he_id::T) where {T<:Integer}
    he1 = he_id
    he2 = twin(g, he_id)
    next1 = next(g, he1)
    next2 = next(g, he2)
    f1 = face(g, he1)
    f2 = face(g, he2)
    s = src(g, he_id)
    d = dst(g, he_id)
    g.v_max += 1
    v = g.v_max
    g.he_max += 2
    nhe1 = g.he_max - 1
    nhe2 = g.he_max

    g.next[he1] = nhe1
    g.next[nhe1] = next1
    g.next[he2] = nhe2
    g.next[nhe2] = next2
    g.twin[nhe1] = he2
    g.twin[he2] = nhe1
    g.twin[nhe2] = he1
    g.twin[he1] = nhe2

    g.half_edges[he1] = HalfEdge(s, v)
    g.half_edges[nhe2] = HalfEdge(v, s)
    g.half_edges[nhe1] = HalfEdge(v, d)
    g.half_edges[he2] = HalfEdge(d, v)

    g.he2f[nhe1] = f1
    g.he2f[nhe2] = f2

    g.v2he[v] = nhe1

    return v, nhe1, nhe2
end

"""
    normalize(g)

Return a relabeled planar graph.
"""
function normalize(g::PlanarMultigraph)
    f_max = nf(g) - 1
    he_max = nhe(g)
    v_max = nv(g)

    f_map = Dict(zip(faces(g), 0:f_max))
    he_map = Dict(zip(half_edges(g), 1:he_max))
    v_map = Dict(zip(sort!(vertices(g)), 1:v_max))

    v2he = Dict{Int,Int}(v_map[v] => he_map[he] for (v, he) in g.v2he)
    halfedges = Dict{Int,HalfEdge}(
        he_map[he_id] => HalfEdge(v_map[he.src], v_map[he.dst]) for
        (he_id, he) in g.half_edges
    )

    f2he = Dict{Int,Int}(f_map[f] => he_map[he] for (f, he) in g.f2he)
    he2f = Dict{Int,Int}(he_map[he] => f_map[f] for (he, f) in g.he2f)

    next = Dict{Int,Int}(he_map[cur] => he_map[nxt] for (cur, nxt) in g.next)
    twin = Dict{Int,Int}(he_map[cur] => he_map[twn] for (cur, twn) in g.twin)

    g_new = PlanarMultigraph(v2he, halfedges, f2he, he2f, next, twin, v_max, he_max, f_max)
    return g_new, v_map, he_map, f_map
end

"""
    n_conn_comp(g::PlanarMultigraph)

Return the number of connected components.
"""
n_conn_comp(g::PlanarMultigraph) = nv(g) - ne(g) + nf(g) - 1

has_vertex(g::PlanarMultigraph, v) = haskey(g.v2he, v)
has_half_edge(g::PlanarMultigraph, he) = haskey(g.half_edges, he)
has_face(g::PlanarMultigraph, f) = haskey(g.f2he, f)
