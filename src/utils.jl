"""
    round_phases!(zxwd)

Round phases between [0, 2π).
"""
function round_phases!(zxwd::ZXWDiagram{T}) where {T<:Integer}
    st = zxwd.st
    for v in keys(st)
        st[v] = @match st[v] begin
            Z(p) => Z(_round_phase(p))
            X(p) => X(_round_phase(p))
            _ => st[v]
        end
    end
    return
end

function _round_phase(p::Parameter)
    @match p begin
        PiUnit(_...) => rem(rem(p, 2) + 2, 2)
        _ => p
    end
end

"""
    spider_type(zxwd, v)

Returns the spider type of a spider if it exists.
"""
function spider_type(zxwd::ZXWDiagram{T}, v::T) where {T<:Integer}
    if has_vertex(zxwd.mg, v)
        return zxwd.st[v]
    else
        error("Spider $v does not exist!")
    end
end

"""
    parameter(zxwd, v)

Returns the parameter of a spider. If the spider is not a Z or X spider, then return 0.
"""
function parameter(zxwd::ZXWDiagram{T}, v::T) where {T<:Integer}
    @match spider_type(zxwd, v) begin
        Z(p) => p
        X(p) => p
        Input(_) || Output(_) => error("Input and outputs doesn't have valid parameter")
        _ => PiUnit(0, Int64)
    end
end

"""
    set_phase!(zxwd, v, p)

Set the phase of `v` in `zxwd` to `p`. If `v` is not a Z or X spider, then do nothing.
If `v` is not in `zxwd`, then return false to indicate failure.
"""
function set_phase!(zxwd::ZXWDiagram{T}, v::T, p::Parameter) where {T}
    if has_vertex(zxwd.mg, v)
        zxwd.st[v] = @match zxwd.st[v] begin
            Z(_) => Z(_round_phase(p))
            X(_) => X(_round_phase(p))
            _ => zxwd.st[v]
        end
        return true
    end
    return false
end

"""
    nqubits(zxwd)

Returns the qubit number of a ZXW-diagram.
"""
nqubits(zxwd::ZXWDiagram{T}) where {T} = length(zxwd.inputs)

"""
    nin(zxwd)
Returns the number of inputs of a ZXW-diagram.
"""

nin(zxwd::ZXWDiagram{T}) where {T} = sum([@match spy begin
    Input(_) => 1
    _ => 0
end for spy in values(zxwd.st)])


"""
    nout(zxwd)
Returns the number of outputs of a ZXW-diagram
"""
nout(zxwd::ZXWDiagram{T}) where {T} = sum([@match spy begin
    Output(_) => 1
    _ => 0
end for spy in values(zxwd.st)])

"""
    print_spider(io, zxwd, v)

Print a spider to `io`.
"""
function print_spider(io::IO, zxwd::ZXWDiagram{T}, v::T) where {T<:Integer}
    @match zxwd.st[v] begin
        Z(p) => printstyled(io, "S_$(v){phase = $(p)}"; color = :green)
        X(p) => printstyled(io, "S_$(v){phase = $(p)}"; color = :red)
        Input(q) => printstyled(io, "S_$(v){input = $(q)}"; color = :blue)
        Output(q) => printstyled(io, "S_$(v){output = $(q)}"; color = :blue)
        H => printstyled(io, "S_$(v){H}"; color = :yellow)
        W => printstyled(io, "S_$(v){W}"; color = :black)
        D => printstyled(io, "S_$(v){D}"; color = :magenta)
        _ => print(io, "S_$(v)")
    end
end


function Base.show(io::IO, zxwd::ZXWDiagram{T}) where {T<:Integer}
    println(
        io,
        "$(typeof(zxwd)) with $(nv(zxwd.mg)) vertices and $(ne(zxwd.mg)) multiple edges:",
    )
    for v1 in sort!(vertices(zxwd.mg))
        for v2 in neighbors(zxwd.mg, v1)
            if v2 >= v1
                print(io, "(")
                print_spider(io, zxwd, v1)
                print(io, " <-$(mul(zxwd.mg, v1, v2))-> ")
                print_spider(io, zxwd, v2)
                print(io, ")\n")
            end
        end
    end
