using ..ZX: ZX

function to_eincode(zxg::Union{ZX.ZXGraph, ZX.ZXCircuit})
    converted = ZX.simplify!(ZX.HEdgeRule(), copy(zxg))
    return to_eincode_only_regular_edges(converted)
end

to_eincode(zxd::ZX.ZXDiagram{T, P}) where {T, P} = to_eincode_only_regular_edges(zxd)

function to_eincode_only_regular_edges(zxd::ZX.AbstractZXDiagram{T, P}) where {T, P}
    tensors = []
    ixs = Vector{Tuple{T, T, T}}[]
    iy = Tuple{T, T, T}[]
    for (v, st) in ZX.spider_types(zxd)
        res = if st == ZX.SpiderType.Z
            z_tensor(degree(zxd, v), ZX.phase(zxd, v))
        elseif st == ZX.SpiderType.X
            x_tensor(degree(zxd, v), ZX.phase(zxd, v))
        elseif st == ZX.SpiderType.H
            h_tensor(degree(zxd, v))
        else
            nothing
        end

        if !isnothing(res)
            push!(ixs, to_eincode_indices(zxd, v))
            push!(tensors, res)
        end
    end

    for v in ZX.get_outputs(zxd)
        push!(iy, to_eincode_indices(zxd, v)[])
    end

    for v in ZX.get_inputs(zxd)
        push!(iy, to_eincode_indices(zxd, v)[])
    end

    scalar_tensor = zeros(ComplexF64, ())

    scalar_tensor[] = unwrap_scalar(ZX.scalar(zxd))
    push!(ixs, Tuple{T, T, T}[])
    push!(tensors, scalar_tensor)
    return EinCode(ixs, iy), tensors
end

function to_eincode_indices(zxwd::ZX.ZXDiagram{T, P}, v) where {T, P}
    nbs = neighbors(zxwd, v; count_mul=true)
    ids = Tuple{T, T, T}[]
    isempty(nbs) && return ids
    curr_nb = nbs[1]
    curr_mul = 1
    for nb in nbs
        if nb != curr_nb
            curr_nb = nb
            curr_mul = 1
        end
        if nb == v
            push!(ids, edge_index(v, nb, (curr_mul + 1) ÷ 2))
        else
            push!(ids, edge_index(v, nb, curr_mul))
        end
        curr_mul += 1
    end
    return ids
end

function to_eincode_indices(zxwd::Union{ZX.ZXGraph, ZX.ZXCircuit}, v)
    nbs = neighbors(zxwd, v)
    ids = [edge_index(v, nb) for nb in nbs]
    return ids
end

z_tensor(n::Int, p::ZX.Phase) = z_tensor(n, exp(im * pi * p.ex))
x_tensor(n::Int, p::ZX.Phase) = x_tensor(n, exp(im * pi * p.ex))

matrix_shape(zxg::ZX.AbstractZXDiagram) = (1 << ZX.nin(zxg), 1 << ZX.nout(zxg))
