using Test, ZXCalculus, Graphs, ZXCalculus.ZX
using ZXCalculus.ZX: SpiderType, EdgeType
using ZXCalculus.Utils: Phase

using ZXCalculus: ZX

st = Dict(
    0+1 => SpiderType.In,
    1+1 => SpiderType.In,
    2+1 => SpiderType.In,
    3+1 => SpiderType.In,
    4+1 => SpiderType.In,
    5+1 => SpiderType.Z,
    6+1 => SpiderType.Z,
    7+1 => SpiderType.Z,
    8+1 => SpiderType.Z,
    9+1 => SpiderType.Z,
    10+1 => SpiderType.Z,
    11+1 => SpiderType.Z,
    12+1 => SpiderType.Z,
    13+1 => SpiderType.Z,
    14+1 => SpiderType.Z,
    15+1 => SpiderType.Z,
    16+1 => SpiderType.Z,
    17+1 => SpiderType.Z,
    18+1 => SpiderType.Z,
    19+1 => SpiderType.Z,
    20+1 => SpiderType.Z,
    21+1 => SpiderType.Z,
    22+1 => SpiderType.Z,
    23+1 => SpiderType.Out,
    24+1 => SpiderType.Out,
    25+1 => SpiderType.Out,
    26+1 => SpiderType.Out,
    27+1 => SpiderType.Out,
    28+1 => SpiderType.Z,
    29+1 => SpiderType.Z,
    30+1 => SpiderType.Z,
    31+1 => SpiderType.Z,
    32+1 => SpiderType.Z,
    33+1 => SpiderType.Z,
    34+1 => SpiderType.Z,
    35+1 => SpiderType.Z,
    36+1 => SpiderType.Z,
    37+1 => SpiderType.Z,
    38+1 => SpiderType.Z,
    39+1 => SpiderType.Z,
    40+1 => SpiderType.Z,
    41+1 => SpiderType.Z,
    42+1 => SpiderType.Z,
    43+1 => SpiderType.Z,
    44+1 => SpiderType.Z,
    45+1 => SpiderType.Z,
    46+1 => SpiderType.Z,
    47+1 => SpiderType.Z,
    48+1 => SpiderType.Z,
    49+1 => SpiderType.Z,
    50+1 => SpiderType.Z,
    51+1 => SpiderType.Z,
)

ps = Dict(
    0+1 => 0//1,
    1+1 => 0//1,
    2+1 => 0//1,
    3+1 => 0//1,
    4+1 => 0//1,
    5+1 => 0//1,
    6+1 => 5//4,
    7+1 => 0//1,
    8+1 => 5//4,
    9+1 => 3//2,
    10+1 => 0//1,
    11+1 => 0//1,
    12+1 => 0//1,
    13+1 => 1//4,
    14+1 => 0//1,
    15+1 => 0//1,
    16+1 => 1//4,
    17+1 => 0//1,
    18+1 => 7//4,
    19+1 => 0//1,
    20+1 => 0//1,
    21+1 => 0//1,
    22+1 => 3//2,
    23+1 => 0//1,
    24+1 => 0//1,
    25+1 => 0//1,
    26+1 => 0//1,
    27+1 => 0//1,
    28+1 => 1//2,
    29+1 => 7//4,
    30+1 => 1//2,
    31+1 => 1//4,
    32+1 => 1//2,
    33+1 => 1//4,
    34+1 => 1//2,
    35+1 => 1//2,
    36+1 => 7//4,
    37+1 => 1//2,
    38+1 => 0//1,
    39+1 => 1//4,
    40+1 => 0//1,
    41+1 => 3//4,
    42+1 => 0//1,
    43+1 => 1//4,
    44+1 => 0//1,
    45+1 => 3//4,
    46+1 => 0//1,
    47+1 => 7//4,
    48+1 => 0//1,
    49+1 => 0//1,
    50+1 => 0//1,
    51+1 => 0//1
)

