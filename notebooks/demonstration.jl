### A Pluto.jl notebook ###
# v0.19.46

using Markdown
using InteractiveUtils

# ╔═╡ aa11ea12-6a9c-11ee-11b6-77a1fbfdf4b5
begin
	# Extensions
  	using OpenQASM
	using Vega
	using DataFrames

  # ZX Calculus Tools
  using ZXCalculus, ZXCalculus.ZX
  using YaoHIR: BlockIR
  
  
  using PlutoUI

end

# ╔═╡ c467fe63-487b-4087-b166-01ed41a47eec
using MLStyle

# ╔═╡ 6ebebc14-6b0f-48b7-a8e4-fb6f7f9f7f0e
begin
    function Base.show(io::IO, mime::MIME"text/html", zx::Union{ZXDiagram,ZXGraph})
        g = ZXCalculus.plot(zx)
        Base.show(io, mime, g)
    end
end


# ╔═╡ 639aaf18-e63b-4b07-8557-8e21a874d91a
begin
    b1 = BlockIR("""
   // Benchmark was created by MQT Bench on 2023-06-29
   // For more information about MQT Bench, please visit https://www.cda.cit.tum.de/mqtbench/
   // MQT Bench version: v1.0.0
   // TKET version: 1.16.0

   OPENQASM 2.0;
   include "qelib1.inc";

   qreg q[107];
   creg c[106];
   h q[0];
   h q[1];
   h q[2];
   h q[3];
   h q[4];
   h q[5];
   h q[6];
   h q[7];
   h q[8];
   h q[9];
   h q[10];
   h q[11];
   h q[12];
   h q[13];
   h q[14];
   h q[15];
   h q[16];
   h q[17];
   h q[18];
   h q[19];
   h q[20];
   h q[21];
   h q[22];
   h q[23];
   h q[24];
   h q[25];
   h q[26];
   h q[27];
   h q[28];
   h q[29];
   h q[30];
   h q[31];
   h q[32];
   h q[33];
   h q[34];
   h q[35];
   h q[36];
   h q[37];
   h q[38];
   h q[39];
   h q[40];
   h q[41];
   h q[42];
   h q[43];
   h q[44];
   h q[45];
   h q[46];
   h q[47];
   h q[48];
   h q[49];
   h q[50];
   h q[51];
   h q[52];
   h q[53];
   h q[54];
   h q[55];
   h q[56];
   h q[57];
   h q[58];
   h q[59];
   h q[60];
   h q[61];
   h q[62];
   h q[63];
   h q[64];
   h q[65];
   h q[66];
   h q[67];
   h q[68];
   h q[69];
   h q[70];
   h q[71];
   h q[72];
   h q[73];
   h q[74];
   h q[75];
   h q[76];

   h q[105];
   	""")
    c1 = ZXDiagram(b1)

end

# ╔═╡ 69587b8e-26cf-4862-abe6-f81cc6967db3
b1

# ╔═╡ 97eae154-ce25-4f22-b89a-af653f79dcd7
g1_reduced = full_reduction(c1)

