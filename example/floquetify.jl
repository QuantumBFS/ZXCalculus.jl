using Vega, DataFrames
using ZXCalculus
using ZXCalculus.ZX
using ZXCalculus.ZX.Multigraphs, ZXCalculus.ZX.Graphs

function make_meas_mg(weight::T) where {T<:Integer}
    spiders_mg = Multigraph(weight + 1)
    for i in 1:weight
        add_edge!(spiders_mg, i, weight + 1, 1)
    end
    return spiders_mg
end

function make_meas_zxd(::Type{P}, mg::Multigraph{T}, meas_type::Symbol) where {T<:Integer, P}
	weight = nv(mg) - 1
    phase_vec = zeros(P, weight + 1)
    st_vec = [[(meas_type == :X) ? ZX.SpiderType.Z : ZX.SpiderType.X for _ in 1:weight]..., (meas_type == :X) ? ZX.SpiderType.X : ZX.SpiderType.Z]
    return ZXDiagram(mg, st_vec, phase_vec)
end

weight = 4
meas_mg = make_meas_mg(weight)

xstab_meas_zxd = make_meas_zxd(Float64, meas_mg, :X)
zstab_meas_zxd = make_meas_zxd(Float64, meas_mg, :Z)

g = ZX.plot(xstab_meas_zxd)


# Convert requirement checking into linear programming
# Req1: even number of green/red spiders with degree 1 respectively
# Req2: Causallity must not be violated in the colored version, assign variables to the vertices
# Req3: in the finished zx-diagram, a spider will have either degree 1 or 3 
# Req4: topology of the finished diagram will be nice, i.e planar