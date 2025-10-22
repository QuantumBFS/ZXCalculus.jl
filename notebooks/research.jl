### A Pluto.jl notebook ###
# v0.19.43

using Markdown
using InteractiveUtils

# ╔═╡ dd08aa73-0d86-4f8b-970b-59f9ad9fac2d
begin
  using Core.Compiler: IRCode

  # Pluto
  using PlutoUI

  # Weak Dependencies
  using Vega
  using OpenQASM
  using DataFrames
  using YaoHIR
  using YaoLocations
  using YaoHIR: BlockIR
  using YaoHIR.IntrinsicOperation
  using ZXCalculus, ZXCalculus.ZX, ZXCalculus.ZXW
  using DynamicQuantumCircuits

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
bv_101_dynamic = ZXDiagram(BlockIR(unitary_reconstruction(OpenQASM.parse("""
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
"""))))

# ╔═╡ 57301b22-969f-481e-ae0b-0336e1ee5055
md"""
## Logic Verification of Quantum Circuits
### Informal Definition of Quantum Circuit Equality
> Two circuits are equivalent if they produce the same output for every possible input
`` U_1 \cdot U_2 = I ``

"""

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
bv_101_difference = full_reduction(concat!(ZXDiagram(BlockIR(unitary_reconstruction(OpenQASM.parse("""
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
   """)))), dagger(ZXDiagram(BlockIR(unitary_reconstruction(OpenQASM.parse("""
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
    """)))))))

# ╔═╡ 742750be-1262-4cbe-b476-f62e5e5c1fcf
bir = circuit_extraction(bv_101_difference)

# ╔═╡ 686cfe18-598b-4184-8a6d-85711109b055
ZXW.convert_to_zxwd(BlockIR(IRCode(), 4, bir))

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
reduced = full_reduction(concat!(ZXDiagram(BlockIR(traditional)), dagger(ZXDiagram(BlockIR(unitary)))))

# ╔═╡ f7982574-ddff-4e7b-a4fc-52462a59d21c
contains_only_bare_wires(reduced)

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
DynamicQuantumCircuits = "b9e8302f-12f4-484c-8961-adc524bf1aaa"
OpenQASM = "a8821629-a4c0-4df7-9e00-12969ff383a7"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
Vega = "239c3e63-733f-47ad-beb7-a12fde22c578"
YaoHIR = "6769671a-fce8-4286-b3f7-6099e1b1298a"
YaoLocations = "66df03fb-d475-48f7-b449-3d9064bf085b"
ZXCalculus = "3525faa3-032d-4235-a8d4-8c2939a218dd"

[compat]
DataFrames = "~1.6.1"
DynamicQuantumCircuits = "~0.0.2"
OpenQASM = "~2.1.4"
PlutoUI = "~0.7.59"
Vega = "~2.7.0"
YaoHIR = "~0.2.3"
YaoLocations = "~0.1.6"
ZXCalculus = "~0.7.0"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

