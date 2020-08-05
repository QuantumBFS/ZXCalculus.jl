using LightGraphs
import Base: show, copy
import LightGraphs: nv, ne, outneighbors, inneighbors, neighbors, rem_edge!, add_edge!

export ZXDiagram, SpiderType, spiders, spider_type, phase
export push_gate!, push_ctrl_gate!, pushfirst_gate!, pushfirst_ctrl_gate!, tcount

module SpiderType
    @enum SType Z X H In Out
end  # module SpiderType

"""
    ZXDiagram{T, P}
This is the type for representing ZX-diagrams.
"""
struct ZXDiagram{T<:Integer, P} <: AbstractZXDiagram{T, P}
    mg::Multigraph{T}

    st::Dict{T, SpiderType.SType}
    ps::Dict{T, P}

    layout::ZXLayout{T}

    phase_ids::Dict{T, Tuple{T, Int}}

    function ZXDiagram{T, P}(mg::Multigraph{T}, st::Dict{T, SpiderType.SType}, ps::Dict{T, P},
        layout::ZXLayout{T}, phase_ids::Dict{T, Tuple{T, Int}} = Dict{T, Tuple{T, Int}}()) where {T<:Integer, P}
        if nv(mg) == length(ps) && nv(mg) == length(st)
            if length(phase_ids) == 0
                for v in vertices(mg)
                    if st[v] in [SpiderType.Z, SpiderType.X]
                        phase_ids[v] = (v, 1)
                    end
                end
            end
            zxd = new{T, P}(mg, st, ps, layout, phase_ids)
            rounding_phases!(zxd)
            return zxd
        else
            error("There should be a phase and a type for each spider!")
        end
    end
end

"""
    ZXDiagram(mg::Multigraph{T}, st::Dict{T, SpiderType.SType}, ps::Dict{T, P},
        layout::ZXLayout{T} = ZXLayout{T}(),
        phase_ids::Dict{T,Tuple{T, Int}} = Dict{T,Tuple{T,Int}}()) where {T, P}
    ZXDiagram(mg::Multigraph{T}, st::Vector{SpiderType.SType}, ps::Vector{P},
        layout::ZXLayout{T} = ZXLayout{T}()) where {T, P}

Construct a ZXDiagram with all information.

```jldoctest
julia> using LightGraphs, ZXCalculus;

julia> using ZXCalculus.SpiderType: In, Out, H, Z, X;

julia> mg = Multigraph(5);

julia> for i = 1:4
           add_edge!(mg, i, i+1)
       end;

julia> ZXDiagram(mg, [In, Z, H, X, Out], [0//1, 1, 0, 1//2, 0])
ZX-diagram with 5 vertices and 4 multiple edges:
(S_1{input} <-1-> S_2{phase = 1//1⋅π})
(S_2{phase = 1//1⋅π} <-1-> S_3{H})
(S_3{H} <-1-> S_4{phase = 1//2⋅π})
(S_4{phase = 1//2⋅π} <-1-> S_5{output})

```
"""
ZXDiagram(mg::Multigraph{T}, st::Dict{T, SpiderType.SType}, ps::Dict{T, P},
    layout::ZXLayout{T} = ZXLayout{T}(),
    phase_ids::Dict{T,Tuple{T, Int}} = Dict{T,Tuple{T,Int}}()) where {T, P} = ZXDiagram{T, P}(mg, st, ps, layout, phase_ids)
ZXDiagram(mg::Multigraph{T}, st::Vector{SpiderType.SType}, ps::Vector{P},
    layout::ZXLayout{T} = ZXLayout{T}()) where {T, P} =
    ZXDiagram(mg, Dict(zip(vertices(mg), st)), Dict(zip(vertices(mg), ps)), layout)

