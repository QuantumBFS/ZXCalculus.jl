using ZXCalculus, LightGraphs, Multigraphs, SparseArrays
using Documenter
using Test

@testset "scalar.jl" begin
    include("scalar.jl")
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

@testset "ir.jl" begin
    include("ir.jl")
end

@testset "phase.jl" begin
    include("phase.jl")
end

@testset "simplify.jl" begin
    include("simplify.jl")
end

doctest(ZXCalculus)
