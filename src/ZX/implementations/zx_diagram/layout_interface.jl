# Layout Interface Implementation for ZXDiagram

qubit_loc(zxd::ZXDiagram{T, P}, v::T) where {T, P} = qubit_loc(zxd.layout, v)

function column_loc(zxd::ZXDiagram{T, P}, v::T) where {T, P}
    c_loc = column_loc(zxd.layout, v)
    return c_loc
end

function spider_sequence(zxd::ZXDiagram{T, P}) where {T, P}
    seq = []
    generate_layout!(zxd, seq)
    return seq
end

function generate_layout!(zxd::ZXDiagram{T, P}, seq::Vector{Any}=[]) where {T, P}
    layout = zxd.layout
    nbits = length(zxd.inputs)
    vs_frontier = copy(zxd.inputs)
    vs_generated = Set(vs_frontier)
    frontier_col = [1//1 for _ in 1:nbits]
    frontier_active = [true for _ in 1:nbits]
    for i in 1:nbits
        set_qubit!(layout, vs_frontier[i], i)
        set_column!(layout, vs_frontier[i], 1//1)
    end

    while !(zxd.outputs ⊆ vs_frontier)
        while any(frontier_active)
            for q in 1:nbits
                if frontier_active[q]
                    v = vs_frontier[q]
                    nb = neighbors(zxd, v)
                    if length(nb) <= 2
                        set_loc!(layout, v, q, frontier_col[q])
                        push!(seq, v)
                        push!(vs_generated, v)
                        q_active = false
                        for v1 in nb
                            if !(v1 in vs_generated)
                                vs_frontier[q] = v1
                                frontier_col[q] += 1
                                q_active = true
                                break
                            end
                        end
                        frontier_active[q] = q_active
                    else
                        frontier_active[q] = false
                    end
                end
            end
        end
        for q in 1:nbits
            v = vs_frontier[q]
            nb = neighbors(zxd, v)
            isupdated = false
            for v1 in nb
                if !(v1 in vs_generated)
                    q1 = findfirst(isequal(v1), vs_frontier)
                    if !isnothing(q1)
                        col = maximum(frontier_col[min(q, q1):max(q, q1)])
                        set_loc!(layout, v, q, col)
                        set_loc!(layout, v1, q1, col)
                        push!(vs_generated, v, v1)
                        push!(seq, (v, v1))
                        nb_v1 = neighbors(zxd, v1)
                        new_v1 = nb_v1[findfirst(v -> !(v in vs_generated), nb_v1)]
                        new_v = nb[findfirst(v -> !(v in vs_generated), nb)]
                        vs_frontier[q] = new_v
                        vs_frontier[q1] = new_v1
                        for i in min(q, q1):max(q, q1)
                            frontier_col[i] = col + 1
                        end
                        frontier_active[q] = true
                        frontier_active[q1] = true
                        isupdated = true
                        break
                    elseif spider_type(zxd, v1) == SpiderType.H && degree(zxd, v1) == 2
                        nb_v1 = neighbors(zxd, v1)
                        v2 = nb_v1[findfirst(!isequal(v), nb_v1)]
                        q2 = findfirst(isequal(v2), vs_frontier)
                        if !isnothing(q2)
                            col = maximum(frontier_col[min(q, q2):max(q, q2)])
                            set_loc!(layout, v, q, col)
                            set_loc!(layout, v2, q2, col)
                            q1 = (q + q2)//2
                            denominator(q1) == 1 && (q1 += 1//2)
                            set_loc!(layout, v1, q1, col)
                            push!(vs_generated, v, v1, v2)
                            push!(seq, (v, v1, v2))
                            nb_v2 = neighbors(zxd, v2)
                            new_v = nb[findfirst(v -> !(v in vs_generated), nb)]
                            new_v2 = nb_v2[findfirst(v -> !(v in vs_generated), nb_v2)]
                            vs_frontier[q] = new_v
                            vs_frontier[q2] = new_v2
                            for i in min(q, q2):max(q, q2)
                                frontier_col[i] = col + 1
                            end
                            frontier_active[q] = true
                            frontier_active[q2] = true
                            isupdated = true
                            break
                        end
                    end
                end
                isupdated && break
            end
        end
    end
    for q in 1:length(zxd.outputs)
        set_loc!(layout, zxd.outputs[q], q, maximum(frontier_col))
    end
    return layout
end

"""
    get_output_idx(zxd::ZXDiagram{T,P}, q::T) where {T,P}

Get spider index of output qubit q. Returns -1 is non-existant
"""
function get_output_idx(zxd::ZXDiagram{T, P}, q::T) where {T, P}
    for v in get_outputs(zxd)
        if spider_type(zxd, v) == SpiderType.Out && Int(qubit_loc(zxd, v)) == q
            res = v
        else
            res = nothing
        end

        !isnothing(res) && return res
    end
    return -1
end

"""
    get_input_idx(zwd::ZXDiagram{T,P}, q::T) where {T,P}

Get spider index of input qubit q. Returns -1 if non-existant
"""
function get_input_idx(zxd::ZXDiagram{T, P}, q::T) where {T, P}
    for v in get_inputs(zxd)
        if spider_type(zxd, v) == SpiderType.In && Int(qubit_loc(zxd, v)) == q
            res = v
        else
            res = nothing
        end

        !isnothing(res) && return res
    end
    return -1
end
