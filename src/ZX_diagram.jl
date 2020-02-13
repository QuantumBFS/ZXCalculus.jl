# include("graph.jl")
import Base.show

export ZX_diagram, V_Type, Z, X, H, In, Out
export rule_f!, rule_h!, rule_i1!, rule_i2!, rule_pi!, rule_b!, rule_c!

@enum V_Type Z X H In Out

mutable struct ZX_diagram{T<:Integer}
    g::Graph{T}

    phases::Vector{Rational{T}}
    v_type::Vector{V_Type}

    # cir_ind::Vector{Vector{T}}
    # nqubits::T
    # depth::T
end

function show(io::IO, zxd::ZX_diagram{T}) where {T<:Integer}
    println(io, "A ZX-diagram with $(zxd.g.nv) vertices and $(zxd.g.ne) edges:")
    for v1 in 1:zxd.g.nv
        for v2 in (v1+1):zxd.g.nv
            if zxd.g.adjmat[v1, v2] > 0
                for i in 1:zxd.g.adjmat[v1, v2]
                    print(io, "(")
                    print_spider(io, zxd, v1)
                    print(io, " <--> ")
                    print_spider(io, zxd, v2)
                    print(io, ")\n")
                end
            end
        end
    end
end

function print_spider(io::IO, zxd::ZX_diagram{T}, v::T) where {T<:Integer}
    if zxd.v_type[v] == Z
        printstyled(io, "V_$(v){phase = $(zxd.phases[v])⋅π}"; color = :green)
    end
    if zxd.v_type[v] == X
        printstyled(io, "V_$(v){phase = $(zxd.phases[v])⋅π}"; color = :red)
    end
    if zxd.v_type[v] == H
        printstyled(io, "V_$(v){H}"; color = :yellow)
    end
    if zxd.v_type[v] == In
        print(io, "V_$(v){input}")
    end
    if zxd.v_type[v] == Out
        print(io, "V_$(v){output}")
    end
end

find_nbhd(zxd::ZX_diagram{T}, v) where {T<:Integer} = find_nbhd(zxd.g, v)
remove_edge!(zxd::ZX_diagram, es) where {T<:Integer} = remove_edge!(zxd.g, es)

function remove_spider!(zxd::ZX_diagram{T}, vs::Vector{T}) where {T<:Integer}
    vmap = remove_vertex!(zxd.g, vs)
    deleteat!(zxd.phases, sort(vs))
    deleteat!(zxd.v_type, sort(vs))
    return vmap
end

remove_spider!(zxd::ZX_diagram{T}, v::T) where {T<:Integer} = remove_spider!(zxd, [v])

function add_spider!(zxd::ZX_diagram, connect::Vector{T}, vt::V_Type, phase::Rational{T}) where {T<:Integer}
    add_vertex!(zxd.g)
    v = zxd.g.nv
    for c in connect
        add_edge!(zxd.g, v, c)
    end
    push!(zxd.v_type, vt)
    push!(zxd.phases, phase)
    zxd
end

