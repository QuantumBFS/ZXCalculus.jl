import Base: show, vcat, hcat, adjoint, getindex
export QCircuit, QGate, random_circuit, gates, gate_count

struct QGate
    name::Symbol
    loc::Int
    ctrl::Int
    param
end
QGate(name::Symbol, loc::Integer; ctrl::Int = 0, param = nothing) = QGate(name, loc, ctrl, param)
QGate(::Val{:X}, loc) = QGate(:X, loc)
QGate(::Val{:Z}, loc) = QGate(:Z, loc)
QGate(::Val{:H}, loc) = QGate(:H, loc)
QGate(::Val{:S}, loc) = QGate(:S, loc)
QGate(::Val{:Sdag}, loc) = QGate(:Sdag, loc)
QGate(::Val{:T}, loc) = QGate(:T, loc)
QGate(::Val{:Tdag}, loc) = QGate(:Tdag, loc)
QGate(::Val{:shift}, loc, theta) = QGate(:shift, loc; param = theta)
QGate(::Val{:Rz}, loc, theta) = QGate(:Rz, loc; param = theta)
QGate(::Val{:Rx}, loc, theta) = QGate(:Rx, loc; param = theta)
QGate(::Val{:CNOT}, loc, ctrl) = QGate(:CNOT, loc; ctrl = ctrl)
QGate(::Val{:CZ}, loc, ctrl) = QGate(:CZ, loc; ctrl = ctrl)

function adjoint(g::QGate)
    g.name in (:X, :Z, :H, :CNOT, :CZ) && return g
    g.name === :S && return QGate(Val(:Sdag), g.loc)
    g.name === :Sdag && return QGate(Val(:S), g.loc)
    g.name === :T && return QGate(Val(:Tdag), g.loc)
    g.name === :Tdag && return QGate(Val(:T), g.loc)
    g.name in (:shift, :Rz, :Rx) && return QGate(g.name, g.loc; param = -g.param)
end

function show(io::IO, g::QGate)
    if g.ctrl == 0
        if g.param === nothing
            print(io, g.name, " on ($(g.loc))")
        else
            print(io, g.name, "($(g.param)) on ($(g.loc))")
        end
    else
        print(io, g.name, " on ($(g.loc)) with control on ($(g.ctrl))")
    end
end

mutable struct QCircuit
    nbits::Int
    gates::Vector{QGate}
end
function QCircuit(n::Integer)
    n <= 0 && error("The number of qubits should be positive")
    nbits = Int(n)
    gates = QGate[]
    return QCircuit(nbits, gates)
end

function show(io::IO, qc::QCircuit)
    println(io, "Quantum circuit of $(nqubits(qc)) qubits with $(gate_count(qc)) gates:")
    for g in gates(qc)
        println(io, "  ", g)
    end
end

function vcat(qcs::QCircuit...)
    n = nqubits(qcs[1])
    nqc = QCircuit(n)
    for qc in qcs
        n == nqubits(qc) || error("Can not catenate quantum circuits with different qubit numbers")
        nqc.gates = [gates(nqc); gates(qc)]
    end
    return nqc
end
hcat(qcs::QCircuit...) = vcat(qcs...)