# ╔═╡ 15e4062a-37b3-40dc-add3-9d8ad7520b4d
c2 = ZXDiagram(BlockIR("""
// Benchmark was created by MQT Bench on 2023-06-29
// For more information about MQT Bench, please visit https://www.cda.cit.tum.de/mqtbench/
// MQT Bench version: v1.0.0
// TKET version: 1.16.0

OPENQASM 2.0;
include "qelib1.inc";

qreg q[107];
creg c[106];
h q[0];
h q[1];
h q[2];
h q[3];
h q[4];
h q[5];
h q[6];
h q[7];
h q[8];
h q[9];
h q[10];
h q[11];
h q[12];
h q[13];
h q[14];
h q[15];
h q[16];
h q[17];
h q[18];
h q[19];
h q[20];
h q[21];
h q[22];
h q[23];
h q[24];
h q[25];
h q[26];
h q[27];
h q[28];
h q[29];
h q[30];
h q[31];
h q[32];
h q[33];
h q[34];
h q[35];
h q[36];
h q[37];
h q[38];
h q[39];
h q[40];
h q[41];
h q[42];
h q[43];
h q[44];
h q[45];
h q[46];
h q[47];
h q[48];
h q[49];
h q[50];
h q[51];
h q[52];
h q[53];
h q[54];
h q[55];
h q[56];
h q[57];
h q[58];
h q[59];
h q[60];
h q[61];
h q[62];
h q[63];
h q[64];
h q[65];
h q[66];
h q[67];
h q[68];
h q[69];
h q[70];
h q[71];
h q[72];
h q[73];
h q[74];
h q[75];
h q[76];
h q[77];
h q[78];
h q[79];
h q[80];
h q[81];
h q[82];
h q[83];
h q[84];
h q[85];
h q[86];
h q[87];
h q[88];
h q[89];
h q[90];
h q[91];
h q[92];
h q[93];
h q[94];
h q[95];
h q[96];
h q[97];
h q[98];
h q[99];
h q[100];
h q[101];
h q[102];
h q[103];
h q[104];
h q[105];
x q[106];
x q[0];
x q[1];
x q[3];
x q[5];
x q[6];
x q[8];
x q[9];
x q[11];
x q[12];
x q[15];
x q[21];
x q[24];
x q[25];
x q[28];
x q[31];
x q[35];
x q[36];
x q[38];
x q[39];
x q[40];
x q[41];
x q[42];
x q[44];
x q[49];
x q[51];
x q[52];
x q[53];
x q[55];
x q[57];
x q[58];
x q[60];
x q[63];
x q[67];
x q[68];
x q[72];
x q[74];
x q[75];
x q[77];
x q[78];
x q[80];
x q[86];
x q[88];
x q[96];
x q[97];
x q[99];
x q[100];
x q[103];
h q[106];
cx q[0],q[106];
x q[0];
cx q[1],q[106];
h q[0];
x q[1];
cx q[2],q[106];
h q[1];
h q[2];
cx q[3],q[106];
x q[3];
cx q[4],q[106];
h q[3];
h q[4];
cx q[5],q[106];
x q[5];
cx q[6],q[106];
h q[5];
x q[6];
cx q[7],q[106];
h q[6];
h q[7];
cx q[8],q[106];
x q[8];
cx q[9],q[106];
h q[8];
x q[9];
cx q[10],q[106];
h q[9];
h q[10];
cx q[11],q[106];
x q[11];
cx q[12],q[106];
h q[11];
x q[12];
cx q[13],q[106];
h q[12];
h q[13];
cx q[14],q[106];
h q[14];
cx q[15],q[106];
x q[15];
cx q[16],q[106];
h q[15];
h q[16];
cx q[17],q[106];
h q[17];
cx q[18],q[106];
h q[18];
cx q[19],q[106];
h q[19];
cx q[20],q[106];
h q[20];
cx q[21],q[106];
x q[21];
cx q[22],q[106];
h q[21];
h q[22];
cx q[23],q[106];
h q[23];
cx q[24],q[106];
x q[24];
cx q[25],q[106];
h q[24];
x q[25];
cx q[26],q[106];
h q[25];
h q[26];
cx q[27],q[106];
h q[27];
cx q[28],q[106];
x q[28];
cx q[29],q[106];
h q[28];
h q[29];
cx q[30],q[106];
h q[30];
cx q[31],q[106];
x q[31];
cx q[32],q[106];
h q[31];
h q[32];
cx q[33],q[106];
h q[33];
cx q[34],q[106];
h q[34];
cx q[35],q[106];
x q[35];
cx q[36],q[106];
h q[35];
x q[36];
cx q[37],q[106];
h q[36];
h q[37];
cx q[38],q[106];
x q[38];
cx q[39],q[106];
h q[38];
x q[39];
cx q[40],q[106];
h q[39];
x q[40];
cx q[41],q[106];
h q[40];
x q[41];
cx q[42],q[106];
h q[41];
x q[42];
cx q[43],q[106];
h q[42];
h q[43];
cx q[44],q[106];
x q[44];
cx q[45],q[106];
h q[44];
h q[45];
cx q[46],q[106];
h q[46];
cx q[47],q[106];
h q[47];
cx q[48],q[106];
h q[48];
cx q[49],q[106];
x q[49];
cx q[50],q[106];
h q[49];
h q[50];
cx q[51],q[106];
x q[51];
cx q[52],q[106];
h q[51];
x q[52];
cx q[53],q[106];
h q[52];
x q[53];
cx q[54],q[106];
h q[53];
h q[54];
cx q[55],q[106];
x q[55];
cx q[56],q[106];
h q[55];
h q[56];
cx q[57],q[106];
x q[57];
cx q[58],q[106];
h q[57];
x q[58];
cx q[59],q[106];
h q[58];
h q[59];
cx q[60],q[106];
x q[60];
cx q[61],q[106];
h q[60];
h q[61];
cx q[62],q[106];
h q[62];
cx q[63],q[106];
x q[63];
cx q[64],q[106];
h q[63];
h q[64];
cx q[65],q[106];
h q[65];
cx q[66],q[106];
h q[66];
cx q[67],q[106];
x q[67];
cx q[68],q[106];
h q[67];
x q[68];
cx q[69],q[106];
h q[68];
h q[69];
cx q[70],q[106];
h q[70];
cx q[71],q[106];
h q[71];
cx q[72],q[106];
x q[72];
cx q[73],q[106];
h q[72];
h q[73];
cx q[74],q[106];
x q[74];
cx q[75],q[106];
h q[74];
x q[75];
cx q[76],q[106];
h q[75];
h q[76];
cx q[77],q[106];
x q[77];
cx q[78],q[106];
h q[77];
x q[78];
cx q[79],q[106];
h q[78];
h q[79];
cx q[80],q[106];
x q[80];
cx q[81],q[106];
h q[80];
h q[81];
cx q[82],q[106];
h q[82];
cx q[83],q[106];
h q[83];
cx q[84],q[106];
h q[84];
cx q[85],q[106];
h q[85];
cx q[86],q[106];
x q[86];
cx q[87],q[106];
h q[86];
h q[87];
cx q[88],q[106];
x q[88];
cx q[89],q[106];
h q[88];
h q[89];
cx q[90],q[106];
h q[90];
cx q[91],q[106];
h q[91];
cx q[92],q[106];
h q[92];
cx q[93],q[106];
h q[93];
cx q[94],q[106];
h q[94];
cx q[95],q[106];
h q[95];
cx q[96],q[106];
x q[96];
cx q[97],q[106];
h q[96];
x q[97];
cx q[98],q[106];
h q[97];
h q[98];
cx q[99],q[106];
x q[99];
cx q[100],q[106];
h q[99];
x q[100];
cx q[101],q[106];
h q[100];
h q[101];
cx q[102],q[106];
h q[102];
cx q[103],q[106];
x q[103];
cx q[104],q[106];
h q[103];
h q[104];
cx q[105],q[106];
h q[105];
	"""))


