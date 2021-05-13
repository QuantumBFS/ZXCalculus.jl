using ZXCalculus, Test
using YaoHIR, YaoLocations
using CompilerPluginTools

chain = Chain()
push_gate!(chain, Val{:Sdag}(), 1)
push_gate!(chain, Val{:H}(), 1)
push_gate!(chain, Val{:S}(), 1)
push_gate!(chain, Val{:S}(), 2)
push_gate!(chain, Val{:H}(), 4)
push_gate!(chain, Val{:CNOT}(), 3, 2)
push_gate!(chain, Val{:CZ}(), 4, 1)
push_gate!(chain, Val{:H}(), 2)
push_gate!(chain, Val{:T}(), 2)
push_gate!(chain, Val{:CNOT}(), 3, 2)
push_gate!(chain, Val{:Tdag}(), 2)
push_gate!(chain, Val{:CNOT}(), 1, 4)
push_gate!(chain, Val{:H}(), 1)
push_gate!(chain, Val{:T}(), 2)
push_gate!(chain, Val{:S}(), 3)
push_gate!(chain, Val{:H}(), 4)
push_gate!(chain, Val{:T}(), 1)
push_gate!(chain, Val{:H}(), 2)
push_gate!(chain, Val{:H}(), 3)
push_gate!(chain, Val{:Sdag}(), 4)
push_gate!(chain, Val{:S}(), 3)
push_gate!(chain, Val{:X}(), 4)
push_gate!(chain, Val{:CNOT}(), 3, 2)
push_gate!(chain, Val{:H}(), 1)
push_gate!(chain, Val{:S}(), 4)
push_gate!(chain, Val{:X}(), 4)

ir = @make_ircode begin
end
bir = BlockIR(ir, 4, chain)
zxd = convert_to_zxd(bir)
pt_zxd = phase_teleportation(zxd)
@test tcount(pt_zxd) <= tcount(zxd)
pt_chain = convert_to_chain(pt_zxd)
@test length(pt_chain) <= length(chain)

zxg = clifford_simplification(zxd)
cl_chain = circuit_extraction(zxg)

zxg = full_reduction(zxd)
fl_chain = circuit_extraction(zxg)

pt_bir = phase_teleportation(bir)
cl_bir = clifford_simplification(bir)
fl_bir = full_reduction(bir)

@test length(pt_chain) == length(pt_bir.circuit)
@test length(cl_chain) == length(cl_bir.circuit)
@test length(fl_chain) == length(fl_bir.circuit)