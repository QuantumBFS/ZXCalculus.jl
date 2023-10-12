module ZXCalculus

module Utils

using Expronicon.ADT: @const_use, @adt
using MLStyle

include("scalar.jl")
include("phase.jl")
include("parameter.jl")

end

module ZX

using Graphs, Multigraphs, YaoHIR, YaoLocations
using YaoHIR.IntrinsicOperation
using YaoHIR: Chain
using YaoLocations: plain
using MLStyle
using ..Utils: Scalar, Phase, add_phase!

import ..Utils: add_power!

export spiders,
    tcount, spider_type, phase, rem_spider!, rem_spiders!, pushfirst_gate!, push_gate!

export SpiderType, EdgeType
export AbstractZXDiagram, ZXDiagram, ZXGraph

export AbstractRule
export Rule, Match

export rewrite!, simplify!

export convert_to_chain, convert_to_zxd
export clifford_simplification, full_reduction, circuit_extraction, phase_teleportation

include("abstract_zx_diagram.jl")
include("zx_layout.jl")
include("zx_diagram.jl")
include("zx_graph.jl")

include("rules.jl")
include("simplify.jl")

include("circuit_extraction.jl")
include("phase_teleportation.jl")

include("ir.jl")
end

module ZXW

using Expronicon.ADT: @const_use, @adt
using MLStyle, Multigraphs, Graphs
using ..Utils: Scalar, Phase, Parameter, PiUnit, Factor, add_phase!
using ..ZX: safe_convert, AbstractRule, Rule, Match

import ..Utils: add_power!
import ..ZX:
    rewrite!, simplify!, push_gate!, pushfirst_gate!, spiders, rem_spider!, rem_spiders!

export ZXWDiagram, substitute_variables!

include("adts.jl")
include("zxw_diagram.jl")
include("zxw_rules.jl")
include("utils.jl")

end # module ZXW

module PMG

using Graphs

import Graphs: AbstractEdge, src, dst, nv, ne, neighbors
import Graphs.SimpleGraphs: vertices

export HalfEdge, src, dst, new_edge, PlanarMultigraph

include("planar_multigraph.jl")

end # module PlanarMultigraph

module ZW
using Expronicon.ADT: @adt, @const_use
using MLStyle, Graphs
using ..ZXW: _round_phase, Parameter

# these will be changed to using PlanarMultigraph: vertices after we split out package
using ..PMG:
    vertices,
    nv,
    has_vertex,
    ne,
    neighbors,
    rem_edge!,
    add_edge!,
    degree,
    next,
    split_vertex!,
    split_edge!,
    face,
    trace_face,
    make_hole!,
    add_vertex_and_facet_to_boarder!,
    split_facet!,
    twin,
    prev,
    add_multiedge!,
    join_facet!,
    trace_vertex,
    join_vertex!

# these remains
using ..Utils: add_phase!, Scalar, Phase, Parameter, PiUnit, Factor, add_power!
using ..PMG: PlanarMultigraph, HalfEdge, new_edge, src, dst
import ..Utils: add_power!
import ..ZX: add_global_phase!, scalar, spiders, rem_spider!
import Graphs.rem_edge!

export ZWDiagram

include("zw_adt.jl")
include("zw_diagram.jl")
include("zw_utils.jl")
end # module ZW

module Application

using OMEinsum, MLStyle
using ..ZXW: ZXWDiagram, Z, X, W, H, D, Input, Output
using ..Utils: PiUnit, Factor, Parameter, unwrap_scalar
using ..ZXW: get_outputs, get_inputs, degree, neighbors, vertices, scalar, nin, nout

include("to_eincode.jl")
end # module Application

include("deprecations.jl")
end # module
