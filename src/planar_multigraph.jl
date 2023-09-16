import Graphs: AbstractEdge, src, dst, nv, ne, neighbors
import Graphs.SimpleGraphs: rem_edge!, rem_vertex!, add_edge!, add_vertex!, vertices
export HalfEdge, src, dst, new_edge, PlanarMultigraph

"""
    HalfEdge{T<:Integer}(src ,dst)

Datatype to represent a Half Edge

## Reference

* Brönnimann, Hervé [Designing and Implementing a General Purpose Halfedge Data Structure]
(https://doi.org/10.1007/3-540-44688-5_5)
* [CGAL Library HalfEdge Data Structure](https://doc.cgal.org/latest/Arrangement_on_surface_2/classCGAL_1_1Arrangement__on__surface__2_1_1Halfedge.html)
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
## References:
Our implementation is based heavily on the [CGAL
Library](https://www.cgal.org/). A good introduction on the HDS Structure and
the Polyhedron3 Object which gives the boundary representation of a 2-manifold
can be found in this
[paper](https://linkinghub.elsevier.com/retrieve/pii/S0925772199000073).

### TODO: Proof of Completeness for Euler Operations with Preconditions In the
CGAL Library, the Euler Operations are implemented with preconditions. It was
pointed out that Euler Operations are closed for orientable 2-manifolds in
[paper](https://www.sciencedirect.com/science/article/pii/S0925772199000073?via%3Dihub)
where the detailed proof is in
[book](https://books.google.co.jp/books?id=CJVRAAAAMAAJ).
It was further pointed out in
[paper](https://www.sciencedirect.com/science/article/abs/pii/0734189X84901294)
that Euler Operations are complete in Theorem 4.4.

The question remains whether the completeness remains for the preconditions
attached.
One way of proving is to show that for the Euler Operations used in Theorem 4.4,
we could always construct them out of the Euler Operations in CGAL Library with
preconditions?
"""
mutable struct PlanarMultigraph{T<:Integer}
    v2he::Dict{T,T} # v_id -> he_id
    half_edges::Dict{T,HalfEdge{T}} # he_id -> he

    f2he::Dict{T,T}  # f_id -> he_id
    he2f::Dict{T,T}    # he_id -> f_id, if cannot find, then it's a boundary

    next::Dict{T,T}    # he_id -> he_id, counter clockwise
    twin::Dict{T,T}    # he_id -> he_id


    v_max::T
    he_max::T
    f_max::T
    boundary::Vector{T} # f_id
end

PlanarMultigraph{T}() where {T<:Int} = PlanarMultigraph{T}(
    Dict{T,T}(),
    Dict{T,HalfEdge{T}}(),
    Dict{T,T}(),
    Dict{T,T}(),
    Dict{T,T}(),
    Dict{T,T}(),
    0,
    0,
    0,
    [0],
)

function PlanarMultigraph{T}(qubits::Int) where {T<:Integer}
    g = PlanarMultigraph{T}()
    for _ = 1:qubits
        vtxs = create_vertex!(g; mul = 2)
        hes_id, _ = create_edge!(g, vtxs[1], vtxs[2])
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
    copy(g.boundary),
)

function Base.:(==)(pmg1::PlanarMultigraph{T}, pmg2::PlanarMultigraph{T}) where {T<:Integer}
    if nv(pmg1) != nv(pmg2)
        println("nv")
        println(nv(pmg1))
        println(nv(pmg2))
        return false
    end
    if nhe(pmg1) != nhe(pmg2)
        println("nhe")
        println(nhe(pmg1))
        println(nhe(pmg2))
        return false
    end
    if nf(pmg1) != nf(pmg2)
        println("nf")
        println(nf(pmg1))
        println(nf(pmg2))
        return false
    end

    # could be relaxed, idx might be different but content needs to be the same for HalfEdges
    if pmg1.next != pmg2.next
        println("next")
        println(pmg1.next)
        println(pmg2.next)
        return false
    end

    if pmg1.twin != pmg2.twin
        println("twin")
        println(pmg1.twin)
        println(pmg2.twin)
        return false
    end

    if pmg1.he2f != pmg2.he2f
        println("he2f")
        println(pmg1.he2f)
        println(pmg2.he2f)
        return false
    end

    if sort(pmg1.boundary) != sort(pmg2.boundary)
        println("boundary")
        println(pmg1.boundary)
        println(pmg2.boundary)
        return false
    end
    return true
