# Examples

Here we will show some examples of using `ZXCalculus.jl`.

## Clifford simplification

This example can be found in the appendix of [Clifford simplification](https://arxiv.org/abs/1902.03178). Firstly, we build up the circuit by using [`push_gate!`](@ref).

```julia
using ZXCalculus

function generate_example_1()
    zxc = ZXCircuit(4)
    push_gate!(zxc, Val(:Z), 1, 3//2)
    push_gate!(zxc, Val(:H), 1)
    push_gate!(zxc, Val(:Z), 1, 1//2)
    push_gate!(zxc, Val(:H), 4)
    push_gate!(zxc, Val(:CZ), 4, 1)
    push_gate!(zxc, Val(:CNOT), 1, 4)
    push_gate!(zxc, Val(:H), 1)
    push_gate!(zxc, Val(:H), 4)
    push_gate!(zxc, Val(:Z), 1, 1//4)
    push_gate!(zxc, Val(:Z), 4, 3//2)
    push_gate!(zxc, Val(:X), 4, 1//1)
    push_gate!(zxc, Val(:H), 1)
    push_gate!(zxc, Val(:Z), 4, 1//2)
    push_gate!(zxc, Val(:X), 4, 1//1)
    push_gate!(zxc, Val(:Z), 2, 1//2)
    push_gate!(zxc, Val(:CNOT), 3, 2)
    push_gate!(zxc, Val(:H), 2)
    push_gate!(zxc, Val(:CNOT), 3, 2)
    push_gate!(zxc, Val(:Z), 2, 1//4)
    push_gate!(zxc, Val(:Z), 3, 1//2)
    push_gate!(zxc, Val(:H), 2)
    push_gate!(zxc, Val(:H), 3)
    push_gate!(zxc, Val(:Z), 3, 1//2)
    push_gate!(zxc, Val(:CNOT), 3, 2)

    return zxc
end
ex1 = generate_example_1()
```
We can draw this ZX-diagram by using
```julia
using YaoPlots
plot(ex1)
```
![the circuit of example 1](imgs/ex1.svg)
To simplify `ex1`, one can simply use
```julia
simplified_ex1 = clifford_simplification(ex1)
```
or explicitly apply the simplification rules:
```julia
simplify!(LocalCompRule(), ex1)
simplify!(Pivot1Rule(), ex1)
replace!(PivotBoundaryRule(), ex1)
simplified_ex1 = circuit_extraction(ex1)
```
And we draw the simplified circuit.
```julia
plot(simplified_ex1)
```
![the simplified circuit of example 1](imgs/simplified_ex1.svg)


## Phase teleportation

This example is an arithmetic circuit from [phase teleportation](https://arxiv.org/abs/1903.10477).
We first build up the circuit.
```julia
using ZXCalculus, YaoPlots
function generate_example2()
    zxc = ZXCircuit(5)
    push_gate!(zxc, Val(:X), 5, 1//1)
    push_gate!(zxc, Val(:H), 5)
    push_gate!(zxc, Val(:Z), 5)
    push_gate!(zxc, Val(:CNOT), 5, 4)
    push_gate!(zxc, Val(:Z), 5, 7//4)
    push_gate!(zxc, Val(:CNOT), 5, 1)
    push_gate!(zxc, Val(:Z), 5, 1//4)
    push_gate!(zxc, Val(:CNOT), 5, 4)
    push_gate!(zxc, Val(:Z), 4, 1//4)
    push_gate!(zxc, Val(:Z), 5, 7//4)
    push_gate!(zxc, Val(:CNOT), 5, 1)
    push_gate!(zxc, Val(:CNOT), 4, 1)
    push_gate!(zxc, Val(:Z), 5, 1//4)
    push_gate!(zxc, Val(:Z), 1, 1//4)
    push_gate!(zxc, Val(:Z), 4, 7//4)
    push_gate!(zxc, Val(:CNOT), 4, 1)
    push_gate!(zxc, Val(:CNOT), 5, 4)
    push_gate!(zxc, Val(:Z), 5, 7//4)
    push_gate!(zxc, Val(:CNOT), 5, 3)
    push_gate!(zxc, Val(:Z), 5, 1//4)
    push_gate!(zxc, Val(:CNOT), 5, 4)
    push_gate!(zxc, Val(:Z), 4, 1//4)
    push_gate!(zxc, Val(:Z), 5, 7//4)
    push_gate!(zxc, Val(:CNOT), 5, 3)
    push_gate!(zxc, Val(:CNOT), 4, 3)
    push_gate!(zxc, Val(:Z), 5, 1//4)
    push_gate!(zxc, Val(:Z), 3, 1//4)
    push_gate!(zxc, Val(:Z), 4, 7//4)
    push_gate!(zxc, Val(:H), 5)
    push_gate!(zxc, Val(:Z), 5)
    push_gate!(zxc, Val(:CNOT), 4, 3)
    push_gate!(zxc, Val(:CNOT), 5, 4)
    push_gate!(zxc, Val(:H), 5)
    push_gate!(zxc, Val(:Z), 5)
    push_gate!(zxc, Val(:CNOT), 5, 3)
    push_gate!(zxc, Val(:Z), 5, 7//4)
    push_gate!(zxc, Val(:CNOT), 5, 2)
    push_gate!(zxc, Val(:Z), 5, 1//4)
    push_gate!(zxc, Val(:CNOT), 5, 3)
    push_gate!(zxc, Val(:Z), 3, 1//4)
    push_gate!(zxc, Val(:Z), 5, 7//4)
    push_gate!(zxc, Val(:CNOT), 5, 2)
    push_gate!(zxc, Val(:CNOT), 3, 2)
    push_gate!(zxc, Val(:Z), 5, 1//4)
    push_gate!(zxc, Val(:H), 5)
    push_gate!(zxc, Val(:Z), 2, 1//4)
    push_gate!(zxc, Val(:Z), 3, 7//4)
    push_gate!(zxc, Val(:Z), 5)
    push_gate!(zxc, Val(:CNOT), 3, 2)
    push_gate!(zxc, Val(:CNOT), 5, 3)
    push_gate!(zxc, Val(:H), 5)
    push_gate!(zxc, Val(:Z), 5)
    push_gate!(zxc, Val(:CNOT), 5, 2)
    push_gate!(zxc, Val(:Z), 5, 7//4)
    push_gate!(zxc, Val(:CNOT), 5, 1)
    push_gate!(zxc, Val(:Z), 5, 1//4)
    push_gate!(zxc, Val(:CNOT), 5, 2)
    push_gate!(zxc, Val(:Z), 2, 1//4)
    push_gate!(zxc, Val(:Z), 5, 7//4)
    push_gate!(zxc, Val(:CNOT), 5, 1)
    push_gate!(zxc, Val(:CNOT), 2, 1)
    push_gate!(zxc, Val(:Z), 5, 1//4)
    push_gate!(zxc, Val(:Z), 1, 1//4)
    push_gate!(zxc, Val(:Z), 2, 7//4)
    push_gate!(zxc, Val(:H), 5)
    push_gate!(zxc, Val(:Z), 5)
    push_gate!(zxc, Val(:CNOT), 2, 1)
    push_gate!(zxc, Val(:CNOT), 5, 2)
    push_gate!(zxc, Val(:CNOT), 5, 1)
    return zxc
end
ex2 = generate_example2()
plot(ex2)
```
![the circuit of example 2](imgs/ex2.svg)

We can use [`phase_teleportation`](@ref) for reducing the number of T gates of a circuit without changing its general structure.
```julia
reduced_ex2 = phase_teleportation(ex2)
plot(reduced_ex2)
```
![the reduced circuit of example 2](imgs/reduced_ex2.svg)

By using [`tcount`](@ref),
```julia
tcount(ex2)
tcount(reduced_ex2)
```
we can see that the number of T gates has decreased from 28 to 8.


## Other usages

In the previous sections, we introduced how to use `ZXCalculus.jl` for quantum circuits using `ZXCircuit`. Sometimes, one may wish to work with the lower-level graph representation directly.

### Working with ZXGraph directly

For advanced users who need direct access to the graph structure, you can work with `ZXGraph`. However, for most use cases, `ZXCircuit` is the recommended interface.

```julia
using ZXCalculus, YaoPlots, Graphs

# Create a ZXCircuit first
zxc = ZXCircuit(3)
push_gate!(zxc, Val(:H), 1)
push_gate!(zxc, Val(:CNOT), 1, 2)

# Access the underlying ZXGraph if needed for low-level operations
zxg = zxc.zxd  # The internal ZXGraph

# Apply graph-based rules
simplify!(LocalCompRule(), zxc)
```

### Deprecated: ZXDiagram

**Note:** `ZXDiagram` is deprecated. For circuit-based operations, use `ZXCircuit` instead. If you have existing code using `ZXDiagram`, you can convert it:
```julia
zxc = ZXCircuit(old_zxd)  # Convert deprecated ZXDiagram to ZXCircuit
```
