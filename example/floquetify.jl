using Pkg; Pkg.activate("example")
using ZXCalculus
using ZXCalculus.ZXW
using ZXCalculus.ZX.Multigraphs, ZXCalculus.ZX.Graphs
using ZXCalculus.Utils: Parameter
using WGLMakie, GraphMakie
using ZXCalculus.ZX.MLStyle
using JuMP
using SCIP

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

    for sp in ZXW.spiders(zxwd)
        @match ZXW.spider_type(zxwd,sp) begin
            ZXW.Input(_) || ZXW.Output(_) => continue
            ZXW.Z(_) => if ZXW.degree(zxwd, sp) == 1 
                           num_dg1_z_spiders += 1
                        end
            ZXW.X(_) => if ZXW.degree(zxwd, sp) == 1 
                            num_dg1_x_spiders += 1
                        end
        end
    end

    if iseven(num_dg1_z_spiders) && iseven(num_dg1_x_spiders)
        return true
    else
        return false
    end
end


function dg1_zx_spiders_can_be_start(zxwd::ZXWDiagram{T,P}, model, k_colors::Int) where {T,P}
    @variable(model, is_start[1:ZXW.nv(zxwd)], Bin)
    # if the spider is a green/red spider with degree more than 1, then it can't be a start
    for sp in ZXW.spiders(zxwd)
        @match ZXW.spider_type(zxwd,sp) begin
            ZXW.Input(_) || ZXW.Output(_) => continue
            ZXW.Z(_) || ZXW.X(_) => if !isone(ZXW.degree(zxwd, sp))
                @constraint(model, is_start[sp] == 0)
            end
        end
    end

    # must have k_colors number of  worldlines
    @constraint(model, sum(is_start) == k_colors)
    return is_start
end

function edge_direction_assignment(zxwd::ZXWDiagram{T,P}, model) where {T,P}
    @variable(model, small_idx2large_idx[1:ZXW.ne(zxwd)], Bin)

    @variable(model, large_idx2small_idx[1:ZXW.ne(zxwd)], Bin)

    edg2idx = Dict{MultipleEdge{Int,Int},Int}()    
    for edg in ZXW.edges(zxwd)
        @constraint(model, small_idx2large_idx[edg] + large_idx2small_idx[edg] <= 1)
    end

    return small_idx2large_idx, large_idx2small_idx
end

function time_step_assignment(zxwd::ZXWDiagram{T,P}, model, t_steps::Int) where {T,P}
    @variable(model, 0 <= time_steps[1:ZXW.nv(zxwd)] <= t_steps, Int)
    # no input / output spiders could be assigned a time step
    for sp in ZXW.spiders(zxwd)
        @match ZXW.spider_type(zxwd,sp) begin
            ZXW.Input(_) || ZXW.Output(_) => @constraint(model, time_steps[sp] == 0)
            ZXW.Z(_) || ZXW.X(_) => @constraint(model, time_steps[sp] >= 1) 
        end
    end
    return time_steps
end

function extract_k_qubit_circuit(zxwd::ZXWDiagram{T,P}, k_colors::Int, t_steps::Int) where {T,P}

    has_even_dg1_zx_spiders(zxwd) || error("We don't have even number of degree 1 spiders") 
    has_only_dg1_3_spiders(zxwd) || error("We don't have only degree 1 or 3 spiders")

    model = Model(SCIP.Optimizer) 

    is_start = dg1_zx_spiders_can_be_start(zxwd, model, k_colors)

    small_idx2large_idx, large_idx2small_idx = edge_direction_assignment(zxwd, model)

    time_steps = time_step_assignment(zxwd, model, t_steps)




    # @variable(model, 0 <= time_steps[1:ZXW.nv(zxwd)] <= t_steps, Int)

    # # let 0 denote black color
    # # let i denote the ith color which denotes the timeline
    # @variable(model, 0 <= edge_color[1:ZXW.ne(zxwd)] <= k_colors, Int) 

    # @variable(model, edge_direction[1:ZXW.ne(zxwd)], Bin)

    # @constraint(model,const_name[i in 1:ZXW.ne(zxwd)], edge_color[i] == 0)

    @objective(model,Min,1)
    optimize!(model)
    @assert is_solved_and_feasible(model)
    return value.(is_start), value.(small_idx2large_idx), value.(large_idx2small_idx), value.(time_steps)
    # return value.(time_steps), value.(edge_color), value.(edge_direction)
    # Req2: Causallity must not be violated in the colored version, assign variables to the vertices
    # Req4: topology of the finished diagram will be nice, i.e planar
    # Isn't this just extracting circuit from ZX-Diagram? It is proven to be #P-Complete. Need to search
end

extract_k_qubit_circuit(four_layer_after_rewrite_zxwd, 2, 2)


for edg in ZXW.edges(four_layer_after_rewrite_zxwd)
    @show typeof(edg)
    @show edg.src, edg.dst
end

# if need to visualize, use javascript and visualize the modified ZX-diagram
# need to save etc.

# edge-colored graph