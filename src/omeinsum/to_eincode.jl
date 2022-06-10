export to_eincode_indices, to_matrix

Base.Matrix(zxd::ZXDiagram) = to_matrix(zxd)

function to_matrix(zxd)
    nin = sum((spider_type(zxd, v) in (SpiderType.In, SpiderType.Out)) for v in get_inputs(zxd))
    nout = sum((spider_type(zxd, v) in (SpiderType.In, SpiderType.Out)) for v in get_outputs(zxd))
    ec, ts = to_eincode(zxd)
    m = ec(ts...)
    return reshape(m, (1<<nin, 1<<nout))
end

function to_eincode(zxd::ZXDiagram{T, P}) where {T, P}
    vs = spiders(zxd)
    tensors = []
    ixs = Vector{Tuple{T, T, T}}[]
    iy = Tuple{T, T, T}[]
    for v in vs
        if !(spider_type(zxd, v) in (SpiderType.In, SpiderType.Out))
            push!(ixs, to_eincode_indices(zxd, v))
            push!(tensors, to_eincode_tensor(zxd, v))
        end
    end
    for i in get_inputs(zxd)
        if spider_type(zxd, i) in (SpiderType.In, SpiderType.Out)
            push!(iy, to_eincode_indices(zxd, i)[])
        end
    end
    for o in get_outputs(zxd)
        if spider_type(zxd, o) in (SpiderType.In, SpiderType.Out)
            push!(iy, to_eincode_indices(zxd, o)[])
        end
    end
    s = unwrap_scalar(scalar(zxd))
    scalar_tensor = zeros(ComplexF64, ())
    scalar_tensor[] = s
    push!(ixs, [])
    push!(tensors, scalar_tensor)
    return EinCode(ixs, iy), tensors
end

function to_eincode_indices(zxd::ZXDiagram{T, P}, v) where {T, P}
    nbs = neighbors(zxd, v; count_mul = true)
    ids = Tuple{T, T, T}[]
    isempty(nbs) && return ids
    curr_nb = nbs[1]
    curr_mul = 1
    for i = 1:length(nbs)
        nb = nbs[i]
        if nb != curr_nb            
            curr_nb = nb
            curr_mul = 1
        end
        if nb == v
            push!(ids, edge_index(v, nb, (curr_mul+1)÷2))
        else
            push!(ids, edge_index(v, nb, curr_mul))
        end
        curr_mul += 1
    end
    return ids
end
edge_index(v1, v2, mul) = (min(v1, v2), max(v1, v2), mul)

to_eincode_tensor(zxd::ZXDiagram, v) = to_eincode_tensor(spider_type(zxd, v), degree(zxd, v), phase(zxd, v))

function to_eincode_tensor(st::SpiderType.SType, n, p)
    st === SpiderType.Z && return z_tensor(n, unwrap_pi_unit(p))
    st === SpiderType.X && return x_tensor(n, unwrap_pi_unit(p))
    st === SpiderType.H && return h_tensor(n)
    st === SpiderType.W && return w_tensor(n)
    st === SpiderType.D && return d_tensor(n)
    return
end

function z_tensor(n::Int, α::T) where T<:Number
    shape = (fill(2, n)...,)
    factor = exp(im*α)
    out = zeros(typeof(factor), shape...)
    out[1] = one(typeof(factor))
    out[fill(2, n)...] = factor
    return out
end

function x_tensor(n::Int, α::T) where T<:Number
    pos = [1, 1]/sqrt(2)
    neg = [1, -1]/sqrt(2)
    shape = (fill(2, n)...,)
    return reshape(reduce(kron, fill(pos, n)) + exp(im*α)*reduce(kron, fill(neg, n)), shape)
end

function w_tensor(n)
    w = zeros(ComplexF64, fill(2, n)...)
    for i = 1:n
        id = ones(Int, n)
        id[i] = 2
        w[id...] = 1
    end
    return w
end

function h_tensor(n::Int)
    n == 2 || error("General H-boxes with n-arity are not supported")
    return (1/sqrt(2))*ComplexF64[1 1; 1 -1]
end

function d_tensor(n::Int)
    n == 2 || error("A D-box can only has arity 2")
    return ComplexF64[0 1; 1 1]
end