end

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
    σ_inv(pmg::PlanarMultigraph{T}, h::T) where {T}

Get next_at_source, clockwise
"""
σ_inv(pmg::PlanarMultigraph{T}, h::T) where {T} = next(pmg, twin(pmg, h))

nv(pmg::PlanarMultigraph) = length(pmg.v2he)
nf(pmg::PlanarMultigraph) = length(pmg.f2he)
nhe(pmg::PlanarMultigraph) = length(pmg.half_edges)
ne(pmg::PlanarMultigraph) = nhe(pmg) ÷ 2

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

"""
    trace_face(g::PlanarMultigraph{T}, f::T; safe_trace = false) where {T}

Return the half edges of a face.

If `safe_trace` is true, then the half edges are returned in scrambled order.
Otherwise, the returned half edges are in counter clockwise order
but is not guaranteed to be consitent with he2f.
"""
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

neighbors(pmg::PlanarMultigraph{T}, v::T) where {T} =
    [dst(pmg, he) for he in trace_vertex(pmg, v)]

"""
    is_boundary(g::PlanarMultigraph{T}, he_id::T) where {T}

If the half edge is on the boundary of entire manifold
"""
is_boundary(g::PlanarMultigraph{T}, he_id::T) where {T} = (face(g, he_id) ∈ g.boundary)


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
    create_edge!(pmg::PlanarMultigraph{T}, vs::T, vd::T) where {T<:Integer}
Create an a pair of halfedge from vs to vd, add to PlanarMultigraph pmg.
Facet information is not updated yet but set to default value of 0.
Vertex to halfedge is updated and set to the two newly added half edges.
"""
function create_edge!(pmg::PlanarMultigraph{T}, vs::T, vd::T) where {T<:Integer}
    hes = new_edge(vs, vd)
    pmg.he_max += 2
    hes_id = T[pmg.he_max-1, pmg.he_max]
    for (he_id, he) in zip(hes_id, hes)
        pmg.half_edges[he_id] = he
    end
    set_face!(pmg, hes_id, 0; both = false)
    set_opposite!(pmg, hes_id...)
    pmg.v2he[vs] = hes_id[1]
    pmg.v2he[vd] = hes_id[2]
    return hes_id, hes
end

"""
    create_face!(pmg::PlanarMultigraph{T}) where {T<:Integer}

"""
function create_face!(pmg::PlanarMultigraph{T}) where {T<:Integer}
    pmg.f_max += 1
    return pmg.f_max
end

"""
    make_hole!(pmg::PlanarMultigraph{T}, h::T) where {T<:Integer}

Convert the facet incident to a half edge into a hole.

Makes all the half edges in the facet a boundary halfedge.

## Reference
- [CGAL](https://doc.cgal.org/latest/Polyhedron/classCGAL_1_1Polyhedron__3.html#a228add3cae2d328bcdd67192a98fb636)
"""
function make_hole!(pmg::PlanarMultigraph{T}, h::T) where {T<:Integer}
    hes_f = trace_face(pmg, face(pmg, h); safe_trace = false)
    any(he -> is_boundary(pmg, he), hes_f) && error("Can't make hole for boundary halfedge")

    push!(pmg.boundary, face(pmg, h))
    return h
end

function destroy_vertex!(pmg::PlanarMultigraph{T}, v::T) where {T<:Integer}
    !(v in vertices(pmg)) && error("Vertex $v not in graph")
    delete!(pmg.v2he, v)
    return pmg
end

