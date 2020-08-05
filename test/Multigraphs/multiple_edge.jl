me = MultipleEdge(1, 2, 3)
try
    MultipleEdge(1, 2, 0)
catch err
    @test err != nothing
end
@test src(me) == 1 && dst(me) == 2 && mul(me) == 3
e0 = LightGraphs.SimpleEdge(me)
MultipleEdge(e0)
@test MultipleEdge(1, 2) == e0
@test e0 == MultipleEdge(1, 2)
@test e0 == MultipleEdge([1, 2])
@test e0 == MultipleEdge([1, 2, 1])
@test e0 == MultipleEdge((1, 2))
@test e0 == MultipleEdge((1, 2, 1))
@test e0 == MultipleEdge(1 => 2)
@test reverse(me) == MultipleEdge(2, 1, 3)
@test eltype(me) == Int

@test iterate(me)[2] == 2
@test [e0 == e for e in me] == [true for i = 1:mul(me)]
@test Tuple(me) == (1,2,3)
length(me) == mul(me)
