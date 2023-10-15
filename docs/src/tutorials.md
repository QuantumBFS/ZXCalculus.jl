# Tutorials

ZX-diagrams are the basic objects in ZX-calculus. In our implementation, each ZX-diagram consists of a multigraph and vertices information including the type of vertices and the phase of vertices. [`ZXCalculus.ZX.ZXDiagram`](@ref) is the data structure for representing
ZX-diagrams.

There are 5 types of vertices: `In`, `Out`, `Z`, `X`, `H` which represent the inputs of quantum circuits, outputs of quantum circuits, Z-spiders, X-spiders, H-boxes. There can be a phase for each vertex. The phase of a vertex of `Z` or `X` is the phase of a Z or X-spider. For the other types of vertices, the phase is zero by default.

In each `ZXDiagram`, there is a `layout` for storing layout information for the quantum circuit, and a `phase_ids` for storing information which is needed in phase teleportation.

## Construction of ZX-diagrams

As we usually focus on quantum circuits, the recommended way to construct `ZXDiagram`s is by the following function [`ZXCalculus.ZX.ZXDiagram(nbits::T) where {T<:Integer}`](@ref).

Then one can use [`ZXCalculus.ZX.push_gate!`](@ref) to push quantum gates at the end of a quantum circuit, or use [`ZXCalculus.ZX.pushfirst_gate!`](@ref)to push gates at the beginning of a quantum circuit.

For example, in `example\ex1.jl`, one can generate the demo circuit by the function
```julia
using ZXCalculus
function generate_example()
    zxd = ZXCalculus.ZX.ZXDiagram(4)
    push_gate!(zxd, Val(:Z), 1, 3//2)
    push_gate!(zxd, Val(:H), 1)
    push_gate!(zxd, Val(:Z), 1, 1//2)
    push_gate!(zxd, Val(:Z), 2, 1//2)
    push_gate!(zxd, Val(:H), 4)
    push_gate!(zxd, Val(:CNOT), 3, 2)
    push_gate!(zxd, Val(:CZ), 4, 1)
    push_gate!(zxd, Val(:H), 2)
    push_gate!(zxd, Val(:CNOT), 3, 2)
    push_gate!(zxd, Val(:CNOT), 1, 4)
    push_gate!(zxd, Val(:H), 1)
    push_gate!(zxd, Val(:Z), 2, 1//4)
    push_gate!(zxd, Val(:Z), 3, 1//2)
    push_gate!(zxd, Val(:H), 4)
    push_gate!(zxd, Val(:Z), 1, 1//4)
    push_gate!(zxd, Val(:H), 2)
    push_gate!(zxd, Val(:H), 3)
    push_gate!(zxd, Val(:Z), 4, 3//2)
    push_gate!(zxd, Val(:Z), 3, 1//2)
    push_gate!(zxd, Val(:X), 4, 1//1)
    push_gate!(zxd, Val(:CNOT), 3, 2)
    push_gate!(zxd, Val(:H), 1)
    push_gate!(zxd, Val(:Z), 4, 1//2)
    push_gate!(zxd, Val(:X), 4, 1//1)

    return zxd
end
```

In the paper [arXiv:1902.03178](https://arxiv.org/abs/1902.03178), they introduced a special type of ZX-diagrams, graph-like ZX-diagrams, which consists of Z-spiders with 2 different types of edges only. We use [`ZXCalculus.ZX.ZXGraph`](@ref) for representing this special type of ZX-diagrams. One can convert a `ZXDiagram` into a `ZXGraph` by simply use the construction function [`ZXCalculus.ZX.ZXGraph(zxd::ZXCalculus.ZX.ZXDiagram{T, P}) where {T, P}`](@ref):

## Visualization

With the package [`YaoPlots.jl`](https://github.com/QuantumBFS/YaoPlots.jl), one can draw ZX-diagrams with one line of code.
```julia
plot(zxd[; linetype = lt])
```
Here `zxd` can be either a `ZXDiagram` or `ZXGraph`. The argument `lt` is set to `"straight"` by default. One can also set it to `"curve"` to make the edges curves.


## Manipulating ZX-diagrams

With `ZXCalculus.jl`, one can manipulate ZX-diagrams at different levels.
- Simplifying quantum circuits
- Rewriting ZX-diagrams with rules
- Rewriting ZX-diagrams at the graphical level

The highest level is the circuit simplification algorithms. By now there are two algorithms are available: [`ZXCalculus.ZX.clifford_simplification`](@ref) and [`ZXCalculus.ZX.phase_teleportation`](ref).

The input of these algorithms will be a ZX-diagram representing a quantum circuit. And these algorithms will return a ZX-diagram of a simplified quantum circuit. For more details, please refer to [Clifford simplification](https://arxiv.org/abs/1902.03178) and [phase teleportation](https://arxiv.org/abs/1903.10477).

One can rewrite ZX-diagrams with rules. In `ZXCalculus.jl`, rules are identified as data structures [`Rule`](@ref). And we can use the following functions to simplify ZX-diagrams: [`ZXCalculus.ZX.simplify!`](@ref) and [`ZXCalculus.ZX.replace!`](@ref).

For example, in `example/ex1.jl`, we can get a simplified graph-like ZX-diagram by:
```julia
zxd = generate_example()
zxg = ZXGraph(zxd)
simplify!(Rule{:lc}(), zxg)
simplify!(Rule{:p1}(), zxg)
replace!(Rule{:pab}(), zxg)
```

The difference between `simplify!` and `replace!` is that `replace!` only matches vertices and tries to rewrite with all matched vertices once, while `simplify!` will keep matching until nothing matched.

The following APIs are useful for more detailed rewriting.
1. [`ZXCalculus.ZX.match`](@ref)
2. [`ZXCalculus.ZX.rewrite!`](@ref)

The lowest level for rewriting ZX-diagrams is manipulating the multigraphs directly. This way is not recommended unless one wants to develop new rules in ZX-calculus.


## Integration with `YaoLang.jl`

[`YaoLang.jl`](https://github.com/QuantumBFS/YaoLang.jl) is the next DSL for Yao and quantum programs. And it is now integrated with `ZXCalculus.jl`. The compiler of `YaoLang.jl` will optimize the quantum programs when the optimizers are given.

One can use
```julia
@device function circuit()
    ...
end
```
to build up a generic quantum circuit. To set up a optimizer in addition, one can simply use
```julia
@device optimizer = opt function circuit()
    ...
end
```
Here, `opt` can be a sub-vector of `[:zx_clifford, :zx_teleport]`. That is, if `:zx_clifford` is in `opt`, then [`clifford_simplification`](@ref) will be applied to the circuit, and if `:zx_teleport` is in `opt`, then [`phase_teleportation`](@ref) will be applied to the circuit.

For example, the following code will try to simplify `circ` that defined by `circuit()` with [`clifford_simplification`](@ref) and [`phase_teleportation`](@ref).
```julia
@device optimizer = [:zx_clifford, :zx_teleport] function circuit()
    ...
end
circ = circuit()
```
