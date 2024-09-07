using Pkg; Pkg.activate("example")
using ZXCalculus
using ZXCalculus.ZXW
using ZXCalculus.ZX.Multigraphs, ZXCalculus.ZX.Graphs
using ZXCalculus.Utils: Parameter
using WGLMakie, GraphMakie

function make_meas_mg(weight::T) where {T<:Integer}
    spiders_mg = Multigraph(weight + 1)
    for i in 1:weight
        add_edge!(spiders_mg, i, weight + 1, 1)
    end
    return spiders_mg
end

function make_meas_zxwd(::Type{P}, mg::Multigraph{T}, meas_type::Symbol) where {T<:Integer, P}
	weight = nv(mg) - 1
    st_vec = [[(meas_type == :X) ? ZXW.Z(zero(P)) : ZXW.X(zero(P)) for _ in 1:weight]..., (meas_type == :X) ? ZXW.X(zero(P)) : ZXW.Z(zero(P))]
    return ZXWDiagram(mg, st_vec)
end

weight = 4
meas_mg = make_meas_mg(weight)


xstab_meas_zxd = make_meas_zxwd(Parameter, meas_mg, :X)
zstab_meas_zxd = make_meas_zxwd(Parameter, meas_mg, :Z)

ZXCalculus.ZXW.plot(xstab_meas_zxd)

typeof(xstab_meas_zxd)

# Convert requirement checking into linear programming
# Req1: even number of green/red spiders with degree 1 respectively
# Req2: Causallity must not be violated in the colored version, assign variables to the vertices
# Req3: in the finished zx-diagram, a spider will have either degree 1 or 3 
# Req4: topology of the finished diagram will be nice, i.e planar
# Isn't this just extracting circuit from ZX-Diagram? It is proven to be #P-Complete. Need to search