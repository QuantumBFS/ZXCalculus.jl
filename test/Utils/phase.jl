using Test
using ZXCalculus.Utils: AbstractPhase, Phase,
                        is_zero_phase, is_pauli_phase, is_clifford_phase, round_phase

@testset "AbstractPhase" begin
    struct MyPhase <: AbstractPhase end
    p = MyPhase()
    @test_throws MethodError Base.zero(p)
    @test_throws MethodError Base.zero(MyPhase)
    @test_throws MethodError Base.one(p)
    @test_throws MethodError Base.one(MyPhase)
    @test_throws MethodError is_zero_phase(p)
    @test_throws MethodError is_pauli_phase(p)
    @test_throws MethodError is_clifford_phase(p)
    @test_throws MethodError round_phase(p)
end

@testset "Phase" begin
    chain = Chain()
    push_gate!(chain, Val(:shift), 1, Phase(1 // 1))
    push_gate!(chain, Val(:Rz), 1, Phase(2 // 1))

    bir = BlockIR(IRCode(), 4, chain)

    zxd = convert_to_zxd(bir)
    c = clifford_simplification(zxd)
    ZX.generate_layout!(zxd)
    qc_tl = convert_to_chain(phase_teleportation(zxd))
    @test length(qc_tl) == 1

    p = Phase(1 // 1)

    @test p + 1 == 1 + p == p + p
    @test p - 1 == 1 - p == p - p
    @test p / 1 == 1 / p == p / p
    @test zero(Phase) == zero(p) && one(Phase) == one(p)
end