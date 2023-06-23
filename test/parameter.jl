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

    p6 = Parameter(Expr(:call, :+, 1.0, :a), "PiUnit")
    @test p6.pu == Expr(:call, :+, 1.0, :a) && p6.pu_type == Expr

    p7 = Parameter(Expr(:call, :+, :a, :b), "PiUnit")
    @test p7.pu == Expr(:call, :+, :a, :b) && p7.pu_type == Expr

    f4 = Parameter(f3)
    @test f4.f == f3.f

    # in the future, might want to add support for Symbol for Factor
    @test_throws ErrorException Parameter(:a, "Factor")
end

@testset "io" begin

    io = IOBuffer()
    p1 = Parameter(1.0, "PiUnit")
    show(io, p1)
    @test String(take!(io)) == "1.0⋅π"

    p2 = Parameter(:a, "PiUnit")
    show(io, p2)
    @test String(take!(io)) == "PiUnit((a)::Symbol)"

    f1 = Parameter(1, "Factor")
    show(io, f1)
    @test String(take!(io)) == "1"
end

@testset "addition" begin
    p1 = Parameter(1.0, "PiUnit")
    p2 = Parameter(2, "PiUnit")
    p3 = Parameter(:a, "PiUnit")
    p4 = Parameter(:b, "PiUnit")
    f1 = Parameter(1, "Factor")
    f2 = Parameter(2.5, "Factor")

    @test p1 + p2 == Parameter(3.0, "PiUnit")
    @test p1 + 2 == Parameter(3.0, "PiUnit")
    @test 2 + p1 == Parameter(3.0, "PiUnit")
    @test 2 + f2 == Parameter(4.5, "Factor")
    @test f2 + 2 == Parameter(4.5, "Factor")
    p13 = p1 + p3
    @test p13.pu == Expr(:call, :+, 1.0, :a) && p13.pu_type == Expr
    p34 = p3 + p4
    @test p34.pu == Expr(:call, :+, :a, :b) && p34.pu_type == Expr

    @test p2 + f1 == Parameter(exp(im * 2 * π) + 1, "Factor")

end
