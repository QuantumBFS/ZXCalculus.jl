var documenterSearchIndex = {"docs":
[{"location":"api/#APIs","page":"APIs","title":"APIs","text":"","category":"section"},{"location":"api/","page":"APIs","title":"APIs","text":"CurrentModule = ZXCalculus","category":"page"},{"location":"api/#ZX-diagrams","page":"APIs","title":"ZX-diagrams","text":"","category":"section"},{"location":"api/","page":"APIs","title":"APIs","text":"ZXCalculus.ZXDiagram\nZXDiagram(nbit::Int)\nZXCalculus.ZXGraph\nZXCalculus.ZXGraph(::ZXDiagram)\nZXCalculus.ZXLayout\nZXCalculus.qubit_loc\nZXCalculus.tcount(zxd::AbstractZXDiagram)\nspider_type(zxd::ZXDiagram{T, P}, v::T) where {T<:Integer, P}\nZXCalculus.phase(zxd::ZXDiagram{T, P}, v::T) where {T<:Integer, P}\nLightGraphs.nv(zxd::ZXDiagram)\nLightGraphs.ne(::ZXDiagram)\nLightGraphs.neighbors(::ZXDiagram, v)\nZXCalculus.is_interior(zxg::ZXGraph{T, P}, v::T) where {T, P}\nZXCalculus.add_spider!\nZXCalculus.insert_spider!\nZXCalculus.rem_spiders!\nZXCalculus.rem_spider!","category":"page"},{"location":"api/#ZXCalculus.ZXDiagram","page":"APIs","title":"ZXCalculus.ZXDiagram","text":"ZXDiagram{T, P}\n\nThis is the type for representing ZX-diagrams.\n\n\n\n\n\n","category":"type"},{"location":"api/#ZXCalculus.ZXDiagram-Tuple{Int64}","page":"APIs","title":"ZXCalculus.ZXDiagram","text":"ZXDiagram(mg::Multigraph{T}, st::Dict{T, SpiderType.SType}, ps::Dict{T, P},\n    layout::ZXLayout{T} = ZXLayout{T}(),\n    phase_ids::Dict{T,Tuple{T, Int}} = Dict{T,Tuple{T,Int}}()) where {T, P}\nZXDiagram(mg::Multigraph{T}, st::Vector{SpiderType.SType}, ps::Vector{P},\n    layout::ZXLayout{T} = ZXLayout{T}()) where {T, P}\n\nConstruct a ZXDiagram with all information.\n\njulia> using Graphs, Multigraphs, ZXCalculus;\n\njulia> using ZXCalculus.SpiderType: In, Out, H, Z, X;\n\njulia> mg = Multigraph(5);\n\njulia> for i = 1:4\n           add_edge!(mg, i, i+1)\n       end;\n\njulia> ZXDiagram(mg, [In, Z, H, X, Out], [0//1, 1, 0, 1//2, 0])\nZX-diagram with 5 vertices and 4 multiple edges:\n(S_1{input} <-1-> S_2{phase = 1//1⋅π})\n(S_2{phase = 1//1⋅π} <-1-> S_3{H})\n(S_3{H} <-1-> S_4{phase = 1//2⋅π})\n(S_4{phase = 1//2⋅π} <-1-> S_5{output})\n\n\n\n\n\n\nZXDiagram(nbits)\n\nConstruct a ZXDiagram of a empty circuit with qubit number nbit\n\njulia> zxd = ZXDiagram(3)\nZX-diagram with 6 vertices and 3 multiple edges:\n(S_1{input} <-1-> S_2{output})\n(S_3{input} <-1-> S_4{output})\n(S_5{input} <-1-> S_6{output})\n\n\n\n\n\n\n","category":"method"},{"location":"api/#ZXCalculus.ZXGraph","page":"APIs","title":"ZXCalculus.ZXGraph","text":"ZXGraph{T, P}\n\nThis is the type for representing the graph-like ZX-diagrams.\n\n\n\n\n\n","category":"type"},{"location":"api/#ZXCalculus.ZXGraph-Tuple{ZXDiagram}","page":"APIs","title":"ZXCalculus.ZXGraph","text":"ZXGraph(zxd::ZXDiagram)\n\nConvert a ZX-diagram to graph-like ZX-diagram.\n\njulia> using ZXCalculus\n\njulia> zxd = ZXDiagram(2); push_gate!(zxd, Val{:CNOT}(), 2, 1);\n\njulia> zxg = ZXGraph(zxd)\nZX-graph with 6 vertices and 5 edges:\n(S_1{input} <-> S_5{phase = 0//1⋅π})\n(S_2{output} <-> S_5{phase = 0//1⋅π})\n(S_3{input} <-> S_6{phase = 0//1⋅π})\n(S_4{output} <-> S_6{phase = 0//1⋅π})\n(S_5{phase = 0//1⋅π} <-> S_6{phase = 0//1⋅π})\n\n\n\n\n\n\n","category":"method"},{"location":"api/#ZXCalculus.ZXLayout","page":"APIs","title":"ZXCalculus.ZXLayout","text":"ZXLayout\n\nA struct for the layout information of ZXDiagram and ZXGraph.\n\n\n\n\n\n","category":"type"},{"location":"api/#ZXCalculus.qubit_loc","page":"APIs","title":"ZXCalculus.qubit_loc","text":"qubit_loc(layout, v)\n\nReturn the qubit number corresponding to the spider v.\n\n\n\n\n\n","category":"function"},{"location":"api/#ZXCalculus.spider_type-Union{Tuple{P}, Tuple{T}, Tuple{ZXDiagram{T, P}, T}} where {T<:Integer, P}","page":"APIs","title":"ZXCalculus.spider_type","text":"spider_type(zxd, v)\n\nReturns the spider type of a spider.\n\n\n\n\n\n","category":"method"},{"location":"api/#ZXCalculus.phase-Union{Tuple{P}, Tuple{T}, Tuple{ZXDiagram{T, P}, T}} where {T<:Integer, P}","page":"APIs","title":"ZXCalculus.phase","text":"phase(zxd, v)\n\nReturns the phase of a spider. If the spider is not a Z or X spider, then return 0.\n\n\n\n\n\n","category":"method"},{"location":"api/#ZXCalculus.is_interior-Union{Tuple{P}, Tuple{T}, Tuple{ZXGraph{T, P}, T}} where {T, P}","page":"APIs","title":"ZXCalculus.is_interior","text":"is_interior(zxg::ZXGraph, v)\n\nReturn true if v is a interior spider of zxg.\n\n\n\n\n\n","category":"method"},{"location":"api/#ZXCalculus.add_spider!","page":"APIs","title":"ZXCalculus.add_spider!","text":"add_spider!(zxd, spider_type, phase = 0, connect = [])\n\nAdd a new spider which is of the type spider_type with phase phase and connected to the vertices connect.\n\n\n\n\n\n","category":"function"},{"location":"api/#ZXCalculus.insert_spider!","page":"APIs","title":"ZXCalculus.insert_spider!","text":"insert_spider!(zxd, v1, v2, spider_type, phase = 0)\n\nInsert a spider of the type spider_type with phase = phase, between two vertices v1 and v2. It will insert multiple times if the edge between v1 and v2 is a multiple edge. Also it will remove the original edge between v1 and v2.\n\n\n\n\n\n","category":"function"},{"location":"api/#ZXCalculus.rem_spiders!","page":"APIs","title":"ZXCalculus.rem_spiders!","text":"rem_spiders!(zxd, vs)\n\nRemove spiders indexed by vs.\n\n\n\n\n\n","category":"function"},{"location":"api/#ZXCalculus.rem_spider!","page":"APIs","title":"ZXCalculus.rem_spider!","text":"rem_spider!(zxd, v)\n\nRemove a spider indexed by v.\n\n\n\n\n\n","category":"function"},{"location":"api/#Pushing-gates","page":"APIs","title":"Pushing gates","text":"","category":"section"},{"location":"api/","page":"APIs","title":"APIs","text":"ZXCalculus.push_gate!\nZXCalculus.pushfirst_gate!","category":"page"},{"location":"api/#ZXCalculus.push_gate!","page":"APIs","title":"ZXCalculus.push_gate!","text":"push_gate!(zxd, ::Val{M}, locs...[, phase]; autoconvert=true)\n\nPush an M gate to the end of qubit loc where M can be :Z, :X, :H, :SWAP, :CNOT and :CZ. If M is :Z or :X, phase will be available and it will push a rotation M gate with angle phase * π. If autoconvert is false, the input phase should be a rational numbers.\n\n\n\n\n\n","category":"function"},{"location":"api/#ZXCalculus.pushfirst_gate!","page":"APIs","title":"ZXCalculus.pushfirst_gate!","text":"pushfirst_gate!(zxd, ::Val{M}, loc[, phase])\n\nPush an M gate to the beginning of qubit loc where M can be :Z, :X, :H, :SWAP, :CNOT and :CZ. If M is :Z or :X, phase will be available and it will push a rotation M gate with angle phase * π.\n\n\n\n\n\n","category":"function"},{"location":"api/#Simplification","page":"APIs","title":"Simplification","text":"","category":"section"},{"location":"api/","page":"APIs","title":"APIs","text":"ZXCalculus.phase_teleportation\nZXCalculus.clifford_simplification\nRule{L} where L\nZXCalculus.simplify!\nZXCalculus.replace!\nZXCalculus.match\nZXCalculus.rewrite!\nZXCalculus.Match","category":"page"},{"location":"api/#ZXCalculus.phase_teleportation","page":"APIs","title":"ZXCalculus.phase_teleportation","text":"phase_teleportation(zxd)\n\nReducing T-count of zxd with the algorithms in arXiv:1903.10477.\n\n\n\n\n\n","category":"function"},{"location":"api/#ZXCalculus.clifford_simplification","page":"APIs","title":"ZXCalculus.clifford_simplification","text":"clifford_simplification(zxd)\n\nSimplify zxd with the algorithms in arXiv:1902.03178.\n\n\n\n\n\n","category":"function"},{"location":"api/#ZXCalculus.Rule","page":"APIs","title":"ZXCalculus.Rule","text":"Rule{L}\n\nThe struct for identifying different rules.\n\nRule for ZXDiagrams:\n\nRule{:f}(): rule f\nRule{:h}(): rule h\nRule{:i1}(): rule i1\nRule{:i2}(): rule i2\nRule{:pi}(): rule π\nRule{:c}(): rule c\n\nRule for ZXGraphs:\n\nRule{:lc}(): local complementary rule\nRule{:p1}(): pivoting rule\nRule{:pab}(): rule for removing Paulis spiders adjancent to boundary spiders\nRule{:p2}(): rule p2\nRule{:p3}(): rule p3\nRule{:id}(): rule id\nRule{:gf}(): gadget fushion rule\n\n\n\n\n\n","category":"type"},{"location":"api/#ZXCalculus.simplify!","page":"APIs","title":"ZXCalculus.simplify!","text":"simplify!(r, zxd)\n\nSimplify zxd with the rule r.\n\n\n\n\n\n","category":"function"},{"location":"api/#Base.replace!","page":"APIs","title":"Base.replace!","text":"replace!(r, zxd)\n\nMatch and replace with the rule r.\n\n\n\n\n\n","category":"function"},{"location":"api/#Base.match","page":"APIs","title":"Base.match","text":"match(r, zxd)\n\nReturns all matched vertices, which will be store in sturct Match, for rule r in a ZX-diagram zxd.\n\n\n\n\n\n","category":"function"},{"location":"api/#ZXCalculus.rewrite!","page":"APIs","title":"ZXCalculus.rewrite!","text":"rewrite!(r, zxd, matches)\n\nRewrite a ZX-diagram zxd with rule r for all vertices in matches. matches can be a vector of Match or just an instance of Match.\n\n\n\n\n\n","category":"function"},{"location":"api/#ZXCalculus.Match","page":"APIs","title":"ZXCalculus.Match","text":"Match{T<:Integer}\n\nA struct for saving matched vertices.\n\n\n\n\n\n","category":"type"},{"location":"api/#Circuit-extraction","page":"APIs","title":"Circuit extraction","text":"","category":"section"},{"location":"api/","page":"APIs","title":"APIs","text":"ZXCalculus.circuit_extraction(zxg::ZXGraph{T, P}) where {T, P}","category":"page"},{"location":"api/#ZXCalculus.circuit_extraction-Union{Tuple{ZXGraph{T, P}}, Tuple{P}, Tuple{T}} where {T, P}","page":"APIs","title":"ZXCalculus.circuit_extraction","text":"circuit_extraction(zxg::ZXGraph)\n\nExtract circuit from a graph-like ZX-diagram.\n\n\n\n\n\n","category":"method"},{"location":"tutorials/#Tutorials","page":"Tutorials","title":"Tutorials","text":"","category":"section"},{"location":"tutorials/","page":"Tutorials","title":"Tutorials","text":"ZX-diagrams are the basic objects in ZX-calculus. In our implementation, each ZX-diagram consists of a multigraph and vertices information including the type of vertices and the phase of vertices. ZXDiagram is the data structure for representing ZX-diagrams.","category":"page"},{"location":"tutorials/","page":"Tutorials","title":"Tutorials","text":"There are 5 types of vertices: In, Out, Z, X, H which represent the inputs of quantum circuits, outputs of quantum circuits, Z-spiders, X-spiders, H-boxes. There can be a phase for each vertex. The phase of a vertex of Z or X is the phase of a Z or X-spider. For the other types of vertices, the phase is zero by default.","category":"page"},{"location":"tutorials/","page":"Tutorials","title":"Tutorials","text":"In each ZXDiagram, there is a layout for storing layout information for the quantum circuit, and a phase_ids for storing information which is needed in phase teleportation.","category":"page"},{"location":"tutorials/#Construction-of-ZX-diagrams","page":"Tutorials","title":"Construction of ZX-diagrams","text":"","category":"section"},{"location":"tutorials/","page":"Tutorials","title":"Tutorials","text":"As we usually focus on quantum circuits, the recommended way to construct ZXDiagrams is by the following function.","category":"page"},{"location":"tutorials/","page":"Tutorials","title":"Tutorials","text":"ZXDiagram(nbit::T) where T<:Integer","category":"page"},{"location":"tutorials/#ZXCalculus.ZXDiagram-Tuple{T} where T<:Integer","page":"Tutorials","title":"ZXCalculus.ZXDiagram","text":"ZXDiagram(nbits)\n\nConstruct a ZXDiagram of a empty circuit with qubit number nbit\n\njulia> zxd = ZXDiagram(3)\nZX-diagram with 6 vertices and 3 multiple edges:\n(S_1{input} <-1-> S_2{output})\n(S_3{input} <-1-> S_4{output})\n(S_5{input} <-1-> S_6{output})\n\n\n\n\n\n\n","category":"method"},{"location":"tutorials/","page":"Tutorials","title":"Tutorials","text":"Then one can use push_gate! to push quantum gates at the end of a quantum circuit, or use pushfirst_gate! to push gates at the beginning of a quantum circuit.","category":"page"},{"location":"tutorials/","page":"Tutorials","title":"Tutorials","text":"push_gate!(zxd::ZXDiagram{T, P}, ::Val{:Z}, loc::T, phase = zero(P); autoconvert::Bool=true) where {T, P}\npushfirst_gate!(zxd::ZXDiagram{T, P}, ::Val{:Z}, loc::T, phase::P = zero(P)) where {T, P}","category":"page"},{"location":"tutorials/#ZXCalculus.push_gate!-Union{Tuple{P}, Tuple{T}, Tuple{ZXDiagram{T, P}, Val{:Z}, T}, Tuple{ZXDiagram{T, P}, Val{:Z}, T, Any}} where {T, P}","page":"Tutorials","title":"ZXCalculus.push_gate!","text":"push_gate!(zxd, ::Val{M}, locs...[, phase]; autoconvert=true)\n\nPush an M gate to the end of qubit loc where M can be :Z, :X, :H, :SWAP, :CNOT and :CZ. If M is :Z or :X, phase will be available and it will push a rotation M gate with angle phase * π. If autoconvert is false, the input phase should be a rational numbers.\n\n\n\n\n\n","category":"method"},{"location":"tutorials/#ZXCalculus.pushfirst_gate!-Union{Tuple{P}, Tuple{T}, Tuple{ZXDiagram{T, P}, Val{:Z}, T}, Tuple{ZXDiagram{T, P}, Val{:Z}, T, P}} where {T, P}","page":"Tutorials","title":"ZXCalculus.pushfirst_gate!","text":"pushfirst_gate!(zxd, ::Val{M}, loc[, phase])\n\nPush an M gate to the beginning of qubit loc where M can be :Z, :X, :H, :SWAP, :CNOT and :CZ. If M is :Z or :X, phase will be available and it will push a rotation M gate with angle phase * π.\n\n\n\n\n\n","category":"method"},{"location":"tutorials/","page":"Tutorials","title":"Tutorials","text":"For example, in example\\ex1.jl, one can generate the demo circuit by the function","category":"page"},{"location":"tutorials/","page":"Tutorials","title":"Tutorials","text":"using ZXCalculus\nfunction generate_example()\n    zxd = ZXDiagram(4)\n    push_gate!(zxd, Val(:Z), 1, 3//2)\n    push_gate!(zxd, Val(:H), 1)\n    push_gate!(zxd, Val(:Z), 1, 1//2)\n    push_gate!(zxd, Val(:Z), 2, 1//2)\n    push_gate!(zxd, Val(:H), 4)\n    push_gate!(zxd, Val(:CNOT), 3, 2)\n    push_gate!(zxd, Val(:CZ), 4, 1)\n    push_gate!(zxd, Val(:H), 2)\n    push_gate!(zxd, Val(:CNOT), 3, 2)\n    push_gate!(zxd, Val(:CNOT), 1, 4)\n    push_gate!(zxd, Val(:H), 1)\n    push_gate!(zxd, Val(:Z), 2, 1//4)\n    push_gate!(zxd, Val(:Z), 3, 1//2)\n    push_gate!(zxd, Val(:H), 4)\n    push_gate!(zxd, Val(:Z), 1, 1//4)\n    push_gate!(zxd, Val(:H), 2)\n    push_gate!(zxd, Val(:H), 3)\n    push_gate!(zxd, Val(:Z), 4, 3//2)\n    push_gate!(zxd, Val(:Z), 3, 1//2)\n    push_gate!(zxd, Val(:X), 4, 1//1)\n    push_gate!(zxd, Val(:CNOT), 3, 2)\n    push_gate!(zxd, Val(:H), 1)\n    push_gate!(zxd, Val(:Z), 4, 1//2)\n    push_gate!(zxd, Val(:X), 4, 1//1)\n\n    return zxd\nend","category":"page"},{"location":"tutorials/","page":"Tutorials","title":"Tutorials","text":"In the paper arXiv:1902.03178, they introduced a special type of ZX-diagrams, graph-like ZX-diagrams, which consists of Z-spiders with 2 different types of edges only. We use ZXGraph for representing this special type of ZX-diagrams. One can convert a ZXDiagram into a ZXGraph by simply use the construction function:","category":"page"},{"location":"tutorials/","page":"Tutorials","title":"Tutorials","text":"ZXGraph(zxd::ZXDiagram{T, P}) where {T, P}","category":"page"},{"location":"tutorials/#ZXCalculus.ZXGraph-Union{Tuple{ZXDiagram{T, P}}, Tuple{P}, Tuple{T}} where {T, P}","page":"Tutorials","title":"ZXCalculus.ZXGraph","text":"ZXGraph(zxd::ZXDiagram)\n\nConvert a ZX-diagram to graph-like ZX-diagram.\n\njulia> using ZXCalculus\n\njulia> zxd = ZXDiagram(2); push_gate!(zxd, Val{:CNOT}(), 2, 1);\n\njulia> zxg = ZXGraph(zxd)\nZX-graph with 6 vertices and 5 edges:\n(S_1{input} <-> S_5{phase = 0//1⋅π})\n(S_2{output} <-> S_5{phase = 0//1⋅π})\n(S_3{input} <-> S_6{phase = 0//1⋅π})\n(S_4{output} <-> S_6{phase = 0//1⋅π})\n(S_5{phase = 0//1⋅π} <-> S_6{phase = 0//1⋅π})\n\n\n\n\n\n\n","category":"method"},{"location":"tutorials/#Visualization","page":"Tutorials","title":"Visualization","text":"","category":"section"},{"location":"tutorials/","page":"Tutorials","title":"Tutorials","text":"With the package YaoPlots.jl, one can draw ZX-diagrams with one line of code.","category":"page"},{"location":"tutorials/","page":"Tutorials","title":"Tutorials","text":"plot(zxd[; linetype = lt])","category":"page"},{"location":"tutorials/","page":"Tutorials","title":"Tutorials","text":"Here zxd can be either a ZXDiagram or ZXGraph. The argument lt is set to \"straight\" by default. One can also set it to \"curve\" to make the edges curves.","category":"page"},{"location":"tutorials/#Manipulating-ZX-diagrams","page":"Tutorials","title":"Manipulating ZX-diagrams","text":"","category":"section"},{"location":"tutorials/","page":"Tutorials","title":"Tutorials","text":"With ZXCalculus.jl, one can manipulate ZX-diagrams at different levels.","category":"page"},{"location":"tutorials/","page":"Tutorials","title":"Tutorials","text":"Simplifying quantum circuits\nRewriting ZX-diagrams with rules\nRewriting ZX-diagrams at the graphical level","category":"page"},{"location":"tutorials/","page":"Tutorials","title":"Tutorials","text":"The highest level is the circuit simplification algorithms. By now there are two algorithms are available:","category":"page"},{"location":"tutorials/","page":"Tutorials","title":"Tutorials","text":"clifford_simplification(circ::ZXDiagram)\nphase_teleportation(circ::ZXDiagram{T, P}) where {T, P}","category":"page"},{"location":"tutorials/#ZXCalculus.clifford_simplification-Tuple{ZXDiagram}","page":"Tutorials","title":"ZXCalculus.clifford_simplification","text":"clifford_simplification(zxd)\n\nSimplify zxd with the algorithms in arXiv:1902.03178.\n\n\n\n\n\n","category":"method"},{"location":"tutorials/#ZXCalculus.phase_teleportation-Union{Tuple{ZXDiagram{T, P}}, Tuple{P}, Tuple{T}} where {T, P}","page":"Tutorials","title":"ZXCalculus.phase_teleportation","text":"phase_teleportation(zxd)\n\nReducing T-count of zxd with the algorithms in arXiv:1903.10477.\n\n\n\n\n\n","category":"method"},{"location":"tutorials/","page":"Tutorials","title":"Tutorials","text":"The input of these algorithms will be a ZX-diagram representing a quantum circuit. And these algorithms will return a ZX-diagram of a simplified quantum circuit. For more details, please refer to Clifford simplification and phase teleportation.","category":"page"},{"location":"tutorials/","page":"Tutorials","title":"Tutorials","text":"One can rewrite ZX-diagrams with rules. In ZXCalculus.jl, rules are identified as data structures Rule. And we can use the following functions to simplify ZX-diagrams:","category":"page"},{"location":"tutorials/","page":"Tutorials","title":"Tutorials","text":"simplify!(r::ZXCalculus.AbstractRule, zxd::AbstractZXDiagram)\nreplace!(r::ZXCalculus.AbstractRule, zxd::AbstractZXDiagram)","category":"page"},{"location":"tutorials/#ZXCalculus.simplify!-Tuple{ZXCalculus.AbstractRule, AbstractZXDiagram}","page":"Tutorials","title":"ZXCalculus.simplify!","text":"simplify!(r, zxd)\n\nSimplify zxd with the rule r.\n\n\n\n\n\n","category":"method"},{"location":"tutorials/#Base.replace!-Tuple{ZXCalculus.AbstractRule, AbstractZXDiagram}","page":"Tutorials","title":"Base.replace!","text":"replace!(r, zxd)\n\nMatch and replace with the rule r.\n\n\n\n\n\n","category":"method"},{"location":"tutorials/","page":"Tutorials","title":"Tutorials","text":"For example, in example/ex1.jl, we can get a simplified graph-like ZX-diagram by:","category":"page"},{"location":"tutorials/","page":"Tutorials","title":"Tutorials","text":"zxd = generate_example()\nzxg = ZXGraph(zxd)\nsimplify!(Rule{:lc}(), zxg)\nsimplify!(Rule{:p1}(), zxg)\nreplace!(Rule{:pab}(), zxg)","category":"page"},{"location":"tutorials/","page":"Tutorials","title":"Tutorials","text":"The difference between simplify! and replace! is that replace! only matches vertices and tries to rewrite with all matched vertices once, while simplify! will keep matching until nothing matched.","category":"page"},{"location":"tutorials/","page":"Tutorials","title":"Tutorials","text":"The following APIs are useful for more detailed rewriting.","category":"page"},{"location":"tutorials/","page":"Tutorials","title":"Tutorials","text":"match(::ZXCalculus.AbstractRule, zxd::AbstractZXDiagram{T, P}) where {T, P}\nrewrite!(r::ZXCalculus.AbstractRule, zxd::AbstractZXDiagram{T, P}, matches::Vector{Match{T}}) where {T, P}","category":"page"},{"location":"tutorials/#Base.match-Union{Tuple{P}, Tuple{T}, Tuple{ZXCalculus.AbstractRule, AbstractZXDiagram{T, P}}} where {T, P}","page":"Tutorials","title":"Base.match","text":"match(r, zxd)\n\nReturns all matched vertices, which will be store in sturct Match, for rule r in a ZX-diagram zxd.\n\n\n\n\n\n","category":"method"},{"location":"tutorials/#ZXCalculus.rewrite!-Union{Tuple{P}, Tuple{T}, Tuple{ZXCalculus.AbstractRule, AbstractZXDiagram{T, P}, Array{Match{T}, 1}}} where {T, P}","page":"Tutorials","title":"ZXCalculus.rewrite!","text":"rewrite!(r, zxd, matches)\n\nRewrite a ZX-diagram zxd with rule r for all vertices in matches. matches can be a vector of Match or just an instance of Match.\n\n\n\n\n\n","category":"method"},{"location":"tutorials/","page":"Tutorials","title":"Tutorials","text":"The lowest level for rewriting ZX-diagrams is manipulating the multigraphs directly. This way is not recommended unless one wants to develop new rules in ZX-calculus.","category":"page"},{"location":"tutorials/#Integration-with-YaoLang.jl","page":"Tutorials","title":"Integration with YaoLang.jl","text":"","category":"section"},{"location":"tutorials/","page":"Tutorials","title":"Tutorials","text":"YaoLang.jl is the next DSL for Yao and quantum programs. And it is now integrated with ZXCalculus.jl. The compiler of YaoLang.jl will optimize the quantum programs when the optimizers are given.","category":"page"},{"location":"tutorials/","page":"Tutorials","title":"Tutorials","text":"One can use","category":"page"},{"location":"tutorials/","page":"Tutorials","title":"Tutorials","text":"@device function circuit()\n    ...\nend","category":"page"},{"location":"tutorials/","page":"Tutorials","title":"Tutorials","text":"to build up a generic quantum circuit. To set up a optimizer in addition, one can simply use","category":"page"},{"location":"tutorials/","page":"Tutorials","title":"Tutorials","text":"@device optimizer = opt function circuit()\n    ...\nend","category":"page"},{"location":"tutorials/","page":"Tutorials","title":"Tutorials","text":"Here, opt can be a sub-vector of [:zx_clifford, :zx_teleport]. That is, if :zx_clifford is in opt, then clifford_simplification will be applied to the circuit, and if :zx_teleport is in opt, then phase_teleportation will be applied to the circuit.","category":"page"},{"location":"tutorials/","page":"Tutorials","title":"Tutorials","text":"For example, the following code will try to simplify circ that defined by circuit() with clifford_simplification and phase_teleportation.","category":"page"},{"location":"tutorials/","page":"Tutorials","title":"Tutorials","text":"@device optimizer = [:zx_clifford, :zx_teleport] function circuit()\n    ...\nend\ncirc = circuit()","category":"page"},{"location":"examples/#Examples","page":"Examples","title":"Examples","text":"","category":"section"},{"location":"examples/","page":"Examples","title":"Examples","text":"Here we will show some examples of using ZXCalculus.jl.","category":"page"},{"location":"examples/#Clifford-simplification","page":"Examples","title":"Clifford simplification","text":"","category":"section"},{"location":"examples/","page":"Examples","title":"Examples","text":"This example can be found in the appendix of Clifford simplification. Firstly, we build up the circuit by using push_gate!.","category":"page"},{"location":"examples/","page":"Examples","title":"Examples","text":"using ZXCalculus\n\nfunction generate_example_1()\n    zxd = ZXDiagram(4)\n    push_gate!(zxd, Val(:Z), 1, 3//2)\n    push_gate!(zxd, Val(:H), 1)\n    push_gate!(zxd, Val(:Z), 1, 1//2)\n    push_gate!(zxd, Val(:H), 4)\n    push_gate!(zxd, Val(:CZ), 4, 1)\n    push_gate!(zxd, Val(:CNOT), 1, 4)\n    push_gate!(zxd, Val(:H), 1)\n    push_gate!(zxd, Val(:H), 4)\n    push_gate!(zxd, Val(:Z), 1, 1//4)\n    push_gate!(zxd, Val(:Z), 4, 3//2)\n    push_gate!(zxd, Val(:X), 4, 1//1)\n    push_gate!(zxd, Val(:H), 1)\n    push_gate!(zxd, Val(:Z), 4, 1//2)\n    push_gate!(zxd, Val(:X), 4, 1//1)\n    push_gate!(zxd, Val(:Z), 2, 1//2)\n    push_gate!(zxd, Val(:CNOT), 3, 2)\n    push_gate!(zxd, Val(:H), 2)\n    push_gate!(zxd, Val(:CNOT), 3, 2)\n    push_gate!(zxd, Val(:Z), 2, 1//4)\n    push_gate!(zxd, Val(:Z), 3, 1//2)\n    push_gate!(zxd, Val(:H), 2)\n    push_gate!(zxd, Val(:H), 3)\n    push_gate!(zxd, Val(:Z), 3, 1//2)\n    push_gate!(zxd, Val(:CNOT), 3, 2)\n\n    return zxd\nend\nex1 = generate_example_1()","category":"page"},{"location":"examples/","page":"Examples","title":"Examples","text":"We can draw this ZX-diagram by using","category":"page"},{"location":"examples/","page":"Examples","title":"Examples","text":"using YaoPlots\nplot(ex1)","category":"page"},{"location":"examples/","page":"Examples","title":"Examples","text":"(Image: the circuit of example 1) To simplify zxd, one can simply use","category":"page"},{"location":"examples/","page":"Examples","title":"Examples","text":"simplified_ex1 = clifford_simplification(ex1)","category":"page"},{"location":"examples/","page":"Examples","title":"Examples","text":"or explicitly use","category":"page"},{"location":"examples/","page":"Examples","title":"Examples","text":"zxg = ZXGraph(ex1)\nsimplify!(Rule{:lc}(), zxg)\nsimplify!(Rule{:p1}(), zxg)\nreplace!(Rule{:pab}(), zxg)\nsimplified_ex1 = circuit_extraction(zxg)","category":"page"},{"location":"examples/","page":"Examples","title":"Examples","text":"And we draw the simplified circuit.","category":"page"},{"location":"examples/","page":"Examples","title":"Examples","text":"plot(simplified_ex1)","category":"page"},{"location":"examples/","page":"Examples","title":"Examples","text":"(Image: the simplified circuit of example 1)","category":"page"},{"location":"examples/#Phase-teleportation","page":"Examples","title":"Phase teleportation","text":"","category":"section"},{"location":"examples/","page":"Examples","title":"Examples","text":"This example is an arithmetic circuit from phase teleportation. We first build up the circuit.","category":"page"},{"location":"examples/","page":"Examples","title":"Examples","text":"using ZXCalculus, YaoPlots\nfunction generate_example2()\n    cir = ZXDiagram(5)\n    push_gate!(cir, Val(:X), 5, 1//1)\n    push_gate!(cir, Val(:H), 5)\n    push_gate!(cir, Val(:Z), 5)\n    push_gate!(cir, Val(:CNOT), 5, 4)\n    push_gate!(cir, Val(:Z), 5, 7//4)\n    push_gate!(cir, Val(:CNOT), 5, 1)\n    push_gate!(cir, Val(:Z), 5, 1//4)\n    push_gate!(cir, Val(:CNOT), 5, 4)\n    push_gate!(cir, Val(:Z), 4, 1//4)\n    push_gate!(cir, Val(:Z), 5, 7//4)\n    push_gate!(cir, Val(:CNOT), 5, 1)\n    push_gate!(cir, Val(:CNOT), 4, 1)\n    push_gate!(cir, Val(:Z), 5, 1//4)\n    push_gate!(cir, Val(:Z), 1, 1//4)\n    push_gate!(cir, Val(:Z), 4, 7//4)\n    push_gate!(cir, Val(:CNOT), 4, 1)\n    push_gate!(cir, Val(:CNOT), 5, 4)\n    push_gate!(cir, Val(:Z), 5, 7//4)\n    push_gate!(cir, Val(:CNOT), 5, 3)\n    push_gate!(cir, Val(:Z), 5, 1//4)\n    push_gate!(cir, Val(:CNOT), 5, 4)\n    push_gate!(cir, Val(:Z), 4, 1//4)\n    push_gate!(cir, Val(:Z), 5, 7//4)\n    push_gate!(cir, Val(:CNOT), 5, 3)\n    push_gate!(cir, Val(:CNOT), 4, 3)\n    push_gate!(cir, Val(:Z), 5, 1//4)\n    push_gate!(cir, Val(:Z), 3, 1//4)\n    push_gate!(cir, Val(:Z), 4, 7//4)\n    push_gate!(cir, Val(:H), 5)\n    push_gate!(cir, Val(:Z), 5)\n    push_gate!(cir, Val(:CNOT), 4, 3)\n    push_gate!(cir, Val(:CNOT), 5, 4)\n    push_gate!(cir, Val(:H), 5)\n    push_gate!(cir, Val(:Z), 5)\n    push_gate!(cir, Val(:CNOT), 5, 3)\n    push_gate!(cir, Val(:Z), 5, 7//4)\n    push_gate!(cir, Val(:CNOT), 5, 2)\n    push_gate!(cir, Val(:Z), 5, 1//4)\n    push_gate!(cir, Val(:CNOT), 5, 3)\n    push_gate!(cir, Val(:Z), 3, 1//4)\n    push_gate!(cir, Val(:Z), 5, 7//4)\n    push_gate!(cir, Val(:CNOT), 5, 2)\n    push_gate!(cir, Val(:CNOT), 3, 2)\n    push_gate!(cir, Val(:Z), 5, 1//4)\n    push_gate!(cir, Val(:H), 5)\n    push_gate!(cir, Val(:Z), 2, 1//4)\n    push_gate!(cir, Val(:Z), 3, 7//4)\n    push_gate!(cir, Val(:Z), 5)\n    push_gate!(cir, Val(:CNOT), 3, 2)\n    push_gate!(cir, Val(:CNOT), 5, 3)\n    push_gate!(cir, Val(:H), 5)\n    push_gate!(cir, Val(:Z), 5)\n    push_gate!(cir, Val(:CNOT), 5, 2)\n    push_gate!(cir, Val(:Z), 5, 7//4)\n    push_gate!(cir, Val(:CNOT), 5, 1)\n    push_gate!(cir, Val(:Z), 5, 1//4)\n    push_gate!(cir, Val(:CNOT), 5, 2)\n    push_gate!(cir, Val(:Z), 2, 1//4)\n    push_gate!(cir, Val(:Z), 5, 7//4)\n    push_gate!(cir, Val(:CNOT), 5, 1)\n    push_gate!(cir, Val(:CNOT), 2, 1)\n    push_gate!(cir, Val(:Z), 5, 1//4)\n    push_gate!(cir, Val(:Z), 1, 1//4)\n    push_gate!(cir, Val(:Z), 2, 7//4)\n    push_gate!(cir, Val(:H), 5)\n    push_gate!(cir, Val(:Z), 5)\n    push_gate!(cir, Val(:CNOT), 2, 1)\n    push_gate!(cir, Val(:CNOT), 5, 2)\n    push_gate!(cir, Val(:CNOT), 5, 1)\n    return cir\nend\nex2 = generate_example2()\nplot(ex2)","category":"page"},{"location":"examples/","page":"Examples","title":"Examples","text":"(Image: the circuit of example 2)","category":"page"},{"location":"examples/","page":"Examples","title":"Examples","text":"We can use phase_teleportation for reducing the number of T gates of a circuit without changing its general structure.","category":"page"},{"location":"examples/","page":"Examples","title":"Examples","text":"reduced_ex2 = phase_teleportation(ex2)\nplot(reduced_ex2)","category":"page"},{"location":"examples/","page":"Examples","title":"Examples","text":"(Image: the reduced circuit of example 2)","category":"page"},{"location":"examples/","page":"Examples","title":"Examples","text":"By using tcount,","category":"page"},{"location":"examples/","page":"Examples","title":"Examples","text":"tcount(ex2)\ntcount(reduced_ex2)","category":"page"},{"location":"examples/","page":"Examples","title":"Examples","text":"we can see that the number of T gates has decreased from 28 to 8.","category":"page"},{"location":"examples/#Other-usages","page":"Examples","title":"Other usages","text":"","category":"section"},{"location":"examples/","page":"Examples","title":"Examples","text":"In the previous sections, we introduced how to use ZXCalculus.jl for ZX-diagrams which represent quantum circuits. Sometimes, one may wish to use it for general ZX-diagrams. It is possible.","category":"page"},{"location":"examples/","page":"Examples","title":"Examples","text":"One can create a ZXDiagram by building up its Multigraph and other information. For example,","category":"page"},{"location":"examples/","page":"Examples","title":"Examples","text":"using ZXCalculus, YaoPlots, LightGraphs\ng = Multigraph(6)\nadd_edge!(g, 1, 2)\nadd_edge!(g, 2, 3)\nadd_edge!(g, 3, 4)\nadd_edge!(g, 3, 5)\nadd_edge!(g, 3, 6)\nps = [0, 1, 1//2, 0, 0, 0]\nv_t = [SpiderType.In, SpiderType.X, SpiderType.Z, SpiderType.Out, SpiderType.Out, SpiderType.Out]\nzxd = ZXDiagram(g, v_t, ps)","category":"page"},{"location":"examples/","page":"Examples","title":"Examples","text":"Because the information of vertices locations of a general ZX-diagram is not provided, its plot will have a random layout.","category":"page"},{"location":"examples/","page":"Examples","title":"Examples","text":"We can manipulate zxd by using ZX-calculus Rules.","category":"page"},{"location":"examples/","page":"Examples","title":"Examples","text":"matches = match(Rule{:pi}(), zxd)\nrewrite!(Rule{:pi}(), zxd, matches)","category":"page"},{"location":"#ZXCalculus.jl","page":"Home","title":"ZXCalculus.jl","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"A implementation of ZX-calculus in Julia.","category":"page"},{"location":"","page":"Home","title":"Home","text":"ZX-calculus is a graphical language for quantum computing. One can represent quantum states and operators as ZX-diagrams, and manipulate them with ZX-calculus rules. As an application of ZX-calculus, one can simplify quantum circuits with it. For more details about ZX-calculus, one can check this website.","category":"page"},{"location":"#GSoC","page":"Home","title":"GSoC","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"This package is a Google Summer of Code 2020 project.","category":"page"},{"location":"#Package-Features","page":"Home","title":"Package Features","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"As an implementation of ZX-calculus, these following features are available similar to the Python implementation PyZX.","category":"page"},{"location":"","page":"Home","title":"Home","text":"Building up and manipulating ZX-diagrams\nSimplifying ZX-diagrams with specific rules\nSimplifying quantum circuits with ZX-calculus based algorithms including Clifford simplification and phase teleportation.\nVisualization for ZX-diagrams.","category":"page"},{"location":"","page":"Home","title":"Home","text":"ZXCalculus.jl can be integrated into the quantum compiler YaoLang.jl. This makes the following features.","category":"page"},{"location":"","page":"Home","title":"Home","text":"Reading or outputting quantum circuits in various forms (for example, QASM, YaoBlock instructions, and so on).\nA compiler level circuit simplification engine.","category":"page"},{"location":"#Installation","page":"Home","title":"Installation","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"To install ZXCalculus.jl, please open Julia's interactive session (known as REPL) and press ] key in the REPL to use the package mode, then type the following command","category":"page"},{"location":"","page":"Home","title":"Home","text":"pkg> add ZXCalculus","category":"page"},{"location":"","page":"Home","title":"Home","text":"For plotting, please install YaoPlots.jl in addition.","category":"page"},{"location":"","page":"Home","title":"Home","text":"pkg> add YaoPlots","category":"page"},{"location":"#Contents","page":"Home","title":"Contents","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Pages = [\"tutorials.md\", \"examples.md\", \"api.md\"]\nDepth = 2","category":"page"},{"location":"#Index","page":"Home","title":"Index","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"","category":"page"}]
}
