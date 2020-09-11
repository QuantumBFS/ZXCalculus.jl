import Base: match, replace!

export Rule, Match
export rewrite!

abstract type AbstractRule end

"""
    Rule{L}

The struct for identifying different rules.

Rule for `ZXDiagram`s:
* `Rule{:f}()`: rule f
* `Rule{:h}()`: rule h
* `Rule{:i1}()`: rule i1
* `Rule{:i2}()`: rule i2
* `Rule{:pi}()`: rule π
* `Rule{:c}()`: rule c

Rule for `ZXGraph`s:
* `Rule{:lc}()`: local complementary rule
* `Rule{:p1}()`: pivoting rule
* `Rule{:pab}()`: rule for removing Paulis spiders adjancent to boundary spiders
* `Rule{:p2}()`: rule p2
* `Rule{:p3}()`: rule p3
* `Rule{:id}()`: rule id
* `Rule{:gf}()`: gadget fushion rule
"""
struct Rule{L} <: AbstractRule end

"""
    Match{T<:Integer}

A struct for saving matched vertices.
"""
struct Match{T<:Integer}
    vertices::Vector{T}
end

"""
    match(r, zxd)

Returns all matched vertices, which will be store in sturct `Match`, for rule `r`
in a ZX-diagram `zxd`.
"""
match(::AbstractRule, zxd::AbstractZXDiagram{T, P}) where {T, P} = Match{T}[]

function match(::Rule{:f}, zxd::ZXDiagram{T, P}) where {T, P}
    matches = Match{T}[]
    for v1 in spiders(zxd)
        if spider_type(zxd, v1) == SpiderType.Z || spider_type(zxd, v1) == SpiderType.X
            for v2 in neighbors(zxd, v1)
                if spider_type(zxd, v1) == spider_type(zxd, v2) && v2 >= v1
                    push!(matches, Match{T}([v1, v2]))
                end
            end
        end
    end
    return matches
end

function match(::Rule{:h}, zxd::ZXDiagram{T, P}) where {T, P}
    matches = Match{T}[]
    for v1 in spiders(zxd)
        if spider_type(zxd, v1) == SpiderType.X
            push!(matches, Match{T}([v1]))
        end
    end
    return matches
end

function match(::Rule{:i1}, zxd::ZXDiagram{T, P}) where {T, P}
    matches = Match{T}[]
    for v1 in spiders(zxd)
        if spider_type(zxd, v1) == SpiderType.Z || spider_type(zxd, v1) == SpiderType.X
            if phase(zxd, v1) == 0 && (degree(zxd, v1)) == 2
                push!(matches, Match{T}([v1]))
            end
        end
    end
    return matches
end

function match(::Rule{:i2}, zxd::ZXDiagram{T, P}) where {T, P}
    matches = Match{T}[]
    for v1 in spiders(zxd)
        if spider_type(zxd, v1) == SpiderType.H && (degree(zxd, v1)) == 2
            for v2 in neighbors(zxd, v1)
                if spider_type(zxd, v2) == SpiderType.H && (degree(zxd, v2)) == 2
                    v2 >= v1 && push!(matches, Match{T}([v1, v2]))
                end
            end
        end
    end
    return matches
end

function match(::Rule{:pi}, zxd::ZXDiagram{T, P}) where {T, P}
    matches = Match{T}[]
    for v1 in spiders(zxd)
        if spider_type(zxd, v1) == SpiderType.X && phase(zxd, v1) == one(P) && (degree(zxd, v1)) == 2
            for v2 in neighbors(zxd, v1)
                if spider_type(zxd, v2) == SpiderType.Z
                    push!(matches, Match{T}([v1, v2]))
                end
            end
        end
    end
    return matches
end

function match(::Rule{:c}, zxd::ZXDiagram{T, P}) where {T, P}
    matches = Match{T}[]
    for v1 in spiders(zxd)
        if spider_type(zxd, v1) == SpiderType.X && phase(zxd, v1) == zero(P) && (degree(zxd, v1)) == 1
            for v2 in neighbors(zxd, v1)
                if spider_type(zxd, v2) == SpiderType.Z
                    push!(matches, Match{T}([v1, v2]))
                end
            end
        end
    end
    return matches
end

