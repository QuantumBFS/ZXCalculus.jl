struct ZWDiagram{T<:Integer,P}
    pmg::PlanarMultigraph{T}

    st::Dict{T,ZWSpiderType}

    scalar::Scalar{P}
    inputs::Vector{T}
    outputs::Vector{T}
    # what else shoud I maintian
    # 1. locations / numbers of SWAP, monoZ?

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

ZWDiagram(
    pmg::PlanarMultigraph{T},
    st::Dict{T,ZWSpiderType},
    P::Type = Rational,
) where {T} = ZWDiagram{T,P}(pmg, st)

ZWDiagram(
    pmg::PlanarMultigraph{T},
    st::Vector{ZWSpiderType},
    P::Type = Rational,
) where {T} = ZWDiagram{T,P}(pmg, Dict(zip(sort!(vertices(pmg)), st)))

function ZWDiagram(nbits::T) where {T<:Integer}
    pmg = PlanarMultigraph{T}()

    st = [i % 2 == 1 ? Input(div(i, 2) + 1) : Output(div(i, 2)) for i = 1:2*nbits]

    return ZWDiagram{T,Rational}(pmg, st)
end

Base.copy(zwd::ZWDiagram{T,P}) where {T,P} = ZWDiagram{T,P}(
    copy(zwd.pmg),
    copy(zwd.st),
    copy(zwd.scalar),
    copy(zwd.inputs),
    copy(zwd.outputs),
)
