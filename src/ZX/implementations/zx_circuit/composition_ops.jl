# Circuit Composition Operations for ZXCircuit

using DocStringExtensions

"""
    $(TYPEDSIGNATURES)

Add non-input and non-output spiders of circ2 to circ1, modifying circ1.

Records the mapping of vertex indices from circ2 to circ1.
"""
function import_non_in_out!(
        circ1::ZXCircuit{T, P},
        circ2::ZXCircuit{T, P},
        v2tov1::Dict{T, T}
) where {T, P}
    zxg1 = circ1.zx_graph
    zxg2 = circ2.zx_graph

    for v2 in spiders(zxg2)
        st = spider_type(zxg2, v2)
        if st == SpiderType.In || st == SpiderType.Out
            new_v = nothing
        elseif st == SpiderType.Z || st == SpiderType.X || st == SpiderType.H
            new_v = add_spider!(zxg1, st, phase(zxg2, v2))
        else
            throw(ArgumentError("Unknown spider type $(st)"))
        end
        if !isnothing(new_v)
            v2tov1[v2] = new_v
        end
    end
end

"""
    $(TYPEDSIGNATURES)

Import edges of circ2 to circ1, modifying circ1.
"""
function import_edges!(circ1::ZXCircuit{T, P}, circ2::ZXCircuit{T, P}, v2tov1::Dict{T, T}) where {T, P}
    zxg1 = circ1.zx_graph
    zxg2 = circ2.zx_graph

    for v2_src in spiders(zxg2)
        for v2_dst in neighbors(zxg2, v2_src)
            if v2_dst > v2_src && haskey(v2tov1, v2_src) && haskey(v2tov1, v2_dst)
                v1_src = v2tov1[v2_src]
                v1_dst = v2tov1[v2_dst]
                et = edge_type(zxg2, v2_src, v2_dst)
                add_edge!(zxg1, v1_src, v1_dst, et)
            end
        end
    end
end

"""
    $(TYPEDSIGNATURES)

Concatenate two ZX-circuits, where the second circuit is appended after the first.

The circuits must have the same number of qubits. The outputs of the first circuit
are connected to the inputs of the second circuit.

Returns the modified first circuit.
"""
function concat!(circ1::ZXCircuit{T, P}, circ2::ZXCircuit{T, P})::ZXCircuit{T, P} where {T, P}
    @assert nqubits(circ1) == nqubits(circ2) "number of qubits need to be equal, got $(nqubits(circ1)) and $(nqubits(circ2))"
    @assert isnothing(circ1.master) && isnothing(circ2.master) "Concatenation of a circuit with a master circuit is not supported."

    v2tov1 = Dict{T, T}()
    import_non_in_out!(circ1, circ2, v2tov1)

    zxg1 = circ1.zx_graph

    # Connect outputs of circ1 to inputs of circ2
    for i in 1:length(circ1.outputs)
        out_idx = circ1.outputs[i]
        # Output spiders should be connected to exactly one vertex
        prior_vtx = neighbors(zxg1, out_idx)[1]
        rem_edge!(zxg1, out_idx, prior_vtx)
        # Map circ2's input to the vertex prior to circ1's output
        v2tov1[circ2.inputs[i]] = prior_vtx
    end

    # Map circ2's outputs to circ1's outputs
    for i in 1:length(circ2.outputs)
        v2tov1[circ2.outputs[i]] = circ1.outputs[i]
    end

    import_edges!(circ1, circ2, v2tov1)

    # Add scalar factors
    add_global_phase!(zxg1, scalar(circ2.zx_graph).phase)
    add_power!(zxg1, scalar(circ2.zx_graph).power_of_sqrt_2)

    return circ1
end

"""
    $(TYPEDSIGNATURES)

Compute the dagger (adjoint) of a ZX-circuit.

This swaps inputs and outputs and negates all phases. The dagger operation
corresponds to the adjoint of the quantum operation represented by the circuit.

Returns a new ZX-circuit representing the adjoint operation.
"""
function dagger(circ::ZXCircuit{T, P})::ZXCircuit{T, P} where {T, P}
    @assert isnothing(circ.master) "Dagger of a circuit with a master circuit is not supported."
    zxg = circ.zx_graph

    # Negate all phases
    ps_new = Dict{T, P}()
    for v in spiders(zxg)
        ps_new[v] = -phase(zxg, v)
    end

    # Swap spider types for In/Out
    st_new = Dict{T, SpiderType.SType}()
    for v in spiders(zxg)
        st = spider_type(zxg, v)
        if st == SpiderType.In
            st_new[v] = SpiderType.Out
        elseif st == SpiderType.Out
            st_new[v] = SpiderType.In
        else
            st_new[v] = st
        end
    end

    # Create new graph with negated phases and swapped spider types
    zxg_new = ZXGraph{T, P}(
        copy(zxg.mg),
        ps_new,
        st_new,
        copy(zxg.et),
        copy(zxg.scalar)
    )

    # Create new circuit with swapped inputs/outputs
    return ZXCircuit(
        zxg_new,
        copy(circ.outputs),  # Swap: outputs become inputs
        copy(circ.inputs),   # Swap: inputs become outputs
        copy(circ.layout),
        deepcopy(circ.phase_ids),
        isnothing(circ.master) ? nothing : dagger(circ.master)
    )
end
