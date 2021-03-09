qc_swap = QCircuit(4)

push_gate!(qc_swap, Val(:SWAP), 1, 3)
push_gate!(qc_swap, Val(:SWAP), 2, 4)
push_gate!(qc_swap, Val(:SWAP), 2, 3)
push_gate!(qc_swap, Val(:SWAP), 1, 4)
push_gate!(qc_swap, Val(:SWAP), 3, 4)
push_gate!(qc_swap, Val(:SWAP), 4, 3)
push_gate!(qc_swap, Val(:SWAP), 2, 3)

ZXCalculus.bring_swap_forward!(qc_swap)
ZXCalculus.simplify_swap!(qc_swap)
@test gate_count(qc_swap) == 3

ZXCalculus.replace_swap!(qc_swap)
@test gate_count(qc_swap) == 9