function destroy_edge!(pmg::PlanarMultigraph{T}, h::T) where {T<:Integer}
    !(h in half_edges(pmg)) && error("Half edge $h not in graph")
    twin_h = twin(pmg, h)
    pmg.v2he[src(pmg, h)] = σ_inv(pmg, h)
    pmg.v2he[dst(pmg, h)] = σ_inv(pmg, twin_h)
    delete!(pmg.half_edges, h)
    delete!(pmg.half_edges, twin_h)
    delete!(pmg.twin, h)
    delete!(pmg.twin, twin_h)
    delete!(pmg.next, h)
    delete!(pmg.next, twin_h)
    delete!(pmg.he2f, h)
    delete!(pmg.he2f, twin_h)
    return pmg
end

"""
    split_facet!(pmg::PlanarMultigraph{T}, h::T, g::T) where {T<:Integer}

Split a facet incident to h and g into two facets.

## Precondition
1. h and g are in the same facet
2. h and g are not the same half edge
3. Cannot be used to split the faces incident to the multiedge.
"""
function split_facet!(pmg::PlanarMultigraph{T}, h::T, g::T) where {T<:Integer}

    face(pmg, h) == face(pmg, g) || error("h and g are not in the same face")

    h == g && error("h and g can't be the same half edge")

    (next(pmg, h) == g && next(pmg, g) == h) &&
        error("Should use #TODO to add multiedge and split facet!")

    hn = next(pmg, h)
    gn = next(pmg, g)

    new_hes, _ = create_edge!(pmg, dst(pmg, h), dst(pmg, g))

    f_old = face(pmg, g)
    f_new = create_face!(pmg)

    # I require the order to be ccw
    hes_f = trace_face(pmg, f_old; safe_trace = false)
    hes_f = circshift(hes_f, -findfirst(he -> he == h, hes_f))

    # update face information for righ half of the old face
    for he in hes_f
        set_face!(pmg, he, f_new)
        (he == g) && break
    end

    set_face!(pmg, new_hes[1], f_old; both = true)
    set_face!(pmg, new_hes[2], f_new; both = true)

    set_next!(pmg, [h, g, new_hes...], [new_hes..., gn, hn])
    return new_hes[1]
end

"""
    join_facet!(pmg::PlanarMultigraph{T}, h::T) where {T}

Join two facets incident to h and it's twin into one.

The facet incident to h is removed.
"""
function join_facet!(pmg::PlanarMultigraph{T}, h::T) where {T}
    vs = src(pmg, h)
    vd = dst(pmg, h)

    length(trace_vertex(pmg, vs)) <= 3 && error("Src vtx must have degree 3 or above")
    length(trace_vertex(pmg, vd)) <= 3 && error("Dst vtx must have degree 3 or above")

    twin_h = twin(pmg, h)
    hp = prev(pmg, h)
    thp = prev(pmg, twin_h)
    hn = next(pmg, h)
    thn = next(pmg, twin_h)

    f1_id = face(pmg, h)
    f2_id = face(pmg, twin_h)
    hes_f = trace_face(pmg, f2_id; safe_trace = false)

    set_next!(pmg, [thp, hp], [hn, thn])

    set_face!(pmg, hes_f, f1_id; both = true)

    delete!(pmg.f2he, f2_id)

    destroy_edge!(pmg, h)
    return hp
end


