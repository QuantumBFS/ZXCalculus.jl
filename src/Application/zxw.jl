using ..ZXW: ZXW, Z, X, W, H, D, Input, Output
using ..Utils: PiUnit, Factor, Parameter, unwrap_scalar
using Graphs: degree, neighbors, vertices

function to_eincode(zxwd::ZXW.ZXWDiagram{T, P}) where {T, P}
    tensors = []
    ixs = Vector{Tuple{T, T, T}}[]
    iy = Tuple{T, T, T}[]
    for v in vertices(zxwd.mg)
        res = @match zxwd.st[v] begin
            Z(p) => z_tensor(degree(zxwd, v), p)
            X(p) => x_tensor(degree(zxwd, v), p)
            W => w_tensor(degree(zxwd, v))
            H => h_tensor(degree(zxwd, v))
            D => d_tensor(degree(zxwd, v))
            Input(q) => nothing
            Output(q) => nothing
        end

        if !isnothing(res)
            push!(ixs, to_eincode_indices(zxwd, v))
            push!(tensors, res)
        end
    end

    for v in ZXW.get_outputs(zxwd)
        push!(iy, to_eincode_indices(zxwd, v)[])
    end

    for v in ZXW.get_inputs(zxwd)
        push!(iy, to_eincode_indices(zxwd, v)[])
    end

    scalar_tensor = zeros(ComplexF64, ())

    scalar_tensor[] = unwrap_scalar(ZXW.scalar(zxwd))
    push!(ixs, Tuple{T, T, T}[])
    push!(tensors, scalar_tensor)
    return EinCode(ixs, iy), tensors
end

function to_eincode_indices(zxwd::ZXW.ZXWDiagram{T, P}, v) where {T, P}
    nbs = neighbors(zxwd, v; count_mul=true)
    ids = Tuple{T, T, T}[]
    isempty(nbs) && return ids
    curr_nb = nbs[1]
    curr_mul = 1
    for i in 1:length(nbs)
        nb = nbs[i]
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

function z_tensor(n::Int, α::Parameter)
    factor = @match α begin
        PiUnit(pu, _) => exp(im * pu * π)
        Factor(f, _) => f
        _ => error("Invalid parameter type for ZXW.Z-spider")
    end
    return z_tensor(n, factor)
end

function x_tensor(n::Int, α::Parameter)
    factor = @match α begin
        PiUnit(pu, _) => exp(im * pu * π)
        Factor(f, _) => f
        _ => error("Invalid parameter type for ZXW.X-spider")
    end
    return x_tensor(n, factor)
end

matrix_shape(zxg::ZXW.ZXWDiagram) = (1 << ZXW.nin(zxg), 1 << ZXW.nout(zxg))
