import Graphs: AbstractEdge, src, dst, nv, ne, neighbors
import Graphs.SimpleGraphs: rem_edge!, rem_vertex!, add_edge!, add_vertex!
export HalfEdge, src, dst, new_edge, PlanarMultigraph

"""
    HalfEdge{T<:Integer}(src ,dst)

Datatype to represent a Half Edge

## Reference

* Brönnimann, Hervé [Designing and Implementing a General Purpose Halfedge Data Structure]
(https://doi.org/10.1007/3-540-44688-5_5)
"""
struct HalfEdge{T<:Integer} <: AbstractEdge{T}
    src::T
    dst::T
end

src(he::HalfEdge) = he.src
dst(he::HalfEdge) = he.dst

"""
    new_edge(src::T, dst::T) where {T<:Integer}

Create a half edge and its twin
"""
new_edge(src::T, dst::T) where {T<:Integer} = (HalfEdge(src, dst), HalfEdge(dst, src))

function Base.:(==)(he1::HalfEdge, he2::HalfEdge)
    src(he1) == src(he2) && dst(he1) == dst(he2)
end

"""
    PlanarMultigraph{T<:Integer}

Implements a planar multigraph with a maximal HDS Structure.

## Features
1. Stores Forward Half Edge pointer in facet
2. Vertex linked
3. Face Linked
"""
mutable struct PlanarMultigraph{T<:Integer}
    v2he::Dict{T,T}  # v_id -> he_id
    half_edges::Dict{T,HalfEdge{T}} # he_id -> he

    f2he::Dict{T,T}  # f_id -> he_id
    he2f::Dict{T,T}    # he_id -> f_id, if cannot find, then it's a boundary

    next::Dict{T,T}    # he_id -> he_id
    twin::Dict{T,T}    # he_id -> he_id

    v_max::T
    he_max::T
    f_max::T
    PlanarMultigraph{T}() where {T<:Int} = new{Int64}(
        Dict{T,T}(),
        Dict{T,HalfEdge{T}}(),
        Dict{T,T}(),
        Dict{T,T}(),
        Dict{T,T}(),
        Dict{T,T}(),
        0,
        0,
        0,
    )
end

function PlanarMultigraph{T}(qubits::Int) where {T<:Integer}
    g = PlanarMultigraph{T}()
    for _ = 1:qubits
        vtxs = create_vertex(g; mul = 2)
        hes_id, _ = create_edge(g, vtxs[1], vtxs[2])
        g.he2f[hes_id[1]] = 0
        g.he2f[hes_id[2]] = 0
    end
    return g
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

"""
    out_half_edge(g::PlanarMultigraph{T}, v::T)

Get the one out half edge of a vertex
"""
out_half_edge(g::PlanarMultigraph{T}, v::T) where {T} = g.v2he[v]

"""
    surrounding_half_edge(g::PlanarMultigraph{T}, f::T)

Get the one surrounding half edge of a face
"""
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

trace_vertex(g::PlanarMultigraph{T}, v::T) where {T} =
    trace_orbit(h -> σ_inv(g, h), out_half_edge(g, v); rev = true)

neighbors(g::PlanarMultigraph{T}, v::T) where {T} =
    [dst(g, he) for he in trace_vertex(g, v)]

"""
    is_boundary(g::PlanarMultigraph{T}, he_id::T) where {T}

If the half edge is on the boundary of entire manifold
"""
is_boundary(g::PlanarMultigraph{T}, he_id::T) where {T} = (face(g, he_id) == 0)

"""
    split_vertex!(g::PlanarMultigraph{T}, he1::T, he2::T) where {T<:Integer}

Split a vertex into 2 vertices.

Connect the two vertices with a new pair of half edges.
he1 and he2 are half edges that marks the start and end
of half edges that remain on v1.
"""
function split_vertex!(pmg::PlanarMultigraph{T}, h1t::T, g1t::T) where {T<:Integer}
    v1 = dst(pmg, h1t)

    # add new vertex into g
    v2 = create_vertex!(pmg)[1]

    # add new half edges from v1 to v2
    hes_id, _ = create_edge!(pmg, v1, v2)

    he_vec = trace_orbit(h -> σ_inv(pmg, h), h1t; rev = true)
    if length(he_vec) == 1
        pmg.he2f[hes_id[1]] = 0
        pmg.he2f[hes_id[2]] = 0
        return pmg
    end

    # update all half edges in he_vec2 to have destination at v2
    for he in he_vec2
        set_dst!(pmg, he, v2)
    end

    set_next!(pmg, twin(pmg, h1), hes_id[1])
    set_next!(pmg, hes_id[2], g1)

    he2_pos == length(out_hes) && return g

    set_next!(g, twin(g, out_hes[he2_pos+1]), new_he2)
    set_next!(g, new_he1, out_hes[end])
    return pmg
end

