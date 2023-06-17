
"""
    ZXWDiagram{T, P}

This is the type for representing ZXW-diagrams.
"""

struct ZXWDiagram{T<:Integer,P} <: AbstractZXDiagram{T,P}
    mg::Multigraph{T}

    st::Dict{T,SpiderType.SType}
    ps::Dict{T,P}

    layout::ZXLayout{T}

    scalar::Scalar{P}
    inputs::Vector{T}
    outputs::Vector{T}

    function ZXWDiagram{T,P}(
        mg::Multigraph{T},
        st::Dict{T,SpiderType.SType},
        ps::Dict{T,P},
        layout::ZXLayout{T},
        s::Scalar{P} = Scalar{P}(),
        # inputs::Vector{T} = Vector{T}(), let constructor take care
        # outputs::Vector{T} = Vector{T}(), need to pass in layout anyways
    ) where {T<:Integer,P}
        nv(mg) != length(ps) && error("There should be a phase for each spider!")
        nv(mg) != length(st) && error("There should be a type for each spider!")

        inputs = [v for v in vertices(mg) if st[v] == SpiderType.In]
        if layout.nbits > 0
            sort!(inputs, by = (v -> qubit_loc(layout, v)))
        end

        outputs = [v for v in vertices(mg) if st[v] == SpiderType.Out]
        if layout.nbits > 0
            sort!(outputs, by = (v -> qubit_loc(layout, v)))
        end

        zxwd = new{T,P}(mg, st, ps, layout, s)
        round_phases!(zxwd)
        return zxwd

    end
end

ZXWDiagram(
    mg::Multigraph{T},
    st::Dict{T,SpiderType.SType},
    ps::Dict{T,P},
    layout::ZXLayout{T} = ZXLayout{T}(),
) where {T,P} = ZXWDiagram{T,P}(mg, st, ps, layout)


ZXWDiagram(
    mg::Multigraph{T},
    st::Vector{SpiderType.SType},
    ps::Vector{P},
    layout::ZXLayout{T} = ZXLayout{T}(),
) where {T,P} = ZXWDiagram(
    mg,
    Dict(zip(sort!(vertices(mg)), st)),
    Dict(zip(sort!(vertices(mg)), ps)),
    layout,
)

function round_phases!(zxwd::ZXWDiagram{T,P}) where {T<:Integer,P}
    ps = zxwd.ps
    for v in keys(ps)
        while ps[v] < 0
            ps[v] += 2
        end
        ps[v] = rem(ps[v], 2)
    end
    return
end
