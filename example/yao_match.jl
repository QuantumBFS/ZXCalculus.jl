using Yao, YaoExtensions
using Test
using ZXCalculus
import ZXCalculus: push_gate!

# patch
push_gate!(zxd::ZXDiagram, ::Val{:CNOT}, args...) = push_gate!(zxd, Val(:CNOT), args...)
push_gate!(zxd::ZXDiagram, ::Val{:CZ}, args...) = push_gate!(zxd, Val(:CZ), args...)

function ztensor(nleg::Int, α::T) where T<:Number
    shape = (fill(2, nleg)...,)
    factor = exp(im*α)
    out = zeros(typeof(factor), shape...)
    out[1] = one(typeof(factor))
    out[fill(2, nleg)...] = factor
    out
end

function xtensor(nleg::Int, α::T) where T<:Number
    pos = [1, 1]/sqrt(2)
    neg = [1, -1]/sqrt(2)
    shape = (fill(2, nleg)...,)
    reshape(reduce(kron, fill(pos, nleg)) + exp(im*α)*reduce(kron, fill(neg, nleg)), shape)
end

function htensor(nleg::Int, α::T) where T<:Number
    shape = (fill(2, nleg)...,)
    factor = exp(im*α)
    out = fill(one(typeof(factor)), shape)
    out[fill(2, nleg)...] = factor
    return out
end

θ = 0.5
@test mat(Rz(θ) * Yao.phase(θ/2)) ≈ ztensor(2, θ)
@test mat(shift(θ)) ≈ ztensor(2, θ)
@test mat(Rx(θ) * Yao.phase(θ/2)) ≈ xtensor(2, θ)
@test mat(H) .* sqrt(2) ≈ htensor(2, π)
@test mat(T) ≈ ztensor(2, π/4)
@test mat(ConstGate.S) ≈ ztensor(2, π/2)
@test mat(chain(ConstGate.Sdag, X, ConstGate.S)) ≈ mat(Y)
@test mat(T) ≈ mat(Rz(π/4) * Yao.phase(π/8))
@test mat(ConstGate.S) ≈ mat(Rz(π/2) * Yao.phase(π/4))
function push_gate!(zxd::ZXDiagram, c::AbstractBlock)
	push_gate!(zxd, decompose_zx(c))
end

# rotation blocks
function push_gate!(zxd::ZXDiagram, c::PutBlock{N,1,RotationGate{1,T,XGate}}) where {N,T}
	push_gate!(zxd, Val(:X), c.locs[1], c.content.theta/π)
end
function push_gate!(zxd::ZXDiagram, c::PutBlock{N,1,RotationGate{1,T,ZGate}}) where {N,T}
	push_gate!(zxd, Val(:Z), c.locs[1], c.content.theta/π)
end

function push_gate!(zxd::ZXDiagram, c::ChainBlock{N}) where {N}
	push_gate!.(Ref(zxd), subblocks(c))
	zxd
end

# constant block
function push_gate!(zxd::ZXDiagram, c::PutBlock{N,1,HGate}) where {N}
	push_gate!(zxd, Val(:H), c.locs[1])
end

