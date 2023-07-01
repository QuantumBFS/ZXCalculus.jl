using LinearAlgebra
using ZXCalculus: z_tensor, x_tensor, w_tensor, h_tensor, d_tensor
@testset "Tensors" begin
    @test z_tensor(2, Parameter(Val(:PiUnit), 1 // 2)) == [1 0; 0 exp(im * π / 2)]
    @test z_tensor(2, Parameter(Val(:Factor), 1)) == [1 0; 0 1]
    @test x_tensor(2, Parameter(Val(:PiUnit), 1)) ≈ [0 1; 1 0]
    @test x_tensor(2, Parameter(Val(:Factor), -1)) ≈ [0 1; 1 0]

    @test w_tensor(2) == [0 1; 1 0]

    @test h_tensor(2) ≈ (1 / sqrt(2)) * [1 1; 1 -1]
    @test_throws ErrorException h_tensor(3)

    @test d_tensor(2) ≈ [1 1; 1 0]
    @test_throws ErrorException d_tensor(3)
end

@testset "Convert to Einsum" begin

    zxwd = ZXWDiagram(2)

    pushfirst_gate!(zxwd, Val(:CNOT), 1, 2)
    pushfirst_gate!(zxwd, Val(:CNOT), 1, 2)

    @test Matrix(zxwd) ≈ Matrix{ComplexF64}(I, 4, 4)

end