# ╔═╡ e22922f8-5a54-475b-b325-dda82547c556


# ╔═╡ 37954f01-da8c-4018-a7e1-811d4a86fb26
c2_inv = dagger(c2)

# ╔═╡ c984b469-89d0-4d02-9264-e967697e50b3
g2_reduced = full_reduction(c2)

# ╔═╡ 996a236f-90b5-42bb-8627-19d5a7facef6
m_2 = concat!(c1, dagger(c2))

# ╔═╡ df136e09-4958-433d-a3ce-60f73a10968a
verify_equality(c1, c2)

# ╔═╡ 69d97139-73d2-4b3f-8d1f-aa8437880754
m = concat!(c1, c2_inv)

# ╔═╡ 57c4c6eb-54e1-4412-b3ca-3bd7588e4e34
full_reduction(m)

# ╔═╡ a092392c-eff5-4c5a-be9b-c9e67881cf46
verify_equality(c1, c2)

# ╔═╡ a6819a4e-3029-4fec-9baa-8ec842755e49
contains_only_bare_wires(m)

# ╔═╡ d9da3492-048d-4458-aa37-801e84b61ec7
typeof(c2.st[3])

# ╔═╡ d65ab9bd-6dcc-4502-a8fb-301abf404856
vs = spider_sequence(c2)

# ╔═╡ 27b7b121-0c13-49ed-97e6-c73386e844a0
st = SpiderType.Z

# ╔═╡ ed656d2d-c4af-45a3-a5d8-5fd8c1cccac8
st

# ╔═╡ 1b36a6ba-5498-4aa5-ab67-67dff42c8422
st == SpiderType.Z || st == SpiderType.Z || st == SpiderType.H

# ╔═╡ ab841776-6b79-4662-9998-04f513370fee
Int(SpiderType.X)

# ╔═╡ 4ff2d0e2-9dda-405d-aa77-9abb70eace77
SpiderType.H == SpiderType.Out

# ╔═╡ 7bec3f25-507a-42e8-8547-cae8bfc317d8
dj3 = ZXDiagram(BlockIR("""
OPENQASM 2.0;
include "qelib1.inc";

qreg q[3];
creg c[2];
h q[0];
h q[1];
x q[2];
x q[0];
x q[1];
h q[2];
cx q[0],q[2];
x q[0];
cx q[1],q[2];
h q[0];
x q[1];
h q[1];
"""))

# ╔═╡ f3235791-4582-44a3-ba68-6c39a0d0b26b
verify_equality(dj3, dj3)

# ╔═╡ 7220947a-f153-4bb7-a0ba-972af51d3fe7
dj_m = concat!(copy(dj3), dagger(dj3))

# ╔═╡ 3f98b870-a534-4f69-b460-64c59cd8ef96
dj3_reduced = full_reduction(dj_m)

# ╔═╡ dd5c40da-0530-4975-8245-78538ad6d244
replace!(Rule{:id}(), dj3_reduced)


