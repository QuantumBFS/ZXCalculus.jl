### A Pluto.jl notebook ###
# v0.19.29

using Markdown
using InteractiveUtils

# ╔═╡ dd08aa73-0d86-4f8b-970b-59f9ad9fac2d
begin
  import Pkg
  Pkg.add(url="/home/liam/src/quantum-circuits/software/ZXCalculus.jl", rev="feature/plots")
  Pkg.add("YaoLocations")
  Pkg.add("OpenQASM")
  Pkg.add("Vega")
  Pkg.add("DataFrames")
  Pkg.add(url="/home/liam/src/quantum-circuits/software/YaoHIR.jl", rev="feature/OpenQASM")
  Pkg.add(url="/home/liam/src/quantum-circuits/software/QuantumCircuitEquivalence.jl", rev="feat/zx")
  using Vega
  using OpenQASM
  using DataFrames
  using YaoHIR, YaoLocations
  using YaoHIR: BlockIR
  using ZXCalculus, ZXCalculus.ZX

  using QuantumCircuitEquivalence

end

# ╔═╡ 506db9e1-4260-408d-ba72-51581b548e53
function Base.show(io::IO, mime::MIME"text/html", zx::Union{ZXDiagram,ZXGraph})
  g = plot(zx)
  Base.show(io, mime, g)
end


# ╔═╡ db7e9cf8-9abf-448b-be68-43231853faff
md"""


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



## ZX Calculus Diagram
### Introduction
ZX-Calculus is a unified formalism for describing quantum computation, mainly over
qubits. It is a rigorous graphical language, that utilizes the powerful set of rewrite
rules for reasoning about linear maps between qubits, which are represented as string diagrams called ZX-Diagrams.

#### Example
Of three CNOT Gats that are equal to a SWAP Gate

"""




# ╔═╡ c06c5b9f-e5c1-4d0c-8ed5-937ad3871d3d
begin
  zx1 = ZXDiagram(2)
  push_gate!(zx1, Val(:CNOT), 1, 2)
  push_gate!(zx1, Val(:CNOT), 2, 1)
  push_gate!(zx1, Val(:CNOT), 1, 2)

end

# ╔═╡ 5e0fb39e-68b3-45f6-8cb2-2dd0b79b35d4
md"""
### Applications
ZX-Calculus has been successfully applied to 
- quantum circuit compilationoptimization and equivalence checking.

ZX-Calculus is a generaliation of Quantum Computing. It is complete, meaning that all equations concerning quantum processes can be derived using linear algebra, can also be obtained using a handful of graphical rules.


### Example Bernstein-Vazirani ZX-Diagram
"""

# ╔═╡ 587be022-6005-44d5-bb72-53cc9e3ba3bb
bv_101_static = ZXDiagram(BlockIR("""
OPENQASM 2.0;
include "qelib1.inc";
qreg q[4];
creg c[3];
x q[3];
h q[0];
h q[1];
h q[2];
h q[3];
CX q[0],q[3];
CX q[2],q[3];
h q[0];
h q[1];
h q[2];
measure q[0] -> c[0];
measure q[1] -> c[1];
measure q[2] -> c[2];
"""))

# ╔═╡ 482fdb57-2b0b-44b9-a5a0-f4dc26e15a7d
bv_101_dynamic = ZXDiagram(BlockIR(unitary_reconstruction("""
OPENQASM 2.0;
include "qelib1.inc";
qreg q[2];
creg c[3];
x q[1];
h q[0];
h q[1];
CX q[0],q[1];
h q[0];
measure q[0] -> c[0];
reset q[0];
h q[0];
h q[0];
measure q[0] -> c[1];
reset q[0];
h q[0];
CX q[0],q[1];
h q[0];
measure q[0] -> c[2];
""")))

