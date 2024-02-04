### A Pluto.jl notebook ###
# v0.19.37

using Markdown
using InteractiveUtils

# ╔═╡ aa11ea12-6a9c-11ee-11b6-77a1fbfdf4b5
begin
  import Pkg

  Pkg.activate(mktempdir())  
  #Pkg.add(path="/home/liam/src/quantum-circuits/impl/QuantumCircuitEquivalence", rev="feat/zx")
  Pkg.add(url="https://github.com/Roger-luo/Expronicon.jl")  
  Pkg.add(url="https://github.com/JuliaCompilerPlugins/CompilerPluginTools.jl")  
  Pkg.add(url="/home/liam/src/quantum-circuits/software/QuantumCircuitEquivalence.jl", rev="feat/zx")  

  Pkg.add(url="https://github.com/contra-bit/YaoHIR.jl")  
  Pkg.add(url="https://github.com/contra-bit/OpenQASM.jl.git", rev="feature/czgate")  
  Pkg.add(url="https://github.com/QuantumBFS/YaoLocations.jl", rev="master")  
  Pkg.add(url="https://github.com/QuantumBFS/Multigraphs.jl")  
  #Pkg.add(url="https://github.com/contra-bit/ZXCalculus.jl", rev="feat/convert_to_zxwd
  Pkg.add(url="/home/liam/src/quantum-circuits/software/ZXCalculus.jl", rev="feat/equivalence")  
  
	
  # AST Circuit Transformtation
  using QuantumCircuitEquivalence
  using OpenQASM


  # ZX Calculus Tools
  using ZXCalculus
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

# ╔═╡ Cell order:
# ╟─aa11ea12-6a9c-11ee-11b6-77a1fbfdf4b5
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
