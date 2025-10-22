using Test, ZXCalculus, ZXCalculus.ZX
using ZXCalculus: ZX

# Othertests for ZXGraphs and ZXDigram are embededd into the zx_graph and zx_diagram testsets
zxd = ZXDiagram(3)
ZX.insert_spider!(zxd, 1, 2, SpiderType.H)
ZX.insert_spider!(zxd, 1, 2, SpiderType.X)
ZX.insert_spider!(zxd, 1, 2, SpiderType.Z)
zxg = ZXGraph(zxd)

@test !isnothing(plot(zxd))
@test !isnothing(plot(zxg))
