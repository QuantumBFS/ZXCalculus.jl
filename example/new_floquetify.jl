using Pkg; Pkg.activate("example")
using ZXCalculus
using ZXCalculus.ZXW
using ZXCalculus.ZX.Multigraphs, ZXCalculus.ZX.Graphs
using ZXCalculus.Utils: Parameter
using ZXCalculus.ZX.MLStyle
using ZXCalculus.ZX: Rule
using WGLMakie, GraphMakie

function make_422_meas_mg()
	mg = Multigraph(26)
    connectivity = [(1, 9), (2, 10), (3, 11), (4, 12), (13, 9), (13, 10), (13, 11), (13, 12), (9, 14), (10, 15), (11, 16), (12, 17), (14, 18), (15, 19), (16, 20), (17, 21), (22, 18), (22, 19), (22, 20), (22, 21), (18, 23), (19, 24), (20, 25), (21, 26), (23, 5), (24, 6), (25, 7), (26, 8)]
	for (v1, v2) in connectivity
		add_edge!(mg, v1, v2)
	end
	return mg
end

function make_422_meas_zxwd()
	mg = make_422_meas_mg()
    st_vec = [[isodd(i) ? ZXW.Input(i ÷ 2 + 1) : ZXW.Output(i ÷ 2) for i in 1:2*4]..., fill(ZXW.Z(zero(Parameter)), 4)..., ZXW.X(zero(Parameter)), fill(ZXW.H, 4)..., fill(ZXW.Z(zero(Parameter)), 4)..., ZXW.X(zero(Parameter)), fill(ZXW.H, 4)...]
	return ZXWDiagram(mg, st_vec)
end

zxwd_422_meas = make_422_meas_zxwd()

ZXCalculus.ZXW.plot(zxwd_422_meas)