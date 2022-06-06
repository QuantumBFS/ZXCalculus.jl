module ZXCalculus

using YaoHIR, YaoLocations
using YaoHIR.IntrinsicOperation
using YaoHIR: Chain
using YaoLocations: plain
using MLStyle
using Graphs, Multigraphs

using Graphs: nv, ne, outneighbors, inneighbors, neighbors, rem_edge!,
    add_edge!, has_edge, degree, indegree, outdegree

export SpiderType, EdgeType
export AbstractZXDiagram, ZXDiagram, ZXGraph
export Rule, Match

export spider_type, phase, spiders, rem_spider!, rem_spiders!
export push_gate!, pushfirst_gate!, tcount
export convert_to_chain, convert_to_zxd
export rewrite!, simplify!, clifford_simplification, full_reduction, 
    circuit_extraction, phase_teleportation
export random_circuit

include("phase.jl")
include("scalar.jl")
    
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

end # module
