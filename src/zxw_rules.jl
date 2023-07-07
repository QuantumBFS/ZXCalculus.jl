@adt ZXWRule begin
    # adopting convention @ arXiv:2201.13250
    s1
    s2
end

function Base.match(r::ZXWRule, zxwd::ZXWDiagram{T,P}) where {T,P}
    @match r begin
        s1 => s1_match(zxwd)
        s2 => s2_match(zxwd)
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
            res = @match (v1, v2) begin
                (Z(_), Z(_)) && v2 >= v1 => Match{T}([v1, v2])
                (X(_), X(_)) && v2 >= v1 => Match{T}([v1, v2])
                _ => nothing
            end
            match === nothing || push!(matches, res)
        end
    end
    return matches
end

function s2_match(zxwd::ZXWDiagram{T,P}) where {T,P}
    matches = Match{T}[]
    for v1 in spiders(zxwd)
        degree(zxwd, v1) != 2 && continue
        res = @match v1 begin
            Z(p1) && p1 == zero(p1) => Match{T}([v1])
            X(p1) && p1 == zero(p1) => Match{T}([v1])
            _ => nothing
        end
    end
    return matches
end