end


"""
    nv(zxwd)

Returns the number of vertices (spiders) of a ZXW-diagram.
"""
Graphs.nv(zxwd::ZXWDiagram) = nv(zxwd.mg)

"""
    ne(zxwd; count_mul = false)

Returns the number of edges of a ZXW-diagram. If `count_mul`, it will return the
sum of multiplicities of all multiple edges. Otherwise, it will return the
number of multiple edges.
"""
Graphs.ne(zxwd::ZXWDiagram; count_mul::Bool = false) = ne(zxwd.mg, count_mul = count_mul)

Graphs.outneighbors(zxwd::ZXWDiagram, v; count_mul::Bool = false) =
    outneighbors(zxwd.mg, v, count_mul = count_mul)
Graphs.inneighbors(zxwd::ZXWDiagram, v; count_mul::Bool = false) =
    inneighbors(zxwd.mg, v, count_mul = count_mul)
Graphs.degree(zxwd::ZXWDiagram, v::Integer) = degree(zxwd.mg, v)
Graphs.indegree(zxwd::ZXWDiagram, v::Integer) = degree(zxwd, v)
Graphs.outdegree(zxwd::ZXWDiagram, v::Integer) = degree(zxwd, v)

"""
    neighbors(zxwd, v; count_mul = false)

Returns a vector of vertices connected to `v`. If `count_mul`, there will be
multiple copy for each vertex. Otherwise, each vertex will only appear once.
"""
Graphs.neighbors(zxwd::ZXWDiagram, v; count_mul::Bool = false) =
    neighbors(zxwd.mg, v, count_mul = count_mul)
function Graphs.rem_edge!(zxwd::ZXWDiagram, x...)
    rem_edge!(zxwd.mg, x...)
end
function Graphs.add_edge!(zxwd::ZXWDiagram, x...)
    add_edge!(zxwd.mg, x...)
end

"""
    rem_spiders!(zxwd, vs)

Remove spiders indexed by `vs`.
"""
function rem_spiders!(zxwd::ZXWDiagram{T}, vs::Vector{T}) where {T<:Integer}
    if rem_vertices!(zxwd.mg, vs)
        for v in vs
            delete!(zxwd.st, v)
        end
        return true
    end
    return false
end

"""
    rem_spider!(zxwd, v)

Remove a spider indexed by `v`.
"""
rem_spider!(zxwd::ZXWDiagram{T}, v::T) where {T<:Integer} = rem_spiders!(zxwd, [v])

"""
    add_spider!(zxwd, spider, connect = [])

Add a new spider `spider` with appropriate parameter
connected to the vertices `connect`. """
function add_spider!(
    zxwd::ZXWDiagram{T},
    spider::ZXWSpiderType,
    connect::Vector{T} = T[],
) where {T<:Integer}
    if any(!has_vertex(zxwd.mg, c) for c in connect)
        error("The vertex to connect does not exist.")
    end

    v = add_vertex!(zxwd.mg)[1]
    zxwd.st[v] = spider

    for c in connect
        add_edge!(zxwd.mg, v, c)
    end

    return v
end

"""
    insert_spider!(zxwd, v1, v2, spider)

Insert a spider `spider` with appropriate parameter, between two
vertices `v1` and `v2`. It will insert multiple times if the edge between
`v1` and `v2` is a multiple edge. Also it will remove the original edge between
`v1` and `v2`.
"""
function insert_spider!(
    zxwd::ZXWDiagram{T},
    v1::T,
    v2::T,
    spider::ZXWSpiderType,
) where {T<:Integer}
    mt = mul(zxwd.mg, v1, v2)
    vs = Vector{T}(undef, mt)
    for i = 1:mt
        v = add_spider!(zxwd, spider, [v1, v2])
        @inbounds vs[i] = v
        rem_edge!(zxwd, v1, v2)
    end
    return vs