function adjoint(qc::QCircuit)
    adj_qc = QCircuit(nqubits(qc))
    for i = gate_count(qc):-1:1
        push_gate!(adj_qc, qc.gates[i]')
    end
    return adj_qc
end

function getindex(qc::QCircuit, i...)
    n = nqubits(qc)
    return QCircuit(n, gates(qc)[i...])
end

nqubits(qc::QCircuit) = qc.nbits
gates(qc::QCircuit) = qc.gates
gate_count(qc::QCircuit) = length(qc.gates)
function tcount(qc::QCircuit)
    tc = 0
    for g in gates(qc)
        if g.name ∈ (:T, :Tdag)
            tc += 1
        elseif g.name ∈ (:shift, :Rx)
            if rem(Rational(g.param/π), 1//2) != 0
                tc += 1
            end
        end
    end
    return tc
end

function push_gate!(qc::QCircuit, gate::QGate)
    push!(qc.gates, gate)
    return qc
end
push_gate!(qc::QCircuit, gargs...) = push_gate!(qc, QGate(gargs...))

function pushfirst_gate!(qc::QCircuit, gate::QGate)
    pushfirst!(qc.gates, gate)
    return qc
end
pushfirst_gate!(qc::QCircuit, gargs...) = pushfirst_gate!(qc, QGate(gargs...))

function random_circuit(nbits, ngates, cnot_per = 0.2, t_per = 0.1)
    qc = QCircuit(nbits)
    for _ = 1:ngates
        r = rand()
        if nbits <= 1
            r *= (1 - cnot_per)
        end
        if r < 1 - (cnot_per + t_per)
            name = rand([:X, :Z, :H, :S])
            if name == :S
                name = rand([:S, :Sdag])
            end
            push_gate!(qc, Val(name), rand(1:nbits))
        elseif r < 1 - cnot_per
            name = rand([:T, :Tdag])
            push_gate!(qc, Val(name), rand(1:nbits))
        else
            name = rand([:CNOT, :CZ])
            loc = rand(1:nbits)
            ctrl = rand(1:nbits)
            while ctrl == loc
                ctrl = rand(1:nbits)
            end
            push_gate!(qc, Val(name), loc, ctrl)
        end
    end
    return qc
end

function ZXDiagram(qc::QCircuit)
    circ = ZXDiagram(nqubits(qc))
    gates = qc.gates
    for gate in gates
        name = gate.name
        loc = gate.loc
        theta = gate.param
        if name == :Z
            push_gate!(circ, Val(:Z), loc, 1//1)
        elseif name == :X
            push_gate!(circ, Val(:X), loc, 1//1)
        elseif name == :H
            push_gate!(circ, Val(:H), loc)
        elseif name == :S
            push_gate!(circ, Val(:Z), loc, 1//2)
        elseif name == :Sdag
            push_gate!(circ, Val(:Z), loc, 3//2)
        elseif name == :T
            push_gate!(circ, Val(:Z), loc, 1//4)
        elseif name == :Tdag
            push_gate!(circ, Val(:Z), loc, 7//4)
        elseif name == :shift
            push_gate!(circ, Val(:Z), loc, theta/π)
        elseif name == :Rz
            push_gate!(circ, Val(:Z), loc, theta/π)
        elseif name == :Rx
            push_gate!(circ, Val(:X), loc, theta/π)
        elseif name == :CNOT
            push_gate!(circ, Val(:CNOT), loc, gate.ctrl)
        elseif name == :CZ
            push_gate!(circ, Val(:CZ), loc, gate.ctrl)
        end
    end
    return circ
end

function QCircuit(circ::ZXDiagram{T, P}) where {T, P}
    spider_seq = ZXCalculus.spider_sequence(circ)
    vs = spiders(circ)
    locs = Dict()
    nqubit = nqubits(circ)
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
                        if phase(circ, v) == 1
                            push_gate!(qc, Val(:Z), q)
                        elseif phase(circ, v) == 1//2
                            push_gate!(qc, Val(:S), q)
                        elseif phase(circ, v) == 3//2
                            push_gate!(qc, Val(:Sdag), q)
                        elseif phase(circ, v) == 1//4
                            push_gate!(qc, Val(:T), q)
                        elseif phase(circ, v) == 7//4
                            push_gate!(qc, Val(:Tdag), q)
                        elseif phase(circ, v) != 0
                            push_gate!(qc, Val(:shift), q, θ)
                        end
                    elseif spider_type(circ, v) == ZXCalculus.SpiderType.X
                        if phase(circ, v) == 1
                            push_gate!(qc, Val(:X), q)
                        else phase(circ, v) != 0
                            push_gate!(qc, Val(:Rx), q, θ)
                        end    
                    elseif spider_type(circ, v) == ZXCalculus.SpiderType.H
                        push_gate!(qc, Val(:H), q)
                    end

                    frontier_v[q] += 1
                elseif length(nb) == 3
                    v1 = nb[[qubit_loc(circ, u) != q for u in nb]][1]
                    if spider_type(circ, v1) == SpiderType.H
                        v1 = setdiff(ZXCalculus.neighbors(circ, v1), [v])[1]
                    end
                    if sum([findfirst(isequal(u), spider_seq[qubit_loc(circ, u)]) != frontier_v[qubit_loc(circ, u)] for u in [v, v1]]) == 0
                        if phase(circ, v) != 0
                            if spider_type(circ, v) == ZXCalculus.SpiderType.Z
                                if phase(circ, v) == 1
                                    push_gate!(qc, Val(:Z), qubit_loc(circ, v))
                                elseif phase(circ, v) == 1//2
                                    push_gate!(qc, Val(:S), qubit_loc(circ, v))
                                elseif phase(circ, v) == 3//2
                                    push_gate!(qc, Val(:Sdag), qubit_loc(circ, v))
                                elseif phase(circ, v) == 1//4
                                    push_gate!(qc, Val(:T), qubit_loc(circ, v))
                                elseif phase(circ, v) == 7//4
                                    push_gate!(qc, Val(:Tdag), qubit_loc(circ, v))
                                else        
                                    push_gate!(qc, Val(:shift), qubit_loc(circ, v), phase(circ, v)*π)
                                end
                            else
                                if phase(circ, v) == 1
                                    push_gate!(qc, Val(:X), qubit_loc(circ, v))
                                else
                                    push_gate!(qc, Val(:Rx), qubit_loc(circ, v), phase(circ, v)*π)
                                end
                            end
                        end
                        if phase(circ, v1) != 0
                            if spider_type(circ, v1) == ZXCalculus.SpiderType.Z
                                if phase(circ, v1) == 1
                                    push_gate!(qc, Val(:Z), qubit_loc(circ, v1))
                                elseif phase(circ, v1) == 1//2
                                    push_gate!(qc, Val(:S), qubit_loc(circ, v1))
                                elseif phase(circ, v1) == 3//2
                                    push_gate!(qc, Val(:Sdag), qubit_loc(circ, v1))
                                elseif phase(circ, v1) == 1//4
                                    push_gate!(qc, Val(:T), qubit_loc(circ, v1))
                                elseif phase(circ, v1) == 7//4
                                    push_gate!(qc, Val(:Tdag), qubit_loc(circ, v1))
                                else        
                                    push_gate!(qc, Val(:shift), qubit_loc(circ, v1), phase(circ, v1)*π)
                                end
                            else
                                if phase(circ, v1) == 1
                                    push_gate!(qc, Val(:X), qubit_loc(circ, v1))
                                else
                                    push_gate!(qc, Val(:Rx), qubit_loc(circ, v1), phase(circ, v1)*π)
                                end
                            end
                        end

                        if spider_type(circ, v) == spider_type(circ, v1) == ZXCalculus.SpiderType.Z
                            push_gate!(qc, Val(:CZ), qubit_loc(circ, v), qubit_loc(circ, v1))
                        elseif spider_type(circ, v) == ZXCalculus.SpiderType.Z
                            push_gate!(qc, Val(:CNOT), qubit_loc(circ, v1), qubit_loc(circ, v))
                        elseif spider_type(circ, v) == ZXCalculus.SpiderType.X
                            push_gate!(qc, Val(:CNOT), qubit_loc(circ, v), qubit_loc(circ, v1))
                        end
                        for u in [v, v1]
                            frontier_v[qubit_loc(circ, u)] += 1
                        end
                    end
                else
                    error("ZX-diagram without a circuit structure is not supported!")
                end
            end
        end
    end
    return qc
end
