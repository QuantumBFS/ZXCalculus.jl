module ZXCalculus

using OMEinsum
using YaoHIR, YaoLocations
using YaoHIR.IntrinsicOperation
using YaoHIR: Chain
using YaoLocations: plain
using MLStyle
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

import Graphs: has_vertex

export SpiderType, EdgeType
export AbstractZXDiagram, ZXDiagram, ZXGraph
export AbstractRule
export Rule, Match, Scalar

export push_gate!, pushfirst_gate!, tcount
export convert_to_chain, convert_to_zxd
export rewrite!,
    simplify!,
    clifford_simplification,
    full_reduction,
    circuit_extraction,
    phase_teleportation

include("scalar.jl")

include("phase.jl")

include("abstract_zx_diagram.jl")
include("zx_layout.jl")
include("zx_diagram.jl")
include("zx_graph.jl")

include("rules.jl")
include("simplify.jl")
include("circuit_extraction.jl")
include("phase_teleportation.jl")

include("ir.jl")

include("deprecations.jl")

module ZXW
using Expronicon.ADT: @const_use, @adt
using MLStyle, Multigraphs
using OMEinsum
import Multigraphs: has_vertex
using ..ZXCalculus
import ..add_edge!, ..vertices, ..nv, ..round_phases!
import ..rewrite!

include("adts.jl")
include("zxw_diagram.jl")
include("zxw_rules.jl")
include("to_eincode.jl")


export ZXWDiagram, CalcRule, rewrite!
end # module ZXW

using .ZXW:
    ZXWDiagram,
    ZXWSpiderType,
    Parameter,
    CalcRule,
    PiUnit,
    Factor,
    Input,
    Output,
    W,
    H,
    D,
    Z,
    X,
    rewrite!
export ZXWSpiderType,
    ZXWDiagram, Parameter, PiUnit, Factor, Input, Output, W, H, D, Z, X, CalcRule, rewrite!
export substitute_variables!, expval_circ!, stack_zxwd!, concat!, rewrite!
export parameter,
    insert_wtrig!,
    symbol_vertices,
    spiders,
    degree,
    spider_type,
    neighbors,
    set_phase!,
    add_global_phase!,
    add_spider!,
    rem_spider!,
    get_outputs,
    add_power!,
    get_inputs,
    scalar,
    nin,
    nout,
    rem_spiders!,
    phase
include("utils.jl")
include("parameter.jl")

include("planar_multigraph.jl")
end # module