# control blocks
function push_gate!(zxd::ZXDiagram, c::ControlBlock{N,XGate,1}) where {N}
	cloc = c.ctrl_locs[1]
	if c.ctrl_config[1] == 1
		push_gate!(zxd, Val(:CNOT), cloc, c.locs[1])
	else
		push_gate!(zxd, Val(:X), cloc, 1//1)
		push_gate!(zxd, Val(:CNOT), cloc, c.locs[1])
		push_gate!(zxd, Val(:X), cloc, 1//1)
	end
end
function push_gate!(zxd::ZXDiagram, c::ControlBlock{N,ZGate,1}) where {N}
	cloc = c.ctrl_locs[1]
	if c.ctrl_config[1] == 1
		push_gate!(zxd, Val(:CZ), cloc, c.locs[1])
	else
		push_gate!(zxd, Val(:X), cloc, 1//1)
		push_gate!(zxd, Val(:CZ), cloc, c.locs[1])
		push_gate!(zxd, Val(:X), cloc, 1//1)
	end
end

function push_gate!(zxd::ZXDiagram, c::PutBlock{N,2,SWAPGate}) where {N}
	a, b = c.locs
	push_gate!(zxd, Val(:SWAP), [a, b])
end

# ref: https://qiskit.org/textbook/ch-gates/more-circuit-identities.html
function decompose_zx(c::ControlBlock{N,XGate,2}) where N
	a, b = getclocs(c)
	loc = c.locs[1]
	chain(N,
		put(loc=>H),
		cnot(b, loc),
		put(loc=>ConstGate.Tdag),
		cnot(a, loc),
		put(loc=>ConstGate.T),
		cnot(b, loc),
		put(loc=>ConstGate.Tdag),
		cnot(a, loc),
		put(loc=>ConstGate.T),
		put(b=>ConstGate.T),
		put(loc=>H),
		cnot(a, b),
		put(a=>ConstGate.T),
		put(b=>ConstGate.Tdag),
		cnot(a, b),
	)
end

function decompose_zx(c::ControlBlock{N,YGate,1}) where {N}
	a = getclocs(c)[1]
	loc = c.locs[1]
	chain(N, put(loc=>ConstGate.Sdag), cnot(a, loc), put(loc=>ConstGate.S))
end

function decompose_zx(c::ControlBlock{N,ShiftGate{T},1}) where {N,T}
	a = getclocs(c)[1]
	loc = c.locs[1]
	θ = c.content.theta
	chain(N, put(a=>ShiftGate(θ/2)), put(loc=>Rz(θ/2)), cnot(a,loc), put(loc=>Rz(-θ/2)), cnot(a,loc))
end

function decompose_zx(c::ControlBlock{N,RotationGate{1,T,YGate},1}) where {N,T}
	a = getclocs(c)[1]
	loc = c.locs[1]
	θ = c.content.theta
	chain(N, put(loc=>Ry(θ/2)), cnot(a,loc), put(loc=>Ry(-θ/2)), cnot(a,loc))
end

function decompose_zx(c::ControlBlock{N,RotationGate{1,T,XGate},1}) where {N,T}
	a = getclocs(c)[1]
	loc = c.locs[1]
	θ = c.content.theta
	chain(N, put(loc=>Rx(θ/2)), Yao.cz(a,loc), put(loc=>Rx(-θ/2)), Yao.cz(a,loc))
end

function decompose_zx(c::ControlBlock{N,RotationGate{1,T,ZGate},1}) where {N,T}
	a = getclocs(c)[1]
	loc = c.locs[1]
	θ = c.content.theta
	chain(N, put(loc=>Rz(θ/2)), cnot(a,loc), put(loc=>Rz(-θ/2)), cnot(a,loc))
end

# constant block
function decompose_zx(c::PutBlock{N,1,RotationGate{1,T,XGate}}) where {N,T}
	put(N, c.locs[1]=>Rx(π))
end
function decompose_zx(c::PutBlock{N,1,RotationGate{1,T,ZGate}}) where {N,T}
	put(N, c.locs[1]=>Rz(π))
end
function decompose_zx(c::PutBlock{N,1,ConstGate.SGate}) where {N}
	put(N, c.locs[1]=>Rz(π/2))
end
function decompose_zx(c::PutBlock{N,1,ConstGate.TGate}) where {N}
	put(N, c.locs[1]=>Rz(π/4))
end
function decompose_zx(c::PutBlock{N,1,ConstGate.SdagGate}) where {N}
	put(N, c.locs[1]=>Rz(-π/2))
end
function decompose_zx(c::PutBlock{N,1,ConstGate.TdagGate}) where {N}
	put(N, c.locs[1]=>Rz(-π/4))
end
function decompose_zx(c::PutBlock{N,1,ShiftGate{T}}) where {N,T}
	put(N, c.locs[1]=>Rz(c.content.theta))
end

function getclocs(c::ControlBlock)
	(2 .* c.ctrl_config .- 1) .* c.ctrl_locs
end

@testset "decompose gates" begin
	@test getclocs(cnot(2,-2,1)) == (-2,)
	@test getclocs(control(4, (-2, 3), 1=>X)) == (-2, 3)
	for g in [control(5, (2, 1), 4=>X), put(5, (2,4)=>SWAP),
		 	put(5, 3=>ConstGate.T), put(5, 2=>ConstGate.Sdag),
			put(5, 4=>ConstGate.Tdag), put(5, 2=>ConstGate.S),
			control(5, 4, 3=>Y), put(5, 3=>shift(0.4)),
			control(5, 2, 3=>Ry(0.5)),
			control(5, 2, 3=>Rz(0.5)),
			control(5, 2, 3=>Rx(0.5)),
			control(5, -2, 3=>Rx(0.5)),
			cphase(5, 2, 4, 0.5)
			]
		@test operator_fidelity(decompose_zx(g), g) ≈ 1
	end
end

c = qft_circuit(4)
zxd = ZXDiagram(4)
push_gate!(zxd, c)
