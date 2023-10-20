"""
    match(r, zxwd)

Returns all matched vertices, which will be store in sturct `Match`, for rule `r`
in a ZXW-diagram `zxwd`.
"""
Base.match(::AbstractRule, zxwd::ZXWDiagram{T,P}) where {T,P} = Match{T}[]

"""
Rule that implements both f and s1 rule.
"""
function Base.match(::Rule{:s1}, zxwd::ZXWDiagram{T,P}) where {T,P}
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
            isnothing(res) || push!(matches, res)
        end
    end
    return matches
end

function Base.match(::Rule{:s2}, zxwd::ZXWDiagram{T,P}) where {T,P}
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
        isnothing(res) || push!(matches, res)
    end
    return matches
end

function Base.match(::Rule{:ept}, zxwd::ZXWDiagram{T,P}) where {T,P}
    matches = Match{T}[]
    for v1 in spiders(zxwd)
        degree(zxwd, v1) != 1 && continue
        for v2 in neighbors(zxwd, v1)
            res = @match (spider_type(zxwd, v1), spider_type(zxwd, v2)) begin
                (X(p1), Z(_)) && if p1 == zero(p1)
                end => Match{T}([v1, v2])
                _ => nothing
            end
            isnothing(res) || push!(matches, res)
        end
    end
    return matches

end

function Base.match(::Rule{:b1}, zxwd::ZXWDiagram{T,P}) where {T,P}
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
            isnothing(res) || push!(matches, res)
        end
    end
    return matches
end

struct CalcRule{L} <: AbstractRule
    var::Symbol
end

CalcRule(r::Symbol, var::Symbol) = CalcRule{r}(var)

function Base.match(rule::CalcRule{:diff}, zxwd::ZXWDiagram{T,P}) where {T,P}
    vtxs = symbol_vertices(zxwd, rule.var)
    push!(vtxs, zero(T))
    append!(vtxs, symbol_vertices(zxwd, rule.var; neg = true))
    return [Match{T}(vtxs)]
end

function Base.match(rule::CalcRule{:int}, zxwd::ZXWDiagram{T,P}) where {T,P}
    vtxs = symbol_vertices(zxwd, rule.var)
    push!(vtxs, zero(T))
    append!(vtxs, symbol_vertices(zxwd, rule.var; neg = true))
    return [Match{T}(vtxs)]
end


"""
    rewrite!(r, zxd, matches)

Rewrite a ZX-diagram `zxd` with rule `r` for all vertices in `matches`. `matches`
can be a vector of `Match` or just an instance of `Match`.
"""
function rewrite!(
    r::AbstractRule,
    zxwd::ZXWDiagram{T,P},
    matches::Vector{Match{T}},
) where {T,P}
    for each in matches
        rewrite!(r, zxwd, each)
    end
    return zxwd
end

function rewrite!(r::AbstractRule, zxwd::ZXWDiagram{T,P}, matched::Match{T}) where {T,P}
    vs = matched.vertices
    check_rule(r, zxwd, vs) || return zxwd
    return rewrite!(r, zxwd, vs)
end

function rewrite!(::Rule{:s1}, zxwd::ZXWDiagram{T,P}, vs::Vector{T}) where {T,P}
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

function rewrite!(::Rule{:s2}, zxwd::ZXWDiagram{T,P}, vs::Vector{T}) where {T,P}
    v1 = vs[1]
    rem_spider!(zxwd, v1)
    return zxwd
end

function rewrite!(::Rule{:ept}, zxwd::ZXWDiagram{T,P}, vs::Vector{T}) where {T,P}
    rem_spiders!(zxwd, vs)
end

function rewrite!(::Rule{:b1}, zxwd::ZXWDiagram{T,P}, vs::Vector{T}) where {T,P}
    v1, v2 = vs
    for v3 in neighbors(zxwd, v2)
        v3 == v1 && continue
        add_spider!(zxwd, X(zero(v1.p)))
    end
    rem_spiders!(zxwd, vs)
    return zxwd
