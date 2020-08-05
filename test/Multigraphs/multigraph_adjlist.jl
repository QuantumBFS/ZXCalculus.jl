try
    m2 = spzeros(Int, 2, 3)
    dg = Multigraph(m2)
catch e
    @test e != nothing
end
try
    m2 = spzeros(Int, 2, 2)
    m2[1, 2] = 2
    dg = Multigraph(m2)
catch e
    @test e != nothing
end
try
    m2 = spzeros(Int, 2, 2)
    m2[1, 2] = -1
    m2[2, 1] = -1
    dg = Multigraph(m2)
catch e
    @test e != nothing
end

m = spzeros(Int, 4, 4)
m
m[1,2] = 2
m[2,1] = 2
m[2,3] = 2
m[3,2] = 2
m[3,4] += 1
m[3,4] = 0
m[4,3] += 1
m[4,3] = 0
g = Multigraph(m)
g = Multigraph(Matrix(m))

g0 = Multigraph(2)
@test !add_edge!(g0, 2, 3) && !rem_edge!(g0, 1, 2)
g1 = Multigraph(path_graph(3))

@test !is_directed(g)
@test edgetype(g) == MultipleEdge{Int, Int}
@test size(adjacency_matrix(g), 1) == 4

@test nv(g) == 4 && ne(g, count_mul = true) == 4 && ne(g) == 2

add_vertices!(g, 3)
@test nv(g) == 7

@test has_edge(g, 1, 2, 2)
@test rem_vertices!(g, [7, 5, 4, 6])
add_edge!(g, [2, 3, 2])
rem_edge!(g, [2, 3, 2])
add_edge!(g, 2, 3)
rem_edge!(g, 2, 3)
add_edge!(g, 2, 3, 2)
rem_edge!(g, 2, 3, 1)

@test has_edge(g, 2, 3) && has_edge(g, [2, 3])
@test has_edge(g, 2, 3, 2) && has_edge(g, (2, 3, 2))
@test !has_edge(g, 2, 2) && !has_edge(g, 2, 5)
@test has_vertex(g, 1) && !has_vertex(g, 5)
for v in vertices(g)
    @test inneighbors(g, v) == outneighbors(g, v)
    @test degree(g, v) == indegree(g, v) && indegree(g, v) == outdegree(g, v)
end
add_vertex!(g)
@test indegree(g) == outdegree(g)
