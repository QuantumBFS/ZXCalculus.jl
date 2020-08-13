export QCircuit, QGate

struct QGate
    name::Symbol
    locs::NTuple{N, Int} where N
    params::NTuple{M, Any} where M
    function QGate(name::Symbol, locs::NTuple{N, Int}, params::NTuple{M, Any} = ()) where {N, M}
        return new(name, locs, params)
    end
end
QGate(name::Symbol, loc::Integer, params::NTuple{M, Any} = ()) where {M} = QGate(name, (Int(loc),), params)

struct QCircuit
    nbits::Int
    gates::Vector{QGate}
end
function QCircuit(n::Integer)
    nbits = Int(n)
    gates = QGate[]
    return QCircuit(nbits, gates)
end

nqubits(qc::QCircuit) = qc.nbits
gates(qc::QCircuit) = qc.gates
gates_count(qc::QCircuit) = length(qc.gates)

function push_gate!(qc::QCircuit, ::Val{:H}, loc::Integer)
    gate = QGate(:H, loc)
    push!(qc.gates, gate)
    return qc
end
function push_gate!(qc::QCircuit, ::Val{:X}, loc::Integer)
    gate = QGate(:X, loc)
    push!(qc.gates, gate)
    return qc
end
function push_gate!(qc::QCircuit, ::Val{:Z}, loc::Integer)
    gate = QGate(:Z, loc)
    push!(qc.gates, gate)
    return qc
end
function push_gate!(qc::QCircuit, ::Val{:T}, loc::Integer)
    gate = QGate(:T, loc)
    push!(qc.gates, gate)
    return qc
end
function push_gate!(qc::QCircuit, ::Val{:S}, loc::Integer)
    gate = QGate(:S, loc)
    push!(qc.gates, gate)
    return qc
end
function push_gate!(qc::QCircuit, ::Val{:shift}, loc::Integer, theta)
    gate = QGate(:shift, loc, (theta, ))
    push!(qc.gates, gate)
    return qc
end
function push_gate!(qc::QCircuit, ::Val{:Rx}, loc::Integer, theta)
    gate = QGate(:Rx, loc, (theta, ))
    push!(qc.gates, gate)
    return qc
end
function push_gate!(qc::QCircuit, ::Val{:Rz}, loc::Integer, theta)
    gate = QGate(:Rz, loc, (theta, ))
    push!(qc.gates, gate)
    return qc
end

function push_ctrl_gate!(qc::QCircuit, ::Val{:CNOT}, loc::Integer, ctrl::Integer)
    gate = QGate(:CNOT, (loc, ctrl))
    push!(qc.gates, gate)
    return qc
end
function push_ctrl_gate!(qc::QCircuit, ::Val{:CZ}, loc::Integer, ctrl::Integer)
    gate = QGate(:CZ, (loc, ctrl))
    push!(qc.gates, gate)
    return qc
end
function push_ctrl_gate!(qc::QCircuit, ::Val{:TOF}, loc::Integer, ctrl1::Integer, ctrl2::Integer)
    gate = QGate(:TOF, (loc, ctrl1, ctrl2))
    push!(qc.gates, gate)
    return qc
end

function pushfirst_gate!(qc::QCircuit, ::Val{:H}, loc::Integer)
    gate = QGate(:H, loc)
    pushfirst!(qc.gates, gate)
    return qc
end
function pushfirst_gate!(qc::QCircuit, ::Val{:X}, loc::Integer)
    gate = QGate(:X, loc)
    pushfirst!(qc.gates, gate)
    return qc
end
function pushfirst_gate!(qc::QCircuit, ::Val{:Z}, loc::Integer)
    gate = QGate(:Z, loc)
    pushfirst!(qc.gates, gate)
    return qc
end
function pushfirst_gate!(qc::QCircuit, ::Val{:T}, loc::Integer)
    gate = QGate(:T, loc)
    pushfirst!(qc.gates, gate)
    return qc
end
function pushfirst_gate!(qc::QCircuit, ::Val{:S}, loc::Integer)
    gate = QGate(:S, loc)
    pushfirst!(qc.gates, gate)
    return qc
end
function pushfirst_gate!(qc::QCircuit, ::Val{:shift}, loc::Integer, theta)
    gate = QGate(:shift, loc, (theta, ))
    pushfirst!(qc.gates, gate)
    return qc
end
function pushfirst_gate!(qc::QCircuit, ::Val{:Rx}, loc::Integer, theta)
    gate = QGate(:Rx, loc, (theta, ))
    pushfirst!(qc.gates, gate)
    return qc
end
function pushfirst_gate!(qc::QCircuit, ::Val{:Rz}, loc::Integer, theta)
    gate = QGate(:Rz, loc, (theta, ))
    pushfirst!(qc.gates, gate)
    return qc
end

function pushfirst_ctrl_gate!(qc::QCircuit, ::Val{:CNOT}, loc::Integer, ctrl::Integer)
    gate = QGate(:CNOT, (loc, ctrl))
    pushfirst!(qc.gates, gate)
    return qc
end
function pushfirst_ctrl_gate!(qc::QCircuit, ::Val{:CZ}, loc::Integer, ctrl::Integer)
    gate = QGate(:CZ, (loc, ctrl))
    pushfirst!(qc.gates, gate)
    return qc
end
function pushfirst_ctrl_gate!(qc::QCircuit, ::Val{:TOF}, loc::Integer, ctrl1::Integer, ctrl2::Integer)
    gate = QGate(:TOF, (loc, ctrl1, ctrl2))
    pushfirst!(qc.gates, gate)
    return qc
