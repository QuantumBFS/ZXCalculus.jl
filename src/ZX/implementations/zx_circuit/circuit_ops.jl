# Circuit Interface Implementation for ZXCircuit

nqubits(circ::ZXCircuit) = max(length(circ.inputs), length(circ.outputs))
get_inputs(circ::ZXCircuit) = circ.inputs
get_outputs(circ::ZXCircuit) = circ.outputs

# Gate operations - these will be defined in gate_ops.jl for ZXDiagram
# but ZXCircuit doesn't implement them directly yet
# For now, we define stubs that throw NotImplementedError

function push_gate!(circ::ZXCircuit, args...)
    error("push_gate! not yet implemented for ZXCircuit. Use ZXDiagram for gate operations.")
end

function pushfirst_gate!(circ::ZXCircuit, args...)
    error("pushfirst_gate! not yet implemented for ZXCircuit. Use ZXDiagram for gate operations.")
end
