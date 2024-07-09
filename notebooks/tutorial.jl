### A Pluto.jl notebook ###
# v0.19.38

using Markdown
using InteractiveUtils

# ╔═╡ 8ab9b70a-e98d-11ea-239c-73dc659722c2
begin
  import Pkg
  using OpenQASM
  using Vega
  using DataFrames
  using OpenQASM
  using YaoHIR: BlockIR
  using ZXCalculus, ZXCalculus.ZX
  using YaoHIR, YaoLocations
  using YaoHIR.IntrinsicOperation

  # Used for creating the IRCode for a BlockIR
  using Core.Compiler: IRCode
	using PlutoUI
  using PlutoUI

end

# ╔═╡ a9bf8e31-686a-4057-acec-bd04e8b5a3dc
using Multigraphs

# ╔═╡ 1e11009f-7b70-49fd-a6f3-ef8b5a79636e
using ZXCalculus.ZXW

# ╔═╡ fdfa8ed2-f19c-4b80-b64e-f4bb22d09327
function Base.show(io::IO, mime::MIME"text/html", zx::Union{ZXDiagram,ZXGraph})
    g = plot(zx)
    Base.show(io, mime, g)
end

# ╔═╡ 03405af4-0984-43c6-9312-f18fc3b23792
TableOfContents(title="📚 Table of Contents", indent=true, depth=4, aside=true)

# ╔═╡ 227f7884-e99a-11ea-3a90-0beb697a2da6
md"# Construct a ZX diagram"

# ╔═╡ 49d6e6ac-e994-11ea-2ac5-27ab8242e297
z1 = ZXDiagram(4)

