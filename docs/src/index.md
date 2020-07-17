# ZXCalculus.jl

*A implementation of ZX-calculus in Julia.*

ZX-calculus is a graphical language for quantum states. One can represent quantum
states as ZX-diagrams, and manipulate them with ZX-calculus rules. As an application
of ZX-calculus, one can simplify quantum circuits with it. For more details about
ZX-calculus, one can check this [website](http://zxcalculus.com/).

## GSoC

This package is a *Google Summer of Code 2020* project.

## Package Features

As an implementation of ZX-calculus, these following features are available similar to
the Python implementation [`PyZX`](https://github.com/Quantomatic/pyzx).
- Building up and manipulating ZX-diagrams
- Simplifying ZX-diagrams with specific rules
- Simplifying quantum circuits with ZX-calculus based algorithms including
  [Clifford simplification](https://arxiv.org/abs/1902.03178) and
  [phase teleportation](https://arxiv.org/abs/1903.10477).
- Visualization for ZX-diagrams.

`ZXCalculus.jl` can be integrated into the quantum compiler
[`YaoLang.jl`](https://github.com/QuantumBFS/YaoLang.jl). This makes the following features.
- Reading or outputing quantum circuits in various form (for example, QASM,
  YaoBlock instructions, and so on).
- A compiler level circuit simplification engine.


## Installation

To install `ZXCalculus.jl`, please open Julia's interactive session (known as REPL)
and press `]` key in the REPL to use the package mode, then type the following command
```julia
pkg> add ZXCalculus
```

For plotting, please install [`YaoPlots.jl`](https://github.com/QuantumBFS/YaoPlots.jl) in addition.
```julia
pkg> add YaoPlots
```

## Contents

```@contents
Pages = ["tutorial.md", "api.md"]
Depth = 2
```

## Index

```@index
```
