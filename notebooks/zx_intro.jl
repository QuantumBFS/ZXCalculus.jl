### A Pluto.jl notebook ###
# v0.19.38

using Markdown
using InteractiveUtils

# ╔═╡ dd08aa73-0d86-4f8b-970b-59f9ad9fac2d
begin
    using OpenQASM
    using Vega
    using DataFrames
    using YaoHIR: BlockIR
    using ZXCalculus, ZXCalculus.ZX
    using PlutoUI
end

# ╔═╡ 741c3ca4-2dd5-406c-9ae5-7d19a3192e7d
TableOfContents(title = "📚 Table of Contents", indent = true, depth = 2, aside = true)

# ╔═╡ 24749683-0566-4f46-989d-22336d296517
html"""
<style>
	@media screen {
		main {
			margin: 0 auto;
			max-width: 2000px;
    		padding-left: max(283px, 10%);
    		padding-right: max(383px, 10%); 
            # 383px to accomodate TableOfContents(aside=true)
		}
	}
</style>
"""


# ╔═╡ 506db9e1-4260-408d-ba72-51581b548e53
function Base.show(io::IO, mime::MIME"text/html", zx::Union{ZXDiagram,ZXGraph})
    g = plot(zx)
    Base.show(io, mime, g)
end

# ╔═╡ 92dccd1c-6582-40bf-9b57-f326b2aff67a
html"<button onclick='present()'>present</button>"

# ╔═╡ a93915fc-01ef-4411-bc98-ea1fe8674fa9
md"""
# Introduction
ZX-Calculus is a unified formalism for describing quantum computation, mainly over
qubits. It is a rigorous graphical language, that utilizes the powerful set of rewrite
rules [1] for reasoning about linear maps between qubits, which are represented as string diagrams called ZX-Diagrams [2-3].

ZX-Calculus was invented in 2008 by Bob Coecke and Russ Duncan as an extension
of categorical quantum mechanics. They introduced the fundamental concepts of
spiders, strong complementarity and most the rewrite rules

All equations
concerning quantum processes can be derived using a handful of graphical rules [4].

The ZX-Calculus is universal, because any linear map between qubits can be rep-
resented as a ZX-Diagram. It is complete, meaning that all equations concerning
quantum processes can be derived using linear algebra, can also be obtained using a
handful of graphical rules [5, 6]. This makes the ZX-Calculus an alternative to the
Hilbert Space Formalism and a tool for generalization of quantum circuit notations
[1]. 

This section notebook demonstrates the universality of the ZX-Calculus by exhibiting how the Clifford group (CN OT , H, S) + T , one of the universal gate sets [7], is implemented.
The ZX-Calculus, which has been proven complete in [8], provides a powerful repre-
sentation of static quantum circuits. 


## ZXDiagrams
ZXDiagrams can be created by specifying the number of qubits.
Bare wires are equivalent to an identiy gate. The identity gate is the identity matrix and does not modify the quantum state. 

The ZX-Calculus is built around the concept of wires, which serve as a visual representation of a system. The first diagram below shows a single wire, which corresponds to a quantum system with one qubit, emphasizing their equivalence.
It represents the identity I, since the state of the system does not change.
"""

# ╔═╡ 9af85660-a4e3-4f27-b6cb-cf36d9b50d91
z1 = ZXDiagram(1)

# ╔═╡ 3f82bd5a-7528-4b1c-9b67-252ed076ed97
md"The second diagram shows a quantum system with 3 qubits."

# ╔═╡ df00b5c6-9217-11ee-0b09-632420c4e265
z3 = ZXDiagram(3)

