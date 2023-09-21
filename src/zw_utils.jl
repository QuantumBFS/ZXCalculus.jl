"""
    round_phases!(zwd)

Round phases between [0, 2π).
"""
function round_phases!(zwd::ZWDiagram{T,P}) where {T<:Integer,P}
    st = zwd.st
    for v in keys(st)
        st[v] = @match st[v] begin
            binZ(p) => binZ(_round_phase(p))
            monoZ(p) => monoZ(_round_phase(p))
            _ => st[v]
        end
    end
    return
end

"""
    spider_type(zwd, v)

Returns the spider type of a spider if it exists.
"""
function spider_type(zwd::ZWDiagram{T,P}, v::T) where {T<:Integer,P}
    if has_vertex(zwd.pmg, v)
        return zwd.st[v]
    else
        error("Spider $v does not exist!")
    end
end

"""
    parameter(zwd, v)

Returns the parameter of a spider. If the spider is not a monoZ or binZ spider, then return 0.
"""
function parameter(zwd::ZWDiagram{T,P}, v::T) where {T<:Integer,P}
    @match spider_type(zwd, v) begin
        binZ(p) => p
        monoZ(p) => p
        Input(q) || Output(q) => q
        _ => Parameter(Val(:PiUnit), 0)
    end
end

"""
    set_phase!(zwd, v, p)

Set the phase of `v` in `zwd` to `p`. If `v` is not a monoZ or binZ spider, then do nothing.
If `v` is not in `zwd`, then return false to indicate failure.
"""
function set_phase!(zwd::ZWDiagram{T,P}, v::T, p::Parameter) where {T,P}
    if has_vertex(zwd.pmg, v)
        zwd.st[v] = @match zwd.st[v] begin
            monoZ(_) => monoZ(_round_phase(p))
            binZ(_) => binZ(_round_phase(p))
            _ => zxwd.st[v]
        end
        return true
    end
    return false
end

"""
    nqubits(zwd)

Returns the qubit number of a ZW-diagram.
"""
nqubits(zwd::ZWDiagram{T,P}) where {T,P} = length(zwd.inputs)

"""
    nin(zwd)
Returns the number of inputs of a ZW-diagram.
"""

nin(zwd::ZWDiagram{T,P}) where {T,P} = sum([@match spy begin
    Input(_) => 1
    _ => 0
end for spy in values(zwd.st)])

"""
    nout(zwd)
Returns the number of outputs of a ZW-diagram
"""
nout(zwd::ZWDiagram{T,P}) where {T,P} = sum([@match spy begin
    Output(_) => 1
    _ => 0
end for spy in values(zwd.st)])

"""
    print_spider(io, zwd, v)

Print a spider to `io`.
"""
function print_spider(io::IO, zwd::ZWDiagram{T,P}, v::T) where {T<:Integer,P}
    @match zwd.st[v] begin
        monoZ(p) => printstyled(io, "S_$(v){phase = $(p)}"; color = :green)
        binZ(p) => printstyled(io, "S_$(v){phase = $(p)}"; color = :green)
        Input(q) => printstyled(io, "S_$(v){input = $(q)}"; color = :blue)
        Output(q) => printstyled(io, "S_$(v){output = $(q)}"; color = :blue)
        SWAP => printstyled(io, "S_$(v){SWAP}"; color = :black)
        fSWAP => printstyled(io, "S_$(v){fSWAP}"; color = :black)
        W => printstyled(io, "S_$(v){W}"; color = :black)
        _ => print(io, "S_$(v)")
    end
end

function Base.show(io::IO, zwd::ZWDiagram{T,P}) where {T<:Integer,P}
    println(io, "$(typeof(zwd)) with $(nv(zwd.pmg)) vertices and $(ne(zwd.pmg)) edges:")
    for v1 in sort!(vertices(zwd.pmg))
        for v2 in neighbors(zwd.pmg, v1)
            if v2 >= v1
                print(io, "(")
                print_spider(io, zwd, v1)
                print(io, " <- -> ")
                print_spider(io, zwd, v2)
                print(io, ")\n")
            end
        end
    end
end

"""
    nv(zwd)

Returns the number of vertices (spiders) of a ZW-diagram.
"""
Graphs.nv(zwd::ZWDiagram) = nv(zwd.pmg)

"""
    ne(zwd)

Returns the number of edges of a ZW-diagram.
"""
Graphs.ne(zwd::ZWDiagram) = ne(zwd.pmg)

Graphs.outneighbors(zwd::ZWDiagram, v) = neighbors(zwd.pmg, v)
Graphs.inneighbors(zwd::ZWDiagram, v) = neighbors(zwd.pmg, v)
Graphs.degree(zwd::ZWDiagram, v::Integer) = length(neighbors(zwd.pmg, v))
Graphs.indegree(zwd::ZWDiagram, v::Integer) = degree(zwd, v)
Graphs.outdegree(zwd::ZWDiagram, v::Integer) = degree(zwd, v)

"""
    neighbors(zwd, v)

Returns a vector of vertices connected to `v`.
"""
Graphs.neighbors(zwd::ZWDiagram, v) = neighbors(zwd.pmg, v)

# """
#     Graphs.rem_edge!(zwd::ZWDiagram, x...)

