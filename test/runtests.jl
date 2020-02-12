using ZX
using Test
using LinearAlgebra

@testset "ZX.jl" begin
    # Write your own tests here.
end

@testset "graph.jl" begin
    n = 10
    adjm = zeros(Int, n, n)
    for i = 1:n
        adjm[i,i] = 1
    end
    adjm = (1 .- adjm)
    g = Graph(adjm)
    @test g.nv == 10
    @test g.ne == 45

    add_vertex!(g, 2)
    @test g.nv == 12
    add_edge!(g, [11, 12])
    @test g.ne == 46
    @test find_nbhd(g, 11)[1] == 12
end

@testset "ZX_diagram.jl" begin
    g = Graph([0 1 0; 1 0 1; 0 1 0])
    phases = [Rational(0) for i = 1:3]
    v_t = [X, Z, X]
    zxd = ZX_diagram(g, phases, v_t)
    rule_i1!(zxd, 2)
    @test zxd.g.nv == 2 && zxd.g.ne == 1

    rule_h!(zxd, 1)
    @test zxd.g.nv == 3 && zxd.g.ne == 2 && zxd.v_type[3] == H

    rule_h!(zxd, 2)
    @test zxd.g.nv == 4 && zxd.g.ne == 3 && zxd.v_type[2] == Z && zxd.v_type[4] == H

    add_edge!(zxd.g, [1, 2])
    rule_f!(zxd, 1, 2)
    @test zxd.g.nv == 3 && zxd.g.ne == 3

    rule_i2!(zxd, 2, 3)
    @test zxd.g.nv == 1 && zxd.g.ne == 0

    g = Graph(zeros(Int, 6, 6))
    add_edge!(g, [[1,2], [2,3], [3,4], [3,5], [3,6]])
    ps = [0, 1, 1//4, 0, 0, 0]
    v_t = [In, X, Z, Out, Out, Out]
    zxd = ZX_diagram(g, ps, v_t)
    rule_pi!(zxd, 2, 3)
    @test zxd.g.nv == 8 && zxd.g.ne == 7 && zxd.phases[2] == -1//4

    g = Graph(zeros(Int, 5, 5))
    add_edge!(g, [[1,2], [2,3], [2,4], [2,5]])
    ps = [0, 1//4, 0, 0, 0]
    v_t = [X, Z, Out, Out, Out]
    zxd = ZX_diagram(g, ps, v_t)
    rule_c!(zxd, 1, 2)
    @test zxd.g.nv == 6 && zxd.g.ne == 3

    g = Graph(zeros(Int, 6, 6))
    add_edge!(g, [[1,3],[2,3],[3,4],[4,5],[4,6]])
    ps = [0, 0, 0//1, 0//1, 0, 0]
    v_t = [In, In, X, Z, Out, Out]
    zxd = ZX_diagram(g, ps, v_t)
    rule_b!(zxd, 4, 3)
    @test zxd.g.nv == 8 && zxd.g.ne == 8 && zxd.v_type[5] == X && zxd.v_type[7] == Z
end