end

function rewrite!(::CalcRule{:diff}, zxwd::ZXWDiagram{T,P}, vs::Vector{T}) where {T,P}
    zero_loc = findfirst(x -> x == zero(T), vs)

    add_global_phase!(zxwd, P(π / 2))
    w_trig_vs = T[]

    for v in view(vs, 1:zero_loc-1)

        h_v = @match spider_type(zxwd, v) begin
            X(_) => add_spider!(zxwd, H, [v])
            Z(_) => v
        end

        x_v = add_spider!(zxwd, X(Parameter(Val(:PiUnit), 1.0)), [h_v])
        w_v = add_spider!(zxwd, D, [x_v])

        frac_v = @match parameter(zxwd, v) begin
            PiUnit(_, _) => w_v
            Factor(_, _) => error("Only supports PiUnit differentiation")
            _ => error("not a valid parameter")
        end
        push!(w_trig_vs, frac_v)
    end

    for v in view(vs, zero_loc+1:length(vs))

        h_v = @match spider_type(zxwd, v) begin
            X(_) => add_spider!(zxwd, H, [v])
            Z(_) => v
        end

        x_v = add_spider!(zxwd, X(Parameter(Val(:PiUnit), 1.0)), [h_v])
        w_v = add_spider!(zxwd, D, [x_v])

        frac_v = @match spider_type(zxwd, v).p begin
            PiUnit(_, _) => add_spider!(zxwd, Z(Parameter(Val(:PiUnit), 1.0)), [w_v])
            Factor(_, _) => error("Only supports PiUnit differentiation")
            _ => error("not a valid parameter")
        end
        push!(w_trig_vs, frac_v)
    end

    head = insert_wtrig!(zxwd, w_trig_vs)

    add_spider!(zxwd, X(Parameter(Val(:PiUnit), 1.0)), [head])
    # our definition of x_tensor exceeds one power of sqrt(2)
    add_power!(zxwd, -1)

    return zxwd
end

function rewrite!(::CalcRule{:int}, zxwd::ZXWDiagram{T,P}, vs::Vector{T}) where {T,P}
    zero_loc = findfirst(x -> x == zero(T), vs)
    return integrate!(zxwd, view(vs, 1:zero_loc-1)..., view(vs, zero_loc+1:length(vs))...)
end

function integrate!(zxwd::ZXWDiagram{T,P}, loc1::T, loc2::T) where {T,P}
    loc1 = int_prep!(zxwd, loc1)
    loc2 = int_prep!(zxwd, loc2)
    add_edge!(zxwd.mg, loc1, loc2)
    return zxwd
end

"""
Integrate two pairs of +/- parameter. Theorem 23 of https://arxiv.org/abs/2201.13250
"""
function integrate!(zxwd::ZXWDiagram{T,P}, loca::T, locc::T, locb::T, locd::T) where {T,P}
    loca = int_prep!(zxwd, loca)
    locb = int_prep!(zxwd, locb)
    locc = int_prep!(zxwd, locc)
    locd = int_prep!(zxwd, locd)

    # a, c = + , + \theta
    # b, d = - , - \theta
    loca = add_spider!(zxwd, Z(Parameter(Val(:PiUnit), 0)), [loca])
    locb = add_spider!(zxwd, Z(Parameter(Val(:PiUnit), 0)), [locb])
    locc = add_spider!(zxwd, X(Parameter(Val(:PiUnit), 0)), [locc])
    locd = add_spider!(zxwd, X(Parameter(Val(:PiUnit), 0)), [locd])

    add_edge!(zxwd, loca, locc)
    add_edge!(zxwd, locb, locd)

    locm = add_spider!(zxwd, X(Parameter(Val(:PiUnit), 0)), [loca, locb])
    locm = add_spider!(zxwd, D, [locm])
    locm = add_spider!(zxwd, X(Parameter(Val(:PiUnit), 1.0)), [locm])
    add_spider!(zxwd, Z(Parameter(Val(:PiUnit), 0)), [locm, locc, locd])

    # pink spider is different from red spider, we had three of them
    # each with three legs, 3 * (3-2)/2 powers of 2 need to be added
    # see 2307.01803
    add_power!(zxwd, 3)
    return zxwd
