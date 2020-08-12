import LightGraphs: rem_vertex!
import Base: copy

"""
    ZXLayout

A struct for the layout information of `ZXDiagram` and `ZXGraph`.
"""
struct ZXLayout{T<:Integer}
    nbits::Int
    spider_q::Dict{T, Rational{Int}}
    spider_col::Dict{T, Rational{Int}}
end

ZXLayout(nbits::Integer, spider_q::Dict{T, Rational{Int}}, spider_col::Dict{T, Rational{Int}}) where {T} = ZXLayout{T}(Int(nbits), spider_q, spider_col)
ZXLayout{T}() where {T} = ZXLayout(0, Dict{T, Rational{Int}}(), Dict{T, Rational{Int}}())

copy(layout::ZXLayout) = ZXLayout(layout.nbits, copy(layout.spider_q), copy(layout.spider_col))
function rem_vertex!(layout::ZXLayout{T}, v::T) where {T}
    delete!(layout.spider_q, v)
    delete!(layout.spider_col, v)
    return
end

"""
    qubit_loc(layout, v)

Return the qubit number corresponding to the spider `v`.
"""
function qubit_loc(layout::ZXLayout{T}, v::T) where T
    if haskey(layout.spider_q, v)
        return T(layout.spider_q[v])
    end
    return
end

"""
    column_loc(layout, v)

Return the column number corresponding to the spider `v`.
"""
function column_loc(layout::ZXLayout{T}, v::T) where T
    if haskey(layout.spider_col, v)
        return layout.spider_col[v]
    end
    return
end

"""
    set_qubit!(layout, v, q)

Set the qubit number of the spider `v`.
"""
function set_qubit!(layout::ZXLayout{T}, v::T, q) where T
    layout.spider_q[v] = q
    return layout
end

"""
    set_qubit!(layout, v, q)

Set the column number of the spider `v`.
"""
function set_column!(layout::ZXLayout{T}, v::T, col) where T
    layout.spider_col[v] = col
    return layout
end

"""
    set_loc!(layout, v, q, col)

Set the location of the spider `v`.
"""
function set_loc!(layout::ZXLayout{T}, v::T, q, col) where T
    set_qubit!(layout, v, q)
    set_column!(layout, v, col)
    return layout
end
