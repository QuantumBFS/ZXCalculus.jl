export rule_f!, rule_h!, rule_i1!, rule_i2!, rule_pi!, rule_b!, rule_c!

function check_rule_f(zxd::ZXDiagram{T,U,P}, v1::T, v2::T) where {T<:Integer, U<:Integer, P}
    msg = true
    if v1 <= nv(zxd) && v2 <= nv(zxd)
        if !has_edge(zxd.g, v1, v2)
            msg = "Spiders $(v1) and $(v2) are not connected!"
        end
        if spider_type(zxd, v1) == spider_type(zxd, v2)
            if ~(spider_type(zxd, v1) == Z || spider_type(zxd, v1) == X)
                msg = "Spiders $(v1) and $(v2) are not X or Z spiders!"
            end
        else
            msg = "Spiders $(v1) and $(v2) are not the same type!"
        end
    else
        msg = "Spider $(v1) or $(v2) is not in this ZX-diagram!"
    end
    return msg
end

function rule_f!(zxd::ZXDiagram{T,U,P}, v1::T, v2::T) where {T<:Integer, U<:Integer, P}
    msg = check_rule_f(zxd, v1, v2)
    if msg != true
        error(msg)
    end
    adjmx = zxd.g.adjmx
    adjmx[v1,:] += adjmx[v2,:]
    adjmx[:,v1] += adjmx[:,v2]
    adjmx[v1,v1] = 0
    zxd.ps[v1] += zxd.ps[v2]
    vmap = rem_spider!(zxd, v2)
    rounding_phases!(zxd)

    return vmap
end

function check_rule_h(zxd::ZXDiagram{T,U,P}, v::T) where {T<:Integer, U<:Integer, P}
    msg = true
    if v <= nv(zxd)
        if ~(spider_type(zxd, v) ∈ [Z, X])
            msg = "Spider $(v) is not a Z or X spider!"
        end
    else
        msg = "Spider $(v) is not in this ZX-diagram!"
    end
    return msg
end

function rule_h!(zxd::ZXDiagram{T,U,P}, v::T) where {T<:Integer, U<:Integer, P}
    msg = check_rule_h(zxd, v)
    if msg != true
        error(msg)
    end
    zxd.st[v] = SType(1 - Int(zxd.st[v]))
    for v1 in outneighbors(zxd, v)
        insert_spider!(zxd, v1, v, H)
    end
    zxd
end

function check_rule_i1(zxd::ZXDiagram{T,U,P}, v::T) where {T<:Integer, U<:Integer, P}
    msg = true
    if v <= nv(zxd)
        if zxd.st[v] == Z || zxd.st[v] == X
             if zxd.ps[v] == zero(P)
                 if degree(zxd.g, v) != 2
                     msg = "Spider $(v) is not of degree 2!"
                 end
             else
                 msg = "The phase of spider $(v) is not 0!"
             end
        else
            msg = "Spider $(v) is not a Z or X spider!"
        end
    else
        msg = "Spider $(v) is not in this ZX-diagram!"
    end
    return msg
end

function rule_i1!(zxd::ZXDiagram{T,U,P}, v::T) where {T<:Integer, U<:Integer, P}
    msg = check_rule_i1(zxd, v)
    if msg != true
        error(msg)
    end
    nbhd = outneighbors(zxd, v)
    if length(nbhd) == 2
        add_edge!(zxd.g, nbhd[1], nbhd[2])
    end
    vmap = rem_spider!(zxd, v)

    return vmap
end

function check_rule_i2(zxd::ZXDiagram{T,U,P}, v1::T, v2::T) where {T<:Integer, U<:Integer, P}
    msg = true
    if v1 <= nv(zxd) && v2 <= nv(zxd)
        if !(zxd.st[v1] == H && degree(zxd.g, v1) == 2)
            msg = "Spider $(v1) is not an H spider!"
        end
        if !(zxd.st[v2] == H && degree(zxd.g, v2) == 2)
            msg = "Spider $(v2) is not an H spider!"
        end
        if !has_edge(zxd.g, v1, v2)
            msg = "Spiders $(v1) and $(v2) are not connected!"
        end
    else
        msg = "Spider $(v1) or $(v2) is not in this ZX-diagram!"
    end
    return msg
end

function rule_i2!(zxd::ZXDiagram{T,U,P}, v1::T, v2::T) where {T<:Integer, U<:Integer, P}
    msg = check_rule_i2(zxd, v1, v2)
    if msg != true
        error(msg)
    end
    nbhd = [outneighbors(zxd, v1); outneighbors(zxd, v2)]
    nbhd = setdiff(nbhd, [v1, v2])

    if size(nbhd, 1) == 2
        add_edge!(zxd.g, nbhd[1], nbhd[2])
    end

    vmap = rem_spiders!(zxd, [v1, v2])

    return vmap
end

