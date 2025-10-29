# Circuit Composition Operations for ZXDiagram (Legacy)

"""
    $(TYPEDSIGNATURES)

Add non input and output spiders of d2 to d1, modify d1. Record the mapping of vertex indices.
"""
function import_non_in_out!(
        d1::ZXDiagram{T, P},
        d2::ZXDiagram{T, P},
        v2tov1::Dict{T, T}
) where {T, P}
    for v2 in vertices(d2.mg)
        st = spider_type(d2, v2)
        if st == SpiderType.In || st == SpiderType.Out
            new_v = nothing
            # FIXME why is Out = H ?
        elseif st == SpiderType.Z || st == SpiderType.X || st == SpiderType.H
            new_v = add_vertex!(d1.mg)[1]
        else
            throw(ArgumentError("Unknown spider type $(d2.st[v2])"))
        end
        if !isnothing(new_v)
            v2tov1[v2] = new_v
            d1.st[new_v] = spider_type(d2, v2)
            d1.ps[new_v] = d2.ps[v2]
            d1.phase_ids[new_v] = (v2, 1)
        end
    end
end

"""
    $(TYPEDSIGNATURES)

Import edges of d2 to d1, modify d1
"""
function import_edges!(d1::ZXDiagram{T, P}, d2::ZXDiagram{T, P}, v2tov1::Dict{T, T}) where {T, P}
    for edge in edges(d2.mg)
        src, dst, emul = edge.src, edge.dst, edge.mul
        add_edge!(d1.mg, v2tov1[src], v2tov1[dst], emul)
    end
end

"""
    $(TYPEDSIGNATURES)

Appends two diagrams, where the second diagram is inverted
"""
function concat!(zxd_1::ZXDiagram{T, P}, zxd_2::ZXDiagram{T, P})::ZXDiagram{T, P} where {T, P}
    nqubits(zxd_1) == nqubits(zxd_2) || throw(
        ArgumentError(
        "number of qubits need to be equal, go  $(nqubits(zxd_1)) and $(nqubits(zxd_2))",
    ),
    )

    v2tov1 = Dict{T, T}()
    import_non_in_out!(zxd_1, zxd_2, v2tov1)

    for i in 1:nout(zxd_1)
        out_idx = get_output_idx(zxd_1, i)
        # output spiders cannot be connected to multiple vertices or with multiedge
        prior_vtx = neighbors(zxd_1, out_idx)[1]
        rem_edge!(zxd_1, out_idx, prior_vtx)
        # zxd_2 input vtx idx is mapped to the vtx prior to zxd_1 output
        v2tov1[get_input_idx(zxd_2, i)] = prior_vtx
    end

    for i in 1:nout(zxd_2)
        v2tov1[get_output_idx(zxd_2, i)] = get_output_idx(zxd_1, i)
    end

    import_edges!(zxd_1, zxd_2, v2tov1)
    add_global_phase!(zxd_1, zxd_2.scalar.phase)
    add_power!(zxd_1, zxd_2.scalar.power_of_sqrt_2)

    return zxd_1
end

"""
    stype_to_val(st)::Union{SpiderType,nothing}

Converts SpiderType into Val
"""
function stype_to_val(st)::Val
    if st == SpiderType.Z
        Val{:Z}()
    elseif st == SpiderType.X
        Val{:X}()
    elseif st == SpiderType.H
        Val{:H}()
    else
        throw(ArgumentError("$st has no corresponding SpiderType"))
    end
end

"""
    $(TYPEDSIGNATURES)

Dagger of a ZXDiagram by swapping input and outputs and negating the values of the phases
"""
function dagger(zxd::ZXDiagram{T, P})::ZXDiagram{T, P} where {T, P}
    ps_i = Dict([k => -v for (k, v) in phases(zxd)])
    zxd_dg = ZXDiagram{T, P}(
        copy(zxd.mg),
        copy(zxd.st),
        ps_i,
        copy(zxd.layout),
        deepcopy(zxd.phase_ids),
        copy(zxd.scalar),
        copy(zxd.outputs),
        copy(zxd.inputs),
        false
    )
    for v in vertices(zxd_dg.mg)
        value = zxd_dg.st[v]
        if value == SpiderType.In
            zxd_dg.st[v] = SpiderType.Out
        elseif (value == SpiderType.Out)
            zxd_dg.st[v] = SpiderType.In
        end
    end
    return zxd_dg
end
