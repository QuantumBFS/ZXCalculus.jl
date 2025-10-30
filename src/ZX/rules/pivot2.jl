"""
    $(TYPEDEF)

The pivoting rule that convert an internal non-Clifford `u` Z-spider connected to an internal Pauli Z-spider `v` into a phase gadget. Requirements:

  - The internal non-Clifford spider must have at least two neighbors (not a part of the phase gadget).
  - The internal Pauli spider must be connected to the internal non-Clifford spider via a Hadamard edge.
"""
struct Pivot2Rule <: AbstractRule end

function Base.match(::Pivot2Rule, zxg::ZXGraph{T, P}) where {T, P}
    matches = Match{T}[]
    vs = spiders(zxg)
    vB = [get_inputs(zxg); get_outputs(zxg)]
    for i in 1:length(vB)
        push!(vB, neighbors(zxg, vB[i])[1])
    end
    sort!(vB)
    gadgets = T[]
    for g in vs
        if spider_type(zxg, g) == SpiderType.Z && length(neighbors(zxg, g)) == 1
            push!(gadgets, g, neighbors(zxg, g)[1])
        end
    end
    sort!(gadgets)

    v_matched = T[]

    for u in vs
        if spider_type(zxg, u) == SpiderType.Z && length(searchsorted(vB, u)) == 0 &&
           (degree(zxg, u)) > 1 && !is_clifford_phase(phase(zxg, u)) &&
           length(neighbors(zxg, u)) > 1 && u ∉ v_matched
            for v in neighbors(zxg, u)
                if spider_type(zxg, v) == SpiderType.Z &&
                   length(searchsorted(vB, v)) == 0 &&
                   is_pauli_phase(phase(zxg, v))
                    if length(searchsorted(gadgets, v)) == 0 && v ∉ v_matched && is_hadamard(zxg, u, v)
                        push!(matches, Match{T}([u, v]))
                        push!(v_matched, u, v)
                    end
                end
            end
        end
    end
    return matches
end

function check_rule(::Pivot2Rule, zxg::ZXGraph{T, P}, vs::Vector{T}) where {T, P}
    u, v = vs
    if has_vertex(zxg.mg, u)
        if spider_type(zxg, u) == SpiderType.Z && is_interior(zxg, u) &&
           (degree(zxg, u)) > 1 && !is_clifford_phase(phase(zxg, u)) &&
           length(neighbors(zxg, u)) > 1
            if v in neighbors(zxg, u)
                if spider_type(zxg, v) == SpiderType.Z && is_interior(zxg, v) &&
                   is_pauli_phase(phase(zxg, v))
                    if all(length(neighbors(zxg, w)) > 1 for w in neighbors(zxg, v))
                        return is_hadamard(zxg, u, v)
                    end
                end
            end
        end
    end
    return false
end

function rewrite!(::Pivot2Rule, zxg::ZXGraph{T, P}, vs::Vector{T}) where {T, P}
    # u has non-Clifford phase
    u, v = vs
    phase_u = phase(zxg, u)
    phase_v = phase(zxg, v)
    nb_u = setdiff(neighbors(zxg, u), [v])
    nb_v = setdiff(neighbors(zxg, v), [u])

    U = setdiff(nb_u, nb_v)
    V = setdiff(nb_v, nb_u)
    W = intersect(nb_u, nb_v)
    add_power!(zxg, (length(U)+length(V)-1)*length(W) + length(U)*(length(V)-1))

    sgn_phase_v = is_zero_phase(Phase(phase_v)) ? 1 : -1

    rem_spider!(zxg, u)
    for u0 in U, v0 in V

        add_edge!(zxg, u0, v0)
    end
    for u0 in U, w0 in W

        add_edge!(zxg, u0, w0)
    end
    for v0 in V, w0 in W

        add_edge!(zxg, v0, w0)
    end
    for u0 in U
        set_phase!(zxg, u0, phase(zxg, u0)+phase_v)
    end
    for w0 in W
        set_phase!(zxg, w0, phase(zxg, w0)+phase_v+1)
    end
    gad = add_spider!(zxg, SpiderType.Z, P(sgn_phase_v*phase_u))
    add_edge!(zxg, v, gad)
    set_phase!(zxg, v, zero(P))

    return zxg, gad
end

function rewrite!(::Pivot2Rule, circ::ZXCircuit{T, P}, vs::Vector{T}) where {T, P}
    u, v = vs

    if is_one_phase(phase(circ, v))
        @assert flip_phase_tracking_sign!(circ, u) "failed to flip phase tracking sign for $u"
    end
    phase_id_u = circ.phase_ids[u]
    _, gad = rewrite!(Pivot2Rule(), circ.zx_graph, vs)

    circ.phase_ids[gad] = phase_id_u
    # TODO: verify why phase id of v is assigned (v, 1)
    circ.phase_ids[v] = (v, 1)
    delete!(circ.phase_ids, u)
    return circ
end

# TODO: fix scalar tracking