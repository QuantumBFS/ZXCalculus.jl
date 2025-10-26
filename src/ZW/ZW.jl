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