all_out(g::PlanarMultigraph, he_vec::Vector{T}) where {T} =
    all(he -> src(g, he) == src(g, he_vec[1]), he_vec)

function set_opposite!(g::PlanarMultigraph{T}, he1::T, he2::T) where {T<:Integer}
    he1 == he2 && error("Can't set opposite to itself")

    !(he1 ∈ half_edges(g)) && error("he1 not in g")
    !(he2 ∈ half_edges(g)) && error("he2 not in g")

    g.twin[he1] = he2
    g.twin[he2] = he1
    return g
end

function set_next!(g::PlanarMultigraph{T}, he1::T, he2::T) where {T<:Integer}
    he1 == he2 && error("Can't set next to itself")
    g.next[he1] = he2
    return g
end

function set_dst!(g::PlanarMultigraph{T}, he::T, v::T) where {T<:Integer}
    twin_he = twin(g, he)
    g.half_edges[he] = HalfEdge(src(g, he), v)
    g.half_edges[twin_he] = HalfEdge(v, dst(g, twin_he))
    return g
end

"""
    join_vertices!(g::PlanarMultigraph{T}, he::T) where {T<:Integer}

Join two vertices connected by a HalfEdge into one.
"""
function join_vertices!(
    g::PlanarMultigraph{T},
    he::T;
    update::Bool = false,
) where {T<:Integer}
    hes1 = trace_orbit(h -> σ_inv(g, h), he; rev = true)
    hes2 = trace_orbit(h -> σ_inv(g, twin(g, h)), he; rev = true)

    length(hes1) + length(hes2) == 2 &&
        error("Cann't have isolated vertex after vertex merging")
    if length(hes2) > length(hes1)
        he = twin(g, he)
        hes1, hes2 = hes2, hes1
    end

    g.v2he[src(g, he)] = hes1[2]
    delete!(g.v2he, dst(g, he))

    v1 = src(g, he)
    v2 = dst(g, he)
    for he2 in hes2
        twin_id = twin(g, he2)
        g.half_edges[he2] = HalfEdge(v1, dst(g, he2))
        g.half_edges[twin_id] = HalfEdge(src(g, twin_id), v1)
    end

    # update g's fields
    he_face = face(g, next(g, he))
    twin_he_face = face(g, next(g, twin(g, he)))
    # add test here
    g.f2he[he_face] = next(g, he)
    g.f2he[twin_he_face] = next(g, twin(g, he))
    delete!(g.he2f, he)

    g.next[prev(g, he)] = g.next[he]
    g.next[prev(g, twin(g, he))] = g.next[twin(g, he)]

    if update
        g = normalize(g)
    end
    return g
end

function split_facet!(g::PlanarMultigraph{T}, he1::T, he2::T) where {T<:Integer}
    he1n = next(g, he1)
    he2n = next(g, he2)

    g.he_max += 2
    new_he1, new_he2 = g.he_max - 1, g.he_max
    new_he_pair = new_edge(dst(g, he1), dst(g, he2))
    g.half_edges[new_he1] = new_he_pair[1]
    g.half_edges[new_he2] = new_he_pair[2]

    g.twin[new_he1] = new_he2
    g.twin[new_he2] = new_he1

    f1 = face(g, he1)
    g.f_max += 1
    f2 = g.f_max
    g.f2he[f1] = new_he1
    g.f2he[f2] = new_he2

    g.next[he1] = new_he1
    g.next[new_he1] = he2n
    g.next[he2] = new_he2
    g.next[new_he2] = he1n

    return g
end

function join_facets!(g::PlanarMultigraph{T}, he::T; update::Bool = true) where {T}
    twin_he = twin(g, he)
    he1 = prev(g, he)
    he2 = prev(g, twin_he)
    he3 = next(g, he)
    he4 = next(g, twin_he)

    g.next[he1] = he4
    g.next[he2] = he3

    f1_id = face(g, he1)
    f2_id = face(g, he2)

    hes_f = trace_face(g, f2_id; safe_trace = false)
    for hef in hes_f
        g.he2f[hef]f1_id
    end

    g.f2he[f1_id] = he1
    delete!(g.f2he, f2_id)

    if update
        g = normalize(g)
    end
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
            for (v_iso, f_iso) in g.vs_isolated
                f_iso == f_in && (g.vs_isolated[v_iso] = f_out)
            end
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
                g.vs_isolated[v_loop] = f_out
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
            for (v_iso, f_iso) in g.vs_isolated
                f_iso == face_he && (g.vs_isolated[v_iso] = face_twin)
            end
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
            g.vs_isolated[src(g, he_next)] = face(g, he_next)
            delete!(g.v2he, src(g, he_next))
        end
        if twin_next == he_id
            g.vs_isolated[src(g, twin_next)] = face(g, twin_next)
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
    for (v, f) in B.vs_isolated
        A.vs_isolated[v+A.v_max] = (f == 0) ? 0 : (f + A.f_max)
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
    for (v, f) in g.vs_isolated
        (f in fs_rm) && (g.vs_isolated[v] = face_id)
    end
    return g
