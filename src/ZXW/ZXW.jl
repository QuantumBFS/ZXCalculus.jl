module ZXW

using Expronicon.ADT: @const_use, @adt
using MLStyle, Multigraphs, Graphs
using ..Utils: Scalar, Phase, Parameter, PiUnit, Factor, add_phase!
using ..ZX: safe_convert, AbstractRule, Rule, Match
using YaoHIR
using YaoHIR: BlockIR

import ..Utils: add_power!
import ..ZX: rewrite!, simplify!, push_gate!, pushfirst_gate!, spiders, rem_spider!, rem_spiders!,
             canonicalize_single_location

export ZXWDiagram, substitute_variables!

include("adts.jl")
include("zxw_diagram.jl")
include("zxw_rules.jl")
include("utils.jl")

end # module ZXW
