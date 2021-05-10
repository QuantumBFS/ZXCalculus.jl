function convert_to_zxd(root::YaoHIR.Chain, nqubits::Int)
    circ = ZXDiagram(nqubits)

    for gate in YaoHIR.leaves(root)
        @switch gate begin
            @case Gate(&Z, loc::Locations{Int})
                push_gate!(circ, Val(:Z), plain(loc), 1//1)
            @case Gate(&X, loc::Locations{Int})
                push_gate!(circ, Val(:X), plain(loc), 1//1)
            @case Gate(&H, loc::Locations{Int})
                push_gate!(circ, Val(:H), loc)
            @case Gate(&S, loc::Locations{Int})
                push_gate!(circ, Val(:Z), plain(loc), 1//2)
            @case Gate(&T, loc::Locations{Int})
                push_gate!(circ, Val(:Z), plain(loc), 1//4)
            @case Gate(shift(theta), loc::Locations{Int})
                theta = theta isa Number ? theta : Phase(theta)
                push_gate!(circ, Val(:Z), plain(loc), (1/π)*theta)
            @case Gate(Rx(theta), loc::Locations{Int})
                theta = theta isa Number ? theta : Phase(theta)
                push_gate!(circ, Val(:X), plain(loc), (1/π)*theta)
            @case Gate(Ry(theta), loc::Locations{Int})
                theta = theta isa Number ? theta : Phase(theta)
                push_gate!(circ, Val(:X), plain(loc),  1//2)
                push_gate!(circ, Val(:Z), plain(loc),  (1/π) * theta)
                push_gate!(circ, Val(:X), plain(loc), -1//2)
            @case Gate(Rz(theta), loc::Locations{Int})
                theta = theta isa Number ? theta : Phase(theta)
                push_gate!(circ, Val(:Z), plain(loc), (1/π)*theta)
            @case Gate(AdjointOperation(&S), loc::Locations{Int})
                push_gate!(circ, Val(:Z), plain(loc), 3//2)
            @case Gate(AdjointOperation(&T), loc::Locations{Int})
                push_gate!(circ, Val(:Z), plain(loc), 7//4)
            @case Ctrl(Gate(&X, loc::Locations{Int}), ctrl::CtrlLocations{Int}) # CNOT
                push_gate!(circ, Val(:CNOT), plain(loc), plain(ctrl))
            @case Ctrl(Gate(&Z, loc::Locations{Int}), ctrl::CtrlLocations{Int}) # CZ
                push_gate!(circ, Val(:CZ), plain(loc), plain(ctrl))
            @case _
                error("$gate is not supported")
        end
    end
    return circ
end

function convert_to_block_ir(circ::ZXDiagram{T, P}) where {T, P}
    spider_seq = spider_sequence(circ)
    vs = spiders(circ)
    locs = Dict()
    nqubit = nqubits(circ)
    qc = []
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
                            push!(qc, Gate(Z, Locations(q)))
                        elseif phase(circ, v) == 1//2
                            push!(qc, Gate(S, Locations(q)))
                        elseif phase(circ, v) == 3//2
                            push!(qc, Gate(AdjointOperation(S), Locations(q)))
                        elseif phase(circ, v) == 1//4
                            push!(qc, Gate(T, Locations(q)))
                        elseif phase(circ, v) == 7//4
                            push!(qc, Gate(AdjointOperation(T), Locations(q)))
                        elseif phase(circ, v) != 0
                            if θ isa Phase
                                θ = θ.ex
                            end
                            push!(qc, Gate(shift(θ), Locations(q)))
                        end
                    elseif spider_type(circ, v) == ZXCalculus.SpiderType.X
                        if phase(circ, v) == 1
                            push!(qc, Gate(X, Locations(q)))
                        else phase(circ, v) != 0
                            if θ isa Phase
                                θ = θ.ex
                            end
                            push!(qc, Gate(Rx(θ), Locations(q)))
                        end
                    elseif spider_type(circ, v) == ZXCalculus.SpiderType.H
                        push!(qc, Gate(H, Locations(q)))
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
                                    push!(qc, Gate(Z, Locations(qubit_loc(circ, v))))
                                elseif phase(circ, v) == 1//2
                                    push!(qc, Gate(S, Locations(qubit_loc(circ, v))))
                                elseif phase(circ, v) == 3//2
                                    push!(qc, Gate(S', Locations(qubit_loc(circ, v))))
                                elseif phase(circ, v) == 1//4
                                    push!(qc, Gate(T, Locations(qubit_loc(circ, v))))
                                elseif phase(circ, v) == 7//4
                                    push!(qc, GatE(T', Locations(qubit_loc(circ, v))))
                                else
                                    θ = phase(circ, v)*π
                                    if θ isa Phase
                                        θ = θ.ex
                                    end
                                    push!(qc, Gate(shift(θ), Locations(qubit_loc(circ, v))))
                                end
                            else
                                if phase(circ, v) == 1
                                    push!(qc, Gate(X, Locations(qubit_loc(circ, v))))
                                else
                                    θ = phase(circ, v)*π
                                    if θ isa Phase
                                        θ = θ.ex
                                    end
                                    push!(qc, Gate(Rx(θ), Locations(qubit_loc(circ, v))))
                                end
                            end
                        end
                        if phase(circ, v1) != 0
                            if spider_type(circ, v1) == ZXCalculus.SpiderType.Z
                                if phase(circ, v1) == 1
                                    push!(qc, Gate(Z, Locations(qubit_loc(circ, v1))))
                                elseif phase(circ, v1) == 1//2
                                    push!(qc, Gate(S, Locations(qubit_loc(circ, v1))))
                                elseif phase(circ, v1) == 3//2
                                    push!(qc, Gate(S', Locations(qubit_loc(circ, v1))))
                                elseif phase(circ, v1) == 1//4
                                    push!(qc, Gate(T, Locations(qubit_loc(circ, v1))))
                                elseif phase(circ, v1) == 7//4
                                    push!(qc, Gate(T', Locations(qubit_loc(circ, v1))))
                                else
                                    θ = phase(circ, v1)*π
                                    if θ isa Phase
                                        θ = θ.ex
                                    end
                                    push!(qc, Gate(shift(θ), Locations(qubit_loc(circ, v1))))
                                end
                            else
                                if phase(circ, v1) == 1
                                    push!(qc, Gate(X, Locations(qubit_loc(circ, v1))))
                                else
                                    θ = phase(circ, v1)*π
                                    if θ isa Phase
                                        θ = θ.ex
                                    end
                                    push!(qc, Gate(Rx(θ), Locations(qubit_loc(circ, v1))))
                                end
                            end
                        end

                        if spider_type(circ, v) == spider_type(circ, v1) == ZXCalculus.SpiderType.Z
                            push!(qc, Ctrl(Gate(Z, Locations(qubit_loc(circ, v))), CtrlLocations(qubit_loc(circ, v1))))
                        elseif spider_type(circ, v) == ZXCalculus.SpiderType.Z
                            push!(qc, Ctrl(Gate(X, Locations(qubit_loc(circ, v1))), CtrlLocations(qubit_loc(circ, v))))
                        elseif spider_type(circ, v) == ZXCalculus.SpiderType.X
                            push!(qc, Ctrl(Gate(X, Locations(qubit_loc(circ, v))), CtrlLocations(qubit_loc(circ, v1))))
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
