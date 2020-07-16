# Tutorial

ZX-diagrams are the basic objects in ZX-calculus. In our implementation, each
ZX-diagram consists of a multigraph and vertices information including type of
vertices and the phase of vertices. `ZXDiagram` is the data structure for representing
ZX-diagrams.

There are 5 types of vertices: `In`, `Out`, `Z`, `X`, `H` which represent the
inputs of quantum circuits, outputs of quantum circuits, Z-spiders, X-spiders,
H-boxes. There can be a phase for each vertex. The phase of a vertex of `Z` or
`X` is the phase of a Z or X-spider. For the other types of vertices, the phase
is zero by default.

In each `ZXDiagram`, there is a `layout` for storing layout information for the
quantum circuit, and a `phase_ids` for storing information which is needed in phase
teleportation.

## Construction of ZX-diagrams

As we usually focus on quantum circuits, the recommanded way to construct `ZXDiagram`s
is by the following function.
```@docs
ZXDiagram(nbit::T) where T<:Integer
```
Then one can use `push_gate!`, `push_ctrl_gate!` to push quantum gates at the end
of a quantum circuit, or use `pushfirst_gate!`, `pushfirst_ctrl_gate!` to push
gates at the beginning of a quantum circuit.
```@docs
push_gate!(zxd::ZXDiagram{T, P}, ::Val{:Z}, loc::T, phase::P = zero(P)) where {T, P}
push_ctrl_gate!(zxd::ZXDiagram{T, P}, ::Val{:CNOT}, loc::T, ctrl::T) where {T, P}
pushfirst_gate!(zxd::ZXDiagram{T, P}, ::Val{:Z}, loc::T, phase::P = zero(P)) where {T, P}
pushfirst_ctrl_gate!(zxd::ZXDiagram{T, P}, ::Val{:CNOT}, loc::T, ctrl::T) where {T, P}
```

For example, in `example\ex1.jl`, one can generate the demo circuit by the function
```julia
using ZXCalculus
function generate_example()
    zxd = ZXDiagram(4)
    push_gate!(zxd, Val{:Z}(), 1, 3//2)
    push_gate!(zxd, Val{:H}(), 1)
    push_gate!(zxd, Val{:Z}(), 1, 1//2)
    push_gate!(zxd, Val{:Z}(), 2, 1//2)
    push_gate!(zxd, Val{:H}(), 4)
    push_ctrl_gate!(zxd, Val{:CNOT}(), 3, 2)
    push_ctrl_gate!(zxd, Val{:CZ}(), 4, 1)
    push_gate!(zxd, Val{:H}(), 2)
    push_ctrl_gate!(zxd, Val{:CNOT}(), 3, 2)
    push_ctrl_gate!(zxd, Val{:CNOT}(), 1, 4)
    push_gate!(zxd, Val{:H}(), 1)
    push_gate!(zxd, Val{:Z}(), 2, 1//4)
    push_gate!(zxd, Val{:Z}(), 3, 1//2)
    push_gate!(zxd, Val{:H}(), 4)
    push_gate!(zxd, Val{:Z}(), 1, 1//4)
    push_gate!(zxd, Val{:H}(), 2)
    push_gate!(zxd, Val{:H}(), 3)
    push_gate!(zxd, Val{:Z}(), 4, 3//2)
    push_gate!(zxd, Val{:Z}(), 3, 1//2)
    push_gate!(zxd, Val{:X}(), 4, 1//1)
    push_ctrl_gate!(zxd, Val{:CNOT}(), 3, 2)
    push_gate!(zxd, Val{:H}(), 1)
    push_gate!(zxd, Val{:Z}(), 4, 1//2)
    push_gate!(zxd, Val{:X}(), 4, 1//1)

    return zxd
end
```

In the paper [arXiv:1902.03178](https://arxiv.org/abs/1902.03178), they introduced
a special type of ZX-diagrams, graph-like ZX-diagrams, which consists of Z-spiders
with 2 different types of edges only. We use `ZXGraph` for representing this
special type of ZX-diagrams. One can convert a `ZXDiagram` into a `ZXGraph` by
simply use the construction function:
```@docs
ZXGraph(zxd::ZXDiagram{T, P}) where {T, P}
```


## Visualization

With the package [`YaoPlots.jl`](https://github.com/QuantumBFS/YaoPlots.jl),
one can draw ZX-diagrams with one line of code.
```julia
plot(zxd[; linetype = lt])
```
Here `zxd` can be either a `ZXDiagram` or `ZXGraph`. The argument `lt` is set to
`"straight"` by default. One can also set it to `"curve"` to make the edges curves.


## Manipulating ZX-diagrams

With `ZXCalculus.jl`, one can manipulate ZX-diagrams at different levels.
- Simplifying quantum circuits
- Rewriting ZX-diagrams with rules
- Rewriting ZX-diagrams at graphical level

The highest level is circuit simplification algorithms. By now there are two
algorithms are available:
```@docs
clifford_simplification(circ::ZXDiagram)
phase_teleportation(circ::ZXDiagram{T, P}) where {T, P}
```
The input of these algorithms will be a ZX-diagram which representing a quantum
circuit. And these algorithms will return a ZX-diagram of a simplified quantum
circuit. For more details, please refer to [Clifford simplification](https://arxiv.org/abs/1902.03178)
and [phase teleportation](https://arxiv.org/abs/1903.10477).

One can rewrite ZX-diagrams with rules. In `ZXCalculus.jl`, rules is identified
as data structures [`Rule`](@ref).
And we can use the following functions to simplify ZX-diagrams:
```@docs
simplify!(r::ZXCalculus.AbstractRule, zxd::AbstractZXDiagram)
replace!(r::ZXCalculus.AbstractRule, zxd::AbstractZXDiagram)
```
For example, in `example/ex1.jl`, we can get a simplified graph-like ZX-diagram by:
```julia
zxd = generate_example()
zxg = ZXGraph(zxd)
simplify!(Rule{:lc}(), zxg)
simplify!(Rule{:p1}(), zxg)
replace!(Rule{:pab}(), zxg)
```

The difference between `simplify!` and `replace!` is that `replace!` only matches
vertices and tries to rewrite with all matched vertices once, while `simplify!`
will keep matching until nothing matched.

The following APIs are useful for more detailed rewriting.
```@docs
match(::ZXCalculus.AbstractRule, zxd::AbstractZXDiagram{T, P}) where {T, P}
rewrite!(r::ZXCalculus.AbstractRule, zxd::AbstractZXDiagram{T, P}, matches::Vector{Match{T}}) where {T, P}
```

The lowest level for rewriting ZX-diagrams is manipulating the multigraphs directly.
This way is not recommanded unless one want to develop new rules in ZX-calculus.

## Integration with `YaoLang.jl`