"""
    split_vertex!(g::PlanarMultigraph{T}, he1::T, he2::T) where {T<:Integer}

Split a vertex into 2 vertices.

Connect the two vertices with a new pair of half edges.
he1 and he2 are half edges that marks the start and end
of half edges that remain on v1.

After splitting, h points to the newly added vertex

## Reference
- [CGAL](https://doc.cgal.org/latest/Polyhedron/classCGAL_1_1Polyhedron__3.html#a2b17d7bd2045397167b00616f3b4d622)
"""
function split_vertex!(pmg::PlanarMultigraph{T}, h::T, g::T) where {T<:Integer}

    # Preconditions
    dst(pmg, h) == dst(pmg, g) || error("h and g don't have the same destination")
    h == g && error("h and g can't be the same half edge")

    # Get combinatorial info before modifying graph
    gn = next(pmg, g)
    hn = next(pmg, h)

    tg = twin(pmg, g)
    th = twin(pmg, h)

    he_vec = trace_orbit(he -> σ_inv(pmg, he), th; rev = false)
    he_vec = circshift(he_vec, -findfirst(he -> he == th, he_vec))

    hf = face(pmg, h)
    gf = face(pmg, g)

    v1 = dst(pmg, h)

    # add new vertex into g
    v2 = create_vertex!(pmg)[1]

    # add new half edges from v2 to v1
    hes_id, _ = create_edge!(pmg, v2, v1)


    for he in he_vec
        set_dst!(pmg, he, v2)
        (he == tg) && break
    end

    set_next!(pmg, [g, h, hes_id...], [hes_id..., gn, hn])
    set_face!(pmg, hes_id[1], gf; both = true)
    set_face!(pmg, hes_id[2], hf; both = true)

    return hes_id[1]
end


"""
    split_edge!(pmg::PlanarMultigraph{T}, h::T) where {T<:Integer}

Split an edge into two consecutive ones.
1->2->3 becomes 1->4->2->3
"""
function split_edge!(pmg::PlanarMultigraph{T}, h::T) where {T<:Integer}
    nhe = split_vertex!(pmg, twin(pmg, h), prev(pmg, h))
    return twin(pmg, nhe)
end

"""
    add_facet_to_boarder!(pmg::PlanarMultigraph{T}, h::T, g::T) where {T<:Integer}

Creates a facet with edge connecting the destination of h and g.

h and g needs to be in ccw order
## Reference
- [CGAL](https://doc.cgal.org/latest/Polyhedron/classCGAL_1_1Polyhedron__3.html#a73119c0c90bf8612da003305af25a52a)
"""
function add_facet_to_boarder!(pmg::PlanarMultigraph{T}, h::T, g::T) where {T<:Integer}
    # preconditions
    is_boundary(pmg, h) && is_boundary(pmg, g) || error("Can't add facet on top of facet")
    h != g || error("Can't add a loop as a facet!")
    next(pmg, h) != g || error("Can't add a multiedge as a facet!")
    hes_f = trace_face(pmg, face(pmg, h); safe_trace = false)
    hes_f = circshift(hes_f, -findfirst(he -> he == h, hes_f))
    g ∉ hes_f && error("Can't add edge across facet")

    # grab combinatorial info
    v1 = dst(pmg, h)
    v2 = dst(pmg, g)
    gn = next(pmg, g)
    hn = next(pmg, h)

    # start modifying old graph
    h_news, _ = create_edge!(pmg, v1, v2)
    new_f = create_face!(pmg)
    for he in hes_f
        set_face!(pmg, he, new_f; both = false)
        (he == g) && break
    end
    set_face!(pmg, h_news[1], 0; both = true)
    set_face!(pmg, h_news[2], new_f; both = true)
    set_next!(pmg, [h, g, h_news...], [h_news..., gn, hn])
    return h_news[2]

end


