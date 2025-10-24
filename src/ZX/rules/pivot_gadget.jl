struct PivotGadgetRule <: AbstractRule end

function rewrite!(::PivotGadgetRule, zxg::ZXGraph{T, P}, vs::Vector{T}) where {T, P}
    # This rule should be only used in circuit extraction.
    # This rule will do pivoting on u, v but preserve u, v.
    # And the scalars are not considered in this rule.
    # gadget_u is the non-Clifford spider
    u, gadget_u, v = vs
    phase_u = phase(zxg, u)
    phase_v = phase(zxg, v)

    for v0 in neighbors(zxg, v)
        if spider_type(zxg, v0) != SpiderType.Z
            if is_hadamard(zxg, v0, v)
                v1 = insert_spider!(zxg, v0, v)
                insert_spider!(zxg, v0, v1)
            else
                insert_spider!(zxg, v0, v)
            end
            break
        end
    end

    nb_u = setdiff(neighbors(zxg, u), [v, gadget_u])
    nb_v = setdiff(neighbors(zxg, v), [u])

    U = setdiff(nb_u, nb_v)
    V = setdiff(nb_v, nb_u)
    W = intersect(nb_u, nb_v)
    add_power!(zxg, length(U)*length(V) + length(V)*length(W) + length(W)*length(U))

    phase_gadget_u = phase(zxg, gadget_u)
    if !is_zero_phase(Phase(phase_u))
        phase_gadget_u = -phase(zxg, gadget_u)
    end

    for u0 in U, v0 in V

        add_edge!(zxg, u0, v0)
    end
    for u0 in U, w0 in W

        add_edge!(zxg, u0, w0)
    end
    for v0 in V, w0 in W

        add_edge!(zxg, v0, w0)
    end

    for w0 in W
        set_phase!(zxg, w0, phase(zxg, w0)+1)
    end

    set_phase!(zxg, v, phase_gadget_u)

    rem_spider!(zxg, gadget_u)
    return zxg
end

function rewrite!(::PivotGadgetRule, circ::ZXCircuit{T, P}, vs::Vector{T}) where {T, P}
    u, gadget_u, v = vs
    zxg = circ

    if is_one_phase(phase(zxg, u))
        @assert flip_phase_tracking_sign!(circ, gadget_u) "failed to flip phase tracking sign for $gadget_u"
    end
    phase_id_gadget_u = zxg.phase_ids[gadget_u]

    # TODO: verify if needed
    zxg.phase_ids[v] = phase_id_gadget_u
    zxg.phase_ids[u] = (u, 1)

    rewrite!(PivotGadgetRule(), circ.zx_graph, vs)
    return circ
end