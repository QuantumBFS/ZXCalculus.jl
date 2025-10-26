using Test
using ZXCalculus
using ZXCalculus.ZX
using ZXCalculus.Utils: Phase
using Interfaces
using Graphs

# Import functions and types from ZX module for testing
import ZXCalculus.ZX: add_spider!, rem_spider!, rem_spiders!, set_phase!,
                      spiders, spider_type, spider_types, phase, phases,
                      scalar, tcount, nqubits, get_inputs, get_outputs,
                      qubit_loc, column_loc, generate_layout!, spider_sequence,
                      add_edge!, add_global_phase!, add_power!, ZXLayout

@testset "Interface definitions" begin
    @testset "AbstractZXDiagram interface" begin
        # Check interface is defined
        @test isdefined(ZX, :AbstractZXDiagramInterface)

        # Get interface type from ZX module
        AbstractZXDiagramInterface = getfield(ZX, :AbstractZXDiagramInterface)
        @test AbstractZXDiagramInterface <: Interfaces.Interface

        # Check interface components
        components = Interfaces.components(AbstractZXDiagramInterface)
        @test haskey(components, :mandatory)
        @test haskey(components, :optional)

        # Check mandatory methods are defined
        mandatory = components.mandatory
        @test haskey(mandatory, :nv)
        @test haskey(mandatory, :ne)
        @test haskey(mandatory, :spiders)
        @test haskey(mandatory, :spider_type)
        @test haskey(mandatory, :phase)
        @test haskey(mandatory, :scalar)
        @test haskey(mandatory, :tcount)
    end

    @testset "AbstractZXCircuit interface" begin
        # Check interface is defined
        @test isdefined(ZX, :AbstractZXCircuitInterface)

        # Get interface type from ZX module
        AbstractZXCircuitInterface = getfield(ZX, :AbstractZXCircuitInterface)
        @test AbstractZXCircuitInterface <: Interfaces.Interface

        # Check interface components
        components = Interfaces.components(AbstractZXCircuitInterface)
        @test haskey(components, :mandatory)
        @test haskey(components, :optional)

        # Check mandatory methods are defined
        mandatory = components.mandatory
        @test haskey(mandatory, :nqubits)
        @test haskey(mandatory, :get_inputs)
        @test haskey(mandatory, :get_outputs)
        @test haskey(mandatory, :qubit_loc)
        @test haskey(mandatory, :column_loc)
        @test haskey(mandatory, :generate_layout!)
        @test haskey(mandatory, :spider_sequence)
    end
end

