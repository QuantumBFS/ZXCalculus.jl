struct Pivot1Rule <: AbstractRule end

function Base.match(::Pivot1Rule, zxg::ZXGraph{T, P}) where {T, P}
    matches = Match{T}[]
    vs = spiders(zxg)
    vB = [get_inputs(zxg); get_outputs(zxg)]
    for i in 1:length(vB)
        push!(vB, neighbors(zxg, vB[i])[1])
    end
    sort!(vB)
    for v1 in vs
        if spider_type(zxg, v1) == SpiderType.Z && length(searchsorted(vB, v1)) == 0 &&
           is_pauli_phase(phase(zxg, v1))
            for v2 in neighbors(zxg, v1)
                if spider_type(zxg, v2) == SpiderType.Z && length(searchsorted(vB, v2)) == 0 &&
                   is_pauli_phase(phase(zxg, v2)) && v2 > v1
                    push!(matches, Match{T}([v1, v2]))
                end
            end
        end
    end
    return matches
end

function check_rule(::Pivot1Rule, zxg::ZXGraph{T, P}, vs::Vector{T}) where {T, P}
    v1, v2 = vs
    (has_vertex(zxg.mg, v1) && has_vertex(zxg.mg, v2)) || return false
    if has_vertex(zxg.mg, v1)
        if spider_type(zxg, v1) == SpiderType.Z && is_interior(zxg, v1) &&
           is_pauli_phase(phase(zxg, v1))
            if v2 in neighbors(zxg, v1)
                if spider_type(zxg, v2) == SpiderType.Z && is_interior(zxg, v2) &&
                   is_pauli_phase(phase(zxg, v2)) && v2 > v1
                    return true
                end
            end
        end
    end
    return false
end

function rewrite!(::Pivot1Rule, zxg::ZXGraph{T, P}, vs::Vector{T}) where {T, P}
    u, v = vs
    phase_u = phase(zxg, u)
    phase_v = phase(zxg, v)
    add_global_phase!(zxg, phase_u*phase_v)
    nb_u = setdiff(neighbors(zxg, u), [v])
    nb_v = setdiff(neighbors(zxg, v), [u])

    U = setdiff(nb_u, nb_v)
    V = setdiff(nb_v, nb_u)
    W = intersect(nb_u, nb_v)
    add_power!(zxg, (length(U)+length(V)-2)*length(W) + (length(U)-1)*(length(V)-1))

    rem_spiders!(zxg, vs)
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
    for v0 in V
        set_phase!(zxg, v0, phase(zxg, v0)+phase_u)
    end
    for w0 in W
        set_phase!(zxg, w0, phase(zxg, w0)+phase_u+phase_v+1)
    end
    return zxg
end
