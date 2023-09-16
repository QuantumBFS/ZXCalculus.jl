using ZXCalculus.ZW:
    ZWDiagram,
    spider_type,
    set_phase!,
    parameter,
    nin,
    nout,
    nqubits,
    nv,
    ne,
    degree,
    indegree,
    outdegree,
    outneighbors,
    inneighbors

@testset "utils" begin
    zw = ZWDiagram(3)

    @test spider_type(zw, 1) == ZW.Input(1)
    @test parameter(zw, 2) == 1
    @test nqubits(zw) == 3
    @test nin(zw) == 3
    @test nout(zw) == 3
    @test nv(zw) == 6
    @test ne(zw) == 7
    @test sort(outneighbors(zw, 1)) == [2, 3]
    @test sort(inneighbors(zw, 1)) == [2, 3]
    @test degree(zw, 1) == 2
    @test indegree(zw, 1) == 2
    @test outdegree(zw, 1) == 2

    # TODO
    # set_phase!
end
