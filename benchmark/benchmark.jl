using YaoLang: YaoIR, is_pure_quantum
using ZXCalculus
using BenchmarkTools

function zx_load_qasm(filename::String)
    srcs = readlines("benchmark/circuits/$(filename)")
    src = prod([srcs[1]; srcs[3:end]])
    m = @__MODULE__
    ir = YaoIR(m, src, gensym())
    ir.pure_quantum = is_pure_quantum(ir)
    return zxd = ZXDiagram(ir)
end
function run_benchmark()
    filenames = readdir("benchmark/circuits")
    bms = Dict()
    for circ_name in filenames
        zxd = zx_load_qasm(circ_name)
        b = @benchmark phase_teleportation($zxd)
        println(circ_name, "\ttime = ", (mean(b).time / 1e9), "\ttcount = ", tcount(phase_teleportation(zxd)))
        bms[circ_name] = b
    end
    bms
end

bms = run_benchmark()
