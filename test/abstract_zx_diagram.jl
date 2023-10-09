using ZXCalculus.ZX
using ZXCalculus.Utils: Phase

struct TestZXDiagram{T,P} <: AbstractZXDiagram{T,P} end

test_zxd = TestZXDiagram{Int,Phase}();

@test_throws MethodError Graphs.nv(test_zxd)
@test_throws MethodError Graphs.ne(test_zxd)
@test_throws MethodError Graphs.degree(test_zxd, 1)
@test_throws MethodError Graphs.indegree(test_zxd, 1)
@test_throws MethodError Graphs.outdegree(test_zxd, 1)
@test_throws MethodError Graphs.neighbors(test_zxd, 1)
@test_throws MethodError Graphs.outneighbors(test_zxd, 1)
@test_throws MethodError Graphs.inneighbors(test_zxd, 1)
@test_throws MethodError Graphs.rem_edge!(test_zxd, 1, 2)
@test_throws MethodError Graphs.add_edge!(test_zxd, 1, 2, 1)
@test_throws MethodError Graphs.has_edge(test_zxd, 1, 2)

@test_throws MethodError print(test_zxd)
@test_throws MethodError Base.copy(test_zxd)

@test_throws MethodError ZX.nqubits(test_zxd)
@test_throws MethodError spiders(test_zxd)
@test_throws MethodError tcount(test_zxd)
@test_throws MethodError ZX.get_inputs(test_zxd)
@test_throws MethodError ZX.get_outputs(test_zxd)
@test_throws MethodError ZX.scalar(test_zxd)
@test_throws MethodError ZX.spider_sequence(test_zxd)
@test_throws MethodError ZX.round_phases!(test_zxd)

@test_throws MethodError spider_type(test_zxd, 1)
@test_throws MethodError phase(test_zxd, 1)
@test_throws MethodError rem_spider!(test_zxd, 1)
@test_throws MethodError rem_spiders!(test_zxd, [1, 2])
@test_throws MethodError ZX.qubit_loc(test_zxd, 1)
@test_throws MethodError ZX.column_loc(test_zxd, 1)
@test_throws MethodError ZX.add_global_phase!(test_zxd, 3)
@test_throws MethodError ZX.add_power!(test_zxd, 4)
@test_throws MethodError ZX.generate_layout!(test_zxd, [])

@test_throws MethodError ZX.set_phase!(test_zxd, 1, Phase(1 // 1))
@test_throws MethodError push_gate!(test_zxd, 1, Val(:X), Phase(1 // 2))
@test_throws MethodError pushfirst_gate!(test_zxd, 1, 2, Val(:CNOT))
@test_throws MethodError ZX.add_spider!(test_zxd, Phase(1 // 1))
@test_throws MethodError ZX.insert_spider!(test_zxd, Phase(1 // 2), [2, 3])