# ╔═╡ a48d68b5-559a-4937-a2b7-c13e5f5181b0
show(dj3_reduced)

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
MLStyle = "d8e11817-5142-5d16-987a-aa16d5891078"
OpenQASM = "a8821629-a4c0-4df7-9e00-12969ff383a7"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
Vega = "239c3e63-733f-47ad-beb7-a12fde22c578"
YaoHIR = "6769671a-fce8-4286-b3f7-6099e1b1298a"
ZXCalculus = "3525faa3-032d-4235-a8d4-8c2939a218dd"

[compat]
DataFrames = "~1.6.1"
MLStyle = "~0.4.17"
OpenQASM = "~2.1.4"
PlutoUI = "~0.7.55"
Vega = "~2.6.2"
YaoHIR = "~0.2.2"
ZXCalculus = "~0.6.0"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.10.5"
manifest_format = "2.0"
project_hash = "dc2131f03a0dd356c9b167032d6d5c79ba566e98"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "c278dfab760520b8bb7e9511b968bf4ba38b7acc"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.2.3"

[[deps.AbstractTrees]]
git-tree-sha1 = "faa260e4cb5aba097a73fab382dd4b5819d8ec8c"
uuid = "1520ce14-60c1-5f80-bbc7-55ef81b5835c"
version = "0.4.4"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.ArnoldiMethod]]
deps = ["LinearAlgebra", "Random", "StaticArrays"]
git-tree-sha1 = "62e51b39331de8911e4a7ff6f5aaf38a5f4cc0ae"
uuid = "ec485272-7323-5ecc-a04f-4719b315124d"
version = "0.2.0"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.BatchedRoutines]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "441db9f0399bcfb4eeb8b891a6b03f7acc5dc731"
uuid = "a9ab73d0-e05c-5df1-8fde-d6a4645b8d8e"
version = "0.2.2"

[[deps.BetterExp]]
git-tree-sha1 = "dd3448f3d5b2664db7eceeec5f744535ce6e759b"
uuid = "7cffe744-45fd-4178-b173-cf893948b8b7"
version = "0.1.0"

[[deps.BufferedStreams]]
git-tree-sha1 = "4ae47f9a4b1dc19897d3743ff13685925c5202ec"
uuid = "e1450e63-4bb3-523b-b2a4-4ffa8c0fd77d"
version = "1.2.1"

[[deps.ChainRulesCore]]
deps = ["Compat", "LinearAlgebra"]
git-tree-sha1 = "ad25e7d21ce10e01de973cdc68ad0f850a953c52"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.21.1"
weakdeps = ["SparseArrays"]

    [deps.ChainRulesCore.extensions]
    ChainRulesCoreSparseArraysExt = "SparseArrays"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "eb7f0f8307f71fac7c606984ea5fb2817275d6e4"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.4"

[[deps.Combinatorics]]
git-tree-sha1 = "08c8b6831dc00bfea825826be0bc8336fc369860"
uuid = "861a8166-3701-5b0c-9a16-15d98fcdc6aa"
version = "1.0.2"

[[deps.Compat]]
deps = ["TOML", "UUIDs"]
git-tree-sha1 = "75bd5b6fc5089df449b5d35fa501c846c9b6549b"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.12.0"
weakdeps = ["Dates", "LinearAlgebra"]

    [deps.Compat.extensions]
    CompatLinearAlgebraExt = "LinearAlgebra"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.1.1+0"

[[deps.ConstructionBase]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "c53fc348ca4d40d7b371e71fd52251839080cbc9"
uuid = "187b0558-2788-49d3-abe0-74a17ed4e7c9"
version = "1.5.4"

    [deps.ConstructionBase.extensions]
    ConstructionBaseIntervalSetsExt = "IntervalSets"
    ConstructionBaseStaticArraysExt = "StaticArrays"

    [deps.ConstructionBase.weakdeps]
    IntervalSets = "8197267c-284f-5f27-9208-e0e47529a953"
    StaticArrays = "90137ffa-7385-5640-81b9-e52037218182"

[[deps.Crayons]]
git-tree-sha1 = "249fe38abf76d48563e2f4556bebd215aa317e15"
uuid = "a8cc5b0e-0ffa-5ad4-8c14-923d3ee1735f"
version = "4.1.1"

[[deps.DataAPI]]
git-tree-sha1 = "abe83f3a2f1b857aac70ef8b269080af17764bbe"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.16.0"

[[deps.DataFrames]]
deps = ["Compat", "DataAPI", "DataStructures", "Future", "InlineStrings", "InvertedIndices", "IteratorInterfaceExtensions", "LinearAlgebra", "Markdown", "Missings", "PooledArrays", "PrecompileTools", "PrettyTables", "Printf", "REPL", "Random", "Reexport", "SentinelArrays", "SortingAlgorithms", "Statistics", "TableTraits", "Tables", "Unicode"]
git-tree-sha1 = "04c738083f29f86e62c8afc341f0967d8717bdb8"
uuid = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
version = "1.6.1"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "ac67408d9ddf207de5cfa9a97e114352430f01ed"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.16"

[[deps.DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[deps.DataValues]]
deps = ["DataValueInterfaces", "Dates"]
git-tree-sha1 = "d88a19299eba280a6d062e135a43f00323ae70bf"
uuid = "e7dc6d0d-1eca-5fa6-8ad6-5aecde8b7ea5"
version = "0.4.13"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.Expronicon]]
deps = ["MLStyle"]
git-tree-sha1 = "d64373d3c6ca8605baf3f8569e92c0564c17479b"
uuid = "6b7a57c9-7cc1-4fdf-b7f5-e857abae3636"
version = "0.10.5"

