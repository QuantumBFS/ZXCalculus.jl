using ZXCalculus, Documenter, Test
using Vega
using DataFrames

@testset "plots.jl" begin
    include("ZX/plots.jl")
end

@testset "equality.jl" begin
    include("ZX/equality.jl")
end

@testset "abstract_zx_diagram.jl" begin
    include("ZX/abstract_zx_diagram.jl")
end

@testset "zx_diagram.jl" begin
    include("ZX/zx_diagram.jl")
end

@testset "rules.jl" begin
    include("ZX/rules.jl")
end

@testset "zx_graph.jl" begin
    include("ZX/zx_graph.jl")
end

@testset "circuit_extraction.jl" begin
    include("ZX/circuit_extraction.jl")
end

@testset "phase_teleportation.jl" begin
    include("ZX/phase_teleportation.jl")
end

@testset "ir.jl" begin
    include("ZX/ir.jl")
end

@testset "scalar.jl" begin
    include("Utils/scalar.jl")
end

@testset "phase.jl" begin
    include("Utils/phase.jl")
end

@testset "parameter.jl" begin
    include("Utils/parameter.jl")
end

@testset "simplify.jl" begin
    include("ZX/simplify.jl")
end

@testset "ancilla_extraction.jl" begin
    include("ZX/ancilla_extraction.jl")
    include("ZX/challenge.jl")
end

@testset "zxw_diagram.jl" begin
    include("ZXW/zxw_diagram.jl")
end

@testset "utils.jl" begin
    include("ZXW/utils.jl")
end

@testset "zxw_rules.jl" begin
    include("ZXW/zxw_rules.jl")
end

@testset "planar multigraphs.jl" begin
    include("PMG/planar_multigraph.jl")
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
