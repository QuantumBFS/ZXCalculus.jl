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
    nbits < 1 && error("We need to have at least one qubit in the system!")

    half_edges = Dict{T,HalfEdge}()
    for i = 1:2*nbits
        half_edges[i] = HalfEdge(i, iseven(i) ? (i - 1) : (i + 1))
    end
    for i = 1:(2*nbits-2)
        # edges connecting input qubits
        jj = i + 2 * nbits
        # edges connecting output qubits
        kk = i + 4 * nbits - 2
        if iseven(i)
            half_edges[jj] = HalfEdge(i - 1, i + 1)
            half_edges[kk] = HalfEdge(i, i + 2)
        else
            half_edges[jj] = HalfEdge(i + 2, i)
            half_edges[kk] = HalfEdge(i + 3, i + 1)
        end
    end

    he2f = Dict{T,T}()
    for i = 1:(6*nbits-4)
        if i == 2 || i == 2 * nbits - 1
            he2f[i] = 0
            continue
        end

        if i <= 2 * nbits
            if iseven(i)
                he2f[i] = div(i, 2) - 1
            else
                he2f[i] = div(i + 1, 2)
            end
            continue
        end

        if i <= 4 * nbits - 2
            if iseven(i)
                he2f[i] = 0
            else
                he2f[i] = (i - 2 * nbits + 1) ÷ 2
            end
            continue
        end

        if iseven(i)
            he2f[i] = div(i - 4 * nbits + 2, 2)
        else
            he2f[i] = 0
        end
    end

    next = Dict{T,T}()

    if nbits < 2
        next[1] = 2
        next[2] = 1
    else
        for i = 1:(6*nbits-4)
            if i <= 2 * nbits
                if isodd(i)
                    if i == 2 * nbits - 1
                        next[i] = 6 * nbits - 5
                    else
                        next[i] = i + (4 * nbits - 1)
                    end
                else
                    if i == 2
                        next[i] = 2 * nbits + 2
                    else
                        next[i] = i + 2 * nbits - 3
                    end
                end
                continue
            end

            if i <= 4 * nbits - 2
                if iseven(i)
                    if i == 4 * nbits - 2
                        next[i] = 2 * nbits - 1
                    else
                        next[i] = i + 2
                    end
                else
                    if i == 2 * nbits + 1
                        next[i] = 1
                    else
                        next[i] = i - 2 * nbits
                    end
                end
                continue
            end

            if iseven(i)
                next[i] = i - 4 * nbits + 4
            else
                if i == 4 * nbits - 1
                    next[i] = 2
                else
                    next[i] = i - 2
                end
            end
        end
    end

    pmg = PlanarMultigraph{T}(
        Dict([i => i for i = 1:2*nbits]), # v2he
        half_edges, # he_id -> HalfEdge
        Dict([[0 => 2]; [i => 2 * i - 1 for i = 1:nbits-1]]), # f2he
        he2f, # he_id -> f_id
        next,
        Dict([i => iseven(i) ? (i - 1) : (i + 1) for i = 1:(6*nbits-4)]),
        2 * nbits, # v_max
        6 * nbits - 4, # he_max
        nbits - 1,
        [0],
    )

    st = [i % 2 == 1 ? Input(div(i, 2) + 1) : Output(div(i, 2)) for i = 1:2*nbits]

    return ZWDiagram(pmg, st)
end

Base.copy(zwd::ZWDiagram{T,P}) where {T,P} = ZWDiagram{T,P}(
    copy(zwd.pmg),
    copy(zwd.st),
    copy(zwd.scalar),
    copy(zwd.inputs),
    copy(zwd.outputs),
)
