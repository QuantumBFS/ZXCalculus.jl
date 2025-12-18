using ZXCalculus.Utils: continued_fraction, safe_convert

@testset "float to rational" begin
    @test continued_fraction(2.41, 10) === 241 // 100
    @test continued_fraction(1.3, 10) === 13 // 10
    @test continued_fraction(0, 10) === 0 // 1
    @test continued_fraction(-0.5, 10) === -1 // 2
    @test safe_convert(Rational{Int64}, 1.2) == 6 // 5 &&
          safe_convert(Rational{Int64}, 1 // 2) == 1 // 2
end
