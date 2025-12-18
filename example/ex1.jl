using ZXCalculus
using Vega, DataFrames

function generate_example()
    circ = ZXCircuit(4)
    push_gate!(circ, Val{:Z}(), 1, 3//2)
    push_gate!(circ, Val{:H}(), 1)
    push_gate!(circ, Val{:Z}(), 1, 1//2)
    push_gate!(circ, Val{:H}(), 4)
    push_gate!(circ, Val{:CZ}(), 4, 1)
    push_gate!(circ, Val{:CNOT}(), 1, 4)
    push_gate!(circ, Val{:H}(), 1)
    push_gate!(circ, Val{:H}(), 4)
    push_gate!(circ, Val{:Z}(), 1, 1//4)
    push_gate!(circ, Val{:Z}(), 4, 3//2)
    push_gate!(circ, Val{:X}(), 4, 1//1)
    push_gate!(circ, Val{:H}(), 1)
    push_gate!(circ, Val{:Z}(), 4, 1//2)
    push_gate!(circ, Val{:X}(), 4, 1//1)

    push_gate!(circ, Val{:Z}(), 2, 1//2)
    push_gate!(circ, Val{:CNOT}(), 3, 2)
    push_gate!(circ, Val{:H}(), 2)
    push_gate!(circ, Val{:CNOT}(), 3, 2)
    push_gate!(circ, Val{:Z}(), 2, 1//4)
    push_gate!(circ, Val{:Z}(), 3, 1//2)
    push_gate!(circ, Val{:H}(), 2)
    push_gate!(circ, Val{:H}(), 3)
    push_gate!(circ, Val{:Z}(), 3, 1//2)
    push_gate!(circ, Val{:CNOT}(), 3, 2)

    return circ
end

zxc = generate_example()
simp_zxc = clifford_simplification(zxc)

plot(zxc)
plot(simp_zxc)