"""
    ZXDiagram(nbits)

Construct a ZXDiagram of a empty circuit with qubit number `nbit`

```jldoctest; setup = :(using ZXCalculus)
julia> zxd = ZXDiagram(3)
ZX-diagram with 6 vertices and 3 multiple edges:
(S_1{input} <-1-> S_2{output})
(S_3{input} <-1-> S_4{output})
(S_5{input} <-1-> S_6{output})

```
"""
function ZXDiagram(nbits::T) where {T<:Integer}
    mg = Multigraph(2*nbits)
    st = [SpiderType.In for _ = 1:2*nbits]
    ps = [0//1 for _ = 1:2*nbits]
    layout = ZXLayout(nbits, [[2*i-1, 2*i] for i = 1:nbits])
    for i = 1:nbits
        add_edge!(mg, 2*i-1, 2*i)
        st[2*i] = SpiderType.Out
    end
    return ZXDiagram(mg, st, ps, layout)
end

copy(zxd::ZXDiagram) = ZXDiagram(copy(zxd.mg), copy(zxd.st), copy(zxd.ps),
    copy(zxd.layout), deepcopy(zxd.phase_ids))

"""
    spider_type(zxd, v)

Returns the spider type of a spider.
"""
spider_type(zxd::ZXDiagram{T, P}, v::T) where {T<:Integer, P} = zxd.st[v]

"""
    phase(zxd, v)

Returns the phase of a spider. If the spider is not a Z or X spider, then return 0.
"""
phase(zxd::ZXDiagram{T, P}, v::T) where {T<:Integer, P} = zxd.ps[v]


"""
    set_phase!(zxd, v, p)

Set the phase of `v` in `zxd` to `p`.
"""
function set_phase!(zxd::ZXDiagram{T, P}, v::T, p::P) where {T, P}
    if v in spiders(zxd)
        zxd.ps[v] = p
    end
end

"""
    nqubits(zxd)

Returns the qubit number of a ZX-diagram.
"""
nqubits(zxd::ZXDiagram) = zxd.layout.nbits

function print_spider(io::IO, zxd::ZXDiagram{T, P}, v::T) where {T<:Integer, P}
    st_v = spider_type(zxd, v)
    if st_v == SpiderType.Z
        printstyled(io, "S_$(v){phase = $(zxd.ps[v])⋅π}"; color = :green)
    elseif st_v == SpiderType.X
        printstyled(io, "S_$(v){phase = $(zxd.ps[v])⋅π}"; color = :red)
    elseif st_v == SpiderType.H
        printstyled(io, "S_$(v){H}"; color = :yellow)
    elseif st_v == SpiderType.In
        print(io, "S_$(v){input}")
    elseif st_v == SpiderType.Out
        print(io, "S_$(v){output}")
    end
end

function show(io::IO, zxd::ZXDiagram{T, P}) where {T<:Integer, P}
    println(io, "ZX-diagram with $(nv(zxd.mg)) vertices and $(ne(zxd.mg)) multiple edges:")
    for v1 in vertices(zxd.mg)
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

Returns the number of vertices (spiders) of a ZX-diagram.
"""
nv(zxd::ZXDiagram) = nv(zxd.mg)

"""
    ne(zxd; count_mul = false)

Returns the number of edges of a ZX-diagram. If `count_mul`, it will return the
sum of multiplicities of all multiple edges. Otherwise, it will return the
number of multiple edges.
"""
ne(zxd::ZXDiagram; count_mul::Bool = false) = ne(zxd.mg, count_mul = count_mul)

outneighbors(zxd::ZXDiagram, v; count_mul::Bool = false) = outneighbors(zxd.mg, v, count_mul = count_mul)
inneighbors(zxd::ZXDiagram, v; count_mul::Bool = false) = inneighbors(zxd.mg, v, count_mul = count_mul)

"""
    neighbors(zxd, v; count_mul = false)

Returns a vector of vertices connected to `v`. If `count_mul`, there will be
multiple copy for each vertex. Otherwise, each vertex will only appear once.
"""
neighbors(zxd::ZXDiagram, v; count_mul::Bool = false) = neighbors(zxd.mg, v, count_mul = count_mul)
function rem_edge!(zxd::ZXDiagram, x...)
    rem_edge!(zxd.mg, x...)
end
function add_edge!(zxd::ZXDiagram, x...)
    add_edge!(zxd.mg, x...)
end

"""
    rem_spiders!(zxd, vs)

Remove spiders indexed by `vs`.
"""
function rem_spiders!(zxd::ZXDiagram{T, P}, vs::Vector{T}) where {T<:Integer, P}
    if rem_vertices!(zxd.mg, vs)
        for v in vs
            delete!(zxd.ps, v)
            delete!(zxd.st, v)
            delete!(zxd.phase_ids, v)
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
rem_spider!(zxd::ZXDiagram{T, P}, v::T) where {T<:Integer, P} = rem_spiders!(zxd, [v])

"""
    add_spider!(zxd, spider_type, phase = 0, connect = [])

Add a new spider which is of the type `spider_type` with phase `phase` and
connected to the vertices `connect`.
"""
function add_spider!(zxd::ZXDiagram{T, P}, st::SpiderType.SType, phase::P = zero(P), connect::Vector{T}=T[]) where {T<:Integer, P}
    add_vertex!(zxd.mg)
    v = vertices(zxd.mg)[end]
    zxd.ps[v] = phase
    zxd.st[v] = st
    if st in [SpiderType.Z, SpiderType.X]
        zxd.phase_ids[v] = (v, 1)
    end
    if connect ⊆ vertices(zxd.mg)
        for c in connect
            add_edge!(zxd.mg, v, c)
        end
    end
    return zxd
end

"""
    insert_spider!(zxd, v1, v2, spider_type, phase = 0)

Insert a spider of the type `spider_type` with phase = `phase`, between two
vertices `v1` and `v2`. It will insert multiple times if the edge between
`v1` and `v2` is a multiple edge. Also it will remove the original edge between
`v1` and `v2`.
"""
function insert_spider!(zxd::ZXDiagram{T, P}, v1::T, v2::T, st::SpiderType.SType, phase::P = zero(P)) where {T<:Integer, P}
    for i = 1:mul(zxd.mg, v1, v2)
        add_spider!(zxd, st, phase, [v1, v2])
        rem_edge!(zxd, v1, v2)
        l1 = qubit_loc(zxd.layout, v1)
        l2 = qubit_loc(zxd.layout, v2)
        if l1 == l2 && l1 != nothing
            t1 = findfirst(isequal(v1), zxd.layout.spider_seq[l1])
            t2 = findfirst(isequal(v2), zxd.layout.spider_seq[l1])
            t = min(t1, t2) + 1
            insert!(zxd.layout.spider_seq[l1], t, spiders(zxd)[end])
        end
    end
    return zxd
end

"""
    rounding_phases!(zxd)

Round phases between [0, 2π).
"""
function rounding_phases!(zxd::ZXDiagram{T, P}) where {T<:Integer, P}
    ps = zxd.ps
    for v in keys(ps)
        while ps[v] < 0
            ps[v] += 2
        end
        ps[v] = rem(ps[v], one(P)+one(P))
    end
end

spiders(zxd::ZXDiagram) = vertices(zxd.mg)
qubit_loc(zxd::ZXDiagram{T, P}, v::T) where {T, P} = qubit_loc(zxd.layout, v)

"""
    push_gate!(zxd, ::Val{M}, loc[, phase])

Push an `M` gate to the end of qubit `loc` where `M` can be `:Z`, `:X`
and `:H`. If `M` is `:Z` or `:X`, `phase` will be available and it will push a
rotation `M` gate with angle `phase * π`.
"""
function push_gate!(zxd::ZXDiagram{T, P}, ::Val{:Z}, loc::T, phase::P = zero(P)) where {T, P}
    bound_id = zxd.layout.spider_seq[loc][end-1]
    out_id = zxd.layout.spider_seq[loc][end]
    insert_spider!(zxd, bound_id, out_id, SpiderType.Z, phase)
    return zxd
end

function push_gate!(zxd::ZXDiagram{T, P}, ::Val{:X}, loc::T, phase::P = zero(P)) where {T, P}
    bound_id = zxd.layout.spider_seq[loc][end-1]
    out_id = zxd.layout.spider_seq[loc][end]
    insert_spider!(zxd, bound_id, out_id, SpiderType.X, phase)
    return zxd
end

function push_gate!(zxd::ZXDiagram{T, P}, ::Val{:H}, loc::T) where {T, P}
    bound_id = zxd.layout.spider_seq[loc][end-1]
    out_id = zxd.layout.spider_seq[loc][end]
    insert_spider!(zxd, bound_id, out_id, SpiderType.H)
    return zxd
end

function push_gate!(zxd::ZXDiagram{T, P}, ::Val{:SWAP}, locs::Vector{T}) where {T, P}
    q1, q2 = locs
    push_gate!(zxd, Val{:Z}(), q1)
    push_gate!(zxd, Val{:Z}(), q2)
    push_gate!(zxd, Val{:Z}(), q1)
    push_gate!(zxd, Val{:Z}(), q2)
    v1, v2, bound_id1, bound_id2 = spiders(zxd)[end-3:end]
    rem_edge!(zxd, v1, bound_id1)
    rem_edge!(zxd, v2, bound_id2)
    add_edge!(zxd, v1, bound_id2)
    add_edge!(zxd, v2, bound_id1)
    return zxd
end

"""
    push_ctrl_gate!(zxd, ::Val{M}, loc, ctrl)

Push a ctrl gate to the end of qubits `ctrl` and `loc` where `M` can be `:CNOT`
and `:CZ`
"""
function push_ctrl_gate!(zxd::ZXDiagram{T, P}, ::Val{:CNOT}, loc::T, ctrl::T) where {T, P}
    push_gate!(zxd, Val{:Z}(), ctrl)
    push_gate!(zxd, Val{:X}(), loc)
    v1, v2 = spiders(zxd)[end-1:end]
    add_edge!(zxd, v1, v2)
    return zxd
end

function push_ctrl_gate!(zxd::ZXDiagram{T, P}, ::Val{:CZ}, loc::T, ctrl::T) where {T, P}
    push_gate!(zxd, Val{:Z}(), ctrl)
    push_gate!(zxd, Val{:Z}(), loc)
    v1, v2 = spiders(zxd)[end-1:end]
    add_edge!(zxd, v1, v2)
    insert_spider!(zxd, v1, v2, SpiderType.H)
    return zxd
end

"""
    pushfirst_gate!(zxd, ::Val{M}, loc[, phase])

Push an `M` gate to the beginning of qubit `loc` where `M` can be `:Z`, `:X`
and `:H`. If `M` is `:Z` or `:X`, `phase` will be available and it will push a
rotation `M` gate with angle `phase * π`.
"""
function pushfirst_gate!(zxd::ZXDiagram{T, P}, ::Val{:Z}, loc::T, phase::P = zero(P)) where {T, P}
    in_id = zxd.layout.spider_seq[loc][1]
    bound_id = zxd.layout.spider_seq[loc][2]
    insert_spider!(zxd, in_id, bound_id, SpiderType.Z, phase)
    return zxd
end

function pushfirst_gate!(zxd::ZXDiagram{T, P}, ::Val{:X}, loc::T, phase::P = zero(P)) where {T, P}
    in_id = zxd.layout.spider_seq[loc][1]
    bound_id = zxd.layout.spider_seq[loc][2]
    insert_spider!(zxd, in_id, bound_id, SpiderType.X, phase)
    return zxd
end

function pushfirst_gate!(zxd::ZXDiagram{T, P}, ::Val{:H}, loc::T) where {T, P}
    in_id = zxd.layout.spider_seq[loc][1]
    bound_id = zxd.layout.spider_seq[loc][2]
    insert_spider!(zxd, in_id, bound_id, SpiderType.H)
    return zxd
end

function pushfirst_gate!(zxd::ZXDiagram{T, P}, ::Val{:SWAP}, locs::Vector{T}) where {T, P}
    q1, q2 = locs
    pushfirst_gate!(zxd, Val{:Z}(), q1)
    pushfirst_gate!(zxd, Val{:Z}(), q2)
    pushfirst_gate!(zxd, Val{:Z}(), q1)
    pushfirst_gate!(zxd, Val{:Z}(), q2)
    v1, v2, bound_id1, bound_id2 = spiders(zxd)[end-3:end]
    rem_edge!(zxd, v1, bound_id1)
    rem_edge!(zxd, v2, bound_id2)
    add_edge!(zxd, v1, bound_id2)
    add_edge!(zxd, v2, bound_id1)
    return zxd
end

"""
    push_ctrl_gate!(zxd, ::Val{M}, loc, ctrl)

Push a ctrl gate to the beginning of qubits `ctrl` and `loc` where `M` can be `:CNOT`
and `:CZ`
"""
function pushfirst_ctrl_gate!(zxd::ZXDiagram{T, P}, ::Val{:CNOT}, loc::T, ctrl::T) where {T, P}
    pushfirst_gate!(zxd, Val{:Z}(), ctrl)
    pushfirst_gate!(zxd, Val{:X}(), loc)
    v1, v2 = spiders(zxd)[end-1:end]
    add_edge!(zxd, v1, v2)
    return zxd
end

function pushfirst_ctrl_gate!(zxd::ZXDiagram{T, P}, ::Val{:CZ}, loc::T, ctrl::T) where {T, P}
    pushfirst_gate!(zxd, Val{:Z}(), ctrl)
    pushfirst_gate!(zxd, Val{:Z}(), loc)
    v1, v2 = spiders(zxd)[end-1:end]
    add_edge!(zxd, v1, v2)
    insert_spider!(zxd, v1, v2, SpiderType.H)
    return zxd
end

"""
    tcount(zxd)

Returns the T-count of a ZX-diagram.
"""
tcount(cir::AbstractZXDiagram) = sum([phase(cir, v) % 1//2 != 0 for v in spiders(cir)])
