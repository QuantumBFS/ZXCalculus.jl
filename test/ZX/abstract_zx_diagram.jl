using Test, Graphs, ZXCalculus, ZXCalculus.ZX
using ZXCalculus.Utils: Phase
using ZXCalculus: ZX

# Import functions for testing
import ZXCalculus.ZX: spiders, scalar, tcount, nqubits, get_inputs, get_outputs, add_spider!

@testset "AbstractZXDiagram type hierarchy" begin
    # Test that ZXGraph is a subtype of AbstractZXDiagram
    @test ZXGraph{Int, Phase} <: AbstractZXDiagram{Int, Phase}
    @test !(ZXGraph{Int, Phase} <: AbstractZXCircuit{Int, Phase})

    # Test that ZXCircuit is a subtype of both
    @test ZXCircuit{Int, Phase} <: AbstractZXDiagram{Int, Phase}
    @test ZXCircuit{Int, Phase} <: AbstractZXCircuit{Int, Phase}

    # Test that ZXDiagram (deprecated) is a subtype of both
    @test ZXDiagram{Int, Phase} <: AbstractZXDiagram{Int, Phase}
    @test ZXDiagram{Int, Phase} <: AbstractZXCircuit{Int, Phase}
end

@testset "AbstractZXDiagram methods" begin
    # Test that all required methods work for ZXGraph
    zxg = ZXGraph()
    v1 = add_spider!(zxg, SpiderType.Z, Phase(0))

    @test spiders(zxg) isa Vector
    @test scalar(zxg) isa ZXCalculus.Utils.Scalar
    @test tcount(zxg) >= 0
    @test Graphs.nv(zxg) == 1
    @test Graphs.ne(zxg) == 0
end

@testset "AbstractZXCircuit methods" begin
    # Test that all required methods work for ZXCircuit
    zxd = ZXDiagram(2)
    circ = ZXCircuit(zxd)

    @test nqubits(circ) == 2
    @test get_inputs(circ) isa Vector
    @test get_outputs(circ) isa Vector
    @test length(get_inputs(circ)) == 2
    @test length(get_outputs(circ)) == 2
end
