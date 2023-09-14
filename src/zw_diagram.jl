struct ZWDiagram{T<:Integer,P}
    pmg::PlanarMultigraph{T}

    st::Dict{T,ZWSpiderType}

    scalar::Scalar{P}
    inputs::Vector{T}
    outputs::Vector{T}

    function ZWDiagram{T,P}(
        pmg::PlanarMultigraph{T},
        st::Dict{T,ZWSpiderType},
        s::Scalar{P} = Scalar{P}(),
        inputs::Vector{T} = Vector{T}(),
        outputs::Vector{T} = Vector{T}(),
    ) where {T<:Integer,P}
        nv(pmg) != length(st) && error("There should be a type for each spider!")

        if length(inputs) == 0
            inputs = sort!([@match st[v] begin
                Input(_) => v
                _ => -1
            end for v in vertices(pmg)])
            inputs = [i for i in inputs if i != -1]
        end

        if length(outputs) == 0
            outputs = sort!([@match st[v] begin
                Output(_) => v
                _ => -1
            end for v in vertices(pmg)])
            outputs = [i for i in outputs if i != -1]


            zwd = new{T,P}(pmg, st, s, inputs, outputs)
            round_phases!(zwd)
            return zwd
        end
    end
end
