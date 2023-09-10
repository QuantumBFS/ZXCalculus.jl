module ZXCalculus

using OMEinsum
using YaoHIR, YaoLocations
using YaoHIR.IntrinsicOperation
using YaoHIR: Chain
using YaoLocations: plain
using MLStyle
using Expronicon.ADT: @const_use, variant_type
using Graphs, Multigraphs

using Graphs:
    nv,
    ne,
    outneighbors,
    inneighbors,
    neighbors,
    rem_edge!,
    add_edge!,
    has_edge,
    degree,
    indegree,
    outdegree

# using Multigraphs: vertices


export SpiderType, EdgeType
export AbstractZXDiagram, ZXDiagram, ZXGraph
export ZXWDiagram
export Rule, Match
export CalcRule


export parameter
export push_gate!, pushfirst_gate!, tcount, insert_wtrig!
export convert_to_chain, convert_to_zxd
export rewrite!,
    simplify!,
    clifford_simplification,
    full_reduction,
    circuit_extraction,
    phase_teleportation
export substitute_variables!, expval_circ!, stack_zxwd!, concat!

include("adts.jl")
using .ZXW: ZXWSpiderType, Parameter, PiUnit, Factor, Input, Output, W, H, D, Z, X
export ZXWSpiderType, Parameter, PiUnit, Factor, Input, Output, W, H, D, Z, X

include("parameter.jl")

include("phase.jl")
include("scalar.jl")

include("abstract_zx_diagram.jl")
include("zx_layout.jl")
include("zx_diagram.jl")
include("zx_graph.jl")
include("planar_multigraph.jl")

include("zxw_diagram.jl")
include("to_eincode.jl")

include("utils.jl")

include("rules.jl")
include("zxw_rules.jl")
include("simplify.jl")
include("circuit_extraction.jl")
include("phase_teleportation.jl")

include("ir.jl")

include("deprecations.jl")

end # module
