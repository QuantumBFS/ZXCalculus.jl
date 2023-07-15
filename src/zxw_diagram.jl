@adt public ZXWSpiderType begin

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
    ZXWDiagram{T, P}

This is the type for representing ZXW-diagrams.
"""

struct ZXWDiagram{T<:Integer,P}
    mg::Multigraph{T}

    st::Dict{T,ZXWSpiderType}

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

"""
    ZXWDiagram(
        mg::Multigraph{T},
        st::Dict{T,ZXWSpiderType}) where {T}

    ZXWDiagram(
        mg::Multigraph{T},
        st::Vector{ZXWSpiderType}) where {T}

Construct a ZXW-diagram for a given multigraph, spider types, and, phases.
"""

ZXWDiagram(mg::Multigraph{T}, st::Dict{T,ZXWSpiderType}, P::Type = Rational) where {T} =
    ZXWDiagram{T,P}(mg, st)


ZXWDiagram(mg::Multigraph{T}, st::Vector{ZXWSpiderType}, P::Type = Rational) where {T} =
    ZXWDiagram{T,P}(mg, Dict(zip(sort!(vertices(mg)), st)))

"""
    ZXWDiagram(nbits)

Construct a ZXWDiagram of empty circuit with `nbits` qubits.
"""

function ZXWDiagram(nbits::T) where {T<:Integer}
    mg = Multigraph(2 * nbits)
    st = [i % 2 == 1 ? Input(div(i, 2) + 1) : Output(div(i, 2)) for i = 1:2*nbits]

    for i = 1:nbits
        add_edge!(mg, 2 * i - 1, 2 * i)
    end
    return ZXWDiagram(mg, st)
end


Base.copy(zxwd::ZXWDiagram{T,P}) where {T,P} = ZXWDiagram{T,P}(
    copy(zxwd.mg),
    copy(zxwd.st),
    copy(zxwd.scalar),
    copy(zxwd.inputs),
    copy(zxwd.outputs),
)

function dagger(zxwd::ZXWDiagram{T,P}) where {T,P}
    zxwd_dg = copy(zxwd)
    for v in vertices(zxwd_dg.mg)
        @match zxwd_dg.st[v] begin
            Input(q) => (zxwd_dg.st[v] = Output(q))
            Output(q) => (zxwd_dg.st[v] = Input(q))
            Z(p) => (zxwd_dg.st[v] = Z(inv(p)))
            X(p) => (zxwd_dg.st[v] = X(inv(p)))
            W => nothing
            H => nothing
            D => nothing
        end
    end
    return zxwd_dg
end
