module ZXWSpiderType
@enum SType Z X H W D In Out
end # module for ZXW Spider Types

"""
    ZXWDiagram{T, P}

This is the type for representing ZXW-diagrams.
"""

struct ZXWDiagram{T<:Integer,P} <: AbstractZXDiagram{T,P}
    mg::Multigraph{T}

    st::Dict{T,ZXWSpiderType.SType}
    ps::Dict{T,P}

    scalar::Scalar{P}
    inputs::Vector{T}
    outputs::Vector{T}

    function ZXWDiagram{T,P}(
        mg::Multigraph{T},
        st::Dict{T,ZXWSpiderType.SType},
        ps::Dict{T,P},
        s::Scalar{P} = Scalar{P}(),
        inputs::Vector{T} = Vector{T}(),
        outputs::Vector{T} = Vector{T}(),
    ) where {T<:Integer,P}
        nv(mg) != length(ps) && error("There should be a phase for each spider!")
        nv(mg) != length(st) && error("There should be a type for each spider!")

        if length(inputs) == 0
            inputs = sort!([v for v in vertices(mg) if st[v] == ZXWSpiderType.In])
        end

        if length(outputs) == 0
            outputs = sort!([v for v in vertices(mg) if st[v] == ZXWSpiderType.Out])
        end

        zxwd = new{T,P}(mg, st, ps, s, inputs, outputs)
        round_phases!(zxwd)
        return zxwd

    end
end

"""
    ZXWDiagram(
        mg::Multigraph{T},
        st::Dict{T,ZXWSpiderType.SType},
        ps::Dict{T,P},) where {T,P}

    ZXWDiagram(
        mg::Multigraph{T},
        st::Vector{ZXWSpiderType.SType},
        ps::Vector{P},) where {T,P}

Construct a ZXW-diagram for a given multigraph, spider types, and, phases.
"""

ZXWDiagram(mg::Multigraph{T}, st::Dict{T,ZXWSpiderType.SType}, ps::Dict{T,P}) where {T,P} =
    ZXWDiagram{T,P}(mg, st, ps)


ZXWDiagram(mg::Multigraph{T}, st::Vector{ZXWSpiderType.SType}, ps::Vector{P}) where {T,P} =
    ZXWDiagram(mg, Dict(zip(sort!(vertices(mg)), st)), Dict(zip(sort!(vertices(mg)), ps)))

"""
    ZXWDiagram(nbits)

Construct a ZXWDiagram of empty circuit with `nbits` qubits.
"""

function ZXWDiagram(nbits::T) where {T<:Integer}
    mg = Multigraph(2 * nbits)
    st = [ZXWSpiderType.In for _ = 1:2*nbits]
    ps = [Phase(0 // 1) for _ = 1:2*nbits]

    for i = 1:nbits
        add_edge!(mg, 2 * i - 1, 2 * i)
        @inbounds st[2*i] = ZXWSpiderType.Out
    end
    return ZXWDiagram(mg, st, ps)
end


Base.copy(zxwd::ZXWDiagram{T,P}) where {T,P} = ZXWDiagram{T,P}(
    copy(zxwd.mg),
    copy(zxwd.st),
    copy(zxwd.ps),
    copy(zxwd.scalar),
    copy(zxwd.inputs),
    copy(zxwd.outputs),
)
