using ZXCalculus: contains, dagger, concat!

"""
Take derivative of ZXWDiagram with respect to a parameter

Assuming Spiders have Parameter of type PiUnit which is parameterized purely by θ
"""
function diff_diagram(zxwd::ZXWDiagram{T,P}, θ::Symbol) where {T,P}
    add_global_phase!(zxwd, P(π / 2))
    vs = symbol_vertices(zxwd, θ)
    w_trig_vs = T[]
    for v in vs
        x_v = add_spider!(zxwd, X(Parameter(Val(:PiUnit), 1.0)), [v])
        w_v = add_spider!(zxwd, D, [x_v])
        frac_v = @match spider_type(zxwd, v).p begin
            PiUnit(pu, _) && if !(pu == θ)
            end => add_spider!(zxwd, Z(Parameter(Val(:Factor), π)), [w_v])
            PiUnit(pu, _) && if pu == θ
            end => w_v
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
function symbol_vertices(zxwd::ZXWDiagram{T,P}, θ::Symbol) where {T,P}

    matched = T[]
    for v in vertices(zxwd.mg)
        res = @match spider_type(zxwd, v) begin
            Z(p1) && if contains(p1, θ)
            end => v
            X(p1) && if contains(p1, θ)
            end => v
            _ => nothing
        end
        res !== nothing && push!(matched, v)
    end
    return matched
end