end

spiders(zxwd::ZXWDiagram) = vertices(zxwd.mg)
scalar(zxwd::ZXWDiagram) = zxwd.scalar

# """
#     push_gate!(zxwd, ::Val{M}, locs...[, phase]; autoconvert=true)

# Push an `M` gate to the end of qubit `loc` where `M` can be `:Z`, `:X`, `:H`, `:SWAP`, `:CNOT` and `:CZ`.
# If `M` is `:Z` or `:X`, `phase` will be available and it will push a
# rotation `M` gate with angle `phase * π`.
# If `autoconvert` is `false`, the input `phase` should be a rational numbers.
# """
# function push_gate!(
#     zxwd::ZXWDiagram{T},
#     ::Val{:Z},
#     loc::T,
#     phase = zero(P);
#     autoconvert::Bool = true,
# ) where {T}
#     @inbounds out_id = get_outputs(zxwd)[loc]
#     @inbounds bound_id = neighbors(zxwd, out_id)[1]
#     rphase = autoconvert ? safe_convert(P, phase) : phase
#     insert_spider!(zxwd, bound_id, out_id, ZXWSpiderType.Z, rphase)
#     return zxwd
# end

# function push_gate!(
#     zxwd::ZXWDiagram{T},
#     ::Val{:X},
#     loc::T,
#     phase = zero(P);
#     autoconvert::Bool = true,
# ) where {T}
#     @inbounds out_id = get_outputs(zxwd)[loc]
#     @inbounds bound_id = neighbors(zxwd, out_id)[1]
#     rphase = autoconvert ? safe_convert(P, phase) : phase
#     insert_spider!(zxwd, bound_id, out_id, ZXWSpiderType.X, rphase)
#     return zxwd
# end

# function push_gate!(zxwd::ZXWDiagram{T}, ::Val{:H}, loc::T) where {T}
#     @inbounds out_id = get_outputs(zxwd)[loc]
#     @inbounds bound_id = neighbors(zxwd, out_id)[1]
#     insert_spider!(zxwd, bound_id, out_id, ZXWSpiderType.H)
#     return zxwd
# end

# function push_gate!(zxwd::ZXWDiagram{T}, ::Val{:SWAP}, locs::Vector{T}) where {T}
#     q1, q2 = locs
#     push_gate!(zxwd, Val{:Z}(), q1)
#     push_gate!(zxwd, Val{:Z}(), q2)
#     push_gate!(zxwd, Val{:Z}(), q1)
#     push_gate!(zxwd, Val{:Z}(), q2)
#     v1, v2, bound_id1, bound_id2 = (sort!(spiders(zxwd)))[end-3:end]
#     rem_edge!(zxwd, v1, bound_id1)
#     rem_edge!(zxwd, v2, bound_id2)
#     add_edge!(zxwd, v1, bound_id2)
#     add_edge!(zxwd, v2, bound_id1)
#     return zxwd
# end

# function push_gate!(zxwd::ZXWDiagram{T}, ::Val{:CNOT}, loc::T, ctrl::T) where {T}
#     push_gate!(zxwd, Val{:Z}(), ctrl)
#     push_gate!(zxwd, Val{:X}(), loc)
#     @inbounds v1, v2 = (sort!(spiders(zxwd)))[end-1:end]
#     add_edge!(zxwd, v1, v2)
#     add_power!(zxwd, 1)
#     return zxwd
# end

# function push_gate!(zxwd::ZXWDiagram{T}, ::Val{:CZ}, loc::T, ctrl::T) where {T}
#     push_gate!(zxwd, Val{:Z}(), ctrl)
#     push_gate!(zxwd, Val{:Z}(), loc)
#     @inbounds v1, v2 = (sort!(spiders(zxwd)))[end-1:end]
#     add_edge!(zxwd, v1, v2)
#     insert_spider!(zxwd, v1, v2, ZXWSpiderType.H)
#     add_power!(zxwd, 1)
#     return zxwd
# end

