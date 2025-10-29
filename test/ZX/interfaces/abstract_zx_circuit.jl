module ZXCircuitInterfaceTests

using Test
using ZXCalculus.ZX
using ZXCalculus.Utils: Phase

struct DummyZXCircuit{T, P} <: AbstractZXCircuit{T, P} end

@testset "Circuit Interface Tests" begin
    circ = DummyZXCircuit{Int, Phase}()
    @test_throws ErrorException nqubits(circ)
    @test_throws ErrorException get_inputs(circ)
    @test_throws ErrorException get_outputs(circ)
    @test_throws ErrorException push_gate!(circ, Val(:Z), 1, Phase(1//1))
    @test_throws ErrorException push_gate!(circ, Val(:CNOT), 1, 2)
    @test_throws ErrorException pushfirst_gate!(circ, Val(:H), 1)
    @test_throws ErrorException pushfirst_gate!(circ, Val(:SWAP), 2, 1)
end

@testset "Layout Interface Tests" begin
    circ = DummyZXCircuit{Int, Phase}()
    @test_throws ErrorException qubit_loc(circ, 1)
    @test_throws ErrorException column_loc(circ, 2)
    @test_throws ErrorException generate_layout!(circ)
    @test_throws ErrorException spider_sequence(circ)
end

end