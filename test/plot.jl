# bring in includes
function yao_circ()
    return chain(
        5,
        put(5, 5 => Rx(π)),
        put(5, 5 => Yao.H),
        put(5, 5 => Rz(0)),
        cnot(5, 5, 4),
        put(5, 5 => Rz(7 * π / 4)),
        cnot(5, 5, 1),
        put(5, 5 => Rz(π / 4)),
        cnot(5, 5, 4),
        put(5, 4 => Rz(π / 4)),
        put(5, 4 => Rz(7 * π / 4)),
        cnot(5, 5, 1),
        cnot(5, 4, 1),
        put(5, 5 => Rz(π / 4)),
        put(5, 1 => Rz(π / 4)),
        put(5, 4 => Rz(π / 4)),
        cnot(5, 4, 1),
        cnot(5, 5, 4),
        put(5, 5 => Rz(7 * π / 4)),
        cnot(5, 5, 3),
        put(5, 5 => Rz(π / 4)),
        cnot(5, 5, 4)put(5, 4 => Rz(π / 4)),
        put(5, 5 => Rz(7 * π / 4)),
        cnot(5, 5, 3),
        cnot(5, 4, 3),
        put(5, 5 => Rz(π / 4)),
        put(5, 3 => Rz(π / 4)),
        put(5, 4 => Rz(7 * π / 4)),
        put(5, 5 => Yao.H),

        #     cir,
        #     Val{:H}(),
        #     5,
        # )push_gate!(
        #     cir,
        #     Val{:Z}(),
        #     5,
        # )push_gate!(
        #     cir,
        #     Val{:CNOT}(),
        #     4,
        #     3,
        # )push_gate!(
        #     cir,
        #     Val{:CNOT}(),
        #     5,
        #     4,
        # )push_gate!(
        #     cir,
        #     Val{:H}(),
        #     5,
        # )push_gate!(
        #     cir,
        #     Val{:Z}(),
        #     5,
        # )push_gate!(
        #     cir,
        #     Val{:CNOT}(),
        #     5,
        #     3,
        # )push_gate!(
        #     cir,
        #     Val{:Z}(),
        #     5,
        #     7 // 4,
        # )push_gate!(
        #     cir,
        #     Val{:CNOT}(),
        #     5,
        #     2,
        # )push_gate!(
        #     cir,
        #     Val{:Z}(),
        #     5,
        #     1 // 4,
        # )push_gate!(
        #     cir,
        #     Val{:CNOT}(),
        #     5,
        #     3,
        # )push_gate!(
        #     cir,
        #     Val{:Z}(),
        #     3,
        #     1 // 4,
        # )push_gate!(
        #     cir,
        #     Val{:Z}(),
        #     5,
        #     7 // 4,
        # )push_gate!(
        #     cir,
        #     Val{:CNOT}(),
        #     5,
        #     2,
        # )push_gate!(
        #     cir,
        #     Val{:CNOT}(),
        #     3,
        #     2,
        # )push_gate!(
        #     cir,
        #     Val{:Z}(),
        #     5,
        #     1 // 4,
        # )push_gate!(
        #     cir,
        #     Val{:H}(),
        #     5,
        # )push_gate!(
        #     cir,
        #     Val{:Z}(),
        #     2,
        #     1 // 4,
        # )push_gate!(
        #     cir,
        #     Val{:Z}(),
        #     3,
        #     7 // 4,
        # )push_gate!(
        #     cir,
        #     Val{:Z}(),
        #     5,
        # )push_gate!(
        #     cir,
        #     Val{:CNOT}(),
        #     3,
        #     2,
        # )push_gate!(
        #     cir,
        #     Val{:CNOT}(),
        #     5,
        #     3,
        # )push_gate!(
        #     cir,
        #     Val{:H}(),
        #     5,
        # )push_gate!(
        #     cir,
        #     Val{:Z}(),
        #     5,
        # )push_gate!(
        #     cir,
        #     Val{:CNOT}(),
        #     5,
        #     2,
        # )push_gate!(
        #     cir,
        #     Val{:Z}(),
        #     5,
        #     7 // 4,
        # )push_gate!(
        #     cir,
        #     Val{:CNOT}(),
        #     5,
        #     1,
        # )push_gate!(
        #     cir,
        #     Val{:Z}(),
        #     5,
        #     1 // 4,
        # )push_gate!(
        #     cir,
        #     Val{:CNOT}(),
        #     5,
        #     2,
        # )push_gate!(
        #     cir,
        #     Val{:Z}(),
        #     2,
        #     1 // 4,
        # )push_gate!(
        #     cir,
        #     Val{:Z}(),
        #     5,
        #     7 // 4,
        # )push_gate!(
        #     cir,
        #     Val{:CNOT}(),
        #     5,
        #     1,
        # )push_gate!(
        #     cir,
        #     Val{:CNOT}(),
        #     2,
        #     1,
        # )push_gate!(
        #     cir,
        #     Val{:Z}(),
        #     5,
        #     1 // 4,
        # )push_gate!(
        #     cir,
        #     Val{:Z}(),
        #     1,
        #     1 // 4,
        # )push_gate!(
        #     cir,
        #     Val{:Z}(),
        #     2,
        #     7 // 4,
        # )push_gate!(
        #     cir,
        #     Val{:H}(),
        #     5,
        # )push_gate!(
        #     cir,
        #     Val{:Z}(),
        #     5,
        # )push_gate!(
        #     cir,
        #     Val{:CNOT}(),
        #     2,
        #     1,
        # )push_gate!(cir, Val{:CNOT}(), 5, 2)push_gate!(cir, Val{:CNOT}(), 5, 1),
    )
