const ZDiagram{T,P} = Union{ZXDiagram{T,P},ZXWDiagram{T,P}}
"""
    round_phases!(zxd)

Round phases between [0, 2π).
"""
function round_phases!(
    zx::Union{ZXDiagram{T,P},ZXGraph{T,P},ZXWDiagram{T,P}},
) where {T<:Integer,P}
    _round_phase_dict!(zx.ps)
    return
end

function _round_phase_dict!(ps::Dict{T,P}) where {T<:Integer,P}
    for v in keys(ps)
        ps[v] = rem(rem(ps[v], 2) + 2, 2)
    end
    return
end

"""
    spider_type(zxd, v)

Returns the spider type of a spider.
"""
spider_type(zxd::ZDiagram{T,P}, v::T) where {T<:Integer,P} = zxd.st[v]

"""
    phase(zxd, v)

Returns the phase of a spider. If the spider is not a Z or X spider, then return 0.
"""
function phase(zxd::ZDiagram{T,P}, v::T) where {T<:Integer,P}
    if spider_type(zxd, v) ∈ (SpiderType.Z, SpiderType.X)
        return zxd.ps[v]
    else
        return zero(P)
    end
end

"""
    set_phase!(zxd, v, p)

Set the phase of `v` in `zxd` to `p`. If `v` is not a Z or X spider, then do nothing.
"""
function set_phase!(zxd::ZDiagram{T,P}, v::T, p::P) where {T,P}

    if has_vertex(zxd.mg, v)
        if spider_type(zxd, v) ∉ (SpiderType.Z, SpiderType.X)
            p = zero(P)
        end
        p = rem(rem(p, 2) + 2, 2)
        zxd.ps[v] = p
        return true
    end
    return false
end

"""
    nqubits(zxd)

Returns the qubit number of a ZX-diagram.
"""
nqubits(zxd::ZDiagram{T,P}) where {T,P} = zxd.layout.nbits

"""
    print_spider(io, zxd, v)

Print a spider to `io`.
"""
function print_spider(io::IO, zxd::ZDiagram{T,P}, v::T) where {T<:Integer,P}
    st_v = spider_type(zxd, v)
    if st_v == SpiderType.Z
        printstyled(
            io,
            "S_$(v){phase = $(zxd.ps[v])" * (zxd.ps[v] isa Phase ? "}" : "⋅π}");
            color = :green,
        )
    elseif st_v == SpiderType.X
        printstyled(
            io,
            "S_$(v){phase = $(zxd.ps[v])" * (zxd.ps[v] isa Phase ? "}" : "⋅π}");
            color = :red,
        )
    elseif st_v == SpiderType.H
        printstyled(io, "S_$(v){H}"; color = :yellow)
    elseif st_v == SpiderType.W
        printstyled(io, "S_$(v){W}"; color = :black)
    elseif st_v == SpiderType.D
        printstyled(io, "S_$(v){D}"; color = :yellow)
    elseif st_v == SpiderType.In
        print(io, "S_$(v){input}")
    elseif st_v == SpiderType.Out
        print(io, "S_$(v){output}")
    end
end


function Base.show(io::IO, zxd::ZDiagram{T,P}) where {T<:Integer,P}
    println(
        io,
        "$(typeof(zxd)) with $(nv(zxd.mg)) vertices and $(ne(zxd.mg)) multiple edges:",
    )
    for v1 in sort!(vertices(zxd.mg))
        for v2 in neighbors(zxd.mg, v1)
            if v2 >= v1
                print(io, "(")
                print_spider(io, zxd, v1)
                print(io, " <-$(mul(zxd.mg, v1, v2))-> ")
                print_spider(io, zxd, v2)
                print(io, ")\n")
            end
        end
    end
end


"""
    nv(zxd)

Returns the number of vertices (spiders) of a ZX(W)-diagram.
"""
Graphs.nv(zxd::ZDiagram) = nv(zxd.mg)

