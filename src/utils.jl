
"""
    round_phases!(zxwd)

Round phases between [0, 2π).
"""
function round_phases!(zxwd::ZXWDiagram{T,P}) where {T<:Integer,P}
    ps = zxwd.ps
    for v in keys(ps)
        ps[v] = _round_phase(ps[v])
    end
    return
end

function _round_phase(ps::P) where {P}
    return rem(rem(ps, 2) + 2, 2)
end

"""
    spider_type(zxwd, v)

Returns the spider type of a spider if it exists.
"""
function spider_type(zxwd::ZXWDiagram{T,P}, v::T) where {T<:Integer,P}
    if has_vertex(zxwd.mg, v)
        return zxwd.st[v]
    else
        error("Spider $v does not exist!")
    end
end

"""
    phase(zxwd, v)

Returns the phase of a spider. If the spider is not a Z or X spider, then return 0.
"""
function phase(zxwd::ZXWDiagram{T,P}, v::T) where {T<:Integer,P}
    if spider_type(zxwd, v) ∈ (ZXWSpiderType.Z, ZXWSpiderType.X)
        return zxwd.ps[v]
    else
        return zero(P)
    end
end

"""
    set_phase!(zxwd, v, p)

Set the phase of `v` in `zxwd` to `p`. If `v` is not a Z or X spider, then do nothing.
If `v` is not in `zxwd`, then return false to indicate failure.
"""
function set_phase!(zxwd::ZXWDiagram{T,P}, v::T, p::P) where {T,P}

    if has_vertex(zxwd.mg, v)
        if spider_type(zxwd, v) ∉ (ZXWSpiderType.Z, ZXWSpiderType.X)
            p = zero(P)
        end
        p = rem(rem(p, 2) + 2, 2)
        zxwd.ps[v] = p
        return true
    end
    return false
end

"""
    nqubits(zxwd)

Returns the qubit number of a ZXW-diagram.
"""
nqubits(zxwd::ZXWDiagram{T,P}) where {T,P} = length(zxwd.inputs)

"""
    print_spider(io, zxwd, v)

Print a spider to `io`.
"""
function print_spider(io::IO, zxwd::ZXWDiagram{T,P}, v::T) where {T<:Integer,P}
    st_v = spider_type(zxwd, v)
    if st_v == ZXWSpiderType.Z
        printstyled(
            io,
            "S_$(v){phase = $(zxwd.ps[v])" * (zxwd.ps[v] isa Phase ? "}" : "⋅π}");
            color = :green,
        )
    elseif st_v == ZXWSpiderType.X
        printstyled(
            io,
            "S_$(v){phase = $(zxwd.ps[v])" * (zxwd.ps[v] isa Phase ? "}" : "⋅π}");
            color = :red,
        )
    elseif st_v == ZXWSpiderType.H
        printstyled(io, "S_$(v){H}"; color = :yellow)
    elseif st_v == ZXWSpiderType.W
        printstyled(io, "S_$(v){W}"; color = :black)
    elseif st_v == ZXWSpiderType.D
        printstyled(io, "S_$(v){D}"; color = :yellow)
    elseif st_v == ZXWSpiderType.In
        print(io, "S_$(v){input}")
    elseif st_v == ZXWSpiderType.Out
        print(io, "S_$(v){output}")
    end
end


function Base.show(io::IO, zxwd::ZXWDiagram{T,P}) where {T<:Integer,P}
    println(
        io,
        "$(typeof(zxwd)) with $(nv(zxwd.mg)) vertices and $(ne(zxwd.mg)) multiple edges:",
    )
    for v1 in sort!(vertices(zxwd.mg))
        for v2 in neighbors(zxwd.mg, v1)
            if v2 >= v1
                print(io, "(")
                print_spider(io, zxwd, v1)
                print(io, " <-$(mul(zxwd.mg, v1, v2))-> ")
                print_spider(io, zxwd, v2)
                print(io, ")\n")
            end
        end
    end
end


"""
    nv(zxwd)

Returns the number of vertices (spiders) of a ZXW-diagram.
"""
Graphs.nv(zxwd::ZXWDiagram) = nv(zxwd.mg)

"""
    ne(zxwd; count_mul = false)

Returns the number of edges of a ZXW-diagram. If `count_mul`, it will return the
sum of multiplicities of all multiple edges. Otherwise, it will return the
number of multiple edges.
"""
Graphs.ne(zxwd::ZXWDiagram; count_mul::Bool = false) = ne(zxwd.mg, count_mul = count_mul)

Graphs.outneighbors(zxwd::ZXWDiagram, v; count_mul::Bool = false) =
    outneighbors(zxwd.mg, v, count_mul = count_mul)
Graphs.inneighbors(zxwd::ZXWDiagram, v; count_mul::Bool = false) =
    inneighbors(zxwd.mg, v, count_mul = count_mul)
Graphs.degree(zxwd::ZXWDiagram, v::Integer) = degree(zxwd.mg, v)
Graphs.indegree(zxwd::ZXWDiagram, v::Integer) = degree(zxwd, v)
Graphs.outdegree(zxwd::ZXWDiagram, v::Integer) = degree(zxwd, v)

