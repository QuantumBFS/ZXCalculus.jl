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
    inneighbors,
    neighbors,
    spiders,
    scalar,
    get_inputs,
    get_outputs,
    get_input_idx,
    get_output_idx,
    add_power!,
    add_global_phase!

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
    @test sort(neighbors(zw, 3)) == [1, 4, 5]
    @test degree(zw, 1) == 2
    @test indegree(zw, 1) == 2
    @test outdegree(zw, 1) == 2

    @test sort(spiders(zw)) == [1, 2, 3, 4, 5, 6]
    @test sort(get_inputs(zw)) == [1, 3, 5]
    @test sort(get_outputs(zw)) == [2, 4, 6]

    @test get_input_idx(zw, 2) == 3
    @test get_output_idx(zw, 2) == 4

    sc = scalar(zw)
    @test sc == Scalar{Rational}()
    add_power!(zw, 2)
    add_global_phase!(zw, 1 // 2)
    sc = scalar(zw)
    @test sc == Scalar{Rational}(2, 1 // 2)

    # TODO
    # set_phase!
end