"""
    ne(zxd; count_mul = false)

Returns the number of edges of a ZX(W)-diagram. If `count_mul`, it will return the
sum of multiplicities of all multiple edges. Otherwise, it will return the
number of multiple edges.
"""
Graphs.ne(zxd::ZDiagram; count_mul::Bool = false) = ne(zxd.mg, count_mul = count_mul)

Graphs.outneighbors(zxd::ZDiagram, v; count_mul::Bool = false) =
    outneighbors(zxd.mg, v, count_mul = count_mul)
Graphs.inneighbors(zxd::ZDiagram, v; count_mul::Bool = false) =
    inneighbors(zxd.mg, v, count_mul = count_mul)
Graphs.degree(zxd::ZDiagram, v::Integer) = degree(zxd.mg, v)
Graphs.indegree(zxd::ZDiagram, v::Integer) = degree(zxd, v)
Graphs.outdegree(zxd::ZDiagram, v::Integer) = degree(zxd, v)

"""
    neighbors(zxd, v; count_mul = false)

Returns a vector of vertices connected to `v`. If `count_mul`, there will be
multiple copy for each vertex. Otherwise, each vertex will only appear once.
"""
Graphs.neighbors(zxd::ZDiagram, v; count_mul::Bool = false) =
    neighbors(zxd.mg, v, count_mul = count_mul)
function Graphs.rem_edge!(zxd::ZDiagram, x...)
    rem_edge!(zxd.mg, x...)
end
function Graphs.add_edge!(zxd::ZDiagram, x...)
    add_edge!(zxd.mg, x...)
end

"""
    rem_spiders!(zxd, vs)

Remove spiders indexed by `vs`.
"""
function rem_spiders!(zxd::ZDiagram{T,P}, vs::Vector{T}) where {T<:Integer,P}
    if rem_vertices!(zxd.mg, vs)
        for v in vs
            delete!(zxd.ps, v)
            delete!(zxd.st, v)
            rem_vertex!(zxd.layout, v)
        end
        return true
    end
    return false
end

"""
    rem_spider!(zxd, v)

Remove a spider indexed by `v`.
"""
rem_spider!(zxd::ZDiagram{T,P}, v::T) where {T<:Integer,P} = rem_spiders!(zxd, [v])

"""
    add_spider!(zxd, spider_type, phase = 0, connect = [])

Add a new spider which is of the type `spider_type` with phase `phase` and
connected to the vertices `connect`.
"""
function add_spider!(
    zxd::ZDiagram{T,P},
    st::SpiderType.SType,
    phase::P = zero(P),
    connect::Vector{T} = T[],
) where {T<:Integer,P}
    if any(!has_vertex(zxd.mg, c) for c in connect)
        error("The vertex to connect does not exist.")
    end

    v = add_vertex!(zxd.mg)[1]
    zxd.st[v] = st # has update before set_phase!
    set_phase!(zxd, v, phase)

    for c in connect
        add_edge!(zxd.mg, v, c)
    end

    return v
end

"""
    insert_spider!(zxd, v1, v2, spider_type, phase = 0)

Insert a spider of the type `spider_type` with phase = `phase`, between two
vertices `v1` and `v2`. It will insert multiple times if the edge between
`v1` and `v2` is a multiple edge. Also it will remove the original edge between
`v1` and `v2`.
"""
function insert_spider!(
    zxd::ZDiagram{T,P},
    v1::T,
    v2::T,
    st::SpiderType.SType,
    phase::P = zero(P),
) where {T<:Integer,P}
    mt = mul(zxd.mg, v1, v2)
    vs = Vector{T}(undef, mt)
    for i = 1:mt
        v = add_spider!(zxd, st, phase, [v1, v2])
        @inbounds vs[i] = v
        rem_edge!(zxd, v1, v2)
    end
    return vs
end

spiders(zxd::ZDiagram) = vertices(zxd.mg)
qubit_loc(zxd::ZDiagram{T,P}, v::T) where {T,P} = qubit_loc(zxd.layout, v)
function column_loc(zxd::ZDiagram{T,P}, v::T) where {T,P}
    c_loc = column_loc(zxd.layout, v)
    return c_loc
end
