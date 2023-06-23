@testset "Constructor" begin
    p1 = Parameter.PiUnit()
    @test p1.pu == 0.0 && p1.pu_type == Float64
    p2 = Parameter.PiUnit(0.5, Float64)
    @test p2.pu == 0.5 && p2.pu_type == Float64

    f1 = Parameter.Factor()
    @test f1.f == 1.0
    f2 = Parameter.Factor(4.0 * im)
    @test f2.f == 4.0 * im

    p3 = Parameter(1.0, "PiUnit")
    @test p3.pu == 1.0 && p3.pu_type == Float64

    f3 = Parameter(1)
    @test f3.f == 1

    p4 = Parameter(p3)
    @test p4.pu == p3.pu && p4.pu_type == p4.pu_type

    p5 = Parameter(:a, "PiUnit")
    @test p5.pu == :a && p5.pu_type == Symbol

    f4 = Parameter(f3)
    @test f4.f == f3.f

    # in the future, might want to add support for Symbol for Factor
    @test_throws ErrorException Parameter(:a, "Factor")
end
