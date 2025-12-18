using Test, ZXCalculus
using ZXCalculus.ZX
using ZXCalculus.Utils: Phase
using ZXCalculus.ZX: SpiderType
using Graphs
using YaoHIR, YaoLocations
using YaoHIR.IntrinsicOperation

@testset "ZXCircuit basic constructor" begin
    # Test nbits constructor
    circ = ZXCircuit(3)
    @test nqubits(circ) == 3
    @test length(get_inputs(circ)) == 3
    @test length(get_outputs(circ)) == 3
    @test nv(circ) == 6
    @test ne(circ) == 3

    # Test structure
    for i in 1:3
        in_id = 2*i-1
        out_id = 2*i
        @test spider_type(circ, in_id) == SpiderType.In
        @test spider_type(circ, out_id) == SpiderType.Out
        @test has_edge(circ, in_id, out_id)
        @test qubit_loc(circ, in_id) == i
        @test qubit_loc(circ, out_id) == i
    end
end

@testset "ZXCircuit gate operations" begin
    circ = ZXCircuit(2)

    # Test push_gate!
    push_gate!(circ, Val(:Z), 1, 1//2)
    push_gate!(circ, Val(:X), 2, 1//4)
    push_gate!(circ, Val(:H), 1)
    push_gate!(circ, Val(:CNOT), 2, 1)

    @test nv(circ) == 9
    @test tcount(circ) == 1

    # Test pushfirst_gate!
    circ2 = ZXCircuit(2)
    pushfirst_gate!(circ2, Val(:H), 1)
    pushfirst_gate!(circ2, Val(:X), 2)

    @test nv(circ2) == 6
end

@testset "ZXCircuit from ZXDiagram conversion" begin
    # Create a ZXDiagram
    zxd = ZXDiagram(2)
    push_gate!(zxd, Val(:H), 1)
    push_gate!(zxd, Val(:CNOT), 2, 1)

    # Convert to ZXCircuit
    circ = ZXCircuit(zxd)
    @test circ isa ZXCircuit
    @test nqubits(circ) == 2

    # Convert back to ZXDiagram
    zxd2 = ZXDiagram(circ)
    @test zxd2 isa ZXDiagram
    @test nqubits(zxd2) == 2
end

@testset "ZXCircuit equality verification" begin
    # Create two identical circuits
    circ1 = ZXCircuit(2)
    push_gate!(circ1, Val(:H), 1)
    push_gate!(circ1, Val(:CNOT), 2, 1)

    circ2 = ZXCircuit(2)
    push_gate!(circ2, Val(:H), 1)
    push_gate!(circ2, Val(:CNOT), 2, 1)

    # Test ZXCircuit equality
    @test verify_equality(circ1, circ2)
end

@testset "ZXCircuit IR conversion" begin
    # Create a simple BlockIR
    circuit = Chain(
        Gate(H, Locations(1)),
        Ctrl(Gate(X, Locations(2)), CtrlLocations(1))
    )
    bir = BlockIR(Core.Compiler.IRCode(), 2, circuit)

    # Test convert_to_zx_circuit
    circ = convert_to_zx_circuit(bir)
    @test circ isa ZXCircuit
    @test nqubits(circ) == 2

    # Test ZXCircuit constructor from BlockIR
    circ2 = ZXCircuit(bir)
    @test circ2 isa ZXCircuit
    @test nqubits(circ2) == 2

    # Test deprecated convert_to_zxd still works
    zxd = convert_to_zxd(bir)
    @test zxd isa ZXDiagram
    @test nqubits(zxd) == 2
end

@testset "ZXCircuit simplification" begin
    circ = ZXCircuit(2)
    push_gate!(circ, Val(:H), 1)
    push_gate!(circ, Val(:H), 1)  # Double H should simplify

    # Test clifford simplification
    simplified = clifford_simplification(circ)
    @test ne(simplified) == 2

    # Test full reduction
    circ2 = ZXCircuit(2)
    push_gate!(circ2, Val(:Z), 1, 1//4)
    reduced = full_reduction(circ2)
    @test nv(reduced) == 5
    @test ne(reduced) == 3
end

@testset "ZXCircuit copy" begin
    circ = ZXCircuit(2)
    push_gate!(circ, Val(:H), 1)

    circ2 = copy(circ)
    @test circ2 isa ZXCircuit
    @test nqubits(circ2) == nqubits(circ)
    @test length(get_inputs(circ2)) == length(get_inputs(circ))

    # Modify copy shouldn't affect original
    push_gate!(circ2, Val(:X), 1)
    @test nv(circ2) != nv(circ)
end
