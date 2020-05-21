import Base: match

export Rule, Match
export rewrite!

abstract type AbstractRule end

struct Rule{L} <: AbstractRule end

struct Match{T<:Integer}
    vertices::Vector{T}
end

match(::AbstractRule, zxd::ZXDiagram{T, P}) where {T, P} = Match{T}[]

function match(::Rule{:f}, zxd::ZXDiagram{T, P}) where {T, P}
    matches = Match{T}[]
    for v1 in spiders(zxd)
        if spider_type(zxd, v1) == Z || spider_type(zxd, v1) == X
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
        if spider_type(zxd, v1) == X
            push!(matches, Match{T}([v1]))
        end
    end
    return matches
end

function match(::Rule{:i1}, zxd::ZXDiagram{T, P}) where {T, P}
    matches = Match{T}[]
    for v1 in spiders(zxd)
        if spider_type(zxd, v1) == Z || spider_type(zxd, v1) == X
            if phase(zxd, v1) == 0 && length(neighbors(zxd, v1, count_mul = true)) == 2
                push!(matches, Match{T}([v1]))
            end
        end
    end
    return matches
end

function match(::Rule{:i2}, zxd::ZXDiagram{T, P}) where {T, P}
    matches = Match{T}[]
    for v1 in spiders(zxd)
        if spider_type(zxd, v1) == H && length(neighbors(zxd, v1, count_mul = true)) == 2
            for v2 in neighbors(zxd, v1)
                if spider_type(zxd, v2) == H && length(neighbors(zxd, v2, count_mul = true)) == 2
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
        if spider_type(zxd, v1) == X && phase(zxd, v1) == one(P) && length(neighbors(zxd, v1, count_mul = true)) == 2
            for v2 in neighbors(zxd, v1)
                if spider_type(zxd, v2) == Z
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
        if spider_type(zxd, v1) == X && phase(zxd, v1) == zero(P) && length(neighbors(zxd, v1, count_mul = true)) == 1
            for v2 in neighbors(zxd, v1)
                if spider_type(zxd, v2) == Z
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
        if spider_type(zxd, v1) == X && phase(zxd, v1) == zero(P) && length(neighbors(zxd, v1, count_mul = true)) == 3
            for v2 in neighbors(zxd, v1)
                if spider_type(zxd, v2) == Z && phase(zxd, v2) == zero(P) && length(neighbors(zxd, v2, count_mul = true)) == 3 && mul(zxd.mg, v1, v2) == 1
                    push!(matches, Match{T}([v1, v2]))
                end
            end
        end
    end
    return matches
end

function rewrite!(r::AbstractRule, zxd::ZXDiagram{T, P}, matches::Vector{Match{T}}) where {T, P}
    for each in matches
        rewrite!(r, zxd, each)
    end
    zxd
end

function rewrite!(r::AbstractRule, zxd::ZXDiagram{T, P}, matched::Match{T}) where {T, P}
    vs = matched.vertices
    if check_rule(r, zxd, vs)
        return rewrite!(r, zxd, vs)
    else
        return zxd
    end
end

function check_rule(r::Rule{:f}, zxd::ZXDiagram{T, P}, vs::Vector{T}) where {T, P}
    vs ⊆ spiders(zxd) || return false
    v1 = vs[1]
    v2 = vs[2]
    if spider_type(zxd, v1) == Z || spider_type(zxd, v1) == X
        if v2 in neighbors(zxd, v1)
            if spider_type(zxd, v1) == spider_type(zxd, v2) && v2 >= v1
                return true
            end
        end
    end
    return false
end

function rewrite!(r::Rule{:f}, zxd::ZXDiagram{T, P}, vs::Vector{T}) where {T, P}
    v1 = vs[1]
    v2 = vs[2]
    for v3 in neighbors(zxd, v2)
        if v3 != v1
            add_edge!(zxd, v1, v3)
        end
    end
    zxd.ps[v1] += zxd.ps[v2]
    rem_spider!(zxd, v2)
    rounding_phases!(zxd)
    zxd
end

function check_rule(r::Rule{:h}, zxd::ZXDiagram{T, P}, vs::Vector{T}) where {T, P}
    vs ⊆ spiders(zxd) || return false
    v1 = vs[1]
    if spider_type(zxd, v1) == X
        return true
    end
    return false
end

function rewrite!(r::Rule{:h}, zxd::ZXDiagram{T, P}, vs::Vector{T}) where {T, P}
    v1 = vs[1]
    for v2 in neighbors(zxd, v1)
        if v2 != v1
            insert_spider!(zxd, v1, v2, H)
        end
    end
    zxd.st[v1] = Z
    zxd
end

function check_rule(r::Rule{:i1}, zxd::ZXDiagram{T, P}, vs::Vector{T}) where {T, P}
    vs ⊆ spiders(zxd) || return false
    v1 = vs[1]
    if spider_type(zxd, v1) == Z || spider_type(zxd, v1) == X
        if phase(zxd, v1) == 0 && length(neighbors(zxd, v1, count_mul = true)) == 2
            return true
        end
    end
    return false
end