# """
#     pushfirst_gate!(zxwd, ::Val{M}, loc[, phase])

# Push an `M` gate to the beginning of qubit `loc` where `M` can be `:Z`, `:X`, `:H`, `:SWAP`, `:CNOT` and `:CZ`.
# If `M` is `:Z` or `:X`, `phase` will be available and it will push a
# rotation `M` gate with angle `phase * π`.
# """
# function pushfirst_gate!(
#     zxwd::ZXWDiagram{T},
#     ::Val{:Z},
#     loc::T,
#     phase::P = zero(P),
# ) where {T}
#     @inbounds in_id = get_inputs(zxwd)[loc]
#     @inbounds bound_id = neighbors(zxwd, in_id)[1]
#     insert_spider!(zxwd, in_id, bound_id, ZXWSpiderType.Z, phase)
#     return zxwd
# end

# function pushfirst_gate!(
#     zxwd::ZXWDiagram{T},
#     ::Val{:X},
#     loc::T,
#     phase::P = zero(P),
# ) where {T}
#     @inbounds in_id = get_inputs(zxwd)[loc]
#     @inbounds bound_id = neighbors(zxwd, in_id)[1]
#     insert_spider!(zxwd, in_id, bound_id, ZXWSpiderType.X, phase)
#     return zxwd
# end

# function pushfirst_gate!(zxwd::ZXWDiagram{T}, ::Val{:H}, loc::T) where {T}
#     @inbounds in_id = get_inputs(zxwd)[loc]
#     @inbounds bound_id = neighbors(zxwd, in_id)[1]
#     insert_spider!(zxwd, in_id, bound_id, ZXWSpiderType.H)
#     return zxwd
# end

# function pushfirst_gate!(zxwd::ZXWDiagram{T}, ::Val{:SWAP}, locs::Vector{T}) where {T}
#     q1, q2 = locs
#     pushfirst_gate!(zxwd, Val{:Z}(), q1)
#     pushfirst_gate!(zxwd, Val{:Z}(), q2)
#     pushfirst_gate!(zxwd, Val{:Z}(), q1)
#     pushfirst_gate!(zxwd, Val{:Z}(), q2)
#     @inbounds v1, v2, bound_id1, bound_id2 = (sort!(spiders(zxwd)))[end-3:end]
#     rem_edge!(zxwd, v1, bound_id1)
#     rem_edge!(zxwd, v2, bound_id2)
#     add_edge!(zxwd, v1, bound_id2)
#     add_edge!(zxwd, v2, bound_id1)
#     return zxwd
# end

# function pushfirst_gate!(zxwd::ZXWDiagram{T}, ::Val{:CNOT}, loc::T, ctrl::T) where {T}
#     pushfirst_gate!(zxwd, Val{:Z}(), ctrl)
#     pushfirst_gate!(zxwd, Val{:X}(), loc)
#     @inbounds v1, v2 = (sort!(spiders(zxwd)))[end-1:end]
#     add_edge!(zxwd, v1, v2)
#     add_power!(zxwd, 1)
#     return zxwd
# end

# function pushfirst_gate!(zxwd::ZXWDiagram{T}, ::Val{:CZ}, loc::T, ctrl::T) where {T}
#     pushfirst_gate!(zxwd, Val{:Z}(), ctrl)
#     pushfirst_gate!(zxwd, Val{:Z}(), loc)
#     @inbounds v1, v2 = (sort!(spiders(zxwd)))[end-1:end]
#     add_edge!(zxwd, v1, v2)
#     insert_spider!(zxwd, v1, v2, ZXWSpiderType.H)
#     add_power!(zxwd, 1)
#     return zxwd
# end
