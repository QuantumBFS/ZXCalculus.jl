using Test
using ZXCalculus.ZX
using ZXCalculus.ZX: ZXLayout, set_loc!, nqubits, qubit_loc, column_loc

@testset "ZXLayout" begin
    layout = ZXLayout{Int}(3)
    @test nqubits(layout) == 3
    set_loc!(layout, 1, 1, 2)
    another_layout = copy(ZXLayout(3, Dict(1 => 1//1), Dict(1 => 2//1)))
    @test qubit_loc(layout, 1) == qubit_loc(another_layout, 1) == 1
    @test column_loc(layout, 1) == column_loc(another_layout, 1) == 2
end