es = Dict(
    (0+1, 8+1) => EdgeType.HAD,
    (1+1, 6+1) => EdgeType.HAD,
    (2+1, 13+1) => EdgeType.HAD,
    (3+1, 16+1) => EdgeType.HAD,
    (4+1, 5+1) => EdgeType.HAD,
    (5+1, 6+1) => EdgeType.HAD,
    (5+1, 8+1) => EdgeType.HAD,
    (5+1, 9+1) => EdgeType.HAD,
    (6+1, 8+1) => EdgeType.HAD,
    (6+1, 10+1) => EdgeType.HAD,
    (6+1, 11+1) => EdgeType.HAD,
    (6+1, 13+1) => EdgeType.HAD,
    (6+1, 18+1) => EdgeType.HAD,
    (6+1, 19+1) => EdgeType.HAD,
    (6+1, 20+1) => EdgeType.HAD,
    (6+1, 40+1) => EdgeType.HAD,
    (6+1, 42+1) => EdgeType.HAD,
    (6+1, 46+1) => EdgeType.HAD,
    (6+1, 49+1) => EdgeType.HAD,
    (7+1, 8+1) => EdgeType.HAD,
    (7+1, 9+1) => EdgeType.HAD,
    (7+1, 30+1) => EdgeType.HAD,
    (8+1, 10+1) => EdgeType.HAD,
    (8+1, 13+1) => EdgeType.HAD,
    (8+1, 18+1) => EdgeType.HAD,
    (8+1, 19+1) => EdgeType.HAD,
    (8+1, 21+1) => EdgeType.HAD,
    (8+1, 38+1) => EdgeType.HAD,
    (8+1, 40+1) => EdgeType.HAD,
    (8+1, 46+1) => EdgeType.HAD,
    (8+1, 48+1) => EdgeType.HAD,
    (9+1, 10+1) => EdgeType.HAD,
    (9+1, 11+1) => EdgeType.HAD,
    (9+1, 13+1) => EdgeType.HAD,
    (9+1, 18+1) => EdgeType.HAD,
    (9+1, 38+1) => EdgeType.HAD,
    (9+1, 42+1) => EdgeType.HAD,
    (9+1, 44+1) => EdgeType.HAD,
    (9+1, 46+1) => EdgeType.HAD,
    (10+1, 35+1) => EdgeType.HAD,
    (11+1, 32+1) => EdgeType.HAD,
    (12+1, 16+1) => EdgeType.HAD,
    (12+1, 18+1) => EdgeType.HAD,
    (12+1, 33+1) => EdgeType.HAD,
    (13+1, 14+1) => EdgeType.HAD,
    (13+1, 15+1) => EdgeType.HAD,
    (13+1, 17+1) => EdgeType.HAD,
    (13+1, 22+1) => EdgeType.HAD,
    (13+1, 50+1) => EdgeType.HAD,
    (14+1, 16+1) => EdgeType.HAD,
    (14+1, 18+1) => EdgeType.HAD,
    (14+1, 36+1) => EdgeType.HAD,
    (15+1, 16+1) => EdgeType.HAD,
    (15+1, 29+1) => EdgeType.HAD,
    (16+1, 51+1) => EdgeType.HAD,
    (17+1, 18+1) => EdgeType.HAD,
    (17+1, 31+1) => EdgeType.HAD,
    (18+1, 22+1) => EdgeType.HAD,
    (19+1, 22+1) => EdgeType.HAD,
    (19+1, 28+1) => EdgeType.HAD,
    (20+1, 22+1) => EdgeType.HAD,
    (20+1, 37+1) => EdgeType.HAD,
    (21+1, 22+1) => EdgeType.HAD,
    (21+1, 34+1) => EdgeType.HAD,
    (22+1, 27+1) => EdgeType.HAD,
    (22+1, 38+1) => EdgeType.HAD,
    (22+1, 42+1) => EdgeType.HAD,
    (22+1, 44+1) => EdgeType.HAD,
    (22+1, 46+1) => EdgeType.HAD,
    (23+1, 48+1) => EdgeType.HAD,
    (24+1, 49+1) => EdgeType.HAD,
    (25+1, 50+1) => EdgeType.HAD,
    (26+1, 51+1) => EdgeType.HAD,
    (38+1, 39+1) => EdgeType.HAD,
    (40+1, 41+1) => EdgeType.HAD,
    (42+1, 43+1) => EdgeType.HAD,
    (44+1, 45+1) => EdgeType.HAD,
    (46+1, 47+1) => EdgeType.HAD,
)

zxg = ZXGraph(ZXDiagram(0))
vs = 1:52
for v in vs
    ZX.add_spider!(zxg, st[v], Phase(ps[v]))
end
for (e, _) in es
    Graphs.add_edge!(zxg, e[1], e[2])
end
for i = 1:5
    push!(zxg.inputs, i)
    push!(zxg.outputs, i+23)
end

ZX.ancilla_extraction(zxg)
