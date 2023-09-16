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
