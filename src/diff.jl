# provide differentiation capability on ZX Diagram
# for the brain free method, i.e not limited to expectation
# value of a circuit, just pickout the spiders that has the correct parameter
# and do the differentiation
# for the simplified version, you will need to check and make sure
# the ZX Diagram is representing dag(U)H U

function partial_diff(zxwd::ZXWDiagram{T,P}, θ::Symbol) where {T,P}
    # I need to first return the indices of Z / X spiders that has the parameter \theta

end

function symbol_vertices(zxwd::ZXWDiagram{T,P}, θ::Symbol) where {T,P}
    vertices = [T]
    for v in vertices(zxwd)
        res = @match spider_type(zxwd, v) begin
            Z(p1) && if p1 == θ
            end => v
            X(p1) && if p1 == θ
            end => v
            _ => nothing
        end
        res !== nothing && push!(vertices, v)
end