# ╔═╡ 51e72d20-e994-11ea-1a50-854039f728aa
push_gate!(z1, Val(:Z), 1, 3 // 2)

# ╔═╡ e1dbb828-e995-11ea-385d-fb20b58d1b49
let
    push_gate!(z1, Val(:H), 1)
    push_gate!(z1, Val(:H), 1)
    push_gate!(z1, Val(:Z), 1, 1 // 2)
    push_gate!(z1, Val(:H), 4)
    push_gate!(z1, Val(:CZ), 4, 1)
    push_gate!(z1, Val(:CNOT), 1, 4)
end

# ╔═╡ 60c59c0a-e994-11ea-02da-7360cbcf81f7
function load_graph()
    zxd = ZXDiagram(4)
    push_gate!(zxd, Val(:Z), 1, 3 // 2)
    push_gate!(zxd, Val(:H), 1)
    push_gate!(zxd, Val(:Z), 1, 1 // 2)
    push_gate!(zxd, Val(:H), 4)
    push_gate!(zxd, Val(:CZ), 4, 1)
    push_gate!(zxd, Val(:CNOT), 1, 4)
    push_gate!(zxd, Val(:H), 1)
    push_gate!(zxd, Val(:H), 4)
    push_gate!(zxd, Val(:Z), 1, 1 // 4)
    push_gate!(zxd, Val(:Z), 4, 3 // 2)
    push_gate!(zxd, Val(:X), 4, 1 // 1)
    push_gate!(zxd, Val(:H), 1)
    push_gate!(zxd, Val(:Z), 4, 1 // 2)
    push_gate!(zxd, Val(:X), 4, 1 // 1)
    push_gate!(zxd, Val(:Z), 2, 1 // 2)
    push_gate!(zxd, Val(:CNOT), 3, 2)
    push_gate!(zxd, Val(:H), 2)
    push_gate!(zxd, Val(:CNOT), 3, 2)
    push_gate!(zxd, Val(:Z), 2, 1 // 4)
    push_gate!(zxd, Val(:Z), 3, 1 // 2)
    push_gate!(zxd, Val(:H), 2)
    push_gate!(zxd, Val(:H), 3)
    push_gate!(zxd, Val(:Z), 3, 1 // 2)
    push_gate!(zxd, Val(:CNOT), 3, 2)
end

# ╔═╡ ba769665-063b-4a17-8aa8-afa1fffc574c
md"""
# Multigraph ZXDigram
"""


# ╔═╡ b9d32b41-8bff-4faa-b198-db096582fb2e
begin
    g = Multigraph([0 1 0; 1 0 1; 0 1 0])
    ps = [Rational(0) for i = 1:3]
    v_t = [SpiderType.X, SpiderType.Z, SpiderType.X]
    zxd_m = ZXDiagram(g, v_t, ps)
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

# ╔═╡ 52c1ae46-a440-4d72-8dc1-fa9903feac80
pt_zxg = ZXGraph(pt_zxd)

# ╔═╡ c3e8b5b4-e99a-11ea-0e56-6b18757f94df
md"# Extract circuit"

# ╔═╡ c1b9828c-e99a-11ea-006a-013a2eab8cf3
chain_simplified = circuit_extraction(pt_zxg)

# ╔═╡ 6ddffea2-e9a4-11ea-1c32-0975a45aba7c
tcount(pt_zxg)

# ╔═╡ 4f07895a-58aa-4555-aa14-b0526bc1de2d
md"""
## ZXWDiagram as a Matrix
Convert a ZXWDiagram into a matrix using Einsum.jl
"""

# ╔═╡ 80c79503-b85e-4938-9253-58dd45cf42b0
begin
    zxw1 = ZXWDiagram(2)
    push_gate!(zxw1, Val(:Z), 1, 1 // 2)
    push_gate!(zxw1, Val(:H), 2)
    push_gate!(zxw1, Val(:CZ), 2, 1)
end

# ╔═╡ a5b21163-7e60-409f-ad59-66ca72375094
Matrix(zxw1)

# ╔═╡ 2082486e-e9fd-11ea-1a46-6395b4b34657
md"""
# Porting Yao

We can define a Yao Chain and push gates into the chain

"""

# ╔═╡ d1789ff9-3628-4fd3-aa39-823191e78ee0
begin
    chain_t = Chain()
    push_gate!(chain_t, Val(:H), 1)
    push_gate!(chain_t, Val(:H), 2)
    push_gate!(chain_t, Val(:X), 3)
    push_gate!(chain_t, Val(:H), 3)
    push_gate!(chain_t, Val(:CNOT), 1, 3)
    push_gate!(chain_t, Val(:X), 1)
    push_gate!(chain_t, Val(:CNOT), 2, 3)
    push_gate!(chain_t, Val(:H), 2)
end

# ╔═╡ 9ba5aa18-9e6b-4f75-a35c-e7a3e548d557
md"""
## Convert BlockIR to ZXDiagram
Create a BlockIR and convert it into a ZXDiagram
"""

# ╔═╡ 71fc6836-3c30-43de-aa2b-2d3d48bdb3da
begin

    ir_t = IRCode()
    bir_t = BlockIR(ir_t, 4, chain_t)
    zxd_t = convert_to_zxd(bir_t)
end

# ╔═╡ 31753c83-847a-4c2a-a6b3-8be6aaa8f792
zxg_t = ZXGraph(zxd_t)

# ╔═╡ 4a189a46-9ae6-458c-94c4-7cc8d5dab788
md"""
# Equivalence Checking

## Equivalence Checking of Quantum Circuits
### Principle of Quantum Circuit Equality
#### Reversiblity
Equivalence checking the equality of two quantum circuits relies on the reversibility
of quantum operations. Every quantum operation is *unitary* and thus reversible. The product of any quantum operation and its inverse (adjoint)
will always yield the identity. 


#### Unitary
For a matrix to be unitary, this property needs to hold:
`` U \cdot U^\dagger = U^\dagger \cdot U = I_n | U \in \mathbb{R}^{n \times n} ``

If ``U_1`` and ``U_2`` are unitary matrices, so is their matrix product ``U_1 \cdot U_2``. 
Unitary matrices preserve inner products. Thus, if ``U`` is unitary, then for all ``V , V′ \in \mathbb{C}^n`` we have:
``⟨U V |U V ′ ⟩ = ⟨U |V ′ ⟩``

### Equality
In order to verify the equality of two quantum circuits we exploit their reversibility. 

Given two quantum circuits ``G_1`` and ``G_2`` as well the systems matrices  ``U_1`` and ``U_1`` that describe the operations of these quantum circuits we ask ourself, the problem of equivalence checking is to verify if there is no difference ``D = U_1 \cdot U_2^\dagger`` between the first and second quantum circuit. 

To verify if the two quantum circuits are equal we check if ``tr(D) = 0``, as this implies that the difference is the idenity matrix.
 ``U_1 \cdot U_2^\dagger = D````U_1 \cdot U_2^\dagger = D =  I``. 

If the two quantum circuits are not equal,  ``U_1 \cdot U_2^\dagger = D != I``, the 
problem is to 
- approximate how close the quantum circuits are
- debug the quantum circuits, in order to reduce the difference `D` between them. 


"""

# ╔═╡ daa4e9e7-aefa-490d-b8ba-876643b4c7f3
bv_010 = full_reduction(concat!(ZXDiagram(BlockIR("""
OPENQASM 2.0;
include "qelib1.inc";
qreg q[4];
creg c[3];
x q[3];
h q[2];
h q[3];
h q[2];
h q[1];
CX q[1], q[3];
h q[1];
h q[0];
h q[0];
measure q[0] -> c[2];
measure q[2] -> c[0];
measure q[1] -> c[1];
   """)), dagger(ZXDiagram(BlockIR("""
OPENQASM 2.0;
include "qelib1.inc";
qreg q[4];
creg c[3];
x q[3];
h q[0];
h q[1];
h q[2];
h q[3];
CX q[1],q[3];
h q[0];
h q[1];
h q[2];
measure q[0] -> c[0];
measure q[1] -> c[1];
measure q[2] -> c[2];
    """)))))

# ╔═╡ 7bcc5502-a6d3-44fc-85a1-5ee33d855fa9
contains_only_bare_wires(bv_010)

# ╔═╡ Cell order:
# ╠═8ab9b70a-e98d-11ea-239c-73dc659722c2
# ╠═fdfa8ed2-f19c-4b80-b64e-f4bb22d09327
# ╠═03405af4-0984-43c6-9312-f18fc3b23792
# ╟─227f7884-e99a-11ea-3a90-0beb697a2da6
# ╠═49d6e6ac-e994-11ea-2ac5-27ab8242e297
# ╠═51e72d20-e994-11ea-1a50-854039f728aa
# ╠═e1dbb828-e995-11ea-385d-fb20b58d1b49
# ╠═60c59c0a-e994-11ea-02da-7360cbcf81f7
# ╟─ba769665-063b-4a17-8aa8-afa1fffc574c
# ╠═a9bf8e31-686a-4057-acec-bd04e8b5a3dc
# ╠═b9d32b41-8bff-4faa-b198-db096582fb2e
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
# ╠═52c1ae46-a440-4d72-8dc1-fa9903feac80
# ╟─c3e8b5b4-e99a-11ea-0e56-6b18757f94df
# ╠═c1b9828c-e99a-11ea-006a-013a2eab8cf3
# ╠═6ddffea2-e9a4-11ea-1c32-0975a45aba7c
# ╟─4f07895a-58aa-4555-aa14-b0526bc1de2d
# ╠═1e11009f-7b70-49fd-a6f3-ef8b5a79636e
# ╠═80c79503-b85e-4938-9253-58dd45cf42b0
# ╠═a5b21163-7e60-409f-ad59-66ca72375094
# ╟─2082486e-e9fd-11ea-1a46-6395b4b34657
# ╠═d1789ff9-3628-4fd3-aa39-823191e78ee0
# ╟─9ba5aa18-9e6b-4f75-a35c-e7a3e548d557
# ╠═71fc6836-3c30-43de-aa2b-2d3d48bdb3da
# ╠═31753c83-847a-4c2a-a6b3-8be6aaa8f792
# ╟─4a189a46-9ae6-458c-94c4-7cc8d5dab788
# ╠═daa4e9e7-aefa-490d-b8ba-876643b4c7f3
# ╠═7bcc5502-a6d3-44fc-85a1-5ee33d855fa9
