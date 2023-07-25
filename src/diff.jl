using ZXCalculus: contains, dagger, concat!

"""
Take derivative of ZXWDiagram with respect to a parameter

Assuming Spiders have Parameter of type PiUnit which is parameterized purely by θ
"""
function diff_diagram(zxwd::ZXWDiagram{T,P}, θ::Symbol) where {T,P}
    vs_pos = symbol_vertices(zxwd, θ)
    vs_neg = symbol_vertices(zxwd, θ; neg = true)

    length(vs_pos) + length(vs_neg) == 0 && return zxwd

    add_global_phase!(zxwd, P(π / 2))
    w_trig_vs = T[]

    for v in vs_pos
        x_v = add_spider!(zxwd, X(Parameter(Val(:PiUnit), 1.0)), [v])
        w_v = add_spider!(zxwd, D, [x_v])
        frac_v = @match spider_type(zxwd, v).p begin
            PiUnit(pu, _) => w_v
            Factor(f, _) => error("Only supports PiUnit differentiation")
            _ => error("not a valid parameter")
        end
        push!(w_trig_vs, frac_v)
    end

    for v in vs_neg
        x_v = add_spider!(zxwd, X(Parameter(Val(:PiUnit), 1.0)), [v])
        w_v = add_spider!(zxwd, D, [x_v])
        frac_v = @match spider_type(zxwd, v).p begin
            PiUnit(pu, _) => add_spider!(zxwd, Z(Parameter(Val(:Factor), π)), [w_v])
            Factor(f, _) => error("Only supports PiUnit differentiation")
            _ => error("not a valid parameter")
        end
        push!(w_trig_vs, frac_v)
    end

    head = insert_wtrig!(zxwd, w_trig_vs)

    add_spider!(zxwd, X(Parameter(Val(:PiUnit), 1.0)), [head])

    return zxwd
end

"""
Take derivative with of Circuit with expectation of Hamiltonian H.
"""
function diff_expval!(zxwd::ZXWDiagram{T,P}, H::String, θ::Symbol) where {T,P}
    # convert U to U^\dag H U
    zxwd_dag = dagger(zxwd)
    for (i, h) in enumerate(H)
        if h == "Z"
            push_gate!(zxwd, Val(:Z), i)
        elseif h == "X"
            push_gate!(zxwd, Val(:X), i)
        elseif h == "Y"
            push_gate!(zxwd, Val(:Z), i)
            push_gate!(zxwd, Val(:X), i)
            add_global_phase!(zxwd, P(-π / 2))
        end
    end
    concat!(zxwd, zxwd_dag)
    return diff_diagram(zxwd, θ)
end

"""

Finds vertices of Spider that contains the parameter θ or -θ
"""
function symbol_vertices(zxwd::ZXWDiagram{T,P}, θ::Symbol; neg::Bool = false) where {T,P}
    if neg
        target = Expr(:call, :-, θ)
    else
        target = θ
    end
    matched = T[]
    for v in vertices(zxwd.mg)
        res = @match spider_type(zxwd, v) begin
            Z(p1) && if contains(p1, target)
            end => v
            X(p1) && if contains(p1, target)
            end => v
            _ => nothing
        end
        res !== nothing && push!(matched, v)
    end
    return matched
end

"""
Replace symbols in ZXW Diagram with specific values
"""
function substitute_variables!(
    zxwd::ZXWDiagram{T,P},
    sbd::Dict{Symbol,<:Number},
) where {T,P}
    for (θ, val) in sbd
        for negative in [false, true]
            matched_pos = symbol_vertices(zxwd, θ; neg = negative)
            val = negative ? -val : val
            for idx in matched_pos
                p = spider_type(zxwd, idx).p
                @match p begin
                    PiUnit(pu, _) => set_phase!(zxwd, idx, Parameter(Val(:PiUnit), val))
                    Factor(pf, _) => set_phase!(zxwd, idx, Parameter(Val(:Factor), val))
                end
            end
        end
    end
    return zxwd
end

"""
Integrate over the Spiders at locs with respect to the parameter θ.

User need to check that the parameters are indeed in the form of k * θ where k is Int
"""
function integrate!(zxwd::ZXWDiagram{T,P}, locs::Vector{T}) where {T,P}
    length(locs) == 2 && return integrate2!(zxwd, locs[1], locs[2])
    length(locs) == 4 && return integrate4!(zxwd, locs[1], locs[2], locs[3], locs[4])
end

function integrate2!(zxwd::ZXWDiagram{T,P}, loc1::T, loc2::T) where {T,P}
    loc1 = int_prep!(zxwd, loc1)
    loc2 = int_prep!(zxwd, loc2)
    add_edge!(zxwd.mg, loc1, loc2)
    return zxwd
end

"""
Integrate two pairs of +/- parameter. Theorem 23 of https://arxiv.org/abs/2201.13250
"""
function integrate4!(zxwd::ZXWDiagram{T,P}, loca::T, locb::T, locc::T, locd::T) where {T,P}
    loca = int_prep!(zxwd, loca)
    locb = int_prep!(zxwd, locb)
    locc = int_prep!(zxwd, locc)
    locd = int_prep!(zxwd, locd)

    # a, b = + , - \theta
    # c, d = + , - \theta
    loca = add_spider!(zxwd, Z(Parameter(Val(:PiUnit), 0)), [loca])
    locb = add_spider!(zxwd, Z(Parameter(Val(:PiUnit), 0)), [locb])
    locc = add_spider!(zxwd, X(Parameter(Val(:PiUnit), 0)), [locc])
    locd = add_spider!(zxwd, X(Parameter(Val(:PiUnit), 0)), [locd])

    add_edge!(zxwd, loca, locc)
    add_edge!(zxwd, locb, locd)

    locm = add_spider!(zxwd, X(Parameter(Val(:PiUnit), 0)), [loca, locb])
    locm = add_spider!(zxwd, D, [locm])
    locm = add_spider!(zxwd, X(Parameter(Val(:PiUnit), π)), [locm])
    add_spider!(zxwd, X(Parameter(Val(:PiUnit), 0)), [locm, locc, locd])
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
