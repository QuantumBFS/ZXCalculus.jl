using Test, ZXCalculus, ZXCalculus.ZX
using ZXCalculus.ZX: ancilla_extraction

import ZXCalculus.ZX as ZX

function gen_phase_gadget()
    zxd = ZXDiagram(2)
    push_gate!(zxd, Val(:Z), 1, 1//2)
    push_gate!(zxd, Val(:CNOT), 1, 2)
    push_gate!(zxd, Val(:Z), 1, 1//4)
    push_gate!(zxd, Val(:CNOT), 1, 2)
    push_gate!(zxd, Val(:Z), 1, 1//2)
    
    return zxd
end

zxd = gen_phase_gadget()
zxg = full_reduction(zxd)
anc_circ = ancilla_extraction(zxg)

# plot(anc_circ)

zxd_swap = ZXDiagram(2)
pushfirst_gate!(zxd_swap, Val(:SWAP), [1, 2])
# plot(zxd_swap)
convert_to_chain(zxd_swap)

zxg_swap = ZXGraph(zxd_swap)
zxd_anc = ancilla_extraction(zxg_swap)
# plot(zxd_anc)
@test length(ZX.convert_to_chain(zxd_anc)) == 3
