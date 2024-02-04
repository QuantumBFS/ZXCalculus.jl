### A Pluto.jl notebook ###
# v0.19.38

using Markdown
using InteractiveUtils

# ╔═╡ dd08aa73-0d86-4f8b-970b-59f9ad9fac2d
begin
		import Pkg
	Pkg.add(url="/home/liam/src/quantum-circuits/software/ZXCalculus.jl", rev="feat/equivalence")
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
	using YaoHIR.IntrinsicOperation
	using ZXCalculus
	
	using QuantumCircuitEquivalence
	using QuantumCircuitEquivalence.QuantumInformation
end

# ╔═╡ 506db9e1-4260-408d-ba72-51581b548e53
function Base.show(io::IO, mime::MIME"text/html", zx::Union{ZXDiagram, ZXGraph})
       g = plot(zx)
       Base.show(io, mime, g)
end


# ╔═╡ 9af85660-a4e3-4f27-b6cb-cf36d9b50d91
z1 = ZXDiagram(1)


# ╔═╡ df00b5c6-9217-11ee-0b09-632420c4e265
z3 = ZXDiagram(3)


# ╔═╡ 785ec008-63af-4f56-9792-f66b27a27388


# ╔═╡ 44cbd3d8-6d36-4a0b-8613-552bbba48f3d
begin
	zx_z = ZXDiagram(1)
	push_gate!(zx_z, Val(:Z), 1)
end

# ╔═╡ 0c2b4e33-5dcc-476d-8a9c-1e4244231e05
begin
	zx_x = ZXDiagram(1)
	push_gate!(zx_x, Val(:X), 1, 1//1)
end


# ╔═╡ eebd1e46-0c0f-487d-8bee-07b1c17552c4
begin
	zx_s = ZXDiagram(1)
	push_gate!(zx_s, Val(:Z), 1, 1//2)
end




# ╔═╡ 9200a1b1-11f7-4428-8840-c52dd4403c45
begin
	zx_t = ZXDiagram(1)
	push_gate!(zx_t, Val(:Z), 1, 1//4)
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
	 	push_gate!(zx, Val(:X),1,  1//1)
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
  merged_diagram = concat!(zx, zx_dagger)

# ╔═╡ 0b838710-91e4-4572-9fe0-5c97e579ddd1
  m_simple = full_reduction(merged_diagram)


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
full_reduction(concat!(ZXDiagram(BlockIR(traditional)), dagger(ZXDiagram(BlockIR(unitary)))))

# ╔═╡ f7982574-ddff-4e7b-a4fc-52462a59d21c
verify_equivalence(traditional, string(dynamic), true, true)

# ╔═╡ Cell order:
# ╠═dd08aa73-0d86-4f8b-970b-59f9ad9fac2d
# ╠═506db9e1-4260-408d-ba72-51581b548e53
# ╠═9af85660-a4e3-4f27-b6cb-cf36d9b50d91
# ╠═df00b5c6-9217-11ee-0b09-632420c4e265
# ╠═785ec008-63af-4f56-9792-f66b27a27388
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
