using Pkg; Pkg.activate("example")
using ZXCalculus
using ZXCalculus.ZXW
using ZXCalculus.ZX.Multigraphs, ZXCalculus.ZX.Graphs
using ZXCalculus.Utils: Parameter
using WGLMakie, GraphMakie
using ZXCalculus.ZX.MLStyle

function make_meas_mg(weight::T) where {T<:Integer}
    spiders_mg = Multigraph(weight * 3 + 1)

    for i in 1:weight
        add_edge!(spiders_mg, 2 * (i - 1) + 1, 2 * weight + i)
        add_edge!(spiders_mg, 2 * (i - 1) + 2, 2 * weight + i)
    end

    for i in 1:weight
        add_edge!(spiders_mg, 2 * weight + i, 3 * weight + 1)
    end

    return spiders_mg
end

function make_meas_zxwd(::Type{P}, mg::Multigraph{T}, meas_type::Symbol) where {T<:Integer,P}
    weight = (nv(mg) - 1) // 3
    st_vec = [[isodd(i) ? ZXW.Input(i ÷ 2 + 1) : ZXW.Output(i ÷ 2) for i in 1:2*weight]..., [(meas_type == :X) ? ZXW.Z(zero(P)) : ZXW.X(zero(P)) for _ in 1:weight]..., (meas_type == :X) ? ZXW.X(zero(P)) : ZXW.Z(zero(P))]
    return ZXWDiagram(mg, st_vec)
end

function make_after_rewrite_mg()
    spiders_mg = Multigraph(22)
    edge_list = [(1, 11), (2, 10), (3, 14), (4, 15), (5, 18), (6, 19), (7, 21), (8, 20), (9, 10), (10, 11), (11, 12), (12, 13), (12, 19), (13, 14), (13, 20), (14, 15), (15, 16), (17, 18), (18, 19), (20, 21), (21, 22)]
    for edg in edge_list 
        add_edge!(spiders_mg, edg[1], edg[2])
    end
    return spiders_mg
end

function make_after_rewrite_zxw(::Type{P}, mg::Multigraph{T},meas_type::Symbol) where {T,P}
    num_input_outputs = 8 
    num_other_spiders = 14
    st_vec = [[isodd(i) ? ZXW.Input(i ÷ 2 + 1) : ZXW.Output(i ÷ 2) for i in 1:num_input_outputs]..., [(meas_type == :X) ? ZXW.Z(zero(P)) : ZXW.X(zero(P)) for _ in 1:num_other_spiders]...]
    if meas_type == :X
        st_vec[12:13] = [ZXW.X(zero(P)), ZXW.X(zero(P))]
    else
        st_vec[12:13] = [ZXW.Z(zero(P)), ZXW.Z(zero(P))]
    end
    return ZXWDiagram(mg, st_vec)
end

weight = 4
meas_mg = make_meas_mg(weight)

xstab_meas_zxwd = make_meas_zxwd(Parameter, meas_mg, :X)
zstab_meas_zxwd = make_meas_zxwd(Parameter, meas_mg, :Z)

ZXCalculus.ZXW.plot(xstab_meas_zxwd)
ZXCalculus.ZXW.plot(zstab_meas_zxwd)

concat_zxwd = ZXW.concat!(copy(xstab_meas_zxwd), copy(zstab_meas_zxwd))
res_zxwd = ZXW.concat!(copy(concat_zxwd), copy(concat_zxwd))
res_zxwd = ZXW.concat!(res_zxwd, copy(concat_zxwd))

ZXCalculus.ZXW.plot(res_zxwd)

after_rewrite_mg = make_after_rewrite_mg()
after_rewrite_zxwd_x = make_after_rewrite_zxw(Parameter, after_rewrite_mg, :X)
after_rewrite_zxwd_z = make_after_rewrite_zxw(Parameter, after_rewrite_mg, :Z)

ZXCalculus.ZXW.plot(after_rewrite_zxwd_x)

two_layer_after_rewrite_zxwd = ZXW.concat!(copy(after_rewrite_zxwd_x), copy(after_rewrite_zxwd_z))

ZXCalculus.ZXW.plot(two_layer_after_rewrite_zxwd)

four_layer_after_rewrite_zxwd = ZXW.concat!(copy(two_layer_after_rewrite_zxwd), copy(two_layer_after_rewrite_zxwd))

ZXCalculus.ZXW.plot(four_layer_after_rewrite_zxwd)

for sp in ZXW.spiders(four_layer_after_rewrite_zxwd)
    @show ZXW.degree(four_layer_after_rewrite_zxwd, sp)
end



# Convert requirement checking into linear programming

function has_only_dg1_3_spiders(zxwd::ZXWDiagram{T,P}) where {T,P}
    # Req3: in the finished zx-diagram, a spider will have either degree 1 or 3 
    for sp in ZXW.spiders(zxwd)
        @match ZXW.spider_type(zxwd,sp) begin
            ZXW.Input(_) || ZXW.Output(_) => continue
            ZXW.Z(_) || ZXW.X(_) => ZXW.degree(zxwd, sp) == 1 || ZXW.degree(zxwd, sp) == 3 || return false
        end
    end
    return true
end

function has_even_dg1_zx_spiders(zxwd::ZXWDiagram{T,P}) where {T,P}
    # Req1: even number of green/red spiders with degree 1 respectively
    num_dg1_z_spiders = 0
    num_dg1_x_spiders = 0    

end


function extract_k_qubit_circuit(zxwd::ZXWDiagram{T,P}) where {T,P}
    # Req2: Causallity must not be violated in the colored version, assign variables to the vertices
    # Req4: topology of the finished diagram will be nice, i.e planar
    # Isn't this just extracting circuit from ZX-Diagram? It is proven to be #P-Complete. Need to search

end

# if need to visualize, use javascript and visualize the modified ZX-diagram
# need to save etc.

# edge-colored graph