"""
    neighbors(zxwd, v; count_mul = false)

Returns a vector of vertices connected to `v`. If `count_mul`, there will be
multiple copy for each vertex. Otherwise, each vertex will only appear once.
"""
Graphs.neighbors(zxwd::ZXWDiagram, v; count_mul::Bool = false) =
    neighbors(zxwd.mg, v, count_mul = count_mul)
function Graphs.rem_edge!(zxwd::ZXWDiagram, x...)
    rem_edge!(zxwd.mg, x...)
end
function Graphs.add_edge!(zxwd::ZXWDiagram, x...)
    add_edge!(zxwd.mg, x...)
end

"""
    rem_spiders!(zxwd, vs)

Remove spiders indexed by `vs`.
"""
function rem_spiders!(zxwd::ZXWDiagram{T,P}, vs::Vector{T}) where {T<:Integer,P}
    if rem_vertices!(zxwd.mg, vs)
        for v in vs
            delete!(zxwd.ps, v)
            delete!(zxwd.st, v)
        end
        return true
    end
    return false
end

"""
    rem_spider!(zxwd, v)

Remove a spider indexed by `v`.
"""
rem_spider!(zxwd::ZXWDiagram{T,P}, v::T) where {T<:Integer,P} = rem_spiders!(zxwd, [v])

"""
    add_spider!(zxwd, spider_type, phase = 0, connect = [])

Add a new spider which is of the type `spider_type` with phase `phase` and
connected to the vertices `connect`.
"""
function add_spider!(
    zxwd::ZXWDiagram{T,P},
    st::ZXWSpiderType.SType,
    phase::P = zero(P),
    connect::Vector{T} = T[],
) where {T<:Integer,P}
    if any(!has_vertex(zxwd.mg, c) for c in connect)
        error("The vertex to connect does not exist.")
    end

    v = add_vertex!(zxwd.mg)[1]
    zxwd.st[v] = st # have to update before set_phase!
    set_phase!(zxwd, v, phase)

    for c in connect
        add_edge!(zxwd.mg, v, c)
    end

    return v
end

"""
    insert_spider!(zxwd, v1, v2, spider_type, phase = 0)

Insert a spider of the type `spider_type` with phase = `phase`, between two
vertices `v1` and `v2`. It will insert multiple times if the edge between
`v1` and `v2` is a multiple edge. Also it will remove the original edge between
`v1` and `v2`.
"""
function insert_spider!(
    zxwd::ZXWDiagram{T,P},
    v1::T,
    v2::T,
    st::ZXWSpiderType.SType,
    phase::P = zero(P),
) where {T<:Integer,P}
    mt = mul(zxwd.mg, v1, v2)
    vs = Vector{T}(undef, mt)
    for i = 1:mt
        v = add_spider!(zxwd, st, phase, [v1, v2])
        @inbounds vs[i] = v
        rem_edge!(zxwd, v1, v2)
    end
    return vs
end

spiders(zxwd::ZXWDiagram) = vertices(zxwd.mg)

"""
    push_gate!(zxwd, ::Val{M}, locs...[, phase]; autoconvert=true)

Push an `M` gate to the end of qubit `loc` where `M` can be `:Z`, `:X`, `:H`, `:SWAP`, `:CNOT` and `:CZ`.
If `M` is `:Z` or `:X`, `phase` will be available and it will push a
rotation `M` gate with angle `phase * π`.
If `autoconvert` is `false`, the input `phase` should be a rational numbers.
"""
function push_gate!(
    zxwd::ZXWDiagram{T,P},
    ::Val{:Z},
    loc::T,
    phase = zero(P);
    autoconvert::Bool = true,
) where {T,P}
    @inbounds out_id = get_outputs(zxwd)[loc]
    @inbounds bound_id = neighbors(zxwd, out_id)[1]
    rphase = autoconvert ? safe_convert(P, phase) : phase
    insert_spider!(zxwd, bound_id, out_id, ZXWSpiderType.Z, rphase)
    return zxwd
end

function push_gate!(
    zxwd::ZXWDiagram{T,P},
    ::Val{:X},
    loc::T,
    phase = zero(P);
    autoconvert::Bool = true,
) where {T,P}
    @inbounds out_id = get_outputs(zxwd)[loc]
    @inbounds bound_id = neighbors(zxwd, out_id)[1]
    rphase = autoconvert ? safe_convert(P, phase) : phase
    insert_spider!(zxwd, bound_id, out_id, ZXWSpiderType.X, rphase)
    return zxwd
end

function push_gate!(zxwd::ZXWDiagram{T,P}, ::Val{:H}, loc::T) where {T,P}
    @inbounds out_id = get_outputs(zxwd)[loc]
    @inbounds bound_id = neighbors(zxwd, out_id)[1]
    insert_spider!(zxwd, bound_id, out_id, ZXWSpiderType.H)
    return zxwd
end

