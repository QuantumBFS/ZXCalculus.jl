using Test, Graphs, ZXCalculus, ZXCalculus.ZX
using ZXCalculus.Utils: Phase
using ZXCalculus: ZX
using Interfaces

# Import functions for testing
import ZXCalculus.ZX: spiders, scalar, tcount, nqubits, get_inputs, get_outputs, add_spider!

@testset "AbstractZXDiagram interface enforcement" begin
    # Define a minimal incomplete implementation to test interface requirements
    struct IncompleteZXDiagram{T, P} <: AbstractZXDiagram{T, P} end

    test_zxd = IncompleteZXDiagram{Int, Phase}()

    # Get the interface type
    AbstractZXDiagramInterface = getfield(ZX, :AbstractZXDiagramInterface)

    # Test that incomplete implementation fails interface checks
    @testset "Interface components defined" begin
        components = Interfaces.components(AbstractZXDiagramInterface)
        @test haskey(components, :mandatory)
        @test haskey(components, :optional)

        # Check that all mandatory methods are defined in the interface
        mandatory = components.mandatory
        @test length(mandatory) >= 26  # We defined 26 mandatory methods
    end

    @testset "Incomplete implementation throws errors" begin
        # Test that calling methods on incomplete implementation throws errors
        # Note: Interfaces.jl doesn't enforce MethodError specifically,
        # but methods should fail when not implemented

        # Test some key graph methods
        @test_throws Exception Graphs.nv(test_zxd)
        @test_throws Exception Graphs.ne(test_zxd)
        @test_throws Exception spiders(test_zxd)
        @test_throws Exception scalar(test_zxd)
        @test_throws Exception tcount(test_zxd)
    end
end

@testset "Complete implementations pass interface" begin
    # Test that our complete implementations work correctly
    @testset "ZXGraph implements AbstractZXDiagram" begin
        zxg = ZXGraph()

        # These should all work without throwing
        @test Graphs.nv(zxg) >= 0
        @test Graphs.ne(zxg) >= 0
        @test spiders(zxg) isa Vector
        @test scalar(zxg) !== nothing

        # Add a spider so tcount doesn't fail on empty collection
        add_spider!(zxg, SpiderType.Z, Phase(0))
        @test tcount(zxg) >= 0
    end

    @testset "ZXCircuit implements AbstractZXCircuit" begin
        zxd = ZXDiagram(2)
        circ = ZXCircuit(zxd)

        # Test AbstractZXDiagram interface
        @test Graphs.nv(circ) >= 0
        @test spiders(circ) isa Vector
        @test scalar(circ) !== nothing

        # Test AbstractZXCircuit interface
        @test nqubits(circ) == 2
        @test get_inputs(circ) isa Vector
        @test get_outputs(circ) isa Vector
        @test length(get_inputs(circ)) == 2
        @test length(get_outputs(circ)) == 2
    end

    @testset "ZXDiagram implements AbstractZXCircuit" begin
        zxd = ZXDiagram(3)

        # Test AbstractZXDiagram interface
        @test Graphs.nv(zxd) >= 0
        @test spiders(zxd) isa Vector
        @test scalar(zxd) !== nothing

        # Test AbstractZXCircuit interface
        @test nqubits(zxd) == 3
        @test get_inputs(zxd) isa Vector
        @test get_outputs(zxd) isa Vector
    end
end