function rewrite!(r::Rule{:i1}, zxd::ZXDiagram{T, P}, vs::Vector{T}) where {T, P}
    v1 = vs[1]
    v2, v3 = neighbors(zxd, v1, count_mul = true)
    add_edge!(zxd, v2, v3)
    rem_spider!(zxd, v1)
    zxd
end

function check_rule(r::Rule{:i2}, zxd::ZXDiagram{T, P}, vs::Vector{T}) where {T, P}
    vs ⊆ spiders(zxd) || return false
    v1 = vs[1]
    v2 = vs[2]
    if spider_type(zxd, v1) == H && spider_type(zxd, v2) == H && has_edge(zxd.mg, v1, v2)
        if length(neighbors(zxd, v1, count_mul = true)) == 2 && length(neighbors(zxd, v2, count_mul = true)) == 2
            return true
        end
    end
    return false
end

function rewrite!(r::Rule{:i2}, zxd::ZXDiagram{T, P}, vs::Vector{T}) where {T, P}
    v1 = vs[1]
    v2 = vs[2]
    nb1 = neighbors(zxd, v1, count_mul = true)
    nb2 = neighbors(zxd, v2, count_mul = true)
    v3 = (nb1[1] == v2 ? nb1[2] : nb1[1])
    v4 = (nb2[1] == v1 ? nb2[2] : nb2[1])
    add_edge!(zxd, v3, v4)
    rem_spiders!(zxd, [v1, v2])
    zxd
end

function check_rule(r::Rule{:pi}, zxd::ZXDiagram{T, P}, vs::Vector{T}) where {T, P}
    vs ⊆ spiders(zxd) || return false
    v1 = vs[1]
    v2 = vs[2]
    if spider_type(zxd, v1) == X && phase(zxd, v1) == one(phase(zxd, v1)) &&
            length(neighbors(zxd, v1, count_mul = true)) == 2
        if v2 in neighbors(zxd, v1)
            if spider_type(zxd, v2) == Z
                return true
            end
        end
    end
    return false
end

function rewrite!(r::Rule{:pi}, zxd::ZXDiagram{T, P}, vs::Vector{T}) where {T, P}
    v1 = vs[1]
    v2 = vs[2]
    zxd.ps[v2] = -zxd.ps[v2]
    nb = neighbors(zxd, v2, count_mul = true)
    for v3 in nb
        v3 != v1 && insert_spider!(zxd, v2, v3, X, phase(zxd, v1))
    end
    if neighbors(zxd, v1) != [v2]
        add_edge!(zxd, neighbors(zxd, v1))
        rem_spider!(zxd, v1)
    end
    rounding_phases!(zxd)
    zxd
end

function check_rule(r::Rule{:c}, zxd::ZXDiagram{T, P}, vs::Vector{T}) where {T, P}
    vs ⊆ spiders(zxd) || return false
    v1 = vs[1]
    v2 = vs[2]
    if spider_type(zxd, v1) == X && phase(zxd, v1) == zero(phase(zxd, v1)) && length(neighbors(zxd, v1, count_mul = true)) == 1
        if v2 in neighbors(zxd, v1)
            if spider_type(zxd, v2) == Z
                return true
            end
        end
    end
    return false
end

function rewrite!(r::Rule{:c}, zxd::ZXDiagram{T, P}, vs::Vector{T}) where {T, P}
    v1 = vs[1]
    v2 = vs[2]
    ph = phase(zxd, v1)
    rem_spider!(zxd, v1)
    nb = neighbors(zxd, v2, count_mul = true)
    for v3 in nb
        add_spider!(zxd, X, ph, [v3])
    end
    rem_spider!(zxd, v2)
    zxd
end

function check_rule(r::Rule{:b}, zxd::ZXDiagram{T, P}, vs::Vector{T}) where {T, P}
    vs ⊆ spiders(zxd) || return false
    v1 = vs[1]
    v2 = vs[2]
    if spider_type(zxd, v1) == X && phase(zxd, v1) == 0 && length(neighbors(zxd, v1, count_mul = true)) == 3
        if v2 in neighbors(zxd, v1)
            if spider_type(zxd, v2) == Z && phase(zxd, v2) == 0 && length(neighbors(zxd, v2, count_mul = true)) == 3 && mul(zxd.mg, v1, v2) == 1
                return true
            end
        end
    end
    return false
end

function rewrite!(r::Rule{:b}, zxd::ZXDiagram{T, P}, vs::Vector{T}) where {T, P}
    v1 = vs[1]
    v2 = vs[2]
    nb1 = neighbors(zxd, v1)
    nb2 = neighbors(zxd, v2)
    v3, v4 = nb1[nb1 .!= v2]
    v5, v6 = nb2[nb2 .!= v1]

    insert_spider!(zxd, v1, v3, Z)
    insert_spider!(zxd, v1, v4, Z)
    insert_spider!(zxd, v2, v5, X)
    insert_spider!(zxd, v2, v6, X)
    rem_spiders!(zxd, [v1, v2])
    a1, a2, a3, a4 = spiders(zxd)[end-3:end]

    add_edge!(zxd, a1, a3)
    add_edge!(zxd, a1, a4)
    add_edge!(zxd, a2, a3)
    add_edge!(zxd, a2, a4)
    zxd
end