@testset "ZXGraph implements AbstractZXDiagram" begin
    # Create a simple test ZXGraph
    zxg = ZXGraph()

    @testset "Type hierarchy" begin
        @test zxg isa AbstractZXDiagram
        @test !(zxg isa AbstractZXCircuit)
        @test ZXGraph <: AbstractZXDiagram
        @test !(ZXGraph <: AbstractZXCircuit)
    end

    @testset "Basic graph operations" begin
        # Test nv and ne
        @test Graphs.nv(zxg) == 0
        @test Graphs.ne(zxg) == 0

        # Add spiders
        v1 = add_spider!(zxg, SpiderType.Z, Phase(0))
        v2 = add_spider!(zxg, SpiderType.X, Phase(1//2))

        @test Graphs.nv(zxg) == 2
        @test v1 != v2

        # Add edge
        add_edge!(zxg, v1, v2)
        @test Graphs.ne(zxg) == 1
        @test Graphs.has_edge(zxg, v1, v2)

        # Test degree
        @test Graphs.degree(zxg, v1) == 1
        @test Graphs.degree(zxg, v2) == 1

        # Test neighbors
        @test v2 in Graphs.neighbors(zxg, v1)
        @test v1 in Graphs.neighbors(zxg, v2)
    end

    @testset "Spider operations" begin
        zxg = ZXGraph()
        v1 = add_spider!(zxg, SpiderType.Z, Phase(1//4))
        v2 = add_spider!(zxg, SpiderType.X, Phase(1//2))

        # Test spiders
        @test length(spiders(zxg)) == 2
        @test v1 in spiders(zxg)
        @test v2 in spiders(zxg)

        # Test spider_type
        @test spider_type(zxg, v1) == SpiderType.Z
        @test spider_type(zxg, v2) == SpiderType.X

        # Test spider_types
        types = spider_types(zxg)
        @test types[v1] == SpiderType.Z
        @test types[v2] == SpiderType.X

        # Test phase
        @test phase(zxg, v1) == Phase(1//4)
        @test phase(zxg, v2) == Phase(1//2)

        # Test phases
        ps = phases(zxg)
        @test ps[v1] == Phase(1//4)
        @test ps[v2] == Phase(1//2)

        # Test set_phase!
        set_phase!(zxg, v1, Phase(3//4))
        @test phase(zxg, v1) == Phase(3//4)
    end

    @testset "Global properties" begin
        zxg = ZXGraph()
        v1 = add_spider!(zxg, SpiderType.Z, Phase(1//4))  # T gate
        v2 = add_spider!(zxg, SpiderType.Z, Phase(1//2))  # S gate

        # Test scalar
        s = scalar(zxg)
        @test s isa ZXCalculus.Utils.Scalar

        # Test tcount (counts non-Clifford phases)
        @test tcount(zxg) == 1  # Only v1 has non-Clifford phase π/4

        # Test add_global_phase!
        add_global_phase!(zxg, Phase(1//2))
        @test scalar(zxg).phase == Phase(1//2)

        # Test add_power!
        add_power!(zxg, 1)
        @test scalar(zxg).power_of_sqrt_2 == 1
    end

    @testset "Copy operation" begin
        zxg = ZXGraph()
        v1 = add_spider!(zxg, SpiderType.Z, Phase(1//4))
        v2 = add_spider!(zxg, SpiderType.X, Phase(1//2))
        add_edge!(zxg, v1, v2)

        # Test copy
        zxg_copy = copy(zxg)
        @test zxg_copy !== zxg
        @test Graphs.nv(zxg_copy) == Graphs.nv(zxg)
        @test Graphs.ne(zxg_copy) == Graphs.ne(zxg)
        @test phase(zxg_copy, v1) == phase(zxg, v1)
    end

    @testset "Spider manipulation" begin
        zxg = ZXGraph()
        v1 = add_spider!(zxg, SpiderType.Z, Phase(0))
        v2 = add_spider!(zxg, SpiderType.X, Phase(0))
        v3 = add_spider!(zxg, SpiderType.Z, Phase(0))

        add_edge!(zxg, v1, v2)
        add_edge!(zxg, v2, v3)

        @test Graphs.nv(zxg) == 3

        # Test rem_spider!
        rem_spider!(zxg, v2)
        @test Graphs.nv(zxg) == 2
        @test v2 ∉ spiders(zxg)
        @test !Graphs.has_edge(zxg, v1, v2)
    end
end

@testset "ZXCircuit implements AbstractZXCircuit" begin
    # Create a simple test circuit
    zxd = ZXDiagram(2)  # 2 qubits
    circ = ZXCircuit(zxd)

    @testset "Type hierarchy" begin
        @test circ isa AbstractZXCircuit
        @test circ isa AbstractZXDiagram
        # Check with concrete type parameters
        @test ZXCircuit{Int, Phase} <: AbstractZXCircuit{Int, Phase}
        @test ZXCircuit{Int, Phase} <: AbstractZXDiagram{Int, Phase}
    end

    @testset "Circuit structure" begin
        # Test nqubits
        @test nqubits(circ) == 2

        # Test get_inputs and get_outputs
        inputs = get_inputs(circ)
        outputs = get_outputs(circ)
        @test length(inputs) == 2
        @test length(outputs) == 2

        # Inputs and outputs should be different
        @test inputs != outputs
    end

    @testset "Layout information" begin
        # Test generate_layout!
        layout = generate_layout!(circ)
        @test layout isa ZXLayout

        # Test qubit_loc and column_loc for input spiders
        inputs = get_inputs(circ)
        for (i, v) in enumerate(inputs)
            loc = qubit_loc(circ, v)
            # Input should have valid qubit location
            @test loc !== nothing
        end
    end

    @testset "Inherits AbstractZXDiagram interface" begin
        # Test that circuit also implements graph operations
        @test Graphs.nv(circ) >= 4  # At least 2 inputs + 2 outputs
        @test spiders(circ) isa Vector
        @test scalar(circ) isa ZXCalculus.Utils.Scalar
    end
end

@testset "ZXDiagram implements AbstractZXCircuit (deprecated)" begin
    # Test that deprecated ZXDiagram still implements the interface
    zxd = ZXDiagram(2)

    @testset "Type hierarchy" begin
        @test zxd isa AbstractZXCircuit
        @test zxd isa AbstractZXDiagram
        # Check with concrete type parameters
        @test ZXDiagram{Int, Phase} <: AbstractZXCircuit{Int, Phase}
        @test ZXDiagram{Int, Phase} <: AbstractZXDiagram{Int, Phase}
    end

    @testset "Circuit operations" begin
        @test nqubits(zxd) == 2
        @test length(get_inputs(zxd)) == 2
        @test length(get_outputs(zxd)) == 2
    end

    @testset "Graph operations" begin
        @test Graphs.nv(zxd) >= 4
        @test spiders(zxd) isa Vector
    end
end

@testset "Interface compatibility" begin
    @testset "Functions accept AbstractZXDiagram" begin
        # Test that functions can work with any AbstractZXDiagram
        function count_spiders(zxd::AbstractZXDiagram)
            return length(spiders(zxd))
        end

        zxg = ZXGraph()
        add_spider!(zxg, SpiderType.Z, Phase(0))
        add_spider!(zxg, SpiderType.X, Phase(0))

        zxd = ZXDiagram(2)
        circ = ZXCircuit(zxd)

        # All should work with the same function
        @test count_spiders(zxg) == 2
        @test count_spiders(zxd) >= 4
        @test count_spiders(circ) >= 4
    end

    @testset "Functions accept AbstractZXCircuit" begin
        # Test that functions can work with any AbstractZXCircuit
        function get_qubit_count(zxc::AbstractZXCircuit)
            return nqubits(zxc)
        end

        zxd = ZXDiagram(3)
        circ = ZXCircuit(zxd)

        # Both should work
        @test get_qubit_count(zxd) == 3
        @test get_qubit_count(circ) == 3

        # But not ZXGraph (should not compile/error)
        zxg = ZXGraph()
        @test_throws MethodError get_qubit_count(zxg)
    end
end