end

"""
Prepare spider at loc for integration.

Perform the simplified step of zeroing out phase of spider
and readying it for integration
1. If target spider is X spider, turn it to Z by adding H to all its legs
2. Pull out the Phase of the spider
3. zero out the phase
4. change the current spider back to its original type if necessary,
 will generate one extra H spider.
"""
function int_prep!(zxwd::ZXWDiagram{T,P}, loc::T) where {T,P}
    set_phase!(zxwd, loc, Parameter(Val(:PiUnit), 0.0))

    new_loc = @match spider_type(zxwd, loc) begin
        X(_) => add_spider!(zxwd, H, [loc])
        Z(_) => loc
        _ => error("Not a valid Spider to integrate over")
    end
    return new_loc
end

function check_rule(::Rule{:s1}, zxwd::ZXWDiagram{T,P}, vs::Vector{T}) where {T,P}
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

function check_rule(::Rule{:s2}, zxwd::ZXWDiagram{T,P}, vs::Vector{T}) where {T,P}
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

function check_rule(::Rule{:ept}, zxwd::ZXWDiagram{T,P}, vs::Vector{T}) where {T,P}
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

function check_rule(::Rule{:b1}, zxwd::ZXWDiagram{T,P}, vs::Vector{T}) where {T,P}
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

function check_rule(r::CalcRule{:diff}, zxwd::ZXWDiagram{T,P}, vs::Vector{T}) where {T,P}

    zero_loc = findfirst(x -> x == zero(T), vs)

    vs_len = length(vs)

    vs_len == 1 && return false

    all(has_vertex(zxwd.mg, v) for v in view(vs, 1:zero_loc-1)) || return false
    all(has_vertex(zxwd.mg, v) for v in view(vs, zero_loc+1:vs_len)) || return false

    for v in view(vs, 1:zero_loc-1)
        res = @match spider_type(zxwd, v) begin
            Z(p1) && if contains(p1, r.var)
            end => true
            X(p1) && if contains(p1, r.var)
            end => true
            _ => false
        end
        !res && return false
    end

    for v in view(vs, zero_loc+1:vs_len)
        res = @match spider_type(zxwd, v) begin
            Z(p1) && if contains(p1, Expr(:call, :-, r.var))
            end => true
            X(p1) && if contains(p1, Expr(:call, :-, r.var))
            end => true
            _ => false
        end
        !res && return false
    end
    return true
end

function check_rule(r::CalcRule{:int}, zxwd::ZXWDiagram{T,P}, vs::Vector{T}) where {T,P}
    vs_len = length(vs)

    zero_loc = findfirst(x -> x == zero(T), vs)
    zero_loc == 1 && return false
    zero_loc > 3 && return false
    2 * zero_loc != vs_len + 1 && return false

    all(has_vertex(zxwd.mg, v) for v in view(vs, 1:zero_loc-1)) || return false
    all(has_vertex(zxwd.mg, v) for v in view(vs, zero_loc+1:vs_len)) || return false

    for v in view(vs, 1:zero_loc-1)
        res = @match spider_type(zxwd, v) begin
            Z(p1) && if contains(p1, r.var)
            end => true
            X(p1) && if contains(p1, r.var)
            end => true
            _ => false
        end
        !res && return false
    end

    for v in view(vs, zero_loc+1:vs_len)
        res = @match spider_type(zxwd, v) begin
            Z(p1) && if contains(p1, Expr(:call, :-, r.var))
            end => true
            X(p1) && if contains(p1, Expr(:call, :-, r.var))
            end => true
            _ => false
        end
        !res && return false
    end
    return true
end