# Remove Edge that connects vertices with indices `x...`.

# You could both remove the edge from face or merge the two vertices.
# A more suitable way to perform this action is during the process of
# adding and removing a spider.
# """
# function Graphs.rem_edge!(zwd::ZWDiagram, x...)
#     #TODO
# end



# """
#     rem_spiders!(zwd, vs)

# Remove spiders indexed by `vs`.
# """
# function rem_spiders!(zwd::ZWDiagram{T,P}, vs::Vector{T}) where {T<:Integer,P}
#     if rem_vertices!(zwd.pmg, vs)
#         for v in vs
#             delete!(zwd.st, v)
#         end
#         return true
#     end
#     return false
# end

# """
#     rem_spider!(zwd, v)

# Remove a spider indexed by `v`.
# """
# rem_spider!(zwd::ZWDiagram{T,P}, v::T) where {T<:Integer,P} = rem_spiders!(zwd, [v])
#
#
"""
    Graphs.add_edge!(zwd::ZWDiagram, he, mul)

Add `mul` of edges that connects vertices with already connected with edge`x`.

"""
function Graphs.add_edge!(zwd::ZWDiagram, he, mul::Int)
    return add_multiedge!(zwd.pmg, he, mul)
end

function join_spider!(zwd::ZWDiagram{T,P}, he1::T, he2::T) where {T<:Integer,P}
    face(zwd.pmg, he1) != face(zwd.pmg, he2) &&
        error("The two half edges must be on the same face!")
    return split_facet!(zwd.pmg, he1, he2)
end

"""
    add_spider!(zwd, spider, connect = [])

Add a new spider `spider` with appropriate parameter
connected to the half edges`connect`.

Had to make halfedge class 1 citizen because there will be ambiguity
Consider A to B and there are multiple edges to A and from A to B
"""
function add_spider!(
    zwd::ZWDiagram{T,P},
    spider::ZWSpiderType,
    connect::Vector{T},
) where {T<:Integer,P}
    length(connect) < 1 && error("The new vertex must be connect to something!")

    f_id = face(zwd.pmg, src(zwd.pmg, connect[1]))
    he_on_face = trace_face(zwd.pmg, f_id)
    if !all(x -> x ∈ he_on_face, connect)
        error("You must connect to vertices on the same face!")
    end
    make_hole!(zwd.pmg, f_id)
    connect = connect[sortperm([findfirst(x -> x == i, he_on_face) for i in connect])]
    he_new =
        add_vertex_and_facet_to_boarder!(zwd.pmg, prev(zwd.pmg, connect[1]), connect[1])
    v_new = src(zwd.pmg, he_new)
    zwd.st[v_new] = spider

    he_on_trig = twin(zwd.pmg, next(zwd.pmg, he_new))

    for next_he in connect[2:end]
        join_spider!(zwd, he_on_trig, next_he)
    end
    return v_new
end

"""
    insert_spider!(zwd, he1, spider)

Insert a spider `spider` with appropriate parameter on the half-edge prior to `he1`.
v1 <- he1 - v2 becomes
v1 <- he1 - v2 <- he_new - v_new
"""
function insert_spider!(
    zwd::ZWDiagram{T,P},
    he1::T,
    spider::ZWSpiderType,
) where {T<:Integer,P}
    he_new = split_edge!(zwd.pmg, he1)
    v_new = dst(zwd.pmg, he_new)
    zwd.st[v_new] = spider
    return v_new
end


"""
    spiders(zwd::ZWDiagram)

Returns a vector of spider idxs.
"""
spiders(zwd::ZWDiagram) = vertices(zwd.pmg)

"""
    get_inputs(zwd)

Returns a vector of input ids.
"""
get_inputs(zwd::ZWDiagram) = zwd.inputs

"""
    get_input_idx(zwd::ZXWDiagram{T,P}, q::T) where {T,P}

Get spider index of input qubit q.
"""
function get_input_idx(zwd::ZWDiagram{T,P}, q::T) where {T,P}
    for (i, v) in enumerate(get_inputs(zwd))
        res = @match spider_type(zwd, v) begin
            Input(q2) && if q2 == q
            end => v
            _ => nothing
        end
        !isnothing(res) && return res
    end
    return -1
end

"""
    get_outputs(zwd)

Returns a vector of output ids.
"""
get_outputs(zwd::ZWDiagram) = zwd.outputs

"""
    get_output_idx(zwd::ZWDiagram{T,P}, q::T) where {T,P}

Get spider index of output qubit q.
"""
function get_output_idx(zwd::ZWDiagram{T,P}, q::T) where {T,P}
    for (i, v) in enumerate(get_outputs(zwd))
        res = @match spider_type(zwd, v) begin
            Output(q2) && if q2 == q
            end => v
            _ => nothing
        end
        !isnothing(res) && return res
    end
    return -1
end

scalar(zwd::ZWDiagram) = zwd.scalar

function add_global_phase!(zwd::ZWDiagram{T,P}, p::P) where {T,P}
    add_phase!(zwd.scalar, p)
    return zwd
end

function add_power!(zwd::ZWDiagram, n)
    add_power!(zwd.scalar, n)
    return zwd
end
