using ZXCalculus, LightGraphs
using Test
using ZXCalculus: Phase

struct TestZXDiagram{T, P} <: AbstractZXDiagram{T, P} end

test_zxd = TestZXDiagram{Int, Phase}();

@test_throws MethodError LightGraphs.nv(test_zxd)
@test_throws MethodError LightGraphs.ne(test_zxd)
@test_throws MethodError LightGraphs.degree(test_zxd, 1)
@test_throws MethodError LightGraphs.indegree(test_zxd, 1)
@test_throws MethodError LightGraphs.outdegree(test_zxd, 1)
@test_throws MethodError LightGraphs.neighbors(test_zxd, 1)
@test_throws MethodError LightGraphs.outneighbors(test_zxd, 1)
@test_throws MethodError LightGraphs.inneighbors(test_zxd, 1)
@test_throws MethodError LightGraphs.rem_edge!(test_zxd, 1, 2)
@test_throws MethodError LightGraphs.add_edge!(test_zxd, 1, 2, 1)
@test_throws MethodError LightGraphs.has_edge(test_zxd, 1, 2)

@test_throws MethodError print(test_zxd)
@test_throws MethodError Base.copy(test_zxd)

@test_throws MethodError ZXCalculus.nqubits(test_zxd)
@test_throws MethodError spiders(test_zxd)
@test_throws MethodError tcount(test_zxd)
@test_throws MethodError ZXCalculus.get_inputs(test_zxd)
@test_throws MethodError ZXCalculus.get_outputs(test_zxd)
@test_throws MethodError ZXCalculus.scalar(test_zxd)
@test_throws MethodError ZXCalculus.spider_sequence(test_zxd)
@test_throws MethodError ZXCalculus.round_phases!(test_zxd)

@test_throws MethodError spider_type(test_zxd, 1)
@test_throws MethodError phase(test_zxd, 1)
@test_throws MethodError rem_spider!(test_zxd, 1)
@test_throws MethodError rem_spiders!(test_zxd, [1, 2])
@test_throws MethodError ZXCalculus.qubit_loc(test_zxd, 1)
@test_throws MethodError ZXCalculus.column_loc(test_zxd, 1)
@test_throws MethodError ZXCalculus.add_global_phase!(test_zxd, 3)
@test_throws MethodError ZXCalculus.add_power!(test_zxd, 4)
@test_throws MethodError ZXCalculus.generate_layout!(test_zxd, [])

@test_throws MethodError ZXCalculus.set_phase!(test_zxd, 1, Phase(1//1))
@test_throws MethodError push_gate!(test_zxd, 1, Val(:X), Phase(1//2))
@test_throws MethodError pushfirst_gate!(test_zxd, 1, 2, Val(:CNOT))
@test_throws MethodError ZXCalculus.add_spider!(test_zxd, Phase(1//1))
@test_throws MethodError ZXCalculus.insert_spider!(test_zxd, Phase(1//2), [2, 3])