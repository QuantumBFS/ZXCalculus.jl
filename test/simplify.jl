chain_swap = Chain()

push_gate!(chain_swap, Val(:SWAP), 1, 3)
push_gate!(chain_swap, Val(:SWAP), 2, 4)
push_gate!(chain_swap, Val(:SWAP), 2, 3)
push_gate!(chain_swap, Val(:SWAP), 1, 4)
push_gate!(chain_swap, Val(:SWAP), 3, 4)
push_gate!(chain_swap, Val(:SWAP), 4, 3)
push_gate!(chain_swap, Val(:SWAP), 2, 3)

ZX.simplify_swap!(chain_swap)

@test length(chain_swap) == 9