function push_gate!(zxwd::ZXWDiagram{T,P}, ::Val{:SWAP}, locs::Vector{T}) where {T,P}
    q1, q2 = locs
    push_gate!(zxwd, Val{:Z}(), q1)
    push_gate!(zxwd, Val{:Z}(), q2)
    push_gate!(zxwd, Val{:Z}(), q1)
    push_gate!(zxwd, Val{:Z}(), q2)
    v1, v2, bound_id1, bound_id2 = (sort!(spiders(zxwd)))[end-3:end]
    rem_edge!(zxwd, v1, bound_id1)
    rem_edge!(zxwd, v2, bound_id2)
    add_edge!(zxwd, v1, bound_id2)
    add_edge!(zxwd, v2, bound_id1)
    return zxwd
end

function push_gate!(zxwd::ZXWDiagram{T,P}, ::Val{:CNOT}, loc::T, ctrl::T) where {T,P}
    push_gate!(zxwd, Val{:Z}(), ctrl)
    push_gate!(zxwd, Val{:X}(), loc)
    @inbounds v1, v2 = (sort!(spiders(zxwd)))[end-1:end]
    add_edge!(zxwd, v1, v2)
    add_power!(zxwd, 1)
    return zxwd
end

function push_gate!(zxwd::ZXWDiagram{T,P}, ::Val{:CZ}, loc::T, ctrl::T) where {T,P}
    push_gate!(zxwd, Val{:Z}(), ctrl)
    push_gate!(zxwd, Val{:Z}(), loc)
    @inbounds v1, v2 = (sort!(spiders(zxwd)))[end-1:end]
    add_edge!(zxwd, v1, v2)
    insert_spider!(zxwd, v1, v2, ZXWSpiderType.H)
    add_power!(zxwd, 1)
    return zxwd
end

"""
    pushfirst_gate!(zxwd, ::Val{M}, loc[, phase])

Push an `M` gate to the beginning of qubit `loc` where `M` can be `:Z`, `:X`, `:H`, `:SWAP`, `:CNOT` and `:CZ`.
If `M` is `:Z` or `:X`, `phase` will be available and it will push a
rotation `M` gate with angle `phase * π`.
"""
function pushfirst_gate!(
    zxwd::ZXWDiagram{T,P},
    ::Val{:Z},
    loc::T,
    phase::P = zero(P),
) where {T,P}
    @inbounds in_id = get_inputs(zxwd)[loc]
    @inbounds bound_id = neighbors(zxwd, in_id)[1]
    insert_spider!(zxwd, in_id, bound_id, ZXWSpiderType.Z, phase)
    return zxwd
end

function pushfirst_gate!(
    zxwd::ZXWDiagram{T,P},
    ::Val{:X},
    loc::T,
    phase::P = zero(P),
) where {T,P}
    @inbounds in_id = get_inputs(zxwd)[loc]
    @inbounds bound_id = neighbors(zxwd, in_id)[1]
    insert_spider!(zxwd, in_id, bound_id, ZXWSpiderType.X, phase)
    return zxwd
end

function pushfirst_gate!(zxwd::ZXWDiagram{T,P}, ::Val{:H}, loc::T) where {T,P}
    @inbounds in_id = get_inputs(zxwd)[loc]
    @inbounds bound_id = neighbors(zxwd, in_id)[1]
    insert_spider!(zxwd, in_id, bound_id, ZXWSpiderType.H)
    return zxwd
end

function pushfirst_gate!(zxwd::ZXWDiagram{T,P}, ::Val{:SWAP}, locs::Vector{T}) where {T,P}
    q1, q2 = locs
    pushfirst_gate!(zxwd, Val{:Z}(), q1)
    pushfirst_gate!(zxwd, Val{:Z}(), q2)
    pushfirst_gate!(zxwd, Val{:Z}(), q1)
    pushfirst_gate!(zxwd, Val{:Z}(), q2)
    @inbounds v1, v2, bound_id1, bound_id2 = (sort!(spiders(zxwd)))[end-3:end]
    rem_edge!(zxwd, v1, bound_id1)
    rem_edge!(zxwd, v2, bound_id2)
    add_edge!(zxwd, v1, bound_id2)
    add_edge!(zxwd, v2, bound_id1)
    return zxwd
end

function pushfirst_gate!(zxwd::ZXWDiagram{T,P}, ::Val{:CNOT}, loc::T, ctrl::T) where {T,P}
    pushfirst_gate!(zxwd, Val{:Z}(), ctrl)
    pushfirst_gate!(zxwd, Val{:X}(), loc)
    @inbounds v1, v2 = (sort!(spiders(zxwd)))[end-1:end]
    add_edge!(zxwd, v1, v2)
    add_power!(zxwd, 1)
    return zxwd
end

function pushfirst_gate!(zxwd::ZXWDiagram{T,P}, ::Val{:CZ}, loc::T, ctrl::T) where {T,P}
    pushfirst_gate!(zxwd, Val{:Z}(), ctrl)
    pushfirst_gate!(zxwd, Val{:Z}(), loc)
    @inbounds v1, v2 = (sort!(spiders(zxwd)))[end-1:end]
    add_edge!(zxwd, v1, v2)
    insert_spider!(zxwd, v1, v2, ZXWSpiderType.H)
    add_power!(zxwd, 1)
    return zxwd
end
