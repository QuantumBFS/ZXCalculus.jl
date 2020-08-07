using YaoLang: YaoIR, is_pure_quantum
using ZXCalculus
circ_name = "adder_8"
srcs = readlines("benchmark/circuits/$(circ_name).qasm")
src = prod([srcs[1]; srcs[3:end]])
m = @__MODULE__
ir = YaoIR(m, src, circ_name)
ir.pure_quantum = true
zxd = ZXDiagram(ir);
using ProfileView: @profview
@profiler ZXGraph(zxd);
@profview phase_teleportation(zxd)
using BenchmarkTools
@benchmark clifford_simplification(zxd)
@benchmark phase_teleportation(zxd);