# ╔═╡ 785ec008-63af-4f56-9792-f66b27a27388
md"""
## Gates
Spiders, which represent gates can be pushed onto a Diagram.
The following example shows, how the clifford+T universal gate set, is constructed using ZXCalculus.

### Pauli-X Gate
The Pauli-X Gate rotates around the x axis of the Bloch Sphere with a phase of ``\pi``. The quantum equivalent of the classical NOT gate is the Pauli-X gate with respect to the standard basis ``|0\rangle, |1\rangle``
It flips the ``|0\rangle`` into the  ``|1\rangle`` state and vice-versa.

Its matrix is represented as:
`` X = \sigma_x =\operatorname{NOT} = \begin{bmatrix} 0 & 1 \\ 1 & 0 \end{bmatrix}``

"""

# ╔═╡ 0c2b4e33-5dcc-476d-8a9c-1e4244231e05
begin
    zx_x = ZXDiagram(1)
    push_gate!(zx_x, Val(:X), 1, 1 // 1)
end


# ╔═╡ 3cf7e1a1-7f99-4191-8e38-1533da8ebba1
md"""
### Z-Gate
The effect of the Pauli-Z Gate is a phase flip. It leaves the basis state ``|0\rangle`` and maps
``|0\rangle`` to ``−|0\rangle``.

`` Z = \begin{bmatrix} 1 & 0 \\ 0 & e^{i \pi} \end{bmatrix} = \begin{bmatrix} 1 & 0 \\ 0 & -1 \end{bmatrix} = P\left(\pi\right)``
"""

# ╔═╡ eeb5001c-2599-4d01-8e45-d417bda4d83c
begin
    zx_z = ZXDiagram(1)
    push_gate!(zx_z, Val(:Z), 1, 1 // 1)
end

# ╔═╡ 24609bab-a13b-49d9-be85-b8770a9153b1
md"""
### S-Gate 
The T-Gate has a phase of ``P(\frac{\pi}{2})``


``S = \begin{bmatrix} 1 & 0 \\ 0 & e^{i \frac{\pi}{2}} \end{bmatrix} = \begin{bmatrix} 1 & 0 \\ 0 & i \end{bmatrix} = P\left(\frac{\pi}{2}\right)=\sqrt{Z}``
"""

# ╔═╡ eebd1e46-0c0f-487d-8bee-07b1c17552c4
begin
    zx_s = ZXDiagram(1)
    push_gate!(zx_s, Val(:Z), 1, 1 // 2)
end

# ╔═╡ 3e0f5adc-c47c-4363-890f-f2c6a9843115
md"""
### T-Gate 
The T-Gate has a phase of ``P(\frac{\pi}{4})``


``T = \begin{bmatrix} 1 & 0 \\ 0 & e^{i \frac{\pi}{4}} \end{bmatrix} =P\left(\frac{\pi}{4}\right) = \sqrt{S} = \sqrt[4]{Z}``

"""

# ╔═╡ 9200a1b1-11f7-4428-8840-c52dd4403c45
begin
    zx_t = ZXDiagram(1)
    push_gate!(zx_t, Val(:Z), 1, 1 // 4)
end

# ╔═╡ 518c82ab-ee25-4929-b9c7-976c27482d51
md"""
### H-Gate
The Hadamard gate is a fundamental gate used to create superposition states in quantum computing. 
When applied to a qubit, the Hadamard gate creates a superposition of the basis
states ``|0\rangle`` and ``|1\rangle``. It transforms the basis states as follows:

``H = \frac{1}{\sqrt{2}} \begin{bmatrix} 1 & 1 \\ 1 & -1 \end{bmatrix}``
"""

# ╔═╡ 924efc08-681b-4804-93c6-38acc125315a
begin
    zx_h = ZXDiagram(1)
    push_gate!(zx_h, Val(:H), 1)
end

# ╔═╡ 08199250-2746-4779-b2d7-347c321ceb55
md"""
### H-Gate
Contary to quantum logic gates, CNOT is not a gate primitive but composed out of a red and a green spider.

"""

# ╔═╡ 5fdc6a08-c284-414e-9e96-8734289a98de
begin
    zx_cnot = ZXDiagram(2)
    push_gate!(zx_cnot, Val(:CNOT), 1, 2)

end

# ╔═╡ e2d695a4-7962-4d77-b348-74eb05c72b9c
md"""

## Quantum Circuit

"""

# ╔═╡ 0523c034-06ac-4383-b50f-6b68e6b1739f
begin
    zx = ZXDiagram(3)
    push_gate!(zx, Val(:X), 1, 1 // 1)
    push_gate!(zx, Val(:CNOT), 1, 2)
    push_gate!(zx, Val(:H), 1)
    push_gate!(zx, Val(:CNOT), 2, 3)
    push_gate!(zx, Val(:H), 2)
end


# ╔═╡ 92fd5c2b-95a1-4820-99cb-45923429117c
md"""
# Rewrite Rules
The ZX-Calculus provides a set of rewrite rules that allow us to transform one diagram
into another equivalent diagram. These rules include the ability to move wires and
effects, cancel pairs of H and Z gates, and commute certain gates. Rewrite rules are
powerful, they allow us to change the structure of the ZX-Diagrams without changing
the quantum circuit, since the linear maps remain the same.

## Spider Fusion Rule
Spiders of the same color can be fused together. Their phases are then added up.
In this example we have the equivalent of two Pauli-X Gates on a wire. 

> Spider Fusion (f): Two spiders of the same color can fuse together if touching, adding their phases. This is because spiders of the same color represent an orthonormal basis.
"""

# ╔═╡ 5dabc4ae-ecd7-4339-837a-e1272b925acf
begin
    push_gate!(zx_x, Val(:X), 1, 1 // 1)
end


# ╔═╡ 973ad229-2b87-48f8-9926-c833766d45cb
md"""
After fusion them together, we get a phaseless spider.
"""

# ╔═╡ 852455dd-b95d-45a4-a771-053c1e95b82f
simplify!(Rule{:f}(), zx_x)

# ╔═╡ b4702fb4-e21a-43b0-8be4-fbfca81b4a8b
md"""
## Identiy Rule
The identiy rules states, that phase less spiders are the idenity, as they do not change the phase of the Z or the X base. 

> Identity Rule (id): A phaseless arity 2 Z-or X-spider equals the identity. The Bell State (Definiton TODO) is the same if expressed in the computational basis or Hadamard basis.

After applying the second idenity rule, we are left with a bare wire.

"""

# ╔═╡ 64be3d04-4983-467e-9b06-45b64132ee30
simplify!(Rule{:i1}(), zx_x)

# ╔═╡ c604a76d-9b95-4f0d-8133-df2a3e9dabe9
md"""
We can verify, that these rules are correct by checking constructing the same qunatum circuit using matrices in the hilbert space.

`` \fbox{x} \cdot \fbox{x} = \begin{bmatrix} 0 & 1 \\ 1 & 0 \end{bmatrix} \cdot \begin{bmatrix} 0 & 1 \\ 1 & 0 \end{bmatrix} = \begin{bmatrix} 1 & 0 \\ 0 & 1 \end{bmatrix} = \mathbb{I}``

"""

# ╔═╡ 4d7d8a96-5aba-4b63-a5da-959716f2d2bf
md"""#
## ZXDiagrams and ZXGraphs"""

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

# ╔═╡ 99bb5eff-79e7-4c0e-95ae-a6d2130f46cb
md"## Equality"

# ╔═╡ f240382f-b682-4947-938f-c98d9c901c90
zx_dagger = dagger(zx)

# ╔═╡ 89f14c32-895d-4101-b4a8-bc410a2adaa5
merged_diagram = concat!(zx, zx_dagger)

# ╔═╡ 0b838710-91e4-4572-9fe0-5c97e579ddd1
m_simple = full_reduction(merged_diagram)


# ╔═╡ fdb7ca6a-bf5c-4216-8a18-a7c3603240ea
contains_only_bare_wires(m_simple)

# ╔═╡ 6b431ff3-f644-4123-82fd-704c054eb5bb
md"""# Circuit Verification
## Informal Definition
Equivalence checking the equality of two quantum circuits relies on the reversibility
of quantum operations. Every quantum operation is *unitary* and thus reversible. The product of any quantum operation and its inverse (adjoint)
will always yield the identity. 

## Formal Definition
### Unitary
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

### Example
Given circuits `b1` and `b2`. Can we proof that they are equal?
"""

# ╔═╡ cee877f2-8fd8-4a4e-9b8c-199411d449c5
begin
    b1 = BlockIR("""
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
    x q0[2];
    x q0[2];
       measure q0[0] -> c0[0];
       measure q0[1] -> c0[1];
       """)
    c1 = ZXDiagram(b1)
end

# ╔═╡ 20886e57-0c2c-4bf3-8c3d-8ed7d4f33fec
begin
    b2 = BlockIR("""
         OPENQASM 2.0;
      include "qelib1.inc";
      qreg q0[3];
      creg mcm[1];
      creg end[1];
      h q0[1];
      x q0[2];
      h q0[2];
      CX q0[1], q0[2];
      h q0[1];
      h q0[0];
      CX q0[0], q0[2];
      h q0[0];
      measure q0[0] -> end[0];
      measure q0[1] -> mcm[0];
          """)
    c2 = ZXDiagram(b2)


end

# ╔═╡ 02be99e0-1b97-4fe0-b316-5151febe92d8
concat!(c1, dagger(c2))

# ╔═╡ e529aa93-4f3e-4038-97dd-1ce570df8076
c_reduced = full_reduction(c1)

# ╔═╡ 94ac0dd1-390e-42d6-8300-f67a5a633043
contains_only_bare_wires(c_reduced)

# ╔═╡ 796e6c34-0664-488d-a186-c7810df06d77
verify_equality(ZXDiagram(b1), ZXDiagram(b1))

# ╔═╡ f7982574-ddff-4e7b-a4fc-52462a59d21c
md"""
# Sources
1. [B. Coecke, D. Horsman, A. Kissinger, and Q. Wang. “Kindergarden quantum mechanics graduates ...or how I learned to stop gluing LEGO together and love the ZX-calculus”. In: Theoretical Computer Science 897 (2022), pp. 1–22. issn: 0304-3975](https://doi.org/10.1016/j.tcs.2021.07.024)

2. [R. Duncan, A. Kissinger, S. Perdrix, and J. van de Wetering. “Graph-theoretic Simplification of Quantum Circuits with the ZX -calculus”. In: Quantum 4 (June 2020), p. 279. issn: 2521-327X](https://doi.org/10.22331/q-2020-06-04-279)

3. [J. van de Wetering. ZX-calculus for the working quantum computer scientist. 2020. arXiv: 2012.13966 [quant-ph]](https://arxiv.org/abs/2012.13966)

4. [A. Kissinger and J. van de Wetering. “PyZX: Large Scale Automated Diagrammatic Reasoning”. In: Electronic Proceedings in Theoretical Computer Science 318 (May 2020), pp. 229–241](https://doi.org/10.4204/eptcs.318.14)

5. [A. Hadzihasanovic, K. F. Ng, and Q. Wang. “Two complete axiomatisations of pure-state qubit quantum computing”. In: Proceedings of the 33rd Annual ACM/IEEE Symposium on Logic in Computer Science (2018)](https://api.semanticscholar.org/CorpusID:195347007)

6. [R. Vilmart. “A Near-Minimal Axiomatisation of ZX-Calculus for Pure Qubit Quantum Mechanics”. In: 2019 34th Annual ACM/IEEE Symposium on Logic in Computer Science (LICS). 2019, pp. 1–10](https://doi.org/10.1109/LICS.2019.8785765)

7. [M. A. Nielsen and I. L. Chuang. Quantum computation and quantum information. 10th anniversary ed. Cambridge ; New York: Cambridge University Press, 2010. isbn: 9781107002173](#)

8. [Q. Wang. Completeness of the ZX-calculus. 2023. arXiv: 2209 . 14894 [quant-ph]](https://arxiv.org/abs/2209.14894)


"""

# ╔═╡ Cell order:
# ╠═dd08aa73-0d86-4f8b-970b-59f9ad9fac2d
# ╠═741c3ca4-2dd5-406c-9ae5-7d19a3192e7d
# ╠═24749683-0566-4f46-989d-22336d296517
# ╠═506db9e1-4260-408d-ba72-51581b548e53
# ╠═92dccd1c-6582-40bf-9b57-f326b2aff67a
# ╟─a93915fc-01ef-4411-bc98-ea1fe8674fa9
# ╠═9af85660-a4e3-4f27-b6cb-cf36d9b50d91
# ╟─3f82bd5a-7528-4b1c-9b67-252ed076ed97
# ╠═df00b5c6-9217-11ee-0b09-632420c4e265
# ╟─785ec008-63af-4f56-9792-f66b27a27388
# ╠═0c2b4e33-5dcc-476d-8a9c-1e4244231e05
# ╟─3cf7e1a1-7f99-4191-8e38-1533da8ebba1
# ╠═eeb5001c-2599-4d01-8e45-d417bda4d83c
# ╟─24609bab-a13b-49d9-be85-b8770a9153b1
# ╠═eebd1e46-0c0f-487d-8bee-07b1c17552c4
# ╟─3e0f5adc-c47c-4363-890f-f2c6a9843115
# ╠═9200a1b1-11f7-4428-8840-c52dd4403c45
# ╟─518c82ab-ee25-4929-b9c7-976c27482d51
# ╠═924efc08-681b-4804-93c6-38acc125315a
# ╟─08199250-2746-4779-b2d7-347c321ceb55
# ╠═5fdc6a08-c284-414e-9e96-8734289a98de
# ╟─e2d695a4-7962-4d77-b348-74eb05c72b9c
# ╠═0523c034-06ac-4383-b50f-6b68e6b1739f
# ╟─92fd5c2b-95a1-4820-99cb-45923429117c
# ╠═5dabc4ae-ecd7-4339-837a-e1272b925acf
# ╟─973ad229-2b87-48f8-9926-c833766d45cb
# ╠═852455dd-b95d-45a4-a771-053c1e95b82f
# ╟─b4702fb4-e21a-43b0-8be4-fbfca81b4a8b
# ╠═64be3d04-4983-467e-9b06-45b64132ee30
# ╟─c604a76d-9b95-4f0d-8133-df2a3e9dabe9
# ╟─4d7d8a96-5aba-4b63-a5da-959716f2d2bf
# ╠═7da637f0-e359-41d9-b395-27168459c20c
# ╠═bed7a0c5-da16-40b5-9d84-4dad2dfb8739
# ╠═8cde99fd-ee0a-4d94-a94e-23ebc9ac8608
# ╟─99bb5eff-79e7-4c0e-95ae-a6d2130f46cb
# ╠═f240382f-b682-4947-938f-c98d9c901c90
# ╠═89f14c32-895d-4101-b4a8-bc410a2adaa5
# ╠═0b838710-91e4-4572-9fe0-5c97e579ddd1
# ╠═fdb7ca6a-bf5c-4216-8a18-a7c3603240ea
# ╠═6b431ff3-f644-4123-82fd-704c054eb5bb
# ╠═cee877f2-8fd8-4a4e-9b8c-199411d449c5
# ╠═20886e57-0c2c-4bf3-8c3d-8ed7d4f33fec
# ╠═02be99e0-1b97-4fe0-b316-5151febe92d8
# ╠═e529aa93-4f3e-4038-97dd-1ce570df8076
# ╠═94ac0dd1-390e-42d6-8300-f67a5a633043
# ╠═796e6c34-0664-488d-a186-c7810df06d77
# ╟─f7982574-ddff-4e7b-a4fc-52462a59d21c
