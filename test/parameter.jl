using Base: CodegenParams

@testset "Constructor" begin
    p1 = Parameter(Val(:PiUnit))
    @test p1.pu == 0.0 && p1.pu_type == Float64
    p2 = Parameter(Val(:PiUnit), 0.5)
    @test p2.pu == 0.5 && p2.pu_type == Float64

    f1 = Parameter(Val(:Factor))
    @test f1.f == 1.0 && f1.f_type == Float64
    f2 = Parameter(Val(:Factor), 4.0 * im)
    @test f2.f == 4.0 * im && f2.f_type == ComplexF64

    p3 = Parameter(p1)
    @test p3.pu == p1.pu && p3.pu_type == p1.pu_type
    f3 = Parameter(f2)
    @test f3.f == f2.f && f3.f_type == f2.f_type

    p4 = Parameter(Val(:PiUnit), :a)
    @test p4.pu == :a && p4.pu_type == Symbol

    p5 = Parameter(Val(:PiUnit), Expr(:call, :+, 1.0, :a))
    @test p5.pu == Expr(:call, :+, 1.0, :a) && p5.pu_type == Expr

    p6 = Parameter(Val(:PiUnit), Expr(:call, :+, :a, :b))
    @test p6.pu == Expr(:call, :+, :a, :b) && p6.pu_type == Expr

    @test p2 == Base.convert(Parameter, p2)
    @test Base.convert(Parameter, ("PiUnit", 0.5)) == p2
    @test f2 == Base.convert(Parameter, f2)
    @test Base.convert(Parameter, ("Factor", 4.0 * im)) == f2

    @test p1 == zero(p2)
    @test p1 == zero(f3)
    @test one(p2).pu == 1.0
    @test one(f3).f == exp(im * 1.0 * π)

    @test zero(Parameter).pu == 0.0
    @test one(Parameter).pu == 1.0

    @test Base.iseven(Parameter(Val(:PiUnit), 2))
    @test !Base.iseven(Parameter(Val(:PiUnit), 1))
    @test Base.iseven(Parameter(Val(:Factor), 1.0))
    @test !Base.iseven(Parameter(Val(:Factor), 1.00001))

    p_cp = copy(p2)
    @test p_cp.pu == p2.pu && p_cp.pu_type == p2.pu_type
    f_cp = copy(f2)
    @test f_cp.f == f2.f
end

@testset "io" begin

    io = IOBuffer()
    p1 = Parameter(Val(:PiUnit), 1.0)
    show(io, p1)
    @test String(take!(io)) == "Parameter.PiUnit(pu=1.0, pu_type=Float64)"

    p2 = Parameter(Val(:PiUnit), :a)
    show(io, p2)
    @test String(take!(io)) == "Parameter.PiUnit(pu=:a, pu_type=Symbol)"

    f1 = Parameter(Val(:Factor), 1)
    show(io, f1)
    @test String(take!(io)) == "Parameter.Factor(f=1, f_type=Int64)"
end

@testset "relational" begin
    p1 = Parameter(Val(:PiUnit), 1.0)
    p2 = Parameter(Val(:PiUnit), 1)
    p3 = Parameter(Val(:PiUnit), :a)
    p4 = Parameter(Val(:PiUnit), :b)
    p5 = Parameter(Val(:PiUnit), 0.0)
    f1 = Parameter(Val(:Factor), π)
    f2 = Parameter(Val(:Factor), 1)


    @test p1 == p2
    @test p3 == p3
    @test p3 != p4

    @test f1 != f2

    @test p5 == f2
    @test f2 == p5

    @test p1 == 1.0
    @test f1 == π

    @test p1 < 3.0
    @test !(p3 < 4.0)
    @test f1 < 20

    @test contains(p3, :a)
    @test !contains(p3, :b)
end




@testset "addition" begin
    p1 = Parameter(Val(:PiUnit), 1.0)
    p2 = Parameter(Val(:PiUnit), 2)
    p3 = Parameter(Val(:PiUnit), :a)
    p4 = Parameter(Val(:PiUnit), :b)
    f1 = Parameter(Val(:Factor), 1)
    f2 = Parameter(Val(:Factor), 2.5)

    @test p1 + p2 == Parameter(Val(:PiUnit), 3.0)
    @test p1 + 2 == Parameter(Val(:PiUnit), 3.0)
    @test 2 + p1 == Parameter(Val(:PiUnit), 3.0)
    @test f1 + f2 == Parameter(Val(:Factor), 3.5)
    @test 2 + f2 == Parameter(Val(:Factor), 4.5)
    @test f2 + 2 == Parameter(Val(:Factor), 4.5)
    p13 = p1 + p3
    @test p13.pu == Expr(:call, :+, 1.0, :a) && p13.pu_type == Union{}
    p34 = p3 + p4
    @test p34.pu == Expr(:call, :+, :a, :b) && p34.pu_type == Union{}

    @test p2 + f1 == Parameter(Val(:Factor), exp(im * 2 * π) * 1)
    @test f1 + p2 == Parameter(Val(:Factor), exp(im * 2 * π) * 1)

end

@testset "subtraction" begin
    p1 = Parameter(Val(:PiUnit), 1.0)
    p2 = Parameter(Val(:PiUnit), 2)
    p3 = Parameter(Val(:PiUnit), :a)
    p4 = Parameter(Val(:PiUnit), :b)
    f1 = Parameter(Val(:Factor), 1)
    f2 = Parameter(Val(:Factor), 2.5)


    @test p1 - p2 == Parameter(Val(:PiUnit), -1.0)
    @test p1 - 2 == Parameter(Val(:PiUnit), -1.0)
    @test 2 - p1 == Parameter(Val(:PiUnit), 1.0)
    @test f1 - f2 == Parameter(Val(:Factor), -1.5)
    @test 2 - f2 == Parameter(Val(:Factor), -0.5)
    @test f2 - 2 == Parameter(Val(:Factor), 0.5)
    p13 = p1 - p3
    @test p13.pu == Expr(:call, :-, 1.0, :a) && p13.pu_type == Union{}
    p34 = p3 - p4
    @test p34.pu == Expr(:call, :-, :a, :b) && p34.pu_type == Union{}

    @test p2 - f1 == Parameter(Val(:Factor), exp(im * 2 * π) - 1)
    @test f1 - p2 == Parameter(Val(:Factor), 1 - exp(im * 2 * π))
end

@testset "misc" begin
    p1 = Parameter(Val(:PiUnit), 15.0)
    p2 = Parameter(Val(:PiUnit), :a)
    @test Base.rem(p1, 12) == Parameter(Val(:PiUnit), 3.0)
    @test Base.rem(p2, 12) == Parameter(Val(:PiUnit), :a)

    f1 = Parameter(Val(:Factor), 13)
    @test Base.rem(f1, 12) == Parameter(Val(:Factor), 1)

end