end

function ZXDiagram(qc::QCircuit)
    circ = ZXDiagram(nqubits(qc))
    gates = qc.gates
    for gate in gates
        name = gate.name
        locs = gate.locs
        params = gate.params
        if name == :Z
            push_gate!(circ, Val{:Z}(), locs[1], 1//1)
        elseif name == :X
            push_gate!(circ, Val{:X}(), locs[1], 1//1)
        elseif name == :H
            push_gate!(circ, Val{:H}(), locs[1])
        elseif name == :S
            push_gate!(circ, Val{:Z}(), locs[1], 1//2)
        elseif name == :T
            push_gate!(circ, Val{:T}(), locs[1], 1//4)
        elseif name == :shift || name == :Rz
            push_gate!(circ, Val{:Z}(), locs[1], Rational(params[1] / π))
        elseif name == :Rx
            push_gate!(circ, Val{:X}(), locs[1], Rational(params[1] / π))
        elseif name == :CNOT
            push_ctrl_gate!(circ, Val{:CNOT}(), locs...)
        elseif name == :CZ
            push_ctrl_gate!(circ, Val{:CZ}(), locs...)
        elseif name == :TOF
            a, b, c = locs
            push_gate!(circ, Val{:H}(), a)
            push_ctrl_gate!(circ, Val{:CNOT}(), a, c)
            push_gate!(circ, Val{:Z}(), a, 7//4)
            push_ctrl_gate!(circ, Val{:CNOT}(), a, b)
            push_gate!(circ, Val{:Z}(), a, 1//4)
            push_ctrl_gate!(circ, Val{:CNOT}(), a, c)
            push_gate!(circ, Val{:Z}(), a, 7//4)
            push_ctrl_gate!(circ, Val{:CNOT}(), a, b)
            push_gate!(circ, Val{:Z}(), c, 1//4)
            push_gate!(circ, Val{:Z}(), a, 1//4)
            push_gate!(circ, Val{:H}(), a)
            push_ctrl_gate!(circ, Val{:CNOT}(), c, b)
            push_gate!(circ, Val{:Z}(), b, 1//4)
            push_gate!(circ, Val{:Z}(), c, 7//4)
            push_ctrl_gate!(circ, Val{:CNOT}(), c, b)
        end
    end
    return circ
end



function QCircuit(circ::ZXDiagram{T, P}) where {T, P}
    lo = circ.layout
    spider_seq = ZXCalculus.spider_sequence(circ)
    vs = spiders(circ)
    locs = Dict()
    nqubit = lo.nbits
    qc = QCircuit(nqubit)
    frontier_v = ones(T, nqubit)

    while sum([frontier_v[i] <= length(spider_seq[i]) for i = 1:nqubit]) > 0
        for q = 1:nqubit
            if frontier_v[q] <= length(spider_seq[q])
                v = spider_seq[q][frontier_v[q]]
                nb = ZXCalculus.neighbors(circ, v)
                if length(nb) <= 2
                    θ = phase(circ, v) * π
                    if spider_type(circ, v) == ZXCalculus.SpiderType.Z
                        push_gate!(qc, Val{:shift}(), q, θ)
                    elseif spider_type(circ, v) == ZXCalculus.SpiderType.X
                        push_gate!(qc, Val{:Rx}(), q, θ)
                    elseif spider_type(circ, v) == ZXCalculus.SpiderType.H
                        push_gate!(qc, Val{:H}(), q)
                    end

                    frontier_v[q] += 1
                elseif length(nb) == 3
                    v1 = nb[[qubit_loc(lo, u) != q for u in nb]][1]
                    if spider_type(circ, v1) == SpiderType.H
                        v1 = setdiff(ZXCalculus.neighbors(circ, v1), [v])[1]
                    end
                    if sum([findfirst(isequal(u), spider_seq[qubit_loc(lo, u)]) != frontier_v[qubit_loc(lo, u)] for u in [v, v1]]) == 0
                        if phase(circ, v) != 0
                            if spider_type(circ, v) == ZXCalculus.SpiderType.Z
                                push_gate!(qc, Val{:shift}(), qubit_loc(circ, v), phase(circ, v)*π)
                            else
                                push_gate!(qc, Val{:Rx}(), qubit_loc(circ, v), phase(circ, v)*π)
                            end
                        end
                        if phase(circ, v1) != 0
                            if spider_type(circ, v1) == ZXCalculus.SpiderType.Z
                                push_gate!(qc, Val{:shift}(), qubit_loc(circ, v1), phase(circ, v1)*π)
                            else
                                push_gate!(qc, Val{:Rx}(), qubit_loc(circ, v1), phase(circ, v1)*π)
                            end
                        end

                        if spider_type(circ, v) == spider_type(circ, v1) == ZXCalculus.SpiderType.Z
                            push_ctrl_gate!(qc, Val{:CZ}(), qubit_loc(lo, v), qubit_loc(lo, v1))
                        elseif spider_type(circ, v) == ZXCalculus.SpiderType.Z
                            push_ctrl_gate!(qc, Val{:CNOT}(), qubit_loc(lo, v1), qubit_loc(lo, v))
                        elseif spider_type(circ, v) == ZXCalculus.SpiderType.X
                            push_ctrl_gate!(qc, Val{:CNOT}(), qubit_loc(lo, v), qubit_loc(lo, v1))
                        end
                        for u in [v, v1]
                            frontier_v[qubit_loc(lo, u)] += 1
                        end
                    end
                end
            end
        end
    end
    return qc
end