"""
    add_vertex_and_facet_to_boarder!(
    pmg::PlanarMultigraph{T},
    h::T,
    g::T,
) where {T<:Integer}

TBW

## Reference
- [CGAl](https://doc.cgal.org/latest/Polyhedron/classCGAL_1_1Polyhedron__3.html#a684bc8315f9e97d59e10bf896f0a166c)

"""
function add_vertex_and_facet_to_boarder!(
    pmg::PlanarMultigraph{T},
    h::T,
    g::T,
) where {T<:Integer}
    # preconditions
    is_boundary(pmg, h) && is_boundary(pmg, g) || error("Can't add facet on top of facet")
    h != g || error("Can't add a loop as a facet!")
    hes_f = trace_face(pmg, face(pmg, h); safe_trace = false)
    hes_f = circshift(hes_f, -findfirst(he -> he == h, hes_f))
    g ∉ hes_f && error("Can't add edge across facet")

    # get combinatorial info
    hv = dst(pmg, h)
    gv = dst(pmg, g)
    hn = next(pmg, h)
    gn = next(pmg, g)


    # modify old graph
    new_v = create_vertex!(pmg)[1]

    hes_hv2newv, _ = create_edge!(pmg, hv, new_v)
    hes_gv2newv, _ = create_edge!(pmg, gv, new_v)
    set_next!(
        pmg,
        [h, hes_hv2newv..., hes_gv2newv..., g],
        [hes_hv2newv[1], hes_gv2newv[2], hn, hes_hv2newv[2], gn, hes_gv2newv[1]],
    )
    new_f = create_face!(pmg)
    for he in hes_f
        set_face!(pmg, he, new_f; both = false)
        (he == g) && break
    end
    set_face!(pmg, [hes_hv2newv[2], hes_gv2newv[1]], new_f; both = true)
    return hes_gv2newv[1]
end

"""
    erase_facet!(pmg::PlanarMultigraph{T}, h::T)

Erase the facet incident on h.

## Reference
- [CGAL Library](https://doc.cgal.org/latest/Polyhedron/classCGAL_1_1Polyhedron__3.html#ac67041483c1e7c67c8dfd87716feebea)
"""
function erase_facet!(pmg::PlanarMultigraph{T}, h::T) where {T<:Integer}
    # precondition
    is_boundary(pmg, h) && error("There's no facet incident to boundary halfedge")

    # grab combinatorial info
    hes_f = trace_face(pmg, face(pmg, h); safe_trace = false)
    hes_ft = [twin(pmg, he) for he in hes_f]
    touched_vtx = [dst(pmg, he) for he in hes_f]

    is_bry = [is_boundary(pmg, he) for he in hes_ft]

    # modify old graph
    set_face!(pmg, hes_f, 0; both = false)
    delete!(pmg.f2he, face(pmg, h))
    for idx = 1:length(hes_ft)
        if is_bry[idx]
            he_f_prev = prev(pmg, hes_f[idx])
            he_ft_prev = prev(pmg, hes_ft[idx])
            he_ft_next = next(pmg, hes_ft[idx])
            he_f_next = next(pmg, hes_f[idx])
            destroy_edge!(pmg, hes_ft[idx])
            set_next!(pmg, [he_f_prev, he_ft_prev], [he_ft_next, he_f_next])
        end
    end

    gc_vertex!(pmg, touched_vtx)

    return h
end

"""
    join_vertex!(pmg::PlanarMultigraph{T}, h::T) where {T<:Integer}

Join two vertices connected by a HalfEdge into one.

Provides the removal of an edge.
"""
function join_vertex!(pmg::PlanarMultigraph{T}, h::T) where {T<:Integer}
    # start obtaining original graph information
    # has to be this order other wise setting updating v2he later breaks
    hes_del = trace_orbit(he -> σ_inv(pmg, he), h; rev = false)
    hes_kp = trace_orbit(he -> σ_inv(pmg, he), twin(pmg, h); rev = false)
    he_face = face(pmg, h)
    twin_he_face = face(pmg, twin(pmg, h))

    hprev = prev(pmg, h)
    hnext = next(pmg, h)
    twin_h_prev = prev(pmg, twin(pmg, h))
    twin_h_next = next(pmg, twin(pmg, h))

    length(trace_face(pmg, face(pmg, h); safe_trace = false)) < 4 &&
        length(trace_face(pmg, face(pmg, twin(pmg, h)); safe_trace = false)) < 4 &&
        error("Facets incident to halfedge needs to have size at least 4")

    # start modifying
    pmg.v2he[dst(pmg, h)] = hes_kp[2]
    delete!(pmg.v2he, src(pmg, h))

    vkp = dst(pmg, h)
    vdel = src(pmg, h)
    for he in hes_del[2:end]
        twin_he = twin(pmg, he)
        pmg.half_edges[he] = HalfEdge(vkp, dst(pmg, he))
        pmg.half_edges[twin_he] = HalfEdge(src(pmg, twin_he), vkp)
    end

    # add test here
    set_face!(pmg, next(pmg, h), he_face; both = true)
    set_face!(pmg, next(pmg, twin(pmg, h)), twin_he_face; both = true)
    destroy_edge!(pmg, h)

    set_next!(pmg, [hprev, twin_h_prev], [hnext, twin_h_next])
    destroy_vertex!(pmg, vdel)

    return twin(pmg, hes_kp[end])
