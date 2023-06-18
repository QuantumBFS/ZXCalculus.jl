"""
    round_phases!(zxd)

Round phases between [0, 2π).
"""
function round_phases!(
    zx::Union{ZXDiagram{T,P},ZXGraph{T,P},ZXWDiagram{T,P}},
) where {T<:Integer,P}
    _round_phase_dict!(zx.ps)
    return
end

function _round_phase_dict!(ps::Dict{T,P}) where {T<:Integer,P}
    for v in keys(ps)
        ps[v] = rem(rem(ps[v], 2) + 2, 2)
    end
    return
end

"""
    spider_type(zxd, v)

Returns the spider type of a spider.
"""
spider_type(zxd::Union{ZXDiagram{T,P},ZXWDiagram{T,P}}, v::T) where {T<:Integer,P} =
    zxd.st[v]

"""
    phase(zxd, v)

Returns the phase of a spider. If the spider is not a Z or X spider, then return 0.
"""
function phase(zxd::Union{ZXDiagram{T,P},ZXWDiagram{T,P}}, v::T) where {T<:Integer,P}
    if spider_type(zxd, v) ∈ (SpiderType.Z, SpiderType.X)
        return zxd.ps[v]
    else
        return zero(P)
    end
end

"""
    set_phase!(zxd, v, p)

Set the phase of `v` in `zxd` to `p`. If `v` is not a Z or X spider, then do nothing.
"""
function set_phase!(zxd::Union{ZXDiagram{T,P},ZXWDiagram{T,P}}, v::T, p::P) where {T,P}
    if has_vertex(zxd.mg, v) && spider_type(zxd, v) ∈ (SpiderType.Z, SpiderType.X)
        p = rem(rem(p, 2) + 2, 2)
        zxd.ps[v] = p
        return true
    end
    return false
end

"""
    nqubits(zxd)

Returns the qubit number of a ZX-diagram.
"""
nqubits(zxd::Union{ZXDiagram,ZXWDiagram}) = zxd.layout.nbits

"""
    print_spider(io, zxd, v)

Print a spider to `io`.
"""
function print_spider(
    io::IO,
    zxd::Union{ZXDiagram{T,P},ZXWDiagram{T,P}},
    v::T,
) where {T<:Integer,P}
    st_v = spider_type(zxd, v)
    if st_v == SpiderType.Z
        printstyled(
            io,
            "S_$(v){phase = $(zxd.ps[v])" * (zxd.ps[v] isa Phase ? "}" : "⋅π}");
            color = :green,
        )
    elseif st_v == SpiderType.X
        printstyled(
            io,
            "S_$(v){phase = $(zxd.ps[v])" * (zxd.ps[v] isa Phase ? "}" : "⋅π}");
            color = :red,
        )
    elseif st_v == SpiderType.H
        printstyled(io, "S_$(v){H}"; color = :yellow)
    elseif st_v == SpiderType.W
        printstyled(io, "S_$(v){W}"; color = :black)
    elseif st_v == SpiderType.D
        printstyled(io, "S_$(v){D}"; color = :yellow)
    elseif st_v == SpiderType.In
        print(io, "S_$(v){input}")
    elseif st_v == SpiderType.Out
        print(io, "S_$(v){output}")
    end
end


function Base.show(io::IO, zxd::Union{ZXDiagram{T,P},ZXWDiagram{T,P}}) where {T<:Integer,P}
    println(
        io,
        "$(typeof(zxd)) with $(nv(zxd.mg)) vertices and $(ne(zxd.mg)) multiple edges:",
    )
    for v1 in sort!(vertices(zxd.mg))
        for v2 in neighbors(zxd.mg, v1)
            if v2 >= v1
                print(io, "(")
                print_spider(io, zxd, v1)
                print(io, " <-$(mul(zxd.mg, v1, v2))-> ")
                print_spider(io, zxd, v2)
                print(io, ")\n")
            end
        end
    end
end
