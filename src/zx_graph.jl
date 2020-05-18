using LightGraphs

import Base: show

export ZXGraph

const hadamard_edge = 1
const other_edge = 2

"""
    ZXGraph{T, P}
This is the type for representing the graph-like ZX-diagrams.
"""
struct ZXGraph{T<:Integer, P}
    mg::Multigraph{T}
    ps::Dict{T, P}
    st::Dict{T, SType}
end

function print_spider(io::IO, zxg::ZXGraph{T}, v::T) where {T<:Integer}
    st_v = get_prop(zxg.mg, v, :spider_type)
    if st_v == Z
        printstyled(io, "S_$(v){phase = $(get_prop(zxg.mg, v, :phase))⋅π}"; color = :green)
    elseif st_v == In
        print(io, "S_$(v){input}")
    elseif st_v == Out
        print(io, "S_$(v){output}")
    end
end

function show(io::IO, zxg::ZXGraph{T}) where {T<:Integer}
    println(io, "ZX-graph with $(nv(zxg.mg)) vertices and $(ne(zxg.mg)) edges:")
    for e in edges(zxg.mg)
        print(io, "(")
        print_spider(io, zxg, src(e))
        if get_prop(zxg.mg, e, :is_hadamard) == true
            printstyled(io, " <-> "; color = :blue)
        else
            print(io, " <-> ")
        end
        print_spider(io, zxg, dst(e))
        print(io, ")\n")
    end
end

# TODO: need new implementation of rules
function ZXGraph(zxd::ZXDiagram{T, U, P}) where {T, U, P}
#     nzxd = copy(zxd)
#
#     for v in nv(nzxd):-1:1
#         if check_rule_i1(nzxd, v) == true
#             rule_i1!(nzxd, v)
#         end
#     end
#
#     for v in ZX.find_spiders(nzxd, X)
#         rule_h!(nzxd, v)
#     end
#
#     vH = ZX.find_spiders(nzxd, H)
#     while length(vH) > 0
#         v1 = pop!(vH)
#         nb = outneighbors(nzxd, v1)
#         v2 = v1
#         if nb[1] in vH
#             v2 = nb[1]
#         elseif nb[2] in vH
#             v2 = nb[2]
#         end
#
#         setdiff!(vH, v2)
#         if v1 != v2
#             vmap = rule_i2!(nzxd, v1, v2)
#             vH = [findfirst(x->x==v, vmap) for v in vH]
#         end
#     end
#
#     vZ = find_spiders(nzxd, Z)
#     while length(vZ) > 0
#         v1 = pop!(vZ)
#         for v2 in vZ
#             if check_rule_f(nzxd, v1, v2) == true
#                 rule_f!(nzxd, v1, v2)
#                 break
#             end
#         end
#     end
#
#     vH = find_spiders(nzxd, H)
#     eH = [outneighbors(nzxd, v) for v in vH]
#     vmap = rem_spiders!(nzxd, vH)
#     for e in eH
#         e[1] = findfirst(x->x==e[1], vmap)
#         e[2] = findfirst(x->x==e[2], vmap)
#     end
#
#     g = SimpleGraph(nzxd.g.adjmx)
#     mg = MetaGraph(g)
#     for v in vertices(g)
#         set_prop!(mg, v, :spider_type, nzxd.st[v])
#         set_prop!(mg, v, :phase, nzxd.ps[v])
#     end
#     for e in edges(g)
#         if src(e) == dst(e)
#             rem_edge!(mg, e)
#         else
#             set_prop!(mg, e, :is_hadamard, false)
#         end
#     end
#     for e in eH
#         if has_edge(mg, e[1], e[2])
#             if get_prop(mg, e[1], e[2], :is_hadamard) == true
#                 rem_edge!(mg, e[1], e[2])
#             end
#         elseif e[1] == e[2]
#             new_phase = rem(get_prop(mg, e[1], :phase) + P(2), P(2)) - P(1)
#             set_prop!(mg, e[1], :phase, new_phase)
#         else
#             add_edge!(mg, e[1], e[2])
#             set_prop!(mg, e[1], e[2], :is_hadamard, true)
#         end
#     end
#     return ZXGraph{T, P}(zero(P), mg)
end
