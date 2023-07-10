# provide differentiation capability on ZX Diagram
# for the brain free method, i.e not limited to expectation
# value of a circuit, just pickout the spiders that has the correct parameter
# and do the differentiation
# for the simplified version, you will need to check and make sure
# the ZX Diagram is representing dag(U)H U

function partial_diff(zxwd::ZXWDiagram{T,P}, θ::Symbol) where {T,P}
    # I need to first return the indices of Z / X spiders that has the parameter \theta
    vs = symbol_vertices(zxwd, θ)
    w_trig_vs = T[]
    for v in vs
        x_v = add_spider!(zxwd, X(Parameter(Val(:PiUnit),1.0)), v)
        w_v = add_spider!(zxwd, D, x_v )
        frac_v = @match spider_type(zxwd, v).p begin
            # don't know how to take derivative of Symbol
            # need to change later
            PiUnit(pu,_) => add_spider!(zxwd, Z(Parameter(Val(:Factor), im * π)),w_v)
            Factor(f,_) => add_spider!(zxwd, Z(Parameter(Val(:Factor), 1 // θ)),w_v)
            _ => error("not a valid parameter")
        end
        push!(w_trig_vs, frac_v)
    end

    for wv in w_trig_vs
        # need to connect to w triangles
    end
end

function symbol_vertices(zxwd::ZXWDiagram{T,P}, θ::Symbol) where {T,P}
    matched = T[]
    for v in vertices(zxwd.mg)
        res = @match spider_type(zxwd, v) begin
            Z(p1) && if p1 == θ
            end => v
            X(p1) && if p1 == θ
            end => v
            _ => nothing
        end
        res !== nothing && push!(matched, v)
    end
    return matched
end
