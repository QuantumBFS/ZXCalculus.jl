"""
$(TYPEDEF)

A struct for the layout information of ZX-circuits.

# Fields

$(TYPEDFIELDS)
"""
struct ZXLayout{T <: Integer}
    "Number of qubits in the circuit"
    nbits::Int
    "Mapping from spider vertices to qubit locations"
    spider_q::Dict{T, Rational{Int}}
    "Mapping from spider vertices to column positions"
    spider_col::Dict{T, Rational{Int}}
end

function ZXLayout(nbits::Integer, spider_q::Dict{T, Rational{Int}}, spider_col::Dict{T, Rational{Int}}) where {T}
    return ZXLayout{T}(Int(nbits), spider_q, spider_col)
end
ZXLayout{T}(nbits::Integer=0) where {T} = ZXLayout(nbits, Dict{T, Rational{Int}}(), Dict{T, Rational{Int}}())

Base.copy(layout::ZXLayout) = ZXLayout(layout.nbits, copy(layout.spider_q), copy(layout.spider_col))
function Graphs.rem_vertex!(layout::ZXLayout{T}, v::T) where {T}
    delete!(layout.spider_q, v)
    delete!(layout.spider_col, v)
    return
end

nqubits(layout::ZXLayout) = layout.nbits

"""
    $(TYPEDSIGNATURES)

Return the qubit number corresponding to the spider `v`, or `nothing` if not in layout.
"""
qubit_loc(layout::ZXLayout{T}, v::T) where T = get(layout.spider_q, v, nothing)

"""
    $(TYPEDSIGNATURES)

Return the column number corresponding to the spider `v`, or `nothing` if not in layout.
"""
column_loc(layout::ZXLayout{T}, v::T) where T = get(layout.spider_col, v, nothing)

"""
    $(TYPEDSIGNATURES)

Set the qubit number of the spider `v` to `q`.
"""
function set_qubit!(layout::ZXLayout{T}, v::T, q) where T
    layout.spider_q[v] = q
    return layout
end

"""
    $(TYPEDSIGNATURES)

Set the column number of the spider `v` to `col`.
"""
function set_column!(layout::ZXLayout{T}, v::T, col) where T
    layout.spider_col[v] = col
    return layout
end

"""
    $(TYPEDSIGNATURES)

Set both the qubit and column location of the spider `v`.
"""
function set_loc!(layout::ZXLayout{T}, v::T, q, col) where T
    set_qubit!(layout, v, q)
    set_column!(layout, v, col)
    return layout
end