[[AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "6e1d2a35f2f90a4bc7c2ed98079b2ba09c35b83a"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.3.2"

[[AbstractTrees]]
git-tree-sha1 = "2d9c9a55f9c93e8887ad391fbae72f8ef55e1177"
uuid = "1520ce14-60c1-5f80-bbc7-55ef81b5835c"
version = "0.4.5"

[[ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[ArnoldiMethod]]
deps = ["LinearAlgebra", "Random", "StaticArrays"]
git-tree-sha1 = "d57bd3762d308bded22c3b82d033bff85f6195c6"
uuid = "ec485272-7323-5ecc-a04f-4719b315124d"
version = "0.4.0"

[[Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[BatchedRoutines]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "441db9f0399bcfb4eeb8b891a6b03f7acc5dc731"
uuid = "a9ab73d0-e05c-5df1-8fde-d6a4645b8d8e"
version = "0.2.2"

[[BetterExp]]
git-tree-sha1 = "dd3448f3d5b2664db7eceeec5f744535ce6e759b"
uuid = "7cffe744-45fd-4178-b173-cf893948b8b7"
version = "0.1.0"

[[BufferedStreams]]
git-tree-sha1 = "4ae47f9a4b1dc19897d3743ff13685925c5202ec"
uuid = "e1450e63-4bb3-523b-b2a4-4ffa8c0fd77d"
version = "1.2.1"

[[ChainRulesCore]]
deps = ["Compat", "LinearAlgebra"]
git-tree-sha1 = "71acdbf594aab5bbb2cec89b208c41b4c411e49f"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.24.0"
weakdeps = ["SparseArrays"]

    [ChainRulesCore.extensions]
    ChainRulesCoreSparseArraysExt = "SparseArrays"

[[ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "b10d0b65641d57b8b4d5e234446582de5047050d"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.5"

[[Combinatorics]]
git-tree-sha1 = "08c8b6831dc00bfea825826be0bc8336fc369860"
uuid = "861a8166-3701-5b0c-9a16-15d98fcdc6aa"
version = "1.0.2"

[[Compat]]
deps = ["TOML", "UUIDs"]
git-tree-sha1 = "b1c55339b7c6c350ee89f2c1604299660525b248"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.15.0"
weakdeps = ["Dates", "LinearAlgebra"]

    [Compat.extensions]
    CompatLinearAlgebraExt = "LinearAlgebra"

[[CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.1.1+0"

[[ConstructionBase]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "d8a9c0b6ac2d9081bf76324b39c78ca3ce4f0c98"
uuid = "187b0558-2788-49d3-abe0-74a17ed4e7c9"
version = "1.5.6"

    [ConstructionBase.extensions]
    ConstructionBaseIntervalSetsExt = "IntervalSets"
    ConstructionBaseStaticArraysExt = "StaticArrays"

    [ConstructionBase.weakdeps]
    IntervalSets = "8197267c-284f-5f27-9208-e0e47529a953"
    StaticArrays = "90137ffa-7385-5640-81b9-e52037218182"

[[Crayons]]
git-tree-sha1 = "249fe38abf76d48563e2f4556bebd215aa317e15"
uuid = "a8cc5b0e-0ffa-5ad4-8c14-923d3ee1735f"
version = "4.1.1"

[[DataAPI]]
git-tree-sha1 = "abe83f3a2f1b857aac70ef8b269080af17764bbe"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.16.0"

[[DataFrames]]
deps = ["Compat", "DataAPI", "DataStructures", "Future", "InlineStrings", "InvertedIndices", "IteratorInterfaceExtensions", "LinearAlgebra", "Markdown", "Missings", "PooledArrays", "PrecompileTools", "PrettyTables", "Printf", "REPL", "Random", "Reexport", "SentinelArrays", "SortingAlgorithms", "Statistics", "TableTraits", "Tables", "Unicode"]
git-tree-sha1 = "04c738083f29f86e62c8afc341f0967d8717bdb8"
uuid = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
version = "1.6.1"

[[DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "1d0a14036acb104d9e89698bd408f63ab58cdc82"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.20"

[[DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[DataValues]]
deps = ["DataValueInterfaces", "Dates"]
git-tree-sha1 = "d88a19299eba280a6d062e135a43f00323ae70bf"
uuid = "e7dc6d0d-1eca-5fa6-8ad6-5aecde8b7ea5"
version = "0.4.13"

[[Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "2fb1e02f2b635d0845df5d7c167fec4dd739b00d"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.9.3"

[[Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[DynamicQuantumCircuits]]
deps = ["LinearAlgebra", "Moshi", "OpenQASM", "RBNF", "SparseArrays", "StaticArrays"]
git-tree-sha1 = "e9ee039ef177584145ca6690259dab4ec4fad525"
uuid = "b9e8302f-12f4-484c-8961-adc524bf1aaa"
version = "0.0.2"

[[Expronicon]]
deps = ["MLStyle"]
git-tree-sha1 = "db30dc0e4012c2c30c9441d3eda5f73439f16f76"
uuid = "6b7a57c9-7cc1-4fdf-b7f5-e857abae3636"
version = "0.10.11"

[[ExproniconLite]]
git-tree-sha1 = "1095361e35ea8ad9c660560df4c03c06d5244956"
uuid = "55351af7-c7e9-48d6-89ff-24e801d99491"
version = "0.10.11"

[[FileIO]]
deps = ["Pkg", "Requires", "UUIDs"]
git-tree-sha1 = "82d8afa92ecf4b52d78d869f038ebfb881267322"
uuid = "5789e2e9-d7fb-5bc7-8068-2c6fae9b9549"
version = "1.16.3"

[[FilePaths]]
deps = ["FilePathsBase", "MacroTools", "Reexport", "Requires"]
git-tree-sha1 = "919d9412dbf53a2e6fe74af62a73ceed0bce0629"
uuid = "8fc22ac5-c921-52a6-82fd-178b2807b824"
version = "0.8.3"

[[FilePathsBase]]
deps = ["Compat", "Dates", "Mmap", "Printf", "Test", "UUIDs"]
git-tree-sha1 = "9f00e42f8d99fdde64d40c8ea5d14269a2e2c1aa"
uuid = "48062228-2e41-5def-b9a4-89aafe57970f"
version = "0.9.21"

[[FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "05882d6995ae5c12bb5f36dd2ed3f61c98cbb172"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.5"

[[Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"

[[Graphs]]
deps = ["ArnoldiMethod", "Compat", "DataStructures", "Distributed", "Inflate", "LinearAlgebra", "Random", "SharedArrays", "SimpleTraits", "SparseArrays", "Statistics"]
git-tree-sha1 = "ebd18c326fa6cee1efb7da9a3b45cf69da2ed4d9"
uuid = "86223c79-3864-5bf0-83f7-82e725a168b6"
version = "1.11.2"

[[Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "179267cfa5e712760cd43dcae385d7ea90cc25a4"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.5"

[[HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "7134810b1afce04bbc1045ca1985fbe81ce17653"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.5"

[[IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "b6d6bfdd7ce25b0f9b2f6b3dd56b2673a66c8770"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.5"

[[Inflate]]
git-tree-sha1 = "d1b1b796e47d94588b3757fe84fbf65a5ec4a80d"
uuid = "d25df0c9-e2be-5dd7-82c8-3ad0b3e990b9"
version = "0.1.5"

[[InlineStrings]]
git-tree-sha1 = "45521d31238e87ee9f9732561bfee12d4eebd52d"
uuid = "842dd82b-1e85-43dc-bf29-5d0ee9dffc48"
version = "1.4.2"

    [InlineStrings.extensions]
    ArrowTypesExt = "ArrowTypes"
    ParsersExt = "Parsers"

    [InlineStrings.weakdeps]
    ArrowTypes = "31f734f8-188a-4ce0-8406-c8a06bd891cd"
    Parsers = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"

[[InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[InvertedIndices]]
git-tree-sha1 = "0dc7b50b8d436461be01300fd8cd45aa0274b038"
uuid = "41ab1584-1d38-5bbf-9106-f11c6c58b48f"
version = "1.3.0"

[[IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "31e996f0a15c7b280ba9f76636b3ff9e2ae58c9a"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.4"

[[JSON3]]
deps = ["Dates", "Mmap", "Parsers", "PrecompileTools", "StructTypes", "UUIDs"]
git-tree-sha1 = "eb3edce0ed4fa32f75a0a11217433c31d56bd48b"
uuid = "0f8b85d8-7281-11e9-16c2-39a750bddbf1"
version = "1.14.0"

    [JSON3.extensions]
    JSON3ArrowExt = ["ArrowTypes"]

    [JSON3.weakdeps]
    ArrowTypes = "31f734f8-188a-4ce0-8406-c8a06bd891cd"

[[JSONSchema]]
deps = ["Downloads", "JSON", "JSON3", "URIs"]
git-tree-sha1 = "5f0bd0cd69df978fa64ccdcb5c152fbc705455a1"
uuid = "7d188eb4-7ad8-530c-ae41-71a32a6d4692"
version = "1.3.0"

[[Jieko]]
deps = ["DocStringExtensions", "ExproniconLite"]
git-tree-sha1 = "fede6c8104e3057755a72512b5b6d6076b9e77e2"
uuid = "ae98c720-c025-4a4a-838c-29b094483192"
version = "0.1.2"

[[LaTeXStrings]]
git-tree-sha1 = "50901ebc375ed41dbf8058da26f9de442febbbec"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.3.1"

[[LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.4"

[[LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "8.4.0+0"

[[LibGit2]]
deps = ["Base64", "LibGit2_jll", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[LibGit2_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll"]
uuid = "e37daf67-58a4-590a-8e99-b0245dd2ffc5"
version = "1.6.4+0"

[[LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.11.0+1"

[[Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[LinearAlgebra]]
deps = ["Libdl", "OpenBLAS_jll", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[MIMEs]]
git-tree-sha1 = "65f28ad4b594aebe22157d6fac869786a255b7eb"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "0.1.4"

[[MLStyle]]
git-tree-sha1 = "bc38dff0548128765760c79eb7388a4b37fae2c8"
uuid = "d8e11817-5142-5d16-987a-aa16d5891078"
version = "0.4.17"

[[MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "2fa9ee3e63fd3a4f7a9a4f4744a52f4856de82df"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.13"

[[Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.2+1"

[[Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "ec4f7fbeab05d7747bdf98eb74d130a2a2ed298d"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.2.0"

[[Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[Moshi]]
deps = ["ExproniconLite", "Jieko"]
git-tree-sha1 = "0518b395aeee45b02d65a06aee8a3b9bd56ac6de"
uuid = "2e0e35c7-a2e4-4343-998d-7ef72827ed2d"
version = "0.2.0"

[[MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2023.1.10"

[[Multigraphs]]
deps = ["Graphs", "LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "055a7c49a626e17a8c99bcaaf472d0de60848929"
uuid = "7ebac608-6c66-46e6-9856-b5f43e107bac"
version = "0.3.0"

[[NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[NodeJS]]
deps = ["Pkg"]
git-tree-sha1 = "bf1f49fd62754064bc42490a8ddc2aa3694a8e7a"
uuid = "2bd173c7-0d6d-553b-b6af-13a54713934c"
version = "2.0.0"

[[OMEinsum]]
deps = ["AbstractTrees", "BatchedRoutines", "ChainRulesCore", "Combinatorics", "LinearAlgebra", "MacroTools", "OMEinsumContractionOrders", "Test", "TupleTools"]
git-tree-sha1 = "fd0ce51747b27676ecb5cf21ea652f20e1a28c70"
uuid = "ebe7aa44-baf0-506c-a96f-8464559b3922"
version = "0.8.2"

    [OMEinsum.extensions]
    AMDGPUExt = "AMDGPU"
    CUDAExt = "CUDA"

    [OMEinsum.weakdeps]
    AMDGPU = "21141c5a-9bdb-4563-92ae-f87d6854732e"
    CUDA = "052768ef-5323-5732-b1bb-66c8b64840ba"

[[OMEinsumContractionOrders]]
deps = ["AbstractTrees", "BetterExp", "JSON", "SparseArrays", "Suppressor"]
git-tree-sha1 = "b0cba9f4a6f021a63b066f0bb29a6fd63c93be44"
uuid = "6f22d1fd-8eed-4bb7-9776-e7d684900715"
version = "0.8.3"

    [OMEinsumContractionOrders.extensions]
    KaHyParExt = ["KaHyPar"]

    [OMEinsumContractionOrders.weakdeps]
    KaHyPar = "2a6221f6-aa48-11e9-3542-2d9e0ef01880"

[[OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.23+4"

[[OpenQASM]]
deps = ["MLStyle", "RBNF"]
git-tree-sha1 = "aa6c47be6512e3299d9e56224d13d6a2303e3d6e"
uuid = "a8821629-a4c0-4df7-9e00-12969ff383a7"
version = "2.1.4"

[[OrderedCollections]]
git-tree-sha1 = "dfdf5519f235516220579f949664f1bf44e741c5"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.6.3"

[[Parsers]]
deps = ["Dates", "PrecompileTools", "UUIDs"]
git-tree-sha1 = "8489905bcdbcfac64d1daa51ca07c0d8f0283821"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.8.1"

[[Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "FileWatching", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.10.0"

[[PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "FixedPointNumbers", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "MIMEs", "Markdown", "Random", "Reexport", "URIs", "UUIDs"]
git-tree-sha1 = "ab55ee1510ad2af0ff674dbcced5e94921f867a9"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.59"

[[PooledArrays]]
deps = ["DataAPI", "Future"]
git-tree-sha1 = "36d8b4b899628fb92c2749eb488d884a926614d3"
uuid = "2dfb63ee-cc39-5dd5-95bd-886bf059d720"
version = "1.4.3"

[[PrecompileTools]]
deps = ["Preferences"]
git-tree-sha1 = "5aa36f7049a63a1528fe8f7c3f2113413ffd4e1f"
uuid = "aea7be01-6a6a-4083-8856-8a6e6704d82a"
version = "1.2.1"

[[Preferences]]
deps = ["TOML"]
git-tree-sha1 = "9306f6085165d270f7e3db02af26a400d580f5c6"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.4.3"

[[PrettyPrint]]
git-tree-sha1 = "632eb4abab3449ab30c5e1afaa874f0b98b586e4"
uuid = "8162dcfd-2161-5ef2-ae6c-7681170c5f98"
version = "0.2.0"

[[PrettyTables]]
deps = ["Crayons", "LaTeXStrings", "Markdown", "PrecompileTools", "Printf", "Reexport", "StringManipulation", "Tables"]
git-tree-sha1 = "66b20dd35966a748321d3b2537c4584cf40387c7"
uuid = "08abe8d2-0d0c-5749-adfa-8a2ac140af0d"
version = "2.3.2"

[[Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[RBNF]]
deps = ["DataStructures", "MLStyle", "PrettyPrint"]
git-tree-sha1 = "12c19821099177fad12336af5e3d0ca8f41eb3d3"
uuid = "83ef0002-5b9e-11e9-219b-65bac3c6d69c"
version = "0.2.4"

[[REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[Random]]
deps = ["SHA"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "838a3a4188e2ded87a4f9f184b4b0d78a1e91cb7"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.0"

[[SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[SentinelArrays]]
deps = ["Dates", "Random"]
git-tree-sha1 = "ff11acffdb082493657550959d4feb4b6149e73a"
uuid = "91c51154-3ec4-41a3-a24f-3f23e20d615c"
version = "1.4.5"

[[Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[Setfield]]
deps = ["ConstructionBase", "Future", "MacroTools", "StaticArraysCore"]
git-tree-sha1 = "e2cc6d8c88613c05e1defb55170bf5ff211fbeac"
uuid = "efcf1570-3423-57d1-acb7-fd33fddbac46"
version = "1.1.1"

[[SharedArrays]]
deps = ["Distributed", "Mmap", "Random", "Serialization"]
uuid = "1a1011a3-84de-559e-8e89-a11a2f7dc383"

[[SimpleTraits]]
deps = ["InteractiveUtils", "MacroTools"]
git-tree-sha1 = "5d7e3f4e11935503d3ecaf7186eac40602e7d231"
uuid = "699a6c99-e7fa-54fc-8d76-47d257e15c1d"
version = "0.9.4"

[[Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "66e0a8e672a0bdfca2c3f5937efb8538b9ddc085"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.2.1"

[[SparseArrays]]
deps = ["Libdl", "LinearAlgebra", "Random", "Serialization", "SuiteSparse_jll"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
version = "1.10.0"

[[StaticArrays]]
deps = ["LinearAlgebra", "PrecompileTools", "Random", "StaticArraysCore"]
git-tree-sha1 = "eeafab08ae20c62c44c8399ccb9354a04b80db50"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.9.7"
weakdeps = ["ChainRulesCore", "Statistics"]

    [StaticArrays.extensions]
    StaticArraysChainRulesCoreExt = "ChainRulesCore"
    StaticArraysStatisticsExt = "Statistics"

[[StaticArraysCore]]
git-tree-sha1 = "192954ef1208c7019899fbf8049e717f92959682"
uuid = "1e83bf80-4336-4d27-bf5d-d5a4f845583c"
version = "1.4.3"

[[Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
version = "1.10.0"

[[StringManipulation]]
deps = ["PrecompileTools"]
git-tree-sha1 = "a04cabe79c5f01f4d723cc6704070ada0b9d46d5"
uuid = "892a3eda-7b42-436c-8928-eab12a02cf0e"
version = "0.3.4"

[[StructTypes]]
deps = ["Dates", "UUIDs"]
git-tree-sha1 = "ca4bccb03acf9faaf4137a9abc1881ed1841aa70"
uuid = "856f2bd8-1eba-4b0a-8007-ebc267875bd4"
version = "1.10.0"

[[SuiteSparse_jll]]
deps = ["Artifacts", "Libdl", "libblastrampoline_jll"]
uuid = "bea87d4a-7f5b-5778-9afe-8cc45184846c"
version = "7.2.1+1"

[[Suppressor]]
deps = ["Logging"]
git-tree-sha1 = "9143c41bd539a8885c79728b9dedb0ce47dc9819"
uuid = "fd094767-a336-5f1f-9728-57cf17d0bbfb"
version = "0.2.7"

[[TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.3"

[[TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[TableTraitsUtils]]
deps = ["DataValues", "IteratorInterfaceExtensions", "Missings", "TableTraits"]
git-tree-sha1 = "78fecfe140d7abb480b53a44f3f85b6aa373c293"
uuid = "382cd787-c1b6-5bf2-a167-d5b971a19bda"
version = "1.0.2"

[[Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "OrderedCollections", "TableTraits"]
git-tree-sha1 = "598cd7c1f68d1e205689b1c2fe65a9f85846f297"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.12.0"

[[Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.0"

[[Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[Tricks]]
git-tree-sha1 = "eae1bb484cd63b36999ee58be2de6c178105112f"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.8"

[[TupleTools]]
git-tree-sha1 = "41d61b1c545b06279871ef1a4b5fcb2cac2191cd"
uuid = "9d95972d-f1c8-5527-a6e0-b4b365fa01f6"
version = "1.5.0"

[[URIParser]]
deps = ["Unicode"]
git-tree-sha1 = "53a9f49546b8d2dd2e688d216421d050c9a31d0d"
uuid = "30578b45-9adc-5946-b283-645ec420af67"
version = "0.4.1"

[[URIs]]
git-tree-sha1 = "67db6cc7b3821e19ebe75791a9dd19c9b1188f2b"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.5.1"

[[UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[Vega]]
deps = ["BufferedStreams", "DataStructures", "DataValues", "Dates", "FileIO", "FilePaths", "IteratorInterfaceExtensions", "JSON", "JSONSchema", "MacroTools", "NodeJS", "Pkg", "REPL", "Random", "Setfield", "TableTraits", "TableTraitsUtils", "URIParser"]
git-tree-sha1 = "0efd71a3df864e86d24236c99aaae3970e6f0ed0"
uuid = "239c3e63-733f-47ad-beb7-a12fde22c578"
version = "2.7.0"

[[YaoHIR]]
deps = ["Expronicon", "MLStyle", "YaoLocations"]
git-tree-sha1 = "b1e17fb84f1b322bef9910c942c1c9beb3e919ef"
uuid = "6769671a-fce8-4286-b3f7-6099e1b1298a"
version = "0.2.3"
weakdeps = ["OpenQASM"]

    [YaoHIR.extensions]
    YaoHIRExt = ["OpenQASM"]

[[YaoLocations]]
git-tree-sha1 = "c90c42c8668c9096deb0c861822f0f8f80cbdc68"
uuid = "66df03fb-d475-48f7-b449-3d9064bf085b"
version = "0.1.6"

[[ZXCalculus]]
deps = ["Expronicon", "Graphs", "LinearAlgebra", "MLStyle", "Multigraphs", "OMEinsum", "SparseArrays", "YaoHIR", "YaoLocations"]
git-tree-sha1 = "64cfab6eeafcbb61a1846752d49186a5350a64f0"
uuid = "3525faa3-032d-4235-a8d4-8c2939a218dd"
version = "0.7.0"
weakdeps = ["DataFrames", "Vega"]

    [ZXCalculus.extensions]
    ZXCalculusExt = ["Vega", "DataFrames"]

[[Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.13+1"

[[libblastrampoline_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.8.0+1"

[[nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.52.0+1"

[[p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+2"
"""

# ╔═╡ Cell order:
# ╠═dd08aa73-0d86-4f8b-970b-59f9ad9fac2d
# ╠═506db9e1-4260-408d-ba72-51581b548e53
# ╟─db7e9cf8-9abf-448b-be68-43231853faff
# ╟─c06c5b9f-e5c1-4d0c-8ed5-937ad3871d3d
# ╟─5e0fb39e-68b3-45f6-8cb2-2dd0b79b35d4
# ╠═587be022-6005-44d5-bb72-53cc9e3ba3bb
# ╠═482fdb57-2b0b-44b9-a5a0-f4dc26e15a7d
# ╠═57301b22-969f-481e-ae0b-0336e1ee5055
# ╠═a8470d1a-8dc1-4a86-85b9-efd1836cf42c
# ╠═6e823d50-9107-4488-897e-d647334573f9
# ╠═e3aa4e99-cb1f-478b-9e80-82b0ab02f606
# ╠═a44ef98a-61fb-4271-9d36-c4d096f7e600
# ╠═fb2448ef-aebe-419f-ad1d-a161edacd5a0
# ╠═38da72a7-7e81-426f-ba08-b4158dc6a011
# ╠═742750be-1262-4cbe-b476-f62e5e5c1fcf
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
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
