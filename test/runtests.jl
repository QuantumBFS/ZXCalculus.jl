using ZXCalculus, Documenter, Test
using Vega
using DataFrames


@testset "plotting" begin
  include("plots.jl")
end

@testset "abstract_zx_diagram.jl" begin
    include("abstract_zx_diagram.jl")
end

@testset "zx_diagram.jl" begin
    include("zx_diagram.jl")
end

@testset "rules.jl" begin
    include("rules.jl")
end

@testset "zx_graph.jl" begin
    include("zx_graph.jl")
end

@testset "circuit_extraction.jl" begin
    include("circuit_extraction.jl")
end

@testset "phase_teleportation.jl" begin
    include("phase_teleportation.jl")
end

# @testset "ir.jl" begin
#     include("ir.jl")
# end

@testset "scalar.jl" begin
    include("scalar.jl")
end

@testset "phase.jl" begin
    include("phase.jl")
end

@testset "parameter.jl" begin
    include("parameter.jl")
end

@testset "simplify.jl" begin
    include("simplify.jl")
end

@testset "ancilla_extraction.jl" begin
    include("ancilla_extraction.jl")
    include("challenge.jl")
end

@testset "zxw_diagram.jl" begin
    include("zxw_diagram.jl")
end

@testset "utils.jl" begin
    include("utils.jl")
end

@testset "zxw_rules.jl" begin
    include("zxw_rules.jl")
end

@testset "planar multigraphs.jl" begin
    include("planar_multigraph.jl")
end

@testset "ZW Diagram with Planar Multigraph" begin
    include("zw_diagram.jl")
end

@testset "ZW Diagram Utilities" begin
    include("zw_utils.jl")
end


@testset "to_eincode.jl" begin
    include("to_eincode.jl")
end

doctest(ZXCalculus)
