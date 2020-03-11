# ZX.jl: ZX-calculus for Julia

Chen Zhao

Academy of Mathematics and System Science, Chinese Academy of Sciences

## Abstract

[ZX-calculus](http://zxcalculus.com) is a graphical language which can characterize quantum circuits. It is usually used for quantum circuit simplification. `ZX.jl` will implement quantum circuit simplification algorithms based on ZX-calculus in pure Julia. Also, it will provide interfaces to import and export quantum circuits to the form of YaoIR, such that one can get quantum circuits with higher performance when designing quantum algorithms with `Yao.jl`.

## Why this project?

Since Shor's factoring algorithm, people believe that quantum computers are more powerful than classical computers. However, quantum hardware developing is so difficult. Hence, in the near-term future, only limited number of qubits will be available and only small size of quantum circuits can be run on quantum devices. On the other hand, simulating quantum computer on classical computer need exponential resources. Simpler circuits will help us developing more efficient quantum simulation algorithms. As a result, circuit simplification is a very important problem when designing quantum algorithms.

ZX-calculus is a powerful tool for circuit simplification and lots of algorithms are developed. There exist a Python implementation [`PyZX`](https://github.com/Quantomatic/pyzx). But there is no Julia implementation of these algorithms. `Yao.jl` is a high-performance and extensive package for quantum software framework. I use `Yao.jl` when I study on quantum machine learning algorihms. However, only weak circuit simplification algorithms are available in `Yao.jl`. For these reasons, I want to develop `ZX.jl`.

## Technical Details

`ZX.jl` will be a package for ZX-calculus which any Julia user can install. With `ZX.jl`, one will be develop quantum circuits simplification algorithms, which are important for current quantum algorithm designning, in pure Julia.

The first thing that ZX.jl has to provide is data structures for representing ZX-diagrams which are the basic objects in ZX-calculus. In general, ZX-diagrams are multigraphs with extra information of their edges and vertices, (for example, phases of vertices). Fortunately, there has been [`LightGraphs.jl`](https://github.com/JuliaGraphs/LightGraphs.jl) for simple graphs already. And I have developed [`Multigraphs.jl`](https://github.com/QuantumBFS/Multigraphs.jl) as a multigraph extension for `LightGraphs.jl`. Hence, problems of representing ZX-diagrams can be solved.

Secondly, for developing quantum circuits simplification algorithms, I will develop basic rules which will be applied on ZX-diagrams. These rules are operation on the multigraphs and its extra information. These can be implemented by operating multigraphs.

After defining basic rules, quantum circuit simplification algorithms based on ZX-calculus can be implemented. For example, the state-of-art algorithm for reducing T-count. All these algorithms can be found on [ZX-calculus](http://zxcalculus.com/publications.html).

As an application, I will develop interfaces for importing and exporting quantum circuits in the form of YaoIR. So that, `Yao.jl` can simplify quantum circuits defined by users when compiling quantum algorithms.

For data visualization, I will provide ways to plot ZX-diagrams and quantum circuits. This will based on the graph visualization tool [`GraphPlot.jl`](https://github.com/JuliaGraphs/GraphPlot.jl).

## Schedule of Deliverables

### Before Community Bonding Period

April 1, 2020 - April 27, 2020

Read articles on ZX-calculus
. Be familar with the developing tools, working flow, test systems and documentation systems.

### **Community Bonding Period**

**April 28, 2020 - May 7, 2020**

Discuss about the implementation with the mentor.

**May 8, 2020 - May 17, 2020**

Implement data structures for representing ZX-diagrams.

### **Phase 1**

**May 18, 2020 - May 31, 2020**

Develop basic rules.

**June 1, 2020 - June 14, 2020**

Implement circuit simplification algorithms with basic rules.

**June 15, 2020 - June 19, 2020**

Submit Phase 1 evaluations.

### **Phase 2**

**June 20, 2020 - July 30, 2020**

Add visualization support for ZX-diagram and quantum circuits.

**July 1, 2020 - July 12, 2020**

Develop transformation between YaoIR and ZX-diagrams.

**July 13, 2020 - July 17, 2020**

Submit Phase 2 evaluations.

### **Final Phase**

**July 18, 2020 - August 1, 2020**

Integrate circuit simplification algorithms to the compiler in `Yao.jl`.

**August 1, 2020 - August 9, 2020**

Make full documentation, refine tests, and show some demenstration for `ZX.jl`.

### **Final Week**

**August 10, 2020 - August 17, 2020**

Submit final evaluations.

## About me

I'm Chen Zhao, currently a Ph.D student majoring applied mathematics in Academy of Mathematics and System Science, Chinese Academy of Sciences. I'm researching on quantum machine learning and quantum algorithms.

* E-mail: zhaochen17@mails.ucas.ac.cn

* GitHub: [ChenZhao44](https://github.com/ChenZhao44)

## Development Experience

* [`QDNN.jl`](https://github.com/ChenZhao44/QDNN.jl): an implementation of the model [QDNN (deep neural networks with quantum layers)](https://arxiv.org/abs/1912.12660).
* [`Multigraphs.jl`](https://github.com/QuantumBFS/Multigraphs.jl): a multigraph extension for `LightGraphs.jl`