function match(::Rule{:b}, zxd::ZXDiagram{T, P}) where {T, P}
    matches = Match{T}[]
    for v1 in spiders(zxd)
        if spider_type(zxd, v1) == SpiderType.X && phase(zxd, v1) == zero(P) && (degree(zxd, v1)) == 3
            for v2 in neighbors(zxd, v1)
                if spider_type(zxd, v2) == SpiderType.Z && phase(zxd, v2) == zero(P) && (degree(zxd, v2)) == 3 && mul(zxd.mg, v1, v2) == 1
                    push!(matches, Match{T}([v1, v2]))
                end
            end
        end
    end
    return matches
end

function match(::Rule{:lc}, zxg::ZXGraph{T, P}) where {T, P}
    matches = Match{T}[]
    vs = spiders(zxg)
    vB = [get_inputs(zxg); get_outputs(zxg)]
    for i = 1:length(vB)
        push!(vB, neighbors(zxg, vB[i])[1])
    end
    sort!(vB)
    for v in vs
        if spider_type(zxg, v) == SpiderType.Z && (phase(zxg, v) == 1//2 || phase(zxg, v) == 3//2)
            if length(searchsorted(vB, v)) == 0
                push!(matches, Match{T}([v]))
            end
        end
    end
    return matches
end

function match(::Rule{:p1}, zxg::ZXGraph{T, P}) where {T, P}
    matches = Match{T}[]
    vs = spiders(zxg)
    vB = [get_inputs(zxg); get_outputs(zxg)]
    for i = 1:length(vB)
        push!(vB, neighbors(zxg, vB[i])[1])
    end
    sort!(vB)
    for v1 in vs
        if spider_type(zxg, v1) == SpiderType.Z && length(searchsorted(vB, v1)) == 0 &&
            (phase(zxg, v1) == 0 || phase(zxg, v1) == 1)
            for v2 in neighbors(zxg, v1)
                if spider_type(zxg, v2) == SpiderType.Z && length(searchsorted(vB, v2)) == 0 &&
                    (phase(zxg, v2) == 0 || phase(zxg, v2) == 1) && v2 > v1
                    push!(matches, Match{T}([v1, v2]))
                end
            end
        end
    end
    return matches
end

function match(::Rule{:pab}, zxg::ZXGraph{T, P}) where {T, P}
    matches = Match{T}[]
    vs = spiders(zxg)
    vB = [get_inputs(zxg); get_outputs(zxg)]
    for i = 1:length(vB)
        push!(vB, neighbors(zxg, vB[i])[1])
    end
    sort!(vB)
    for v1 in vs
        if spider_type(zxg, v1) == SpiderType.Z && length(searchsorted(vB, v1)) == 0 &&
            (phase(zxg, v1) == 0 || phase(zxg, v1) == 1)
            for v2 in neighbors(zxg, v1)
                if spider_type(zxg, v2) == SpiderType.Z && length(searchsorted(vB, v2)) > 0
                    push!(matches, Match{T}([v1, v2]))
                end
            end
        end
    end
    return matches
end

function match(::Rule{:p2}, zxg::ZXGraph{T, P}) where {T, P}
    matches = Match{T}[]
    vs = spiders(zxg)
    vB = [get_inputs(zxg); get_outputs(zxg)]
    for i = 1:length(vB)
        push!(vB, neighbors(zxg, vB[i])[1])
    end
    sort!(vB)
    gadgets = T[]
    for v in vs
        if spider_type(zxg, v) == SpiderType.Z && length(neighbors(zxg, v)) == 1
            push!(gadgets, v, neighbors(zxg, v)[1])
        end
    end
    sort!(gadgets)

    for v1 in vs
        if spider_type(zxg, v1) == SpiderType.Z && length(searchsorted(vB, v1)) == 0 &&
            (degree(zxg, v1)) > 1 && (phase(zxg, v1) ∉ (0, 1)) &&
            length(neighbors(zxg, v1)) > 1
            # (qubit_loc(zxg.layout, v1) !== nothing || zxg.layout.nbits == 0)
            for v2 in neighbors(zxg, v1)
                if spider_type(zxg, v2) == SpiderType.Z &&
                    length(searchsorted(vB, v2)) == 0 &&
                    (phase(zxg, v2) == 0 || phase(zxg, v2) == 1)
                    # (qubit_loc(zxg.layout, v2) !== nothing || zxg.layout.nbits == 0)
                    if length(searchsorted(gadgets, v2)) == 0
                        push!(matches, Match{T}([v1, v2]))
                    end
                end
            end
        end
    end
    # println(matches)
    return matches
end

function match(::Rule{:p3}, zxg::ZXGraph{T, P}) where {T, P}
    matches = Match{T}[]
    vs = spiders(zxg)
    vB = [get_inputs(zxg); get_outputs(zxg)]
    for i = 1:length(vB)
        # if length(neighbors(zxg, vB[i])) == 1
        push!(vB, neighbors(zxg, vB[i])[1])
        # else
            # println(vB[i])
            # println(neighbors(zxg, vB[i]))
        # end
    end
    sort!(vB)

    for v1 in vB
        if spider_type(zxg, v1) == SpiderType.Z && length(searchsorted(vB, v1)) > 0 &&
            (phase(zxg, v1) ∉ (0, 1)) && length(neighbors(zxg, v1)) > 1
            # (qubit_loc(zxg.layout, v1) !== nothing || zxg.layout.nbits == 0)
            for v2 in neighbors(zxg, v1)
                if spider_type(zxg, v2) == SpiderType.Z && length(searchsorted(vB, v2)) == 0 &&
                    (phase(zxg, v2) == 0 || phase(zxg, v2) == 1)
                    # (qubit_loc(zxg.layout, v2) !== nothing || zxg.layout.nbits == 0)
                    push!(matches, Match{T}([v1, v2]))
                end
            end
        end
    end
    return matches
end

function match(::Rule{:id}, zxg::ZXGraph{T, P}) where {T, P}
    matches = Match{T}[]
    for v1 in spiders(zxg)
        nb1 = neighbors(zxg, v1)
        if spider_type(zxg, v1) == SpiderType.Z && length(nb1) == 1
            v2 = nb1[1]
            if phase(zxg, v2) in (zero(P), one(P))
                nb2 = neighbors(zxg, v2)
                if length(nb2) == 2
                    v3 = nb2[1]
                    if v3 == v1
                        v3 = nb2[2]
                    end
                    push!(matches, Match{T}([v1, v2, v3]))
                end
            end
        end
    end
    return matches
end

function match(::Rule{:gf}, zxg::ZXGraph{T, P}) where {T, P}
    matches = Match{T}[]
    vs = spiders(zxg)
    gad_ids = vs[[spider_type(zxg, v) == SpiderType.Z && (degree(zxg, v)) == 1 for v in vs]]
    gads = [(v, neighbors(zxg, v)[1], setdiff(neighbors(zxg, neighbors(zxg, v)[1]), [v])) for v in gad_ids]

    for i = 1:length(gads)
        v1, v2, gad_v = gads[i]
        for j in (i+1):length(gads)
            u1, u2, gad_u = gads[j]
            if gad_u == gad_v && phase(zxg, v2) in (zero(P), one(P)) && phase(zxg, u2) in (zero(P), one(P))
                push!(matches, Match{T}([v1, v2, u1, u2]))
            end
        end
    end
    return matches
end

"""
    rewrite!(r, zxd, matches)

Rewrite a ZX-diagram `zxd` with rule `r` for all vertices in `matches`. `matches`
can be a vector of `Match` or just an instance of `Match`.
"""
function rewrite!(r::AbstractRule, zxd::AbstractZXDiagram{T, P}, matches::Vector{Match{T}}) where {T, P}
    for each in matches
        rewrite!(r, zxd, each)
    end
    return zxd
end

function rewrite!(r::AbstractRule, zxd::AbstractZXDiagram{T, P}, matched::Match{T}) where {T, P}
    vs = matched.vertices
    if check_rule(r, zxd, vs)
        rewrite!(r, zxd, vs)
    end
    return zxd
end

function check_rule(r::Rule{:f}, zxd::ZXDiagram{T, P}, vs::Vector{T}) where {T, P}
    v1, v2 = vs
    (has_vertex(zxd.mg, v1) && has_vertex(zxd.mg, v2)) || return false
    if spider_type(zxd, v1) == SpiderType.Z || spider_type(zxd, v1) == SpiderType.X
        if v2 in neighbors(zxd, v1)
            if spider_type(zxd, v1) == spider_type(zxd, v2) && v2 >= v1
                return true
            end
        end
    end
    return false
end

function rewrite!(r::Rule{:f}, zxd::ZXDiagram{T, P}, vs::Vector{T}) where {T, P}
    v1, v2 = vs
    for v3 in neighbors(zxd, v2)
        if v3 != v1
            add_edge!(zxd, v1, v3)
        end
    end
    set_phase!(zxd, v1, phase(zxd, v1)+phase(zxd, v2))
    rem_spider!(zxd, v2)
    return zxd
end

function check_rule(r::Rule{:h}, zxd::ZXDiagram{T, P}, vs::Vector{T}) where {T, P}
    @inbounds v1 = vs[1]
    has_vertex(zxd.mg, v1) || return false
    if spider_type(zxd, v1) == SpiderType.X
        return true
    end
    return false
end

function rewrite!(r::Rule{:h}, zxd::ZXDiagram{T, P}, vs::Vector{T}) where {T, P}
    @inbounds v1 = vs[1]
    for v2 in neighbors(zxd, v1)
        if v2 != v1
            insert_spider!(zxd, v1, v2, SpiderType.H)
        end
    end
    zxd.st[v1] = SpiderType.Z
    return zxd
end

function check_rule(r::Rule{:i1}, zxd::ZXDiagram{T, P}, vs::Vector{T}) where {T, P}
    @inbounds v1 = vs[1]
    has_vertex(zxd.mg, v1) || return false
    if spider_type(zxd, v1) == SpiderType.Z || spider_type(zxd, v1) == SpiderType.X
        if phase(zxd, v1) == 0 && (degree(zxd, v1)) == 2
            return true
        end
    end
    return false
end

function rewrite!(r::Rule{:i1}, zxd::ZXDiagram{T, P}, vs::Vector{T}) where {T, P}
    @inbounds v1 = vs[1]
    v2, v3 = neighbors(zxd, v1, count_mul = true)
    add_edge!(zxd, v2, v3)
    rem_spider!(zxd, v1)
    return zxd
end

function check_rule(r::Rule{:i2}, zxd::ZXDiagram{T, P}, vs::Vector{T}) where {T, P}
    @inbounds v1, v2 = vs
    (has_vertex(zxd.mg, v1) && has_vertex(zxd.mg, v2)) || return false
    if spider_type(zxd, v1) == SpiderType.H && spider_type(zxd, v2) == SpiderType.H && has_edge(zxd.mg, v1, v2)
        if (degree(zxd, v1)) == 2 && (degree(zxd, v2)) == 2
            return true
        end
    end
    return false
end

function rewrite!(r::Rule{:i2}, zxd::ZXDiagram{T, P}, vs::Vector{T}) where {T, P}
    @inbounds v1, v2 = vs
    nb1 = neighbors(zxd, v1, count_mul = true)
    nb2 = neighbors(zxd, v2, count_mul = true)
    @inbounds v3 = (nb1[1] == v2 ? nb1[2] : nb1[1])
    @inbounds v4 = (nb2[1] == v1 ? nb2[2] : nb2[1])
    add_edge!(zxd, v3, v4)
    rem_spiders!(zxd, [v1, v2])
    return zxd
end

function check_rule(r::Rule{:pi}, zxd::ZXDiagram{T, P}, vs::Vector{T}) where {T, P}
    v1, v2 = vs
    (has_vertex(zxd.mg, v1) && has_vertex(zxd.mg, v2)) || return false
    if spider_type(zxd, v1) == SpiderType.X && phase(zxd, v1) == one(phase(zxd, v1)) &&
            (degree(zxd, v1)) == 2
        if v2 in neighbors(zxd, v1)
            if spider_type(zxd, v2) == SpiderType.Z
                return true
            end
        end
    end
    return false
end

function rewrite!(r::Rule{:pi}, zxd::ZXDiagram{T, P}, vs::Vector{T}) where {T, P}
    v1, v2 = vs
    set_phase!(zxd, v2, -phase(zxd, v2))
    nb = neighbors(zxd, v2, count_mul = true)
    for v3 in nb
        # TODO
        v3 != v1 && insert_spider!(zxd, v2, v3, SpiderType.X, phase(zxd, v1))
    end
    if neighbors(zxd, v1) != [v2]
        add_edge!(zxd, neighbors(zxd, v1))
        rem_spider!(zxd, v1)
    end
    return zxd
end

function check_rule(r::Rule{:c}, zxd::ZXDiagram{T, P}, vs::Vector{T}) where {T, P}
    v1, v2 = vs
    (has_vertex(zxd.mg, v1) && has_vertex(zxd.mg, v1)) || return false
    if spider_type(zxd, v1) == SpiderType.X && phase(zxd, v1) == zero(phase(zxd, v1)) && (degree(zxd, v1)) == 1
        if v2 in neighbors(zxd, v1)
            if spider_type(zxd, v2) == SpiderType.Z
                return true
            end
        end
    end
    return false
end

function rewrite!(r::Rule{:c}, zxd::ZXDiagram{T, P}, vs::Vector{T}) where {T, P}
    v1, v2 = vs
    ph = phase(zxd, v1)
    rem_spider!(zxd, v1)
    nb = neighbors(zxd, v2, count_mul = true)
    for v3 in nb
        add_spider!(zxd, SpiderType.X, ph, [v3])
    end
    rem_spider!(zxd, v2)
    return zxd
end

function check_rule(r::Rule{:b}, zxd::ZXDiagram{T, P}, vs::Vector{T}) where {T, P}
    v1, v2 = vs
    (has_vertex(zxd.mg, v1) && has_vertex(zxd.mg, v2)) || return false
    if spider_type(zxd, v1) == SpiderType.X && phase(zxd, v1) == 0 && (degree(zxd, v1)) == 3
        if v2 in neighbors(zxd, v1)
            if spider_type(zxd, v2) == SpiderType.Z && phase(zxd, v2) == 0 && (degree(zxd, v2)) == 3 && mul(zxd.mg, v1, v2) == 1
                return true
            end
        end
    end
    return false
end

function rewrite!(r::Rule{:b}, zxd::ZXDiagram{T, P}, vs::Vector{T}) where {T, P}
    v1, v2 = vs
    nb1 = neighbors(zxd, v1)
    nb2 = neighbors(zxd, v2)
    v3, v4 = nb1[nb1 .!= v2]
    v5, v6 = nb2[nb2 .!= v1]

    # TODO
    a1 = insert_spider!(zxd, v1, v3, SpiderType.Z)[1]
    a2 = insert_spider!(zxd, v1, v4, SpiderType.Z)[1]
    a3 = insert_spider!(zxd, v2, v5, SpiderType.X)[1]
    a4 = insert_spider!(zxd, v2, v6, SpiderType.X)[1]
    rem_spiders!(zxd, [v1, v2])

    add_edge!(zxd, a1, a3)
    add_edge!(zxd, a1, a4)
    add_edge!(zxd, a2, a3)
    add_edge!(zxd, a2, a4)
    return zxd
end

function check_rule(::Rule{:lc}, zxg::ZXGraph{T, P}, vs::Vector{T}) where {T, P}
    @inbounds v = vs[1]
    has_vertex(zxg.mg, v) || return false
    if has_vertex(zxg.mg, v)
        if spider_type(zxg, v) == SpiderType.Z && (phase(zxg, v) == 1//2 || phase(zxg, v) == 3//2)
            if is_interior(zxg, v)
                return true
            end
        end
    end
    return false
end

function rewrite!(r::Rule{:lc}, zxg::ZXGraph{T, P}, vs::Vector{T}) where {T, P}
    @inbounds v = vs[1]
    phase_v = phase(zxg, v)
    nb = neighbors(zxg, v)
    rem_spider!(zxg, v)
    for u1 in nb, u2 in nb
        if u2 > u1
            add_edge!(zxg, u1, u2, EdgeType.HAD)
        end
    end
    for u in nb
        set_phase!(zxg, u, phase(zxg, u)-phase_v)
    end
    return zxg
end

function check_rule(::Rule{:p1}, zxg::ZXGraph{T, P}, vs::Vector{T}) where {T, P}
    v1, v2 = vs
    (has_vertex(zxg.mg, v1) && has_vertex(zxg.mg, v2)) || return false
    if has_vertex(zxg.mg, v1)
        if spider_type(zxg, v1) == SpiderType.Z && is_interior(zxg, v1) &&
            (phase(zxg, v1) == 0 || phase(zxg, v1) == 1)
            if v2 in neighbors(zxg, v1)
                if spider_type(zxg, v2) == SpiderType.Z && is_interior(zxg, v2) &&
                    (phase(zxg, v2) == 0 || phase(zxg, v2) == 1) && v2 > v1
                    return true
                end
            end
        end
    end
    return false
end

function rewrite!(::Rule{:p1}, zxg::ZXGraph{T, P}, vs::Vector{T}) where {T, P}
    u, v = vs
    phase_u = phase(zxg, u)
    phase_v = phase(zxg, v)
    nb_u = setdiff(neighbors(zxg, u), [v])
    nb_v = setdiff(neighbors(zxg, v), [u])

    U = setdiff(nb_u, nb_v)
    V = setdiff(nb_v, nb_u)
    W = intersect(nb_u, nb_v)

    rem_spiders!(zxg, vs)
    for u0 in U, v0 in V
        add_edge!(zxg, u0, v0)
    end
    for u0 in U, w0 in W
        add_edge!(zxg, u0, w0)
    end
    for v0 in V, w0 in W
        add_edge!(zxg, v0, w0)
    end
    for u0 in U
        set_phase!(zxg, u0, phase(zxg, u0)+phase_v)
    end
    for v0 in V
        set_phase!(zxg, v0, phase(zxg, v0)+phase_u)
    end
    for w0 in W
        set_phase!(zxg, w0, phase(zxg, w0)+phase_u+phase_v+1)
    end
    return zxg
end

function check_rule(::Rule{:pab}, zxg::ZXGraph{T, P}, vs::Vector{T}) where {T, P}
    v1, v2 = vs
    (has_vertex(zxg.mg, v1) && has_vertex(zxg.mg, v2)) || return false
    if has_vertex(zxg.mg, v1)
        if spider_type(zxg, v1) == SpiderType.Z && is_interior(zxg, v1) &&
            (phase(zxg, v1) == 0 || phase(zxg, v1) == 1)
            if v2 in neighbors(zxg, v1)
                if spider_type(zxg, v2) == SpiderType.Z && !is_interior(zxg, v2)
                    return true
                end
            end
        end
    end
    return false
end

function rewrite!(::Rule{:pab}, zxg::ZXGraph{T, P}, vs::Vector{T}) where {T, P}
    u, v = vs
    phase_v = phase(zxg, v)
    nb_v = neighbors(zxg, v)
    v_bound = zero(T)
    for v0 in nb_v
        if spider_type(zxg, v0) != SpiderType.Z
            v_bound = v0
            break
        end
    end
    @inbounds if is_hadamard(zxg, v, v_bound)
        # TODO
        insert_spider!(zxg, v, v_bound)
        w = neighbors(zxg, v_bound)[1]
        insert_spider!(zxg, w, v_bound, phase_v)
        w = neighbors(zxg, v_bound)[1]
        set_phase!(zxg, w, phase(zxg, v))
        zxg.phase_ids[w] = zxg.phase_ids[v]
        set_phase!(zxg, v, zero(P))
        zxg.phase_ids[v] = (v, 1)
    else
        # TODO
        insert_spider!(zxg, v, v_bound)
        w = neighbors(zxg, v_bound)[1]
        insert_spider!(zxg, w, v_bound, phase_v)
        w = neighbors(zxg, v_bound)[1]
        set_phase!(zxg, w, phase(zxg, v))
        zxg.phase_ids[w] = zxg.phase_ids[v]
        set_phase!(zxg, v, zero(P))
        zxg.phase_ids[v] = (v, 1)
        rem_edge!(zxg, w, v_bound)
        add_edge!(zxg, w, v_bound, EdgeType.SIM)
    end
    return rewrite!(Rule{:p1}(), zxg, Match{T}([u, v]))
end

function check_rule(::Rule{:p2}, zxg::ZXGraph{T, P}, vs::Vector{T}) where {T, P}
    v1, v2 = vs
    if has_vertex(zxg.mg, v1)
        if spider_type(zxg, v1) == SpiderType.Z && is_interior(zxg, v1) &&
            (degree(zxg, v1)) > 1 && (phase(zxg, v1) ∉ (0, 1)) &&
            length(neighbors(zxg, v1)) > 1
            # (qubit_loc(zxg, v1) !== nothing || nqubits(zxg) == 0)
            if v2 in neighbors(zxg, v1)
                if spider_type(zxg, v2) == SpiderType.Z && is_interior(zxg, v2) &&
                    (phase(zxg, v2) == 0 || phase(zxg, v2) == 1)
                    # (qubit_loc(zxg, v2) !== nothing || nqubits(zxg) == 0)
                    # println("Rule p2 on: ", vs)
                    if all([length(neighbors(zxg, u)) > 1 for u in neighbors(zxg, v2)])
                        return true
                    end
                end
            end
        end
    end
    return false
end

function rewrite!(::Rule{:p2}, zxg::ZXGraph{T, P}, vs::Vector{T}) where {T, P}
    u, v = vs
    phase_u = phase(zxg, u)
    phase_v = phase(zxg, v)
    nb_u = setdiff(neighbors(zxg, u), [v])
    nb_v = setdiff(neighbors(zxg, v), [u])

    U = setdiff(nb_u, nb_v)
    V = setdiff(nb_v, nb_u)
    W = intersect(nb_u, nb_v)

    phase_id_u = zxg.phase_ids[u]
    if (-1)^phase_v < 0
        zxg.phase_ids[u] = (phase_id_u[1], -phase_id_u[2])
        phase_id_u = zxg.phase_ids[u]
    end
    rem_spider!(zxg, u)
    for u0 in U, v0 in V
        add_edge!(zxg, u0, v0)
    end
    for u0 in U, w0 in W
        add_edge!(zxg, u0, w0)
    end
    for v0 in V, w0 in W
        add_edge!(zxg, v0, w0)
    end
    for u0 in U
        set_phase!(zxg, u0, phase(zxg, u0)+phase_v)
    end
    for w0 in W
        set_phase!(zxg, w0, phase(zxg, w0)+phase_v+1)
    end
    gad = add_spider!(zxg, SpiderType.Z, P((-1)^phase_v*phase_u))
    add_edge!(zxg, v, gad)
    set_phase!(zxg, v, zero(P))
    zxg.phase_ids[gad] = phase_id_u
    zxg.phase_ids[v] = (v, 1)

    rem_vertex!(zxg.layout, v)
    # set_loc!(zxg.layout, gad, nqubits(zxg) + 2, column_loc(zxg, v))
    # set_loc!(zxg.layout, v, nqubits(zxg) + 1, column_loc(zxg, v))
    return zxg
end

function check_rule(::Rule{:p3}, zxg::ZXGraph{T, P}, vs::Vector{T}) where {T, P}
    v1, v2 = vs
    if has_vertex(zxg.mg, v1)
        if spider_type(zxg, v1) == SpiderType.Z && !is_interior(zxg, v1) &&
            (phase(zxg, v1) ∉ (0, 1)) && length(neighbors(zxg, v1)) > 1
            # (qubit_loc(zxg, v1) !== nothing || nqubits(zxg) == 0)
            if v2 in neighbors(zxg, v1)
                if spider_type(zxg, v2) == SpiderType.Z && is_interior(zxg, v2) &&
                    (phase(zxg, v2) == 0 || phase(zxg, v2) == 1)
                    # (qubit_loc(zxg, v2) !== nothing || nqubits(zxg) == 0)
                    return true
                end
            end
        end
    end
    return false
end

function rewrite!(::Rule{:p3}, zxg::ZXGraph{T, P}, vs::Vector{T}) where {T, P}
    u, v = vs
    phase_u = phase(zxg, u)
    phase_v = phase(zxg, v)
    nb_u = setdiff(neighbors(zxg, u), [v])
    nb_v = setdiff(neighbors(zxg, v), [u])
    bd_u = nb_u[findfirst([u0 in get_inputs(zxg) || u0 in get_outputs(zxg) for u0 in nb_u])]
    setdiff!(nb_u, [bd_u])

    U = setdiff(nb_u, nb_v)
    V = setdiff(nb_v, nb_u)
    W = intersect(nb_u, nb_v)

    phase_id_u = zxg.phase_ids[u]
    if (-1)^phase_v < 0
        zxg.phase_ids[u] = (phase_id_u[1], -phase_id_u[2])
        phase_id_u = zxg.phase_ids[u]
    end
    phase_id_v = zxg.phase_ids[v]
    rem_edge!(zxg, u, v)
    for u0 in U, v0 in V
        add_edge!(zxg, u0, v0)
    end
    for u0 in U, w0 in W
        add_edge!(zxg, u0, w0)
    end
    for v0 in V, w0 in W
        add_edge!(zxg, v0, w0)
    end
    for u0 in U
        rem_edge!(zxg, u, u0)
        set_phase!(zxg, u0, phase(zxg, u0)+phase_v)
    end
    for v0 in V
        add_edge!(zxg, u, v0)
    end
    for w0 in W
        set_phase!(zxg, w0, phase(zxg, w0)+phase_v+1)
    end
    set_phase!(zxg, v, zero(P))
    set_phase!(zxg, u, phase_v)
    gad = add_spider!(zxg, SpiderType.Z, P((-1)^phase_v*phase_u))
    add_edge!(zxg, v, gad)
    zxg.phase_ids[gad] = phase_id_u
    zxg.phase_ids[u] = phase_id_v
    zxg.phase_ids[v] = (v, 1)

    # set_loc!(zxg.layout, gad, nqubits(zxg) + 2, column_loc(zxg, v))
    # set_loc!(zxg.layout, v, nqubits(zxg) + 1, column_loc(zxg, v))
    rem_vertex!(zxg.layout, v)

    if is_hadamard(zxg, u, bd_u)
        rem_edge!(zxg, u, bd_u)
        add_edge!(zxg, u, bd_u, EdgeType.SIM)
    else
        rem_edge!(zxg, u, bd_u)
        add_edge!(zxg, u, bd_u)
    end
    return zxg
end

function check_rule(::Rule{:id}, zxg::ZXGraph{T, P}, vs::Vector{T}) where {T, P}
    v1, v2, v3 = vs
    @inbounds if has_vertex(zxg.mg, v1)
        nb1 = neighbors(zxg, v1)
        if spider_type(zxg, v1) == SpiderType.Z && length(nb1) == 1
            v2 = nb1[1]
            nb2 = neighbors(zxg, v2)
            if length(nb2) == 2 && phase(zxg, v2) in (zero(P), one(P))
                if v3 == setdiff(nb2, [v1])[1]
                    return true
                end
            end
        end
    end
    return false
end

function rewrite!(::Rule{:id}, zxg::ZXGraph{T, P}, vs::Vector{T}) where {T, P}
    v1, v2, v3 = vs
    if phase(zxg, v2) == 1
        set_phase!(zxg, v2, zero(P))
        set_phase!(zxg, v1, -phase(zxg, v1))
        zxg.phase_ids[v1] = (zxg.phase_ids[v1][1], -zxg.phase_ids[v1][2])
    end
    set_phase!(zxg, v3, phase(zxg, v3)+phase(zxg, v1))
    id1, mul1 = zxg.phase_ids[v1]
    id3, mul3 = zxg.phase_ids[v3]
    set_phase!(zxg.master, id3, (mul3 * phase(zxg.master, id3) + mul1 * phase(zxg.master, id1)) * mul3)
    set_phase!(zxg.master, id1, zero(P))
    rem_spiders!(zxg, [v1, v2])
    return zxg
end

function check_rule(::Rule{:gf}, zxg::ZXGraph{T, P}, vs::Vector{T}) where {T, P}
    @inbounds if all(has_vertex(zxg.mg, v) for v in vs)
        v1, v2, u1, u2 = vs
        if spider_type(zxg, v1) == SpiderType.Z && (degree(zxg, v1)) == 1 &&
            spider_type(zxg, u1) == SpiderType.Z && (degree(zxg, u1)) == 1
            if v2 == neighbors(zxg, v1)[1] && u2 == neighbors(zxg, u1)[1]
                gad_v = setdiff(neighbors(zxg, v2), [v1])
                gad_u = setdiff(neighbors(zxg, u2), [u1])
                if gad_u == gad_v && phase(zxg, v2) in (zero(P), one(P)) && phase(zxg, u2) in (zero(P), one(P))
                    return true
                end
            end
        end
    end
    return false
end

function rewrite!(::Rule{:gf}, zxg::ZXGraph{T, P}, vs::Vector{T}) where {T, P}
    v1, v2, u1, u2 = vs
    if phase(zxg, v2) == 1
        set_phase!(zxg, v2, zero(P))
        set_phase!(zxg, v1, -phase(zxg, v1))
        zxg.phase_ids[v1] = (zxg.phase_ids[v1][1], -zxg.phase_ids[v1][2])
    end
    if phase(zxg, u2) == 1
        set_phase!(zxg, u2, zero(P))
        set_phase!(zxg, u1, -phase(zxg, u1))
        zxg.phase_ids[u1] = (zxg.phase_ids[u1][1], -zxg.phase_ids[u1][2])
    end

    set_phase!(zxg, v1, phase(zxg, v1)+phase(zxg, u1))

    idv, mulv = zxg.phase_ids[v1]
    idu, mulu = zxg.phase_ids[u1]
    set_phase!(zxg.master, idv, (mulv * phase(zxg.master,idv) + mulu * phase(zxg.master,idu)) * mulv)
    set_phase!(zxg.master, idu, zero(P))

    rem_spiders!(zxg, [u1, u2])
    return zxg
end
