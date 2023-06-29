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

    # @test p3 == one(p3)
    # @test p1 == zero(p3)
    # @test f3 == one(f3)
    # @test Parameter(0) == zero(f3)

    # # @test p1 == zero(::Type{Parameter.PiUnit})
    # # @test p3 == one(::Type{Parameter.PiUnit})
    # # @test f3 == one(::Type{Parameter.Factor})
    # # @test Parameter(0) == zero(::Type{Parameter.Factor})

    # @test Base.iseven(Parameter(-2))
    # @test !Base.iseven(Parameter(-1))
    # @test Base.iseven(Parameter(2, "PiUnit"))
    # @test !Base.iseven(Parameter(1, "PiUnit"))

    # p_cp = copy(p2)
    # @test p_cp.pu == p2.pu && p_cp.pu_type == p2.pu_type
    # f_cp = copy(f2)
    # @test f_cp.f == f2.f
end

@testset "io" begin

    io = IOBuffer()
    p1 = Parameter(Val(:PiUnit), 1.0)
    show(io, p1)
    @test String(take!(io)) == "1.0⋅π"

    p2 = Parameter(Val(:PiUnit), :a)
    show(io, p2)
    @test String(take!(io)) == "PiUnit((a)::Symbol)"

    f1 = Parameter(Val(:Factor), 1)
    show(io, f1)
    @test String(take!(io)) == "1"
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
end




# @testset "addition" begin
#     p1 = Parameter(1.0, "PiUnit")
#     p2 = Parameter(2, "PiUnit")
#     p3 = Parameter(:a, "PiUnit")
#     p4 = Parameter(:b, "PiUnit")
#     f1 = Parameter(1, "Factor")
#     f2 = Parameter(2.5, "Factor")

#     @test p1 + p2 == Parameter(3.0, "PiUnit")
#     @test p1 + 2 == Parameter(3.0, "PiUnit")
#     @test 2 + p1 == Parameter(3.0, "PiUnit")
#     @test 2 + f2 == Parameter(4.5, "Factor")
#     @test f2 + 2 == Parameter(4.5, "Factor")
#     p13 = p1 + p3
#     @test p13.pu == Expr(:call, :+, 1.0, :a) && p13.pu_type == Expr
#     p34 = p3 + p4
#     @test p34.pu == Expr(:call, :+, :a, :b) && p34.pu_type == Expr

#     @test p2 + f1 == Parameter(exp(im * 2 * π) + 1, "Factor")

# end

# @testset "subtraction" begin
#     p1 = Parameter(1.0, "PiUnit")
#     p2 = Parameter(2, "PiUnit")
#     p3 = Parameter(:a, "PiUnit")
#     p4 = Parameter(:b, "PiUnit")
#     f1 = Parameter(1, "Factor")
#     f2 = Parameter(2.5, "Factor")


#     @test p1 - p2 == Parameter(-1.0, "PiUnit")
#     @test p1 - 2 == Parameter(-1.0, "PiUnit")
#     @test 2 - p1 == Parameter(1.0, "PiUnit")
#     @test 2 - f2 == Parameter(-0.5, "Factor")
#     @test f2 - 2 == Parameter(0.5, "Factor")
#     p13 = p1 - p3
#     @test p13.pu == Expr(:call, :-, 1.0, :a) && p13.pu_type == Expr
#     p34 = p3 - p4
#     @test p34.pu == Expr(:call, :-, :a, :b) && p34.pu_type == Expr

#     @test p2 - f1 == Parameter(exp(im * 2 * π) - 1, "Factor")
# end


# @testset "multiplication" begin
#     p1 = Parameter(2.5, "PiUnit")
#     p2 = Parameter(3, "PiUnit")
#     p3 = Parameter(:c, "PiUnit")
#     p4 = Parameter(:d, "PiUnit")

#     f1 = Parameter(2, "Factor")
#     f2 = Parameter(3 * im, "Factor")

#     @test p1 * p2 == Parameter(7.5, "PiUnit")
#     @test p3 * p4 == Parameter(Expr(:call, :*, :c, :d), "PiUnit")

#     @test f1 * f2 == Parameter(6im, "Factor")

#     @test p1 * f1 == Parameter(exp(im * 2.5 * π) * 2, "Factor")
#     @test f1 * p1 == Parameter(exp(im * 2.5 * π) * 2, "Factor")

#     @test p2 * 4 == Parameter(12, "PiUnit")
#     @test f1 * 2 == Parameter(4, "Factor")

#     @test p1 * 2 == 2 * p1
# end


# @testset "division" begin
#     p1 = Parameter(3.0, "PiUnit")
#     p2 = Parameter(3, "PiUnit")
#     p3 = Parameter(:c, "PiUnit")
#     p4 = Parameter(:d, "PiUnit")

#     f1 = Parameter(4, "Factor")
#     f2 = Parameter(3 * im, "Factor")
#     @test p1 / p2 == Parameter(1.0, "PiUnit")
#     @test p3 / p4 == Parameter(Expr(:call, :/, :c, :d), "PiUnit")

#     @test f1 / f2 == Parameter(4 / (3 * im), "Factor")

#     @test p1 / f1 == Parameter(exp(im * 3 * π) / 4, "Factor")
#     @test f1 / p1 == Parameter(4 / exp(im * 3 * π), "Factor")

#     @test 5 / p1 == Parameter(5 / 3.0, "PiUnit")

#     @test 33 / f2 == Parameter(33 / (3 * im), "Factor")

#     @test p1 / 2 == Parameter(1.5, "PiUnit")
# end

# @testset "misc" begin
#     p1 = Parameter(15.0, "PiUnit")
#     p2 = Parameter(:a, "PiUnit")
#     @test Base.rem(p1, 12) == Parameter(3.0, "PiUnit")
#     @test Base.rem(p2, 12) == Parameter(:a, "PiUnit")

#     f1 = Parameter(13)
#     @test Base.rem(f1, 12) == Parameter(1)

# end