function insert_spider!(zxd::ZX_diagram{T}, v1::T, v2::T, vt::V_Type, phase::Rational{T} = 0//1) where {T<:Integer}
    for i = 1:zxd.g.adjmat[v1,v2]
        add_spider!(zxd::ZX_diagram, [v1,v2], vt, phase)
        remove_edge!(zxd, [v1,v2])
    end
    zxd
end

function check_rule_f(zxd::ZX_diagram{T}, v1::T, v2::T) where {T<:Integer}
    adjmat = zxd.g.adjmat
    if adjmat[v1, v2] == 0
        error("Spiders $(v1) and $(v2) are not connected!")
    end
    if zxd.v_type[v1] == zxd.v_type[v2]
        if ~(zxd.v_type[v1] == Z || zxd.v_type[v1] == X)
            error("Spiders $(v1) and $(v2) are not X or Z spiders!")
        end
    else
        error("Spiders $(v1) and $(v2) are not the same type!")
    end
    zxd
end

function rule_f!(zxd::ZX_diagram{T}, v1::T, v2::T) where {T<:Integer}
    check_rule_f(zxd, v1, v2)
    adjmat = zxd.g.adjmat
    adjmat[v1,:] += adjmat[v2,:]
    adjmat[:,v1] += adjmat[:,v2]
    adjmat[v1,v1] = 0
    zxd.g.ne -= adjmat[v1, v2]
    zxd.phases[v1] += zxd.phases[v2]
    remove_spider!(zxd, v2)
    zxd
    # returning a vmap maybe better...
end

function check_rule_h(zxd::ZX_diagram{T}, v::T) where {T<:Integer}
    if ~(zxd.v_type[v] ∈ V_Type.([0,1]))
        error("Spider $(v) is not a Z or X spider!")
    end
end

function rule_h!(zxd::ZX_diagram{T}, v::T) where {T<:Integer}
    check_rule_h(zxd, v)
    zxd.v_type[v] = V_Type(1 - Int(zxd.v_type[v]))
    nbhd = find_nbhd(zxd, v)
    for v1 in nbhd
        insert_spider!(zxd, v1, v, H)
    end
    zxd
end

function check_rule_i1(zxd::ZX_diagram{T}, v::T) where {T<:Integer}
    if zxd.v_type[v] == Z::V_Type || zxd.v_type[v] == X::V_Type
         if zxd.phases[v] == 0
             nbhd = find_nbhd(zxd, v)
             if size(nbhd, 1) != 2
                 error("Spider $(v) is not of degree 2!")
             end
         else
             error("The phase of spider $(v) is not 0!")
         end
    else
        error("Spider $(v) is not a Z or X spider!")
    end
end

function rule_i1!(zxd::ZX_diagram{T}, v::T) where {T<:Integer}
    check_rule_i1(zxd, v)
    nbhd = find_nbhd(zxd, v)
    add_edge!(zxd.g, nbhd[1], nbhd[2])
    remove_spider!(zxd, v)

    zxd
end

function check_rule_i2(zxd::ZX_diagram{T}, v1::T, v2::T) where {T<:Integer}
    if ~(zxd.v_type[v1] == H::V_Type && size(find_nbhd(zxd, v1),1) == 2)
        error("Spider $(v1) is not an H spider!")
    end
    if ~(zxd.v_type[v2] == H::V_Type && size(find_nbhd(zxd, v2),1) == 2)
        error("Spider $(v2) is not an H spider!")
    end
end

function rule_i2!(zxd::ZX_diagram{T}, v1::T, v2::T) where {T<:Integer}
    check_rule_i2(zxd, v1, v2)
    nbhd = [find_nbhd(zxd, v1); find_nbhd(zxd, v2)]
    nbhd = setdiff(nbhd, [v1 v2])

    if size(nbhd, 1) == 2
        add_edge!(zxd.g, nbhd[1], nbhd[2])
    end

    remove_spider!(zxd, [v1, v2])

    zxd
end

function check_rule_pi(zxd::ZX_diagram, v1::T, v2::T) where {T<:Integer}
    if zxd.g.adjmat[v1, v2] == 0
        error("Spiders $(v1) and $(v2) are not connected!")
    end
    if zxd.v_type[v1] == X::V_Type && zxd.phases[v1] == 1//1
        nbhd1 = find_nbhd(zxd, v1)
        if size(nbhd1, 1) == 2
            if zxd.v_type[v2] != Z::V_Type
                error("Spider $(v2) is not a Z spider!")
            end
        else
            error("Spider $(v1) is not of degree 2!")
        end
    else
        error("Spider $(v1) is not an X spider of phase π!")
    end
end

function rule_pi!(zxd::ZX_diagram, v1::T, v2::T) where {T<:Integer}
    check_rule_pi(zxd, v1, v2)
    nbhd1 = find_nbhd(zxd, v1)
    zxd.phases[v2] = -zxd.phases[v2]
    nbhd2 = find_nbhd(zxd, v2)
    for v in nbhd2
        if v != v1
            insert_spider!(zxd, v2, v, X, 1//1)
        end
    end
    add_edge!(zxd.g, nbhd1)
    remove_spider!(zxd, v1)

    zxd
end

function checke_rule_c(zxd::ZX_diagram{T}, v1::T, v2::T) where {T<:Integer}
    if zxd.v_type[v1] == X::V_Type && zxd.phases[v1] == 0//1
        if zxd.v_type[v2] == Z::V_Type
            nbhd1 = find_nbhd(zxd, v1)
            if nbhd1 != [v2]
                error("Spider $(v2) is not the only spider connected to spider $(v1)!")
            end
        else
            error("Spider $(v2) is not a Z spider!")
        end
    else
        error("Spider $(v1) is not an X spider of phase 0!")
    end
    zxd
end

function rule_c!(zxd::ZX_diagram{T}, v1::T, v2::T) where {T<:Integer}
    nbhd1 = find_nbhd(zxd, v1)
    remove_edge!(zxd, [v1, v2])
    nbhd2 = find_nbhd(zxd, v2)
    for v in nbhd2
        insert_spider!(zxd, v2, v, X)
    end
    remove_spider!(zxd, [v1, v2])

    zxd
end

function check_rule_b(zxd::ZX_diagram{T}, v1::T, v2::T) where {T<:Integer}
    if (zxd.v_type[v1] == Z && zxd.v_type[v2] == X) || (zxd.v_type[v1] == X && zxd.v_type[v2] == Z)
        if zxd.phases[v1] == 0//1 && zxd.phases[v1] == 0//1
            if zxd.g.adjmat[v1,v2] != 0
                if ~(size(find_nbhd(zxd, v1), 1) == 3 && size(find_nbhd(zxd, v2), 1) == 3)
                    error("Spiders $(v1) or $(v2) is not of degree 3!")
                end
            else
                error("Spiders $(v1) and $(v2) are not connected!")
            end
        else
            error("Spiders $(v1) or $(v2) is not of phase 0!")
        end
    else
        error("Spiders ($(v1), $(v2)) are not a (Z, X) pair!")
    end
end

function rule_b!(zxd::ZX_diagram{T}, v1::T, v2::T) where {T<:Integer}
    check_rule_b(zxd, v1, v2)
    remove_edge!(zxd, [v1, v2])
    nbhd1 = find_nbhd(zxd, v1)
    for v in nbhd1
        insert_spider!(zxd, v1, v, V_Type(1-Int(zxd.v_type[v1])))
    end
    v1_1 = zxd.g.nv
    v1_2 = v1_1 - 1

    nbhd2 = find_nbhd(zxd, v2)
    for v in nbhd2
        insert_spider!(zxd, v2, v, V_Type(1-Int(zxd.v_type[v2])))
    end
    v2_1 = zxd.g.nv
    v2_2 = v2_1 - 1

    add_edge!(zxd.g, [[v1_1, v2_1], [v1_1, v2_2], [v1_2, v2_1], [v1_2, v2_2]])
    remove_spider!(zxd, [v1, v2])

    zxd
end
