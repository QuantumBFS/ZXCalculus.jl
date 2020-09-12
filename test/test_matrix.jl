using YaoLang, YaoArrayRegister

srcs = readlines("benchmark\\circuits\\hwb8.qasm")
src = prod([srcs[1];srcs[3:end]])
begin
    ir_original = YaoLang.Compiler.YaoIR(@__MODULE__, src, :circ_original)
    ir_original.pure_quantum = YaoLang.Compiler.is_pure_quantum(ir_original)
    ir_optimized = YaoLang.Compiler.YaoIR(@__MODULE__, src, :circ_optimized)
    ir_optimized.pure_quantum = YaoLang.Compiler.is_pure_quantum(ir_optimized)
    ir_optimized = YaoLang.Compiler.optimize(ir_optimized, [:zx_teleport])
    code_original = YaoLang.Compiler.codegen(YaoLang.Compiler.JuliaASTCodegenCtx(ir_original), ir_original)
    code_optimized = YaoLang.Compiler.codegen(YaoLang.Compiler.JuliaASTCodegenCtx(ir_optimized), ir_optimized)

    eval(code_original)
    eval(code_optimized)

    nbits = YaoLang.Compiler.count_nqubits(ir_original)

    circ_or = circ_original()
    circ_op = circ_optimized()

    println("Computing matrix of the original circuit...")
    mat_original = zeros(ComplexF64, 2^nbits, 2^nbits)
    for i = 1:2^nbits
        st = zeros(ComplexF64, 2^nbits)
        st[i] = 1
        r0 = ArrayReg(st)
        r0 |> circ_or
        mat_original[:,i] = r0.state
    end

    println("Computing matrix of the optimized circuit...")
    mat_optimized = zeros(ComplexF64, 2^nbits, 2^nbits)
    for i = 1:2^nbits
        st = zeros(ComplexF64, 2^nbits)
        st[i] = 1
        r0 = ArrayReg(st)
        r0 |> circ_op
        mat_optimized[:,i] = r0.state
    end

    ind_or = findfirst(abs.(mat_original) .> 1e-10)
    ind_op = findfirst(abs.(mat_optimized) .> 1e-10)
    if ind_or != ind_op
        println("index mismatch")
        return false
    end

    mat_optimized = mat_optimized .* (mat_original[ind_or] / mat_optimized[ind_op])
    println("hwb8.qasm: ", sum(abs.(mat_original - mat_optimized) .> 1e-10) == 0)
end
