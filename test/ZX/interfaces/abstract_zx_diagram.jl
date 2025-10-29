module ZXDiagramInterfaceTests

using Test
using Graphs
using ZXCalculus.ZX
using ZXCalculus.ZX: AbstractZXDiagram
using ZXCalculus.Utils: Phase

struct DummyZXDiagram{T, P} <: AbstractZXDiagram{T, P} end

@testset "Graph Interface Tests" begin
    zxd = DummyZXDiagram{Int, Phase}()
    @test_throws ErrorException nv(zxd)
    @test_throws ErrorException ne(zxd)

    @test_throws ErrorException degree(zxd, 1)
    @test_throws ErrorException indegree(zxd, 2)
    @test_throws ErrorException outdegree(zxd, 3)

    @test_throws ErrorException neighbors(zxd, 1)
    @test_throws ErrorException outneighbors(zxd, 2)
    @test_throws ErrorException inneighbors(zxd, 3)

    @test_throws ErrorException has_edge(zxd, 1, 2)
    @test_throws ErrorException add_edge!(zxd, 1, 3)
    @test_throws ErrorException rem_edge!(zxd, 2, 3)
end

@testset "Calculus Interface Tests" begin
    zxd = DummyZXDiagram{Int, Phase}()
    @test_throws ErrorException spiders(zxd)
    @test_throws ErrorException spider_types(zxd)
    @test_throws ErrorException phases(zxd)

    @test_throws ErrorException spider_type(zxd, 1)
    @test_throws ErrorException phase(zxd, 2)
    @test_throws ErrorException set_phase!(zxd, 3, Phase(1//1))
    @test_throws ErrorException add_spider!(zxd, SpiderType.SType.Z, Phase(1//1))
    @test_throws ErrorException rem_spider!(zxd, 4)
    @test_throws ErrorException rem_spiders!(zxd, [5, 6])
    @test_throws ErrorException insert_spider!(zxd, 1, 2)

    @test_throws ErrorException scalar(zxd)
    @test_throws ErrorException add_global_phase!(zxd, Phase(1//1))
    @test_throws ErrorException add_power!(zxd, 2)

    @test_throws ErrorException tcount(zxd)
    @test_throws ErrorException round_phases!(zxd)
    @test_throws ErrorException plot(zxd)
end

end
