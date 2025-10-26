# Calculus Interface Implementation for ZXDiagram

"""
    spider_type(zxd, v)

Returns the spider type of a spider.
"""
spider_type(zxd::ZXDiagram{T, P}, v::T) where {T <: Integer, P} = zxd.st[v]
spider_types(zxd::ZXDiagram) = zxd.st

"""
    phase(zxd, v)

Returns the phase of a spider. If the spider is not a Z or X spider, then return 0.
"""
phase(zxd::ZXDiagram{T, P}, v::T) where {T <: Integer, P} = zxd.ps[v]
phases(zxd::ZXDiagram{T, P}) where {T <: Integer, P} = zxd.ps

"""
    set_phase!(zxd, v, p)

Set the phase of `v` in `zxd` to `p`.
"""
function set_phase!(zxd::ZXDiagram{T, P}, v::T, p::P) where {T, P}
    if has_vertex(zxd.mg, v)
        while p < 0
            p += 2
        end
        zxd.ps[v] = round_phase(p)
        return true
    end
    return false
end

spiders(zxd::ZXDiagram) = vertices(zxd.mg)

"""
    rem_spiders!(zxd, vs)

Remove spiders indexed by `vs`.
"""
function rem_spiders!(zxd::ZXDiagram{T, P}, vs::Vector{T}) where {T <: Integer, P}
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
rem_spider!(zxd::ZXDiagram{T, P}, v::T) where {T <: Integer, P} = rem_spiders!(zxd, [v])

"""
    add_spider!(zxd, spider_type, phase = 0, connect = [])

Add a new spider which is of the type `spider_type` with phase `phase` and
connected to the vertices `connect`.
"""
function add_spider!(zxd::ZXDiagram{T, P}, st::SpiderType.SType, phase::P=zero(P), connect::Vector{T}=T[]) where {
        T <: Integer, P}
    v = add_vertex!(zxd.mg)[1]
    set_phase!(zxd, v, phase)
    zxd.st[v] = st
    if st in (SpiderType.Z, SpiderType.X)
        zxd.phase_ids[v] = (v, 1)
    end
    if all(has_vertex(zxd.mg, c) for c in connect)
        for c in connect
            add_edge!(zxd.mg, v, c)
        end
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
        zxd::ZXDiagram{T, P}, v1::T, v2::T, st::SpiderType.SType, phase::P=zero(P)) where {T <: Integer, P}
    mt = mul(zxd.mg, v1, v2)
    vs = Vector{T}(undef, mt)
    for i in 1:mt
        v = add_spider!(zxd, st, phase, [v1, v2])
        @inbounds vs[i] = v
        rem_edge!(zxd, v1, v2)
    end
    return vs
end

"""
    round_phases!(zxd)

Round phases between [0, 2π).
"""
function round_phases!(zxd::ZXDiagram{T, P}) where {T <: Integer, P}
    ps = zxd.ps
    for v in keys(ps)
        while ps[v] < 0
            ps[v] += 2
        end
        ps[v] = round_phase(ps[v])
    end
    return
end

"""
    tcount(zxd)

Returns the T-count of a ZX-diagram.
"""
tcount(cir::ZXDiagram) = sum(!is_clifford_phase(phase(cir, v)) for v in spiders(cir))

"""
    scalar(zxd)

Returns the scalar of `zxd`.
"""
scalar(zxd::ZXDiagram) = zxd.scalar

function add_global_phase!(zxd::ZXDiagram{T, P}, p::P) where {T, P}
    add_phase!(zxd.scalar, p)
    return zxd
end

function add_power!(zxd::ZXDiagram, n)
    add_power!(zxd.scalar, n)
    return zxd
end