end

function set_opposite!(g::PlanarMultigraph{T}, he1::T, he2::T) where {T<:Integer}
    he1 == he2 && error("Can't set opposite to itself")

    !(he1 ∈ half_edges(g)) && error("he1 not in g")
    !(he2 ∈ half_edges(g)) && error("he2 not in g")

    g.twin[he1] = he2
    g.twin[he2] = he1
    return g
end

function set_next!(
    g::PlanarMultigraph{T},
    hss::Vector{T},
    hds::Vector{T},
) where {T<:Integer}
    for (hs, hd) in zip(hss, hds)
        if (hs ∈ keys(g.half_edges) && hd ∈ keys(g.half_edges))
            g.next[hs] = hd
        end
    end
    return g
end

function set_dst!(pmg::PlanarMultigraph{T}, h::T, v::T) where {T<:Integer}
    twin_h = twin(pmg, h)
    pmg.half_edges[h] = HalfEdge(src(pmg, h), v)
    pmg.half_edges[twin_h] = HalfEdge(v, dst(pmg, twin_h))
    return pmg
end

function set_face!(
    pmg::PlanarMultigraph{T},
    hes::Vector{T},
    f::T;
    both::Bool = false,
) where {T<:Integer}
    for he in hes
        pmg.he2f[he] = f
    end
    if both
        pmg.f2he[f] = hes[end]
    end
    return pmg
end

function set_face!(
    pmg::PlanarMultigraph{T},
    he::T,
    f::T;
    both::Bool = false,
) where {T<:Integer}
    return set_face!(pmg, [he], f; both = both)
end

"""
    gc_vertex!(pmg::PlanarMultigraph{T}, vs::Vector{T}) where {T<:Integer}

Garbage collect vertices that's no longer connected to any edge.
"""
function gc_vertex!(pmg::PlanarMultigraph{T}, vs::Vector{T}) where {T<:Integer}
    to_rm = [true for _ in vs]
    for key in keys(pmg.half_edges)
        he_dst = dst(pmg, key)
        dst_idx = findfirst(v -> v == he_dst, vs)
        isnothing(dst_idx) && continue
        to_rm[dst_idx] = false
    end
    for ii = 1:length(to_rm)
        if to_rm[ii]
            delete!(pmg.v2he, vs[ii])
        end
    end
    return to_rm
end

function add_multiedge!(pmg::PlanarMultigraph{T}, h::T, multi::Int) where {T<:Integer}
    # grab combinatorial information
    hp = prev(pmg, h)
    hn = next(pmg, h)
    f_id = face(pmg, h)


    # modify old graph
    hes_id, _ = create_edge!(pmg, src(pmg, h), dst(pmg, h))
    set_next!(pmg, [h, hes_id[2]], [hes_id[2], h])
    new_f_id = create_face!(pmg)
    set_face!(pmg, [h, hes_id[2]], new_f_id; both = true)
    for _ = 2:multi
        next_hes_id, _ = create_edge!(pmg, src(pmg, h), dst(pmg, h))
        set_next!(pmg, [hes_id[1], next_hes_id[2]], [next_hes_id[2], hes_id[1]])
        new_f_id = create_face!(pmg)
        set_face!(pmg, [next_hes_id[2], hes_id[1]], new_f_id; both = true)
        hes_id = next_hes_id
    end
    set_next!(pmg, [hp, hes_id[1]], [hes_id[1], hn])
    set_face!(pmg, [hes_id[1]], f_id; both = true)
    return h
end
