using ..ZXW: ZXW
using ..ZX: ZX

Base.Matrix(zxwd::Union{ZXW.ZXWDiagram, ZX.AbstractZXDiagram}) = to_matrix(zxwd)
function to_matrix(zxd::Union{ZXW.ZXWDiagram, ZX.AbstractZXDiagram}; optimizer=GreedyMethod(), verbose=false)
    ec, ts = to_eincode(zxd)
    verbose && println("Optimizing contraction orders...")
    ec_opt = optimize_code(ec, uniformsize(ec, 2), optimizer)
    verbose && println("Contracting...")
    m = ec_opt(ts...)
    return reshape(m, matrix_shape(zxd))
end

function z_tensor(n::Int, factor::Number)
    shape = (fill(2, n)...,)
    out = zeros(ComplexF64, shape...)
    out[1] = 1
    out[fill(2, n)...] = factor
    return out
end

function x_tensor(n::Int, factor::Number)
    pos = [1, 1] / sqrt(2)
    neg = [1, -1] / sqrt(2)
    shape = (fill(2, n)...,)
    return reshape(reduce(kron, fill(pos, n); init=[1]) + ComplexF64(factor) * reduce(kron, fill(neg, n); init=[1]), shape)
end

function w_tensor(n::Int)
    w = zeros(ComplexF64, fill(2, n)...)
    for i in 1:n
        id = ones(Int, n)
        id[i] = 2
        w[id...] = 1
    end
    return w
end

function h_tensor(n::Int)
    n == 2 || error("General ZXW.H-boxes with n-arity are not supported")
    return (1 / sqrt(2)) * ComplexF64[1 1; 1 -1]
end

function d_tensor(n::Int)
    n == 2 || error("A ZXW.D-box can only has arity 2")
    return ComplexF64[1 1; 1 0] # ZXW.D = T * ZXW.X
end

edge_index(v1, v2, mul) = (min(v1, v2), max(v1, v2), mul)
edge_index(v1, v2) = (min(v1, v2), max(v1, v2), 1)
