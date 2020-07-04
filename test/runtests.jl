using ZXCalculus, LightGraphs, SparseArrays
using Documenter
using Test

@testset "multiple_edge.jl" begin
    include("Multigraphs/multiple_edge.jl")
end

@testset "multigraph_adjlist.jl" begin
    include("Multigraphs/multigraph_adjlist.jl")
end

@testset "multiple_edge_iter.jl" begin
    include("Multigraphs/multiple_edge_iter.jl")
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

doctest(ZXCalculus)
