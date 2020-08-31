### A Pluto.jl notebook ###
# v0.11.9

using Markdown
using InteractiveUtils

# ╔═╡ 8ab9b70a-e98d-11ea-239c-73dc659722c2
using YaoLang, YaoPlots, ZXCalculus, Compose, Revise

# ╔═╡ 282bd90e-e9fd-11ea-0b79-174cade05905
using Yao, YaoExtensions

# ╔═╡ e0a83244-e98e-11ea-3213-fdf02f4df920
function Base.show(io::IO, mime::MIME"text/html", zx::Union{ZXDiagram, ZXGraph})
	g = plot(zx; size_x=13, size_y = 3, NODELABELSIZE=8pt)
	Compose.set_default_graphic_size(18cm, 5cm)
	Base.show(io, mime, compose(context(0.0, 0.0, 1.0, 1.0), g))
end

# ╔═╡ 227f7884-e99a-11ea-3a90-0beb697a2da6
md"# Construct a ZX diagram"

# ╔═╡ 49d6e6ac-e994-11ea-2ac5-27ab8242e297
z1 = ZXDiagram(4)

# ╔═╡ 51e72d20-e994-11ea-1a50-854039f728aa
push_gate!(z1, Val(:Z), 1, 3//2)

# ╔═╡ e1dbb828-e995-11ea-385d-fb20b58d1b49
let
	push_gate!(z1, Val(:H), 1)
	push_gate!(z1, Val(:H), 1)
	push_gate!(z1, Val(:Z), 1, 1//2)
	push_gate!(z1, Val(:H), 4)
	push_gate!(z1, Val(:CZ), 4, 1)
	push_gate!(z1, Val(:CNOT), 1, 4)
end

# ╔═╡ 60c59c0a-e994-11ea-02da-7360cbcf81f7
function load_graph()
	zxd = ZXDiagram(4)
	push_gate!(zxd, Val(:Z), 1, 3//2)
	push_gate!(zxd, Val(:H), 1)
    push_gate!(zxd, Val(:Z), 1, 1//2)
    push_gate!(zxd, Val(:H), 4)
    push_gate!(zxd, Val(:CZ), 4, 1)
    push_gate!(zxd, Val(:CNOT), 1, 4)
    push_gate!(zxd, Val(:H), 1)
    push_gate!(zxd, Val(:H), 4)
    push_gate!(zxd, Val(:Z), 1, 1//4)
    push_gate!(zxd, Val(:Z), 4, 3//2)
    push_gate!(zxd, Val(:X), 4, 1//1)
    push_gate!(zxd, Val(:H), 1)
    push_gate!(zxd, Val(:Z), 4, 1//2)
    push_gate!(zxd, Val(:X), 4, 1//1)
    push_gate!(zxd, Val(:Z), 2, 1//2)
    push_gate!(zxd, Val(:CNOT), 3, 2)
    push_gate!(zxd, Val(:H), 2)
    push_gate!(zxd, Val(:CNOT), 3, 2)
    push_gate!(zxd, Val(:Z), 2, 1//4)
    push_gate!(zxd, Val(:Z), 3, 1//2)
    push_gate!(zxd, Val(:H), 2)
    push_gate!(zxd, Val(:H), 3)
    push_gate!(zxd, Val(:Z), 3, 1//2)
    push_gate!(zxd, Val(:CNOT), 3, 2)
end

# ╔═╡ 90b83d5e-e99a-11ea-1fb2-95c907668262
md"# Simplify the ZX diagram"

# ╔═╡ 64bff9ec-e9b5-11ea-3b23-c51d2149697a
zxd = load_graph()

# ╔═╡ 5dbf9f96-e9a4-11ea-19d7-e15e7f2327c9
tcount(zxd)

# ╔═╡ db9a0d4e-e99e-11ea-22ab-1fead216dd07
zxg = ZXGraph(zxd)

# ╔═╡ 66eb6e1a-e99f-11ea-141c-a9017390524f
md"apply the `lc` rule recursively"

# ╔═╡ ce83c0be-e9a3-11ea-1a40-b1b5118a24bd
html"""
<img src="https://user-images.githubusercontent.com/6257240/91627348-c8151080-e984-11ea-9263-849b2c98d88f.png" width=500/>
"""

# ╔═╡ a6b92942-e99a-11ea-227d-f9fe53f8a1cf
# simplify!(Rule{:lc}(), zxd)  #  this should not pass! use `DRule` and `GRule` to distinguish them?
simplify!(Rule{:lc}(), zxg)  # allow Rule(:lc) for simplicity.

# ╔═╡ 86475062-e99f-11ea-2f44-a3c270cc45e5
md"apply the p1 rule recursively"

# ╔═╡ f59bf644-e9a8-11ea-1944-b3843ef5d6c8
html"""
<img src="https://user-images.githubusercontent.com/6257240/91627385-04e10780-e985-11ea-81c3-d50e057e3795.png" width=600/>
"""

# ╔═╡ b739540e-e99a-11ea-2a04-abd99889cf92
simplify!(Rule{:p1}(), zxg)  # does not have any effect?

# ╔═╡ 7af70558-e9b4-11ea-3aa9-3b73357f0a2a
srule!(sym::Symbol) = g -> simplify!(Rule{sym}(), g)

# ╔═╡ a5784394-e9b4-11ea-0e68-8d8211766409
srule_once!(sym::Symbol) = g -> replace!(Rule{sym}(), g)

# ╔═╡ c6f809e8-e9b4-11ea-2dcb-57c4a1d65bb7
zxg |> srule!(:lc) |> srule!(:p1) |> srule_once!(:pab)

# ╔═╡ 25d876b6-e9a9-11ea-2631-fd6f8934daa6
md"apply the `pab` rule once"

# ╔═╡ 3ce5329a-e9a9-11ea-2c7e-312416dd9483
html"""
<img src="https://user-images.githubusercontent.com/6257240/91627574-5a69e400-e986-11ea-93bf-1d45f09b5967.png" width=600/>
"""

# ╔═╡ bd2b3364-e99a-11ea-06e7-4560cb873d2c
replace!(Rule{:pab}(), zxg)  # this naming is not explict, what about `simplify_recursive!` and `simplily!`.

# ╔═╡ c71cdf4c-e9b5-11ea-2aaf-5f4be0eb3e93
md"## To make life easier"

# ╔═╡ b6eaa762-e9b5-11ea-145e-7b5fa6b01872
zxd2 = load_graph()

# ╔═╡ 5464bc40-e9b5-11ea-2a2e-dfb0d31a33d3
ex_zxd = clifford_simplification(zxd2)

# ╔═╡ c0f046ea-e9b5-11ea-302c-c5fd4399d400
pt_zxd = phase_teleportation(zxd2)

# ╔═╡ c3e8b5b4-e99a-11ea-0e56-6b18757f94df
md"# Extract circuit"

# ╔═╡ c1b9828c-e99a-11ea-006a-013a2eab8cf3
zxd_simplified = circuit_extraction(zxg)

# ╔═╡ 6ddffea2-e9a4-11ea-1c32-0975a45aba7c
tcount(zxd_simplified)

# ╔═╡ 2082486e-e9fd-11ea-1a46-6395b4b34657
md"# Porting Yao"

# ╔═╡ 3a2c5d22-e9fd-11ea-1e48-a9be2e8b213b
zxd3 = ZXDiagram(4)

# ╔═╡ d341cde4-e9fd-11ea-1c3b-63f35fc648d5
begin
function ZXCalculus.push_gate!(zxd::ZXDiagram, c::AbstractBlock)
	error("Block type `$c` is not supported.")
end
# rotation blocks
function ZXCalculus.push_gate!(zxd::ZXDiagram, c::PutBlock{N,1,RotationGate{1,T,XGate}}) where {N,T}
	push_gate!(zxd, Val(:X), c.locs[1], c.content.theta)
end
function ZXCalculus.push_gate!(zxd::ZXDiagram, c::PutBlock{N,1,RotationGate{1,T,ZGate}}) where {N,T}
	push_gate!(zxd, Val(:Z), c.locs[1], c.content.theta)
end
function ZXCalculus.push_gate!(zxd::ZXDiagram, c::PutBlock{N,1,ShiftGate{T}}) where {N,T}
	push_gate!(zxd, Val(:Z), c.locs[1], c.content.theta)
end
function ZXCalculus.push_gate!(zxd::ZXDiagram, c::PutBlock{N,1,HGate}) where {N}
	push_gate!(zxd, Val(:H), c.locs[1])
end
function ZXCalculus.push_gate!(zxd::ZXDiagram, c::ChainBlock{N}) where {N}
	push_gate!.(Ref(zxd), subblocks(c))
	zxd
end

# constant block
function ZXCalculus.push_gate!(zxd::ZXDiagram, c::PutBlock{N,1,RotationGate{1,T,XGate}}) where {N,T}
	push_gate!(zxd, Val(:X), c.locs[1], c.content.theta)
end
function ZXCalculus.push_gate!(zxd::ZXDiagram, c::PutBlock{N,1,RotationGate{1,T,ZGate}}) where {N,T}
	push_gate!(zxd, Val(:Z), c.locs[1], c.content.theta)
end

# control blocks
function ZXCalculus.push_gate!(zxd::ZXDiagram, c::ControlBlock{N,1,RotationGate{1,T,XGate}}) where {N,T}
	push_gate!(zxd, Val(:X), c.locs[1], c.content.theta)
end
function ZXCalculus.push_gate!(zxd::ZXDiagram, c::ControBlock{N,1,RotationGate{1,T,ZGate}}) where {N,T}
	push_gate!(zxd, Val(:Z), c.locs[1], c.content.theta)
end
function ZXCalculus.push_gate!(zxd::ZXDiagram, c::ControlBlock{N,1,ShiftGate{T}}) where {N,T}
	push_gate!(zxd, Val(:Z), c.locs[1], c.content.theta)
end
end

# ╔═╡ 581e847c-e9fd-11ea-3fd0-6bbc0f6efd56
c = qft_circuit(4)

# ╔═╡ 2e84a5ce-e9fd-11ea-12d0-b3a3dd75a76f
push_gate!(zxd3, c)

# ╔═╡ 7b850816-ea02-11ea-183c-5db2d670be24
ZXDiagram(4) |> typeof

# ╔═╡ Cell order:
# ╠═8ab9b70a-e98d-11ea-239c-73dc659722c2
# ╟─e0a83244-e98e-11ea-3213-fdf02f4df920
# ╟─227f7884-e99a-11ea-3a90-0beb697a2da6
# ╠═49d6e6ac-e994-11ea-2ac5-27ab8242e297
# ╠═51e72d20-e994-11ea-1a50-854039f728aa
# ╠═e1dbb828-e995-11ea-385d-fb20b58d1b49
# ╠═60c59c0a-e994-11ea-02da-7360cbcf81f7
# ╟─90b83d5e-e99a-11ea-1fb2-95c907668262
# ╠═64bff9ec-e9b5-11ea-3b23-c51d2149697a
# ╠═5dbf9f96-e9a4-11ea-19d7-e15e7f2327c9
# ╠═db9a0d4e-e99e-11ea-22ab-1fead216dd07
# ╟─66eb6e1a-e99f-11ea-141c-a9017390524f
# ╟─ce83c0be-e9a3-11ea-1a40-b1b5118a24bd
# ╠═a6b92942-e99a-11ea-227d-f9fe53f8a1cf
# ╟─86475062-e99f-11ea-2f44-a3c270cc45e5
# ╟─f59bf644-e9a8-11ea-1944-b3843ef5d6c8
# ╠═b739540e-e99a-11ea-2a04-abd99889cf92
# ╠═7af70558-e9b4-11ea-3aa9-3b73357f0a2a
# ╠═a5784394-e9b4-11ea-0e68-8d8211766409
# ╠═c6f809e8-e9b4-11ea-2dcb-57c4a1d65bb7
# ╟─25d876b6-e9a9-11ea-2631-fd6f8934daa6
# ╟─3ce5329a-e9a9-11ea-2c7e-312416dd9483
# ╠═bd2b3364-e99a-11ea-06e7-4560cb873d2c
# ╟─c71cdf4c-e9b5-11ea-2aaf-5f4be0eb3e93
# ╠═b6eaa762-e9b5-11ea-145e-7b5fa6b01872
# ╠═5464bc40-e9b5-11ea-2a2e-dfb0d31a33d3
# ╠═c0f046ea-e9b5-11ea-302c-c5fd4399d400
# ╟─c3e8b5b4-e99a-11ea-0e56-6b18757f94df
# ╠═c1b9828c-e99a-11ea-006a-013a2eab8cf3
# ╠═6ddffea2-e9a4-11ea-1c32-0975a45aba7c
# ╠═2082486e-e9fd-11ea-1a46-6395b4b34657
# ╠═282bd90e-e9fd-11ea-0b79-174cade05905
# ╠═3a2c5d22-e9fd-11ea-1e48-a9be2e8b213b
# ╠═d341cde4-e9fd-11ea-1c3b-63f35fc648d5
# ╠═581e847c-e9fd-11ea-3fd0-6bbc0f6efd56
# ╠═2e84a5ce-e9fd-11ea-12d0-b3a3dd75a76f
# ╠═7b850816-ea02-11ea-183c-5db2d670be24
