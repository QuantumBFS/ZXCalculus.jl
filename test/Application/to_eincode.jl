using Test, ZXCalculus, LinearAlgebra, ZXCalculus.Utils, ZXCalculus.ZXW
using ZXCalculus.Application:
                              z_tensor, x_tensor, w_tensor, h_tensor, d_tensor
using ZXCalculus.Utils: Parameter
using ZXCalculus.ZXW: push_gate!

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
    push_gate!(zxwd, Val(:H), 1)
    push_gate!(zxwd, Val(:H), 2)
    push_gate!(zxwd, Val(:CZ), 1, 2)
    push_gate!(zxwd, Val(:X), 1, :a; autoconvert=false)
    push_gate!(zxwd, Val(:X), 2, :b; autoconvert=false)
    zxwd_sub = substitute_variables!(copy(zxwd), Dict(:a => 0.4, :b => 0.3))
    zxwd_mtx = Matrix(zxwd_sub)

    yao_mtx = ComplexF64[0.6211468747399733+0.23776412907378838im 0.033361622447500294+0.23776412907378833im 0.1727457514062631+0.16674436811368532im -0.1727457514062631+0.642272626261262im
                         0.1727457514062631+0.16674436811368532im 0.1727457514062631-0.642272626261262im 0.6211468747399733+0.23776412907378838im -0.033361622447500294-0.23776412907378833im
                         0.033361622447500294+0.23776412907378833im 0.6211468747399733+0.23776412907378838im 0.1727457514062631-0.642272626261262im -0.1727457514062631-0.16674436811368532im
                         0.1727457514062631-0.642272626261262im 0.1727457514062631+0.16674436811368532im 0.033361622447500294+0.23776412907378833im -0.6211468747399733-0.23776412907378838im]
    @test isapprox(zxwd_mtx' * yao_mtx, Matrix{ComplexF64}((1.0 + 0.0 * im) * I, 4, 4))
end