end

function add_edge_isolated_1!(g::PlanarMultigraph{T}, v1::T, v2::T, f::T) where {T<:Integer}
    f == g.vs_isolated[v1] || return (0, 0)
    hes = trace_vertex(g, v2)
    he2_in = 0
    he2_out = 0
    for he in hes
        if face(g, twin(g, he)) == f
            he2_in = twin(g, he)
            he2_out = next(g, he2_in)
            break
        end
    end
    he2_in * he2_out != 0 || return (0, 0)

    g.he_max += 2
    new_he1 = g.he_max - 1
    new_he2 = g.he_max
    g.v2he[v1] = new_he2
    g.twin[new_he1] = new_he2
    g.twin[new_he2] = new_he1
    g.next[he2_in] = new_he1
    g.next[new_he1] = new_he2
    g.next[new_he2] = he2_out
    g.he2f[new_he1] = f
    g.he2f[new_he2] = f
    g.half_edges[new_he1] = HalfEdge(v2, v1)
    g.half_edges[new_he2] = HalfEdge(v1, v2)
    delete!(g.vs_isolated, v1)

    return (new_he1, new_he2)
end

function add_edge_isolated_2!(g::PlanarMultigraph{T}, v1::T, v2::T, f::T) where {T<:Integer}
    f == g.vs_isolated[v1] == g.vs_isolated[v2] || return (0, 0)
    g.he_max += 2
    new_he1 = g.he_max - 1
    new_he2 = g.he_max
    g.twin[new_he1] = new_he2
    g.twin[new_he2] = new_he1
    g.next[new_he1] = new_he2
    g.next[new_he2] = new_he1
    g.v2he[v1] = new_he1
    g.v2he[v2] = new_he2
    g.he2f[new_he1] = f
    g.he2f[new_he2] = f
    g.half_edges[new_he1] = HalfEdge(v1, v2)
    g.half_edges[new_he2] = HalfEdge(v2, v1)
    delete!(g.vs_isolated, v1)
    delete!(g.vs_isolated, v2)

    return (new_he1, new_he2)
end

function add_edge!(g::PlanarMultigraph{T}, v1::T, v2::T, f::T) where {T<:Integer}
    if is_isolated(g, v1)
        if is_isolated(g, v2)
            return add_edge_isolated_2!(g, v1, v2, f)
        else
            return add_edge_isolated_1!(g, v1, v2, f)
        end
    elseif is_isolated(g, v2)
        return add_edge_isolated_1!(g, v2, v1, f)
    end
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
            rem_vertex!(g, v1; update = true)
            return (v1, v2)
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

    vs_isolated = Dict{Int,Int}(v_map[v] => f_map[f] for (v, f) in g.vs_isolated)

    g_new = PlanarMultigraph(
        v2he,
        halfedges,
        f2he,
        he2f,
        next,
        twin,
        vs_isolated,
        v_max,
        he_max,
        f_max,
    )
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

"""
    create_vertex!(g::PlanarMultigraph{T}; mul::Int = 1) where {T<:Integer}

Create vertices.

Create `mul` of vertices and record them in PlanarMultigraph g's `v_max` field.
"""
function create_vertex!(g::PlanarMultigraph{T}; mul::Int = 1) where {T<:Integer}
    g.v_max += mul
    return collect(g.v_max-mul+1:g.v_max)
end

"""
    create_face!(g::PlanarMultigraph{T}; mul::Int = 1) where {T<:Integer}

Create an a pair of halfedge from vs to vd, add to PlanarMultigraph g.

f2he, he2f, next not updated

"""
function create_edge!(g::PlanarMultigraph{T}, vs::T, vd::T) where {T<:Integer}
    hes = new_edge(vs, vd)
    g.he_max += 2
    hes_id = T[g.he_max-1, g.he_max]
    set_opposite!(g, hes_id[1], hes_id[2])
    for (he_id, he) in zip(hes_id, hes)
        g.half_edges[he_id] = he
    end
    g.v2he[vs] = hes_id[1]
    g.v2he[vd] = hes_id[2]
    return hes_id, hes
end

function destroy_vertex!(g::PlanarMultigraph{T}, v::T) where {T<:Integer}
    !(v in vertices(g)) && error("Vertex $v not in graph")
    delete!(g.v2he, v)
    return g
end

function destroy_edge!(g::PlanarMultigraph{T}, h1::T) where {T<:Integer}
    !(h1 in half_edges(g)) && error("Half edge $h1 not in graph")
    h1_twin = twin(g, h1)
    delete!(g.half_edges, h1)
    delete!(g.half_edges, h1_twin)
    return g
end
