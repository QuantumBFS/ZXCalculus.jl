@adt public ZWSpiderType begin


    # I add more types like edge nodes
    W
    H
    D

    struct Z
        p::Parameter
    end

    struct X
        p::Parameter
    end

    struct Input
        qubit::Int
    end

    struct Output
        qubit::Int
    end
end
"""
    PWDiagram{T, P}

This is the type for representing planar-diagrams.
"""
struct PWDiagram{T<:Integer,P}
    # better as directed weighted graph?
    mg::Multigraph{T}

    st::Dict{T,ZXWSpiderType}

    vtx_order::Vector{T}
    scalar::Scalar{P}
    inputs::Vector{T}
    outputs::Vector{T}

    function ZXWDiagram{T,P}(
        mg::Multigraph{T},
        st::Dict{T,ZXWSpiderType},
        s::Scalar{P} = Scalar{P}(),
        inputs::Vector{T} = Vector{T}(),
        outputs::Vector{T} = Vector{T}(),
    ) where {T<:Integer,P}
        nv(mg) != length(st) && error("There should be a type for each spider!")

        if length(inputs) == 0
            inputs = sort!([@match st[v] begin
                Input(_) => v
                _ => -1
            end for v in vertices(mg)])
            inputs = [i for i in inputs if i != -1]
        end

        if length(outputs) == 0
            outputs = sort!([@match st[v] begin
                Output(_) => v
                _ => -1
            end for v in vertices(mg)])
            outputs = [i for i in outputs if i != -1]
        end

        zxwd = new{T,P}(mg, st, s, inputs, outputs)
        round_phases!(zxwd)
        return zxwd

    end
end
