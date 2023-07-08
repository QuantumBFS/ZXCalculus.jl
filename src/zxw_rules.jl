@adt public ZXWRule begin
    # adopting convention @ arXiv:2201.13250
    s1
    s2
    ept
    b1
end

function Base.match(r::ZXWRule, zxwd::ZXWDiagram{T,P}) where {T,P}
    @match r begin
        s1 => s1_match(zxwd)
        s2 => s2_match(zxwd)
        ept => ept_match(zxwd)
        b1 => b1_match(zxwd)
        _ => error("Rule not implemented")
    end
end

"""
Rule that implements both f and s1 rule.
"""
function s1_match(zxwd::ZXWDiagram{T,P}) where {T,P}
    matches = Match{T}[]
    for v1 in spiders(zxwd)
        for v2 in neighbors(zxwd, v1)
            res = @match (spider_type(zxwd, v1), spider_type(zxwd, v2)) begin
                (Z(_), Z(_)) && if v2 > v1
                end => Match{T}([v1, v2])
                (X(_), X(_)) && if v2 > v1
                end => Match{T}([v1, v2])
                _ => nothing
            end
            res === nothing || push!(matches, res)
        end
    end
    return matches
end

function s2_match(zxwd::ZXWDiagram{T,P}) where {T,P}
    matches = Match{T}[]
    for v1 in spiders(zxwd)
        degree(zxwd, v1) != 2 && continue
        res = @match spider_type(zxwd, v1) begin
            Z(p1) && if p1 == zero(p1)
            end => Match{T}([v1])
            X(p1) && if p1 == zero(p1)
            end => Match{T}([v1])
            _ => nothing
        end
        res === nothing || push!(matches, res)
    end
    return matches
end

function ept_match(zxwd::ZXWDiagram{T,P}) where {T,P}
    matches = Match{T}[]
    for v1 in spiders(zxwd)
        degree(zxwd, v1) != 1 && continue
        for v2 in neighbors(zxwd, v1)
            res = @match (spider_type(zxwd, v1), spider_type(zxwd, v2)) begin
                (X(p1), Z(_)) && if p1 == zero(p1)
                end => Match{T}([v1, v2])
                _ => nothing
            end
            res === nothing || push!(matches, res)
        end
    end
    return matches

end

function b1_match(zxwd::ZXWDiagram{T,P}) where {T,P}
    matches = Match{T}[]
    for v1 in spiders(zxwd)
        degree(zxwd, v1) != 2 && continue
        for v2 in neighbors(zxwd, v1)
            degree(zxwd, v2) != 3 && continue
            res = @match (spider_type(zxwd, v1), spider_type(zxwd, v2)) begin
                (X(p1), Z(p2)) && if p1 == zero(p1) && p2 == zero(p2)
                end => Match{T}([v1, v2])
                _ => nothing
            end
            res === nothing || push!(matches, res)
        end
    end
    return matches
end

function rewrite!(r::ZXWRule, zxwd::ZXWDiagram{T,P}, matches::Vector{Match{T}}) where {T,P}
    for each in matches
        rewrite!(r, zxwd, each)
    end
    return zxwd
end

function rewrite!(r::ZXWRule, zxwd::ZXWDiagram{T,P}, matched::Match{T}) where {T,P}

    vs = matched.vertices
    check_rule(r, zxwd, vs) || return zxwd

    @match r begin
        s1 => s1_rewrite!(zxwd, vs)
        s2 => s2_rewrite!(zxwd, vs)
        ept => ept_rewrite!(zxwd, vs)
        b1 => b1_rewrite!(zxwd, vs)
        _ => error("Rule not implemented")
    end
    return zxwd
end

function s1_rewrite!(zxwd::ZXWDiagram{T,P}, vs::Vector{T}) where {T,P}
    v1, v2 = vs
    sp1, sp2 = spider_type(zxwd, v1), spider_type(zxwd, v2)
    for v3 in neighbors(zxwd, v2)
        v3 == v1 && continue
        add_edge!(zxwd, v1, v3)
    end
    set_phase!(zxwd, v1, sp1.p + sp2.p)
    rem_spider!(zxwd, v2)
    return zxwd
end

function s2_rewrite!(zxwd::ZXWDiagram{T,P}, vs::Vector{T}) where {T,P}
    v1 = vs[1]
    rem_spider!(zxwd, v1)
    return zxwd
end

function ept_rewrite!(zxwd::ZXWDiagram{T,P}, vs::Vector{T}) where {T,P}
    rem_spiders!(zxwd, vs)
end

function b1_rewrite!(zxwd::ZXWDiagram{T,P}, vs::Vector{T}) where {T,P}
    v1, v2 = vs
    for v3 in neighbors(zxwd, v2)
        v3 == v1 && continue
        add_spider!(zxwd, X(zero(v1.p)))
    end
    rem_spiders!(zxwd, vs)
    return zxwd
end

function check_rule(r::ZXWRule, zxwd::ZXWDiagram{T,P}, vs::Vector{T}) where {T,P}
    @match r begin
        s1 => s1_check(zxwd, vs)
        s2 => s2_check(zxwd, vs)
        ept => ept_check(zxwd, vs)
        b1 => b1_check(zxwd, vs)
        _ => error("Rule not implemented")
    end
end


function s1_check(zxwd::ZXWDiagram{T,P}, vs::Vector{T}) where {T,P}
    v1, v2 = vs
    (has_vertex(zxwd.mg, v1) && has_vertex(zxwd.mg, v2)) || return false
    v2 in neighbors(zxwd, v1) || return false
    v2 > v1 || return false

    @match (spider_type(zxwd, v1), spider_type(zxwd, v2)) begin
        (Z(_), Z(_)) => true
        (X(_), X(_)) => true
        _ => false
    end
end

function s2_check(zxwd::ZXWDiagram{T,P}, vs::Vector{T}) where {T,P}
    v1 = vs[1]
    has_vertex(zxwd.mg, v1) || return false
    degree(zxwd, v1) == 2 || return false

    @match spider_type(zxwd, v1) begin
        Z(p1) && if p1 == zero(p1)
        end => true
        X(p1) && if p1 == zero(p1)
        end => true
        _ => false
    end
end

function ept_check(zxwd::ZXWDiagram{T,P}, vs::Vector{T}) where {T,P}
    v1, v2 = vs
    (has_vertex(zxwd.mg, v1) && has_vertex(zxwd.mg, v2)) || return false
    v2 in neighbors(zxwd, v1) || return false
    degree(zxwd, v1) == 1 || return false
    degree(zxwd, v2) == 1 || return false

    @match (spider_type(zxwd, v1), spider_type(zxwd, v2)) begin
        (X(p1), Z(_)) && if p1 == zero(p1)
        end => true
        _ => false
    end
end

function b1_check(zxwd::ZXWDiagram{T,P}, vs::Vector{T}) where {T,P}
    v1, v2 = vs
    (has_vertex(zxwd.mg, v1) && has_vertex(zxwd.mg, v2)) || return false
    v2 in neighbors(zxwd, v1) || return false
    degree(zxwd, v1) == 1 || return false
    degree(zxwd, v2) == 3 || return false

    @match (spider_type(zxwd, v1), spider_type(zxwd, v2)) begin
        (X(p1), Z(p2)) && if p1 == zero(p1) && p2 == zero(p2)
        end => true
        _ => false
    end
end
