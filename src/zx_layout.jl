import LightGraphs: rem_vertex!
import Base: copy

"""
    ZXLayout

A struct for the layout information of `ZXDiagram` and `ZXGraph`.
"""
struct ZXLayout{T<:Integer}
    nbits::T
    spider_seq::Vector{Vector{T}}
end

ZXLayout(nbits::T, spider_seq::Vector{Vector{T}}) where {T} = ZXLayout{T}(nbits, spider_seq)
ZXLayout{T}() where {T} = ZXLayout(T(0), Vector{T}[])

copy(layout::ZXLayout) = ZXLayout(copy(layout.nbits), deepcopy(layout.spider_seq))
function rem_vertex!(layout::ZXLayout{T}, v::T) where {T}
    for seq in layout.spider_seq
        v_ind = findfirst(isequal(v), seq)
        if v_ind !== nothing
            deleteat!(seq, v_ind)
            return true
        end
    end
    return false
end

"""
    qubit_loc(layout, v)

Return the qubit number corresponding to the spider `v`.
"""
qubit_loc(layout::ZXLayout{T}, v::T) where T = findfirst([(v in seq) for seq in layout.spider_seq])