[[deps.FileIO]]
deps = ["Pkg", "Requires", "UUIDs"]
git-tree-sha1 = "c5c28c245101bd59154f649e19b038d15901b5dc"
uuid = "5789e2e9-d7fb-5bc7-8068-2c6fae9b9549"
version = "1.16.2"

[[deps.FilePaths]]
deps = ["FilePathsBase", "MacroTools", "Reexport", "Requires"]
git-tree-sha1 = "919d9412dbf53a2e6fe74af62a73ceed0bce0629"
uuid = "8fc22ac5-c921-52a6-82fd-178b2807b824"
version = "0.8.3"

[[deps.FilePathsBase]]
deps = ["Compat", "Dates", "Mmap", "Printf", "Test", "UUIDs"]
git-tree-sha1 = "9f00e42f8d99fdde64d40c8ea5d14269a2e2c1aa"
uuid = "48062228-2e41-5def-b9a4-89aafe57970f"
version = "0.9.21"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[deps.Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"

[[deps.Graphs]]
deps = ["ArnoldiMethod", "Compat", "DataStructures", "Distributed", "Inflate", "LinearAlgebra", "Random", "SharedArrays", "SimpleTraits", "SparseArrays", "Statistics"]
git-tree-sha1 = "899050ace26649433ef1af25bc17a815b3db52b7"
uuid = "86223c79-3864-5bf0-83f7-82e725a168b6"
version = "1.9.0"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "179267cfa5e712760cd43dcae385d7ea90cc25a4"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.5"

[[deps.HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "7134810b1afce04bbc1045ca1985fbe81ce17653"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.5"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "8b72179abc660bfab5e28472e019392b97d0985c"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.4"

[[deps.Inflate]]
git-tree-sha1 = "ea8031dea4aff6bd41f1df8f2fdfb25b33626381"
uuid = "d25df0c9-e2be-5dd7-82c8-3ad0b3e990b9"
version = "0.1.4"

[[deps.InlineStrings]]
deps = ["Parsers"]
git-tree-sha1 = "9cc2baf75c6d09f9da536ddf58eb2f29dedaf461"
uuid = "842dd82b-1e85-43dc-bf29-5d0ee9dffc48"
version = "1.4.0"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.InvertedIndices]]
git-tree-sha1 = "0dc7b50b8d436461be01300fd8cd45aa0274b038"
uuid = "41ab1584-1d38-5bbf-9106-f11c6c58b48f"
version = "1.3.0"

[[deps.IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "31e996f0a15c7b280ba9f76636b3ff9e2ae58c9a"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.4"

[[deps.JSON3]]
deps = ["Dates", "Mmap", "Parsers", "PrecompileTools", "StructTypes", "UUIDs"]
git-tree-sha1 = "eb3edce0ed4fa32f75a0a11217433c31d56bd48b"
uuid = "0f8b85d8-7281-11e9-16c2-39a750bddbf1"
version = "1.14.0"

    [deps.JSON3.extensions]
    JSON3ArrowExt = ["ArrowTypes"]

    [deps.JSON3.weakdeps]
    ArrowTypes = "31f734f8-188a-4ce0-8406-c8a06bd891cd"

[[deps.JSONSchema]]
deps = ["Downloads", "JSON", "JSON3", "URIs"]
git-tree-sha1 = "5f0bd0cd69df978fa64ccdcb5c152fbc705455a1"
uuid = "7d188eb4-7ad8-530c-ae41-71a32a6d4692"
version = "1.3.0"

[[deps.LaTeXStrings]]
git-tree-sha1 = "50901ebc375ed41dbf8058da26f9de442febbbec"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.3.1"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.4"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "8.4.0+0"

[[deps.LibGit2]]
deps = ["Base64", "LibGit2_jll", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[deps.LibGit2_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll"]
uuid = "e37daf67-58a4-590a-8e99-b0245dd2ffc5"
version = "1.6.4+0"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.11.0+1"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.LinearAlgebra]]
deps = ["Libdl", "OpenBLAS_jll", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.MIMEs]]
git-tree-sha1 = "65f28ad4b594aebe22157d6fac869786a255b7eb"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "0.1.4"

[[deps.MLStyle]]
git-tree-sha1 = "bc38dff0548128765760c79eb7388a4b37fae2c8"
uuid = "d8e11817-5142-5d16-987a-aa16d5891078"
version = "0.4.17"

[[deps.MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "2fa9ee3e63fd3a4f7a9a4f4744a52f4856de82df"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.13"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.2+1"

[[deps.Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "f66bdc5de519e8f8ae43bdc598782d35a25b1272"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.1.0"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2023.1.10"

[[deps.Multigraphs]]
deps = ["Graphs", "LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "055a7c49a626e17a8c99bcaaf472d0de60848929"
uuid = "7ebac608-6c66-46e6-9856-b5f43e107bac"
version = "0.3.0"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.NodeJS]]
deps = ["Pkg"]
git-tree-sha1 = "bf1f49fd62754064bc42490a8ddc2aa3694a8e7a"
uuid = "2bd173c7-0d6d-553b-b6af-13a54713934c"
version = "2.0.0"

[[deps.OMEinsum]]
deps = ["AbstractTrees", "BatchedRoutines", "ChainRulesCore", "Combinatorics", "LinearAlgebra", "MacroTools", "OMEinsumContractionOrders", "Test", "TupleTools"]
git-tree-sha1 = "3b7f8f3ffb63e3c7fd0d9b364862a2e35f70478e"
uuid = "ebe7aa44-baf0-506c-a96f-8464559b3922"
version = "0.7.6"

    [deps.OMEinsum.extensions]
    CUDAExt = "CUDA"

    [deps.OMEinsum.weakdeps]
    CUDA = "052768ef-5323-5732-b1bb-66c8b64840ba"

[[deps.OMEinsumContractionOrders]]
deps = ["AbstractTrees", "BetterExp", "JSON", "SparseArrays", "Suppressor"]
git-tree-sha1 = "b0cba9f4a6f021a63b066f0bb29a6fd63c93be44"
uuid = "6f22d1fd-8eed-4bb7-9776-e7d684900715"
version = "0.8.3"

    [deps.OMEinsumContractionOrders.extensions]
    KaHyParExt = ["KaHyPar"]

    [deps.OMEinsumContractionOrders.weakdeps]
    KaHyPar = "2a6221f6-aa48-11e9-3542-2d9e0ef01880"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.23+4"

[[deps.OpenQASM]]
deps = ["MLStyle", "RBNF"]
git-tree-sha1 = "aa6c47be6512e3299d9e56224d13d6a2303e3d6e"
uuid = "a8821629-a4c0-4df7-9e00-12969ff383a7"
version = "2.1.4"

[[deps.OrderedCollections]]
git-tree-sha1 = "dfdf5519f235516220579f949664f1bf44e741c5"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.6.3"

[[deps.Parsers]]
deps = ["Dates", "PrecompileTools", "UUIDs"]
git-tree-sha1 = "8489905bcdbcfac64d1daa51ca07c0d8f0283821"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.8.1"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "FileWatching", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.10.0"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "FixedPointNumbers", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "MIMEs", "Markdown", "Random", "Reexport", "URIs", "UUIDs"]
git-tree-sha1 = "68723afdb616445c6caaef6255067a8339f91325"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.55"

[[deps.PooledArrays]]
deps = ["DataAPI", "Future"]
git-tree-sha1 = "36d8b4b899628fb92c2749eb488d884a926614d3"
uuid = "2dfb63ee-cc39-5dd5-95bd-886bf059d720"
version = "1.4.3"

[[deps.PrecompileTools]]
deps = ["Preferences"]
git-tree-sha1 = "03b4c25b43cb84cee5c90aa9b5ea0a78fd848d2f"
uuid = "aea7be01-6a6a-4083-8856-8a6e6704d82a"
version = "1.2.0"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "00805cd429dcb4870060ff49ef443486c262e38e"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.4.1"

[[deps.PrettyPrint]]
git-tree-sha1 = "632eb4abab3449ab30c5e1afaa874f0b98b586e4"
uuid = "8162dcfd-2161-5ef2-ae6c-7681170c5f98"
version = "0.2.0"

[[deps.PrettyTables]]
deps = ["Crayons", "LaTeXStrings", "Markdown", "PrecompileTools", "Printf", "Reexport", "StringManipulation", "Tables"]
git-tree-sha1 = "88b895d13d53b5577fd53379d913b9ab9ac82660"
uuid = "08abe8d2-0d0c-5749-adfa-8a2ac140af0d"
version = "2.3.1"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.RBNF]]
deps = ["DataStructures", "MLStyle", "PrettyPrint"]
git-tree-sha1 = "c7da51b46fb5d206ffe19f7c2e86d1cae7bd7fd5"
uuid = "83ef0002-5b9e-11e9-219b-65bac3c6d69c"
version = "0.2.3"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "838a3a4188e2ded87a4f9f184b4b0d78a1e91cb7"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.0"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.SentinelArrays]]
deps = ["Dates", "Random"]
git-tree-sha1 = "0e7508ff27ba32f26cd459474ca2ede1bc10991f"
uuid = "91c51154-3ec4-41a3-a24f-3f23e20d615c"
version = "1.4.1"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.Setfield]]
deps = ["ConstructionBase", "Future", "MacroTools", "StaticArraysCore"]
git-tree-sha1 = "e2cc6d8c88613c05e1defb55170bf5ff211fbeac"
uuid = "efcf1570-3423-57d1-acb7-fd33fddbac46"
version = "1.1.1"

[[deps.SharedArrays]]
deps = ["Distributed", "Mmap", "Random", "Serialization"]
uuid = "1a1011a3-84de-559e-8e89-a11a2f7dc383"

[[deps.SimpleTraits]]
deps = ["InteractiveUtils", "MacroTools"]
git-tree-sha1 = "5d7e3f4e11935503d3ecaf7186eac40602e7d231"
uuid = "699a6c99-e7fa-54fc-8d76-47d257e15c1d"
version = "0.9.4"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "66e0a8e672a0bdfca2c3f5937efb8538b9ddc085"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.2.1"

[[deps.SparseArrays]]
deps = ["Libdl", "LinearAlgebra", "Random", "Serialization", "SuiteSparse_jll"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
version = "1.10.0"

[[deps.StaticArrays]]
deps = ["LinearAlgebra", "PrecompileTools", "Random", "StaticArraysCore"]
git-tree-sha1 = "7b0e9c14c624e435076d19aea1e5cbdec2b9ca37"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.9.2"
weakdeps = ["ChainRulesCore", "Statistics"]

    [deps.StaticArrays.extensions]
    StaticArraysChainRulesCoreExt = "ChainRulesCore"
    StaticArraysStatisticsExt = "Statistics"

[[deps.StaticArraysCore]]
git-tree-sha1 = "36b3d696ce6366023a0ea192b4cd442268995a0d"
uuid = "1e83bf80-4336-4d27-bf5d-d5a4f845583c"
version = "1.4.2"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
version = "1.10.0"

[[deps.StringManipulation]]
deps = ["PrecompileTools"]
git-tree-sha1 = "a04cabe79c5f01f4d723cc6704070ada0b9d46d5"
uuid = "892a3eda-7b42-436c-8928-eab12a02cf0e"
version = "0.3.4"

[[deps.StructTypes]]
deps = ["Dates", "UUIDs"]
git-tree-sha1 = "ca4bccb03acf9faaf4137a9abc1881ed1841aa70"
uuid = "856f2bd8-1eba-4b0a-8007-ebc267875bd4"
version = "1.10.0"

[[deps.SuiteSparse_jll]]
deps = ["Artifacts", "Libdl", "libblastrampoline_jll"]
uuid = "bea87d4a-7f5b-5778-9afe-8cc45184846c"
version = "7.2.1+1"

[[deps.Suppressor]]
deps = ["Logging"]
git-tree-sha1 = "6cd9e4a207964c07bf6395beff7a1e8f21d0f3b2"
uuid = "fd094767-a336-5f1f-9728-57cf17d0bbfb"
version = "0.2.6"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.3"

[[deps.TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[deps.TableTraitsUtils]]
deps = ["DataValues", "IteratorInterfaceExtensions", "Missings", "TableTraits"]
git-tree-sha1 = "78fecfe140d7abb480b53a44f3f85b6aa373c293"
uuid = "382cd787-c1b6-5bf2-a167-d5b971a19bda"
version = "1.0.2"

[[deps.Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "OrderedCollections", "TableTraits"]
git-tree-sha1 = "cb76cf677714c095e535e3501ac7954732aeea2d"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.11.1"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.0"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.Tricks]]
git-tree-sha1 = "eae1bb484cd63b36999ee58be2de6c178105112f"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.8"

[[deps.TupleTools]]
git-tree-sha1 = "155515ed4c4236db30049ac1495e2969cc06be9d"
uuid = "9d95972d-f1c8-5527-a6e0-b4b365fa01f6"
version = "1.4.3"

[[deps.URIParser]]
deps = ["Unicode"]
git-tree-sha1 = "53a9f49546b8d2dd2e688d216421d050c9a31d0d"
uuid = "30578b45-9adc-5946-b283-645ec420af67"
version = "0.4.1"

[[deps.URIs]]
git-tree-sha1 = "67db6cc7b3821e19ebe75791a9dd19c9b1188f2b"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.5.1"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.Vega]]
deps = ["BufferedStreams", "DataStructures", "DataValues", "Dates", "FileIO", "FilePaths", "IteratorInterfaceExtensions", "JSON", "JSONSchema", "MacroTools", "NodeJS", "Pkg", "REPL", "Random", "Setfield", "TableTraits", "TableTraitsUtils", "URIParser"]
git-tree-sha1 = "9d5c73642d291cb5aa34eb47b9d71428c4132398"
uuid = "239c3e63-733f-47ad-beb7-a12fde22c578"
version = "2.6.2"

[[deps.YaoHIR]]
deps = ["Expronicon", "MLStyle", "YaoLocations"]
git-tree-sha1 = "7fa66adcb137e2b3025642b758ce612d2d8ff1fa"
uuid = "6769671a-fce8-4286-b3f7-6099e1b1298a"
version = "0.2.2"

[[deps.YaoLocations]]
git-tree-sha1 = "c90c42c8668c9096deb0c861822f0f8f80cbdc68"
uuid = "66df03fb-d475-48f7-b449-3d9064bf085b"
version = "0.1.6"

[[deps.ZXCalculus]]
deps = ["Expronicon", "Graphs", "LinearAlgebra", "MLStyle", "Multigraphs", "OMEinsum", "SparseArrays", "YaoHIR", "YaoLocations"]
git-tree-sha1 = "9110975b06644a0844c98e13944c00af26087bf4"
uuid = "3525faa3-032d-4235-a8d4-8c2939a218dd"
version = "0.6.0"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.13+1"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.11.0+0"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.52.0+1"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+2"
"""

# ╔═╡ Cell order:
# ╠═aa11ea12-6a9c-11ee-11b6-77a1fbfdf4b5
# ╟─6ebebc14-6b0f-48b7-a8e4-fb6f7f9f7f0e
# ╠═639aaf18-e63b-4b07-8557-8e21a874d91a
# ╠═69587b8e-26cf-4862-abe6-f81cc6967db3
# ╠═97eae154-ce25-4f22-b89a-af653f79dcd7
# ╠═15e4062a-37b3-40dc-add3-9d8ad7520b4d
# ╠═e22922f8-5a54-475b-b325-dda82547c556
# ╟─37954f01-da8c-4018-a7e1-811d4a86fb26
# ╠═c984b469-89d0-4d02-9264-e967697e50b3
# ╠═996a236f-90b5-42bb-8627-19d5a7facef6
# ╠═df136e09-4958-433d-a3ce-60f73a10968a
# ╠═69d97139-73d2-4b3f-8d1f-aa8437880754
# ╠═57c4c6eb-54e1-4412-b3ca-3bd7588e4e34
# ╠═a092392c-eff5-4c5a-be9b-c9e67881cf46
# ╠═a6819a4e-3029-4fec-9baa-8ec842755e49
# ╠═d9da3492-048d-4458-aa37-801e84b61ec7
# ╠═d65ab9bd-6dcc-4502-a8fb-301abf404856
# ╠═c467fe63-487b-4087-b166-01ed41a47eec
# ╠═27b7b121-0c13-49ed-97e6-c73386e844a0
# ╠═ed656d2d-c4af-45a3-a5d8-5fd8c1cccac8
# ╠═1b36a6ba-5498-4aa5-ab67-67dff42c8422
# ╠═ab841776-6b79-4662-9998-04f513370fee
# ╠═4ff2d0e2-9dda-405d-aa77-9abb70eace77
# ╠═7bec3f25-507a-42e8-8547-cae8bfc317d8
# ╠═f3235791-4582-44a3-ba68-6c39a0d0b26b
# ╠═7220947a-f153-4bb7-a0ba-972af51d3fe7
# ╠═3f98b870-a534-4f69-b460-64c59cd8ef96
# ╠═dd5c40da-0530-4975-8245-78538ad6d244
# ╠═a48d68b5-559a-4937-a2b7-c13e5f5181b0
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
