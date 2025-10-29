using Documenter, Test
using ZXCalculus

module TestZX
using Test
@testset "ZX module" begin
    @testset "interfaces.jl" begin
        include("ZX/interfaces/abstract_zx_diagram.jl")
    end

    @testset "layout.jl" begin
        include("ZX/zx_layout.jl")
    end

    @testset "plots.jl" begin
        include("ZX/plots.jl")
    end

    @testset "equality.jl" begin
        include("ZX/equality.jl")
    end

    @testset "zx_diagram.jl" begin
        include("ZX/zx_diagram.jl")
    end

    @testset "zx_circuit_basic.jl" begin
        include("ZX/zx_circuit_basic.jl")
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
        # TODO: fix infinite loop in convert_to_chain
        # include("ZX/ir.jl")
    end

    @testset "simplify.jl" begin
        include("ZX/simplify.jl")
    end

    @testset "ancilla_extraction.jl" begin
        include("ZX/ancilla_extraction.jl")
        # TODO: fix the test
        # include("ZX/challenge.jl")
    end
end
end

module TestUtils
using Test
@testset "Utils module" begin
    @testset "scalar.jl" begin
        include("Utils/scalar.jl")
    end

    @testset "phase.jl" begin
        include("Utils/phase.jl")
    end

    @testset "parameter.jl" begin
        include("Utils/parameter.jl")
    end
end
end

module ZXWTest
using Test
@testset "ZXW module" begin
    @testset "zxw_diagram.jl" begin
        include("ZXW/zxw_diagram.jl")
    end

    @testset "utils.jl" begin
        include("ZXW/utils.jl")
    end

    @testset "zxw_rules.jl" begin
        include("ZXW/zxw_rules.jl")
    end
end
end

module PMGTest
using Test
@testset "PMG module" begin
    @testset "planar multigraphs.jl" begin
        include("PMG/planar_multigraph.jl")
    end
end
end

module ZWTest
using Test
@testset "ZW module" begin
    @testset "ZW Diagram with Planar Multigraph" begin
        include("ZW/zw_diagram.jl")
    end

    @testset "ZW Diagram Utilities" begin
        include("ZW/zw_utils.jl")
    end
end
end

module ApplicationTest
using Test
@testset "Application module" begin
    @testset "to_eincode.jl" begin
        include("Application/to_eincode.jl")
    end
end
end

doctest(ZXCalculus)