end

yc = yao_circ()
vizcircuit(yc)

function gen_cir()
    cir = ZXDiagram(5)
    push_gate!(cir, Val{:X}(), 5, 1 // 1)
    push_gate!(cir, Val{:H}(), 5)
    push_gate!(cir, Val{:Z}(), 5)
    push_gate!(cir, Val{:CNOT}(), 5, 4)
    push_gate!(cir, Val{:Z}(), 5, 7 // 4)
    push_gate!(cir, Val{:CNOT}(), 5, 1)
    push_gate!(cir, Val{:Z}(), 5, 1 // 4)
    push_gate!(cir, Val{:CNOT}(), 5, 4)
    push_gate!(cir, Val{:Z}(), 4, 1 // 4)
    push_gate!(cir, Val{:Z}(), 5, 7 // 4)
    push_gate!(cir, Val{:CNOT}(), 5, 1)
    push_gate!(cir, Val{:CNOT}(), 4, 1)
    push_gate!(cir, Val{:Z}(), 5, 1 // 4)
    push_gate!(cir, Val{:Z}(), 1, 1 // 4)
    push_gate!(cir, Val{:Z}(), 4, 7 // 4)
    push_gate!(cir, Val{:CNOT}(), 4, 1)
    push_gate!(cir, Val{:CNOT}(), 5, 4)
    push_gate!(cir, Val{:Z}(), 5, 7 // 4)
    push_gate!(cir, Val{:CNOT}(), 5, 3)
    push_gate!(cir, Val{:Z}(), 5, 1 // 4)
    push_gate!(cir, Val{:CNOT}(), 5, 4)
    push_gate!(cir, Val{:Z}(), 4, 1 // 4)
    push_gate!(cir, Val{:Z}(), 5, 7 // 4)
    push_gate!(cir, Val{:CNOT}(), 5, 3)
    push_gate!(cir, Val{:CNOT}(), 4, 3)
    push_gate!(cir, Val{:Z}(), 5, 1 // 4)
    push_gate!(cir, Val{:Z}(), 3, 1 // 4)
    push_gate!(cir, Val{:Z}(), 4, 7 // 4)
    push_gate!(cir, Val{:H}(), 5)
    push_gate!(cir, Val{:Z}(), 5)
    push_gate!(cir, Val{:CNOT}(), 4, 3)
    push_gate!(cir, Val{:CNOT}(), 5, 4)
    push_gate!(cir, Val{:H}(), 5)
    push_gate!(cir, Val{:Z}(), 5)
    push_gate!(cir, Val{:CNOT}(), 5, 3)
    push_gate!(cir, Val{:Z}(), 5, 7 // 4)
    push_gate!(cir, Val{:CNOT}(), 5, 2)
    push_gate!(cir, Val{:Z}(), 5, 1 // 4)
    push_gate!(cir, Val{:CNOT}(), 5, 3)
    push_gate!(cir, Val{:Z}(), 3, 1 // 4)
    push_gate!(cir, Val{:Z}(), 5, 7 // 4)
    push_gate!(cir, Val{:CNOT}(), 5, 2)
    push_gate!(cir, Val{:CNOT}(), 3, 2)
    push_gate!(cir, Val{:Z}(), 5, 1 // 4)
    push_gate!(cir, Val{:H}(), 5)
    push_gate!(cir, Val{:Z}(), 2, 1 // 4)
    push_gate!(cir, Val{:Z}(), 3, 7 // 4)
    push_gate!(cir, Val{:Z}(), 5)
    push_gate!(cir, Val{:CNOT}(), 3, 2)
    push_gate!(cir, Val{:CNOT}(), 5, 3)
    push_gate!(cir, Val{:H}(), 5)
    push_gate!(cir, Val{:Z}(), 5)
    push_gate!(cir, Val{:CNOT}(), 5, 2)
    push_gate!(cir, Val{:Z}(), 5, 7 // 4)
    push_gate!(cir, Val{:CNOT}(), 5, 1)
    push_gate!(cir, Val{:Z}(), 5, 1 // 4)
    push_gate!(cir, Val{:CNOT}(), 5, 2)
    push_gate!(cir, Val{:Z}(), 2, 1 // 4)
    push_gate!(cir, Val{:Z}(), 5, 7 // 4)
    push_gate!(cir, Val{:CNOT}(), 5, 1)
    push_gate!(cir, Val{:CNOT}(), 2, 1)
    push_gate!(cir, Val{:Z}(), 5, 1 // 4)
    push_gate!(cir, Val{:Z}(), 1, 1 // 4)
    push_gate!(cir, Val{:Z}(), 2, 7 // 4)
    push_gate!(cir, Val{:H}(), 5)
    push_gate!(cir, Val{:Z}(), 5)
    push_gate!(cir, Val{:CNOT}(), 2, 1)
    push_gate!(cir, Val{:CNOT}(), 5, 2)
    push_gate!(cir, Val{:CNOT}(), 5, 1)
    return cir
end

circ = gen_cir()
circ2 = phase_teleportation(circ)
tcount(circ)
tcount(circ2)
ex_circ = clifford_simplification(circ2)
tcount(ex_circ)


# Example data
circuit_names = ["Before Simplification", "After Simplification"]
circuit_values = [28, 8]  # Replace these with your actual values

fig = Figure(resolution = (600, 400))
ax = Axis(fig, xlabel = "Circuit", ylabel = "T Counts")

barplot(1:2, circuit_values,
        axis = (xticks = (1:2, circuit_names),
                ylabel = "T Counts",
                title = "Simplification Performance"),
        )
barplot!(circuit_names, circuit_values)
fig[1, 1] = ax

# Save the figure to a file
save("~/Desktop/tcounts.png", fig)

# Example data
circuit_names = ["Before Simplification", "After Simplification"]
circuit_values = [5, 3]  # Replace these with your actual values

bar(circuit_names, circuit_values,
    title = "Comparison of Quantum Circuits",
    xlabel = "Circuit",
    ylabel = "Criterion",
    label = false)

zxwd = ZXWDiagram(2)
push_gate!(zxwd, Val(:H), 1)
push_gate!(zxwd, Val(:H), 2)

push_gate!(zxwd, Val(:CZ), 1, 2)
push_gate!(zxwd, Val(:X), 1, Parameter(Val(:PiUnit), :a); autoconvert = false)
push_gate!(zxwd, Val(:X), 2, Parameter(Val(:PiUnit), :b); autoconvert = false)

drawZXWDiagram(zxwd)

zxwd_diff_a = diff_diagram(copy(zxwd), :a)
drawZXWDiagram(zxwd_diff_a)