# ╔═╡ 57301b22-969f-481e-ae0b-0336e1ee5055
md"""
## Logic Verification of Quantum Circuits
### Informal Definition of Quantum Circuit Equality
> Two circuits are equivalent if they produce the same output for every possible input
`` U_1 \cdot U_2 = I ``

"""

# ╔═╡ 283c05a3-3c1b-4e4d-ba19-0cbc9eeada11


# ╔═╡ a8470d1a-8dc1-4a86-85b9-efd1836cf42c
verify_equality(bv_101_dynamic, bv_101_static)

# ╔═╡ 6e823d50-9107-4488-897e-d647334573f9
md"""
What happens if we add an extra Z gate to the first qubit?
"""

# ╔═╡ e3aa4e99-cb1f-478b-9e80-82b0ab02f606
begin
  push_gate!(bv_101_static, Val(:X), 1, 1 // 1)
  verify_equality(bv_101_dynamic, bv_101_static)
end

# ╔═╡ a44ef98a-61fb-4271-9d36-c4d096f7e600
md"""
## Differenciation of ZX-Calculus
"""

# ╔═╡ fb2448ef-aebe-419f-ad1d-a161edacd5a0
md"""
### Difference of two quantum circuits
Approximation equality of ZX-Diagrams using algebraic ZX-Calculus

"""

# ╔═╡ 38da72a7-7e81-426f-ba08-b4158dc6a011
bv_101_difference = full_reduction(concat!(ZXDiagram(BlockIR(unitary_reconstruction("""
   OPENQASM 2.0;
   include "qelib1.inc";
   qreg q[2];
   creg c[3];
   x q[1];
   h q[0];
   h q[1];
   CX q[0],q[1];
   h q[0];
   measure q[0] -> c[0];
   reset q[0];
   h q[0];
   h q[0];
   measure q[0] -> c[1];
   reset q[0];
   h q[0];
   CX q[0],q[1];
   h q[0];
   measure q[0] -> c[2];
   """))), dagger(ZXDiagram(BlockIR(unitary_reconstruction("""
   OPENQASM 2.0;
   include "qelib1.inc";
   qreg q[2];
   creg c[3];
   x q[1];
   h q[0];
   h q[1];
   CX q[0],q[1];
   h q[0];
   measure q[0] -> c[0];
   reset q[0];
   h q[0];
   h q[0];
   measure q[0] -> c[1];
   reset q[0];
   h q[0];
   CX q[0],q[1];
   h q[0];
   x q[0];
   measure q[0] -> c[2];
    """))))))

# ╔═╡ 686cfe18-598b-4184-8a6d-85711109b055
convert_to_zxwd(circuit_extraction(bv_101_difference))

# ╔═╡ 9af85660-a4e3-4f27-b6cb-cf36d9b50d91
z1 = ZXDiagram(1)


# ╔═╡ 785ec008-63af-4f56-9792-f66b27a27388
md"""
Add a green spider
"""

# ╔═╡ 44cbd3d8-6d36-4a0b-8613-552bbba48f3d
begin
  zx_z = ZXDiagram(1)
  push_gate!(zx_z, Val(:Z), 1)
end

# ╔═╡ 0c2b4e33-5dcc-476d-8a9c-1e4244231e05
begin
  zx_x = ZXDiagram(1)
  push_gate!(zx_x, Val(:X), 1, 1 // 1)
end


# ╔═╡ eebd1e46-0c0f-487d-8bee-07b1c17552c4
begin
  zx_s = ZXDiagram(1)
  push_gate!(zx_s, Val(:Z), 1, 1 // 2)
end




# ╔═╡ 9200a1b1-11f7-4428-8840-c52dd4403c45
begin
  zx_t = ZXDiagram(1)
  push_gate!(zx_t, Val(:Z), 1, 1 // 4)
end




# ╔═╡ 924efc08-681b-4804-93c6-38acc125315a
begin
  zx_h = ZXDiagram(1)
  push_gate!(zx_h, Val(:H), 1)
end




# ╔═╡ 5fdc6a08-c284-414e-9e96-8734289a98de
begin
  zx_cnot = ZXDiagram(2)
  push_gate!(zx_cnot, Val(:CNOT), 1, 2)

end

# ╔═╡ 0523c034-06ac-4383-b50f-6b68e6b1739f
begin
  zx = ZXDiagram(3)
  push_gate!(zx, Val(:X), 1, 1 // 1)
  push_gate!(zx, Val(:CNOT), 1, 2)
  push_gate!(zx, Val(:H), 1)
  push_gate!(zx, Val(:CNOT), 2, 3)
  push_gate!(zx, Val(:H), 2)
end


# ╔═╡ 4d7d8a96-5aba-4b63-a5da-959716f2d2bf
md"## Converting ZXDiagrams into ZXGraphs"

# ╔═╡ 7da637f0-e359-41d9-b395-27168459c20c
zx_graph = ZXGraph(zx)

# ╔═╡ bed7a0c5-da16-40b5-9d84-4dad2dfb8739
begin
  zx_id = ZXDiagram(2)
  push_gate!(zx_id, Val(:X), 1)
  push_gate!(zx_id, Val(:X), 1)
end


# ╔═╡ 8cde99fd-ee0a-4d94-a94e-23ebc9ac8608
zx_id_graph = ZXGraph(zx_id)

# ╔═╡ 17389edf-33d2-4dd8-bf86-df0467e65059
full_reduction(zx_id)

# ╔═╡ 99bb5eff-79e7-4c0e-95ae-a6d2130f46cb
md"Equality"

# ╔═╡ f240382f-b682-4947-938f-c98d9c901c90
zx_dagger = dagger(zx)

# ╔═╡ 89f14c32-895d-4101-b4a8-bc410a2adaa5
concat!(zx, zx_dagger)

# ╔═╡ 0b838710-91e4-4572-9fe0-5c97e579ddd1
m_simple = full_reduction(zx)


# ╔═╡ fdb7ca6a-bf5c-4216-8a18-a7c3603240ea
contains_only_bare_wires(m_simple)

# ╔═╡ 6da61df3-b6e7-4991-ab9f-5994b55841e0
full_reduction(zx)

# ╔═╡ 6b431ff3-f644-4123-82fd-704c054eb5bb
md"DQC Example"

# ╔═╡ cee877f2-8fd8-4a4e-9b8c-199411d449c5
begin
  traditional = """
  OPENQASM 2.0;
  include "qelib1.inc";
  qreg q0[3];
  creg c0[2];
  h q0[0];
  h q0[1];
  x q0[2];
  h q0[2];
  CX q0[0],q0[2];
  h q0[0];
  CX q0[1],q0[2];
  h q0[1];
  measure q0[0] -> c0[0];
  measure q0[1] -> c0[1];
  """
  c1 = ZXDiagram(BlockIR(traditional))
end

# ╔═╡ 20886e57-0c2c-4bf3-8c3d-8ed7d4f33fec
begin
  dynamic = OpenQASM.parse("""
     OPENQASM 2.0;
     include "qelib1.inc";
     qreg q0[2];
     creg mcm[1];
     creg end[1];
     h q0[0];
     x q0[1];
     h q0[1];
     CX q0[0],q0[1];
     h q0[0];
     measure q0[0] -> mcm[0];
     reset q0[0];
     h q0[0];
     CX q0[0],q0[1];
     h q0[0];
     measure q0[0] -> end[0];
     """)
  unitary = unitary_reconstruction(dynamic)
  c2 = ZXDiagram(BlockIR(unitary))


end

# ╔═╡ 9b838e52-79f6-49bd-9574-62d94f941558
c2_dagger = dagger(c2)


# ╔═╡ 91ea0d20-8f8b-4bec-a98d-6aebbc4228e1
dqc_merged = concat!(c1, c2_dagger)

# ╔═╡ fbbe52e6-40d0-48ab-aa92-58a5125a33b2
reduced  = full_reduction(concat!(ZXDiagram(BlockIR(traditional)), dagger(ZXDiagram(BlockIR(unitary)))))

# ╔═╡ f7982574-ddff-4e7b-a4fc-52462a59d21c
contains_only_bare_wires(reduced)

# ╔═╡ Cell order:
# ╠═dd08aa73-0d86-4f8b-970b-59f9ad9fac2d
# ╠═506db9e1-4260-408d-ba72-51581b548e53
# ╟─db7e9cf8-9abf-448b-be68-43231853faff
# ╟─c06c5b9f-e5c1-4d0c-8ed5-937ad3871d3d
# ╠═5e0fb39e-68b3-45f6-8cb2-2dd0b79b35d4
# ╠═587be022-6005-44d5-bb72-53cc9e3ba3bb
# ╠═482fdb57-2b0b-44b9-a5a0-f4dc26e15a7d
# ╠═57301b22-969f-481e-ae0b-0336e1ee5055
# ╠═283c05a3-3c1b-4e4d-ba19-0cbc9eeada11
# ╠═a8470d1a-8dc1-4a86-85b9-efd1836cf42c
# ╠═6e823d50-9107-4488-897e-d647334573f9
# ╠═e3aa4e99-cb1f-478b-9e80-82b0ab02f606
# ╠═a44ef98a-61fb-4271-9d36-c4d096f7e600
# ╠═fb2448ef-aebe-419f-ad1d-a161edacd5a0
# ╟─38da72a7-7e81-426f-ba08-b4158dc6a011
# ╠═686cfe18-598b-4184-8a6d-85711109b055
# ╠═9af85660-a4e3-4f27-b6cb-cf36d9b50d91
# ╟─785ec008-63af-4f56-9792-f66b27a27388
# ╠═44cbd3d8-6d36-4a0b-8613-552bbba48f3d
# ╠═0c2b4e33-5dcc-476d-8a9c-1e4244231e05
# ╠═eebd1e46-0c0f-487d-8bee-07b1c17552c4
# ╠═9200a1b1-11f7-4428-8840-c52dd4403c45
# ╠═924efc08-681b-4804-93c6-38acc125315a
# ╠═5fdc6a08-c284-414e-9e96-8734289a98de
# ╠═0523c034-06ac-4383-b50f-6b68e6b1739f
# ╠═4d7d8a96-5aba-4b63-a5da-959716f2d2bf
# ╠═7da637f0-e359-41d9-b395-27168459c20c
# ╠═bed7a0c5-da16-40b5-9d84-4dad2dfb8739
# ╠═8cde99fd-ee0a-4d94-a94e-23ebc9ac8608
# ╠═17389edf-33d2-4dd8-bf86-df0467e65059
# ╠═99bb5eff-79e7-4c0e-95ae-a6d2130f46cb
# ╠═f240382f-b682-4947-938f-c98d9c901c90
# ╠═89f14c32-895d-4101-b4a8-bc410a2adaa5
# ╠═0b838710-91e4-4572-9fe0-5c97e579ddd1
# ╠═fdb7ca6a-bf5c-4216-8a18-a7c3603240ea
# ╠═6da61df3-b6e7-4991-ab9f-5994b55841e0
# ╠═6b431ff3-f644-4123-82fd-704c054eb5bb
# ╠═cee877f2-8fd8-4a4e-9b8c-199411d449c5
# ╠═20886e57-0c2c-4bf3-8c3d-8ed7d4f33fec
# ╠═9b838e52-79f6-49bd-9574-62d94f941558
# ╠═91ea0d20-8f8b-4bec-a98d-6aebbc4228e1
# ╠═fbbe52e6-40d0-48ab-aa92-58a5125a33b2
# ╠═f7982574-ddff-4e7b-a4fc-52462a59d21c
