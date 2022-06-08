using ZXCalculus, Graphs, Multigraphs, SparseArrays
using Documenter
using Test

@testset "scalar.jl" begin
    include("scalar.jl")
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

@testset "ir.jl" begin
    include("ir.jl")
end

@testset "pi_unit.jl" begin
    include("pi_unit.jl")
end

@testset "simplify.jl" begin
    include("simplify.jl")
end

@testset "ancilla_extraction.jl" begin
    include("ancilla_extraction.jl")
    include("challenge.jl")
end

doctest(ZXCalculus)
