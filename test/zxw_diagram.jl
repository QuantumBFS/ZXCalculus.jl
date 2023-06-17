g = Multigraph([0 1 0; 1 0 1; 0 1 0])
ps = [Rational(-10 * i + 1, 2) for i = 1:3]
v_t = [SpiderType.Z for i = 1:3]

@test_throws ErrorException("There should be a type for each spider!") ZXWDiagram(
    g,
    v_t[1:2],
    ps,
)
@test_throws ErrorException("There should be a phase for each spider!") ZXWDiagram(
    g,
    v_t,
    ps[1:2],
)

zxwd = ZXWDiagram(g, v_t, ps)
zxwd_ps = [zxwd.ps[v] for v in sort!(vertices(g))]
for (p, q) in zip(ps, zxwd_ps)
    println(p, q)
end
@test all(pp -> (exp(im * pp[1] * π) ≈ exp(im * pp[2] * π)), zip(ps, zxwd_ps))
@test all(p -> 0 <= p && p <= 2, zxwd_ps)