function check_rule_pi(zxd::ZXDiagram{T,U,P}, v1::T, v2::T) where {T<:Integer, U<:Integer, P}
    msg = true
    if v1 <= nv(zxd) && v2 <= nv(zxd)
        if zxd.g.adjmx[v1, v2] != 1
            msg = "Spiders $(v1) and $(v2) are not connected with a simple edge!"
        end
        if zxd.st[v1] == X && (zxd.ps[v1] == one(P) || zxd.ps[v1] == -one(P))
            if degree(zxd.g, v1) == 2
                if zxd.st[v2] != Z::SType
                    msg = "Spider $(v2) is not a Z spider!"
                end
            else
                msg = "Spider $(v1) is not of degree 2!"
            end
        else
            msg = "Spider $(v1) is not an X spider of phase π!"
        end
    else
        msg = "Spider $(v1) or $(v2) is not in this ZX-diagram!"
    end
    return msg
end

function rule_pi!(zxd::ZXDiagram{T,U,P}, v1::T, v2::T) where {T<:Integer, U<:Integer, P}
    msg = check_rule_pi(zxd, v1, v2)
    if msg != true
        error(msg)
    end
    nbhd1 = outneighbors(zxd, v1)
    zxd.ps[v2] = -zxd.ps[v2]
    nbhd2 = outneighbors(zxd, v2)
    for v in nbhd2
        if v != v1
            insert_spider!(zxd, v2, v, X, 1//1)
        end
    end
    add_edge!(zxd.g, nbhd1[1], nbhd1[2])
    vmap = rem_spider!(zxd, v1)
    rounding_phases!(zxd)

    return vmap
end

function check_rule_c(zxd::ZXDiagram{T,U,P}, v1::T, v2::T) where {T<:Integer, U<:Integer, P}
    msg = true
    if v1 <= nv(zxd) && v2 <= nv(zxd)
        if zxd.st[v1] == X && zxd.ps[v1] == zero(P)
            if zxd.st[v2] == Z
                if degree(zxd.g, v1) != 1 || !has_edge(zxd.g, v1, v2)
                    msg = "Spider $(v1) is not a degree 1 spider connected to spider $(v2)!"
                end
            else
                msg = "Spider $(v2) is not a Z spider!"
            end
        else
            msg = "Spider $(v1) is not an X spider of phase 0!"
        end
    else
        msg = "Spider $(v1) or $(v2) is not in this ZX-diagram!"
    end
    return msg
end

function rule_c!(zxd::ZXDiagram{T,U,P}, v1::T, v2::T) where {T<:Integer, U<:Integer, P}
    msg = check_rule_c(zxd, v1, v2)
    if msg != true
        error(msg)
    end
    rem_edge!(zxd, v1, v2)
    nbhd2 = outneighbors(zxd, v2)
    for v in nbhd2
        insert_spider!(zxd, v2, v, X)
    end
    vmap = rem_spiders!(zxd, [v1, v2])

    return vmap
end

function check_rule_b(zxd::ZXDiagram{T,U,P}, v1::T, v2::T) where {T<:Integer, U<:Integer, P}
    msg = true
    if v1 <= nv(zxd) && v2 <= nv(zxd)
        if (zxd.st[v1] == Z && zxd.st[v2] == X) || (zxd.st[v1] == X && zxd.st[v2] == Z)
            if zxd.ps[v1] == zero(P) && zxd.ps[v1] == zero(P)
                if has_edge(zxd.g, v1, v2)
                    if !(degree(zxd.g, v1) == 3 && degree(zxd.g, v2) == 3)
                        msg = "Spiders $(v1) or $(v2) is not of degree 3!"
                    end
                else
                    msg = "Spiders $(v1) and $(v2) are not connected!"
                end
            else
                msg = "Spiders $(v1) or $(v2) is not of phase 0!"
            end
        else
            msg = "Spiders ($(v1), $(v2)) are not a (Z, X) pair!"
        end
    else
        msg = "Spider $(v1) or $(v2) is not in this ZX-diagram!"
    end
    return msg
end

function rule_b!(zxd::ZXDiagram{T,U,P}, v1::T, v2::T) where {T<:Integer, U<:Integer, P}
    msg = check_rule_b(zxd, v1, v2)
    if msg != true
        error(msg)
    end
    rem_edge!(zxd, v1, v2)
    nbhd1 = outneighbors(zxd, v1)
    for v in nbhd1
        insert_spider!(zxd, v1, v, SType(1-Int(zxd.st[v1])))
    end
    v1_1 = nv(zxd)
    v1_2 = v1_1 - 1

    nbhd2 = outneighbors(zxd, v2)
    for v in nbhd2
        insert_spider!(zxd, v2, v, SType(1-Int(zxd.st[v2])))
    end
    v2_1 = nv(zxd)
    v2_2 = v2_1 - 1

    add_edge!(zxd.g, v1_1, v2_1)
    add_edge!(zxd.g, v1_1, v2_2)
    add_edge!(zxd.g, v1_2, v2_1)
    add_edge!(zxd.g, v1_2, v2_2)
    vmap = rem_spiders!(zxd, [v1, v2])

    return
end
