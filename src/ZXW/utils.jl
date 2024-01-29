"""
	round_phases!(zxwd)

Round phases between [0, 2π).
"""
function round_phases!(zxwd::ZXWDiagram{T, P}) where {T <: Integer, P}
	st = zxwd.st
	for v in keys(st)
		st[v] = @match st[v] begin
			Z(p) => Z(_round_phase(p))
			X(p) => X(_round_phase(p))
			_ => st[v]
		end
	end
	return
end

function _round_phase(p::Parameter)
	@match p begin
		PiUnit(pu, pt) && if pu isa Number
		end => rem(rem(p, 2) + 2, 2)
		_ => p
	end
end

"""
	spider_type(zxwd, v)

Returns the spider type of a spider if it exists.
"""
function spider_type(zxwd::ZXWDiagram{T, P}, v::T) where {T <: Integer, P}
	if has_vertex(zxwd.mg, v)
		return zxwd.st[v]
	else
		error("Spider $v does not exist!")
	end
end

"""
	parameter(zxwd, v)

Returns the parameter of a spider. If the spider is not a Z or X spider, then return 0.
"""
function parameter(zxwd::ZXWDiagram{T, P}, v::T) where {T <: Integer, P}
	@match spider_type(zxwd, v) begin
		Z(p) => p
		X(p) => p
		Input(q) || Output(q) => q
		_ => Parameter(Val(:PiUnit), 0)
	end
end

"""
	set_phase!(zxwd, v, p)

Set the phase of `v` in `zxwd` to `p`. If `v` is not a Z or X spider, then do nothing.
If `v` is not in `zxwd`, then return false to indicate failure.
"""
function set_phase!(zxwd::ZXWDiagram{T, P}, v::T, p::Parameter) where {T, P}
	if has_vertex(zxwd.mg, v)
		zxwd.st[v] = @match zxwd.st[v] begin
			Z(_) => Z(_round_phase(p))
			X(_) => X(_round_phase(p))
			_ => zxwd.st[v]
		end
		return true
	end
	return false
end

"""
	nqubits(zxwd)

Returns the qubit number of a ZXW-diagram.
"""
nqubits(zxwd::ZXWDiagram{T, P}) where {T, P} = length(zxwd.inputs)

"""
	nin(zxwd)
Returns the number of inputs of a ZXW-diagram.
"""

nin(zxwd::ZXWDiagram{T, P}) where {T, P} = sum([@match spy begin
	Input(_) => 1
	_ => 0
end for spy in values(zxwd.st)])


"""
	nout(zxwd)
Returns the number of outputs of a ZXW-diagram
"""
nout(zxwd::ZXWDiagram{T, P}) where {T, P} = sum([@match spy begin
	Output(_) => 1
	_ => 0
end for spy in values(zxwd.st)])

"""
	print_spider(io, zxwd, v)

Print a spider to `io`.
"""
function print_spider(io::IO, zxwd::ZXWDiagram{T, P}, v::T) where {T <: Integer, P}
	@match zxwd.st[v] begin
		Z(p) => printstyled(io, "S_$(v){phase = $(p)}"; color = :green)
		X(p) => printstyled(io, "S_$(v){phase = $(p)}"; color = :red)
		Input(q) => printstyled(io, "S_$(v){input = $(q)}"; color = :blue)
		Output(q) => printstyled(io, "S_$(v){output = $(q)}"; color = :blue)
		H => printstyled(io, "S_$(v){H}"; color = :yellow)
		W => printstyled(io, "S_$(v){W}"; color = :black)
		D => printstyled(io, "S_$(v){D}"; color = :magenta)
		_ => print(io, "S_$(v)")
	end
end


function Base.show(io::IO, zxwd::ZXWDiagram{T, P}) where {T <: Integer, P}
	println(
		io,
		"$(typeof(zxwd)) with $(nv(zxwd.mg)) vertices and $(ne(zxwd.mg)) multiple edges:",
	)
	for v1 in sort!(vertices(zxwd.mg))
		for v2 in neighbors(zxwd.mg, v1)
			if v2 >= v1
				print(io, "(")
				print_spider(io, zxwd, v1)
				print(io, " <-$(mul(zxwd.mg, v1, v2))-> ")
				print_spider(io, zxwd, v2)
				print(io, ")\n")
			end
		end
	end
end


"""
	nv(zxwd)

Returns the number of vertices (spiders) of a ZXW-diagram.
"""
Graphs.nv(zxwd::ZXWDiagram) = nv(zxwd.mg)

"""
	ne(zxwd; count_mul = false)

Returns the number of edges of a ZXW-diagram. If `count_mul`, it will return the
sum of multiplicities of all multiple edges. Otherwise, it will return the
number of multiple edges.
"""
Graphs.ne(zxwd::ZXWDiagram; count_mul::Bool = false) = ne(zxwd.mg, count_mul = count_mul)

Graphs.outneighbors(zxwd::ZXWDiagram, v; count_mul::Bool = false) =
	outneighbors(zxwd.mg, v, count_mul = count_mul)
Graphs.inneighbors(zxwd::ZXWDiagram, v; count_mul::Bool = false) =
	inneighbors(zxwd.mg, v, count_mul = count_mul)
Graphs.degree(zxwd::ZXWDiagram, v::Integer) = degree(zxwd.mg, v)
Graphs.indegree(zxwd::ZXWDiagram, v::Integer) = degree(zxwd, v)
Graphs.outdegree(zxwd::ZXWDiagram, v::Integer) = degree(zxwd, v)

"""
	neighbors(zxwd, v; count_mul = false)

Returns a vector of vertices connected to `v`. If `count_mul`, there will be
multiple copy for each vertex. Otherwise, each vertex will only appear once.
"""
Graphs.neighbors(zxwd::ZXWDiagram, v; count_mul::Bool = false) =
	neighbors(zxwd.mg, v, count_mul = count_mul)
function Graphs.rem_edge!(zxwd::ZXWDiagram, x...)
	rem_edge!(zxwd.mg, x...)
end
function Graphs.add_edge!(zxwd::ZXWDiagram, x...)
	add_edge!(zxwd.mg, x...)
end

"""
	rem_spiders!(zxwd, vs)

Remove spiders indexed by `vs`.
"""
function rem_spiders!(zxwd::ZXWDiagram{T, P}, vs::Vector{T}) where {T <: Integer, P}
	if rem_vertices!(zxwd.mg, vs)
		for v in vs
			delete!(zxwd.st, v)
		end
		return true
	end
	return false
end

"""
	rem_spider!(zxwd, v)

Remove a spider indexed by `v`.
"""
rem_spider!(zxwd::ZXWDiagram{T, P}, v::T) where {T <: Integer, P} = rem_spiders!(zxwd, [v])

"""
	add_spider!(zxwd, spider, connect = [])

Add a new spider `spider` with appropriate parameter
connected to the vertices `connect`. """
function add_spider!(
	zxwd::ZXWDiagram{T, P},
	spider::ZXWSpiderType,
	connect::Vector{T} = T[],
) where {T <: Integer, P}
	if any(!has_vertex(zxwd.mg, c) for c in connect)
		error("The vertex to connect does not exist.")
	end

	v = add_vertex!(zxwd.mg)[1]
	zxwd.st[v] = spider

	for c in connect
		add_edge!(zxwd.mg, v, c)
	end

	return v
end

"""
	insert_spider!(zxwd, v1, v2, spider)

Insert a spider `spider` with appropriate parameter, between two
vertices `v1` and `v2`. It will insert multiple times if the edge between
`v1` and `v2` is a multiple edge. Also it will remove the original edge between
`v1` and `v2`.
"""
function insert_spider!(
	zxwd::ZXWDiagram{T, P},
	v1::T,
	v2::T,
	spider::ZXWSpiderType,
) where {T <: Integer, P}
	mt = mul(zxwd.mg, v1, v2)
	vs = Vector{T}(undef, mt)
	for i ∈ 1:mt
		v = add_spider!(zxwd, spider, [v1, v2])
		@inbounds vs[i] = v
		rem_edge!(zxwd, v1, v2)
	end
	return vs
end

spiders(zxwd::ZXWDiagram) = vertices(zxwd.mg)

"""
	get_inputs(zxwd)

Returns a vector of input ids.
"""
get_inputs(zxwd::ZXWDiagram) = zxwd.inputs

function get_input_idx(zxwd::ZXWDiagram{T, P}, q::T) where {T, P}
	for (i, v) in enumerate(get_inputs(zxwd))
		res = @match spider_type(zxwd, v) begin
			Input(q2) && if q2 == q
			end => v
			_ => nothing
		end
		!isnothing(res) && return res
	end
	return -1
end
"""
	get_outputs(zxwd)

Returns a vector of output ids.
"""
get_outputs(zxwd::ZXWDiagram) = zxwd.outputs

function get_output_idx(zxwd::ZXWDiagram{T, P}, q::T) where {T, P}
	for (i, v) in enumerate(get_outputs(zxwd))
		res = @match spider_type(zxwd, v) begin
			Output(q2) && if q2 == q
			end => v
			_ => nothing
		end
		!isnothing(res) && return res
	end
	return -1
end

scalar(zxwd::ZXWDiagram) = zxwd.scalar

function add_global_phase!(zxwd::ZXWDiagram{T, P}, p::P) where {T, P}
	add_phase!(zxwd.scalar, p)
	return zxwd
end

function add_power!(zxwd::ZXWDiagram, n)
	add_power!(zxwd.scalar, n)
	return zxwd
end

"""
	push_gate!(zxwd, ::Val{M}, locs...[, phase]; autoconvert=true)

Push an `M` gate to the end of qubit `loc` where `M` can be `:Z`, `:X`, `:H`, `:SWAP`, `:CNOT` and `:CZ`.
If `M` is `:Z` or `:X`, `phase` will be available and it will push a
rotation `M` gate with angle `phase * π`.
If `autoconvert` is `false`, the input `phase` should be a rational numbers.
"""

function push_gate!(
	zxwd::ZXWDiagram{T, P},
	::Val{:Z},
	loc::T,
	phase = zero(P);
	autoconvert::Bool = true,
) where {T, P}
	out_id = get_output_idx(zxwd, loc)
	@inbounds bound_id = neighbors(zxwd, out_id)[1]
	rphase = autoconvert ? safe_convert(P, phase) : phase
	insert_spider!(zxwd, bound_id, out_id, Z(Parameter(Val(:PiUnit), rphase)))
	return zxwd
end

function push_gate!(
	zxwd::ZXWDiagram{T, P},
	::Val{:X},
	loc::T,
	phase = zero(P);
	autoconvert::Bool = true,
) where {T, P}
	out_id = get_output_idx(zxwd, loc)
	@inbounds bound_id = neighbors(zxwd, out_id)[1]
	rphase = autoconvert ? safe_convert(P, phase) : phase
	insert_spider!(zxwd, bound_id, out_id, X(Parameter(Val(:PiUnit), rphase)))
	return zxwd
end

function push_gate!(
	zxwd::ZXWDiagram{T, P},
	::Val{:Y},
	loc::T,
	phase = zero(P);
	autoconvert::Bool = true,
) where {T, P}
	push_gate!(zxwd, Val(:Z), loc, 3 // 2)
	push_gate!(zxwd, Val(:X), loc, phase)
	push_gate!(zxwd, Val(:Z), loc, 1 // 2)
	return zxwd
end

function push_gate!(zxwd::ZXWDiagram{T, P}, ::Val{:H}, loc::T) where {T, P}
	out_id = get_output_idx(zxwd, loc)
	@inbounds bound_id = neighbors(zxwd, out_id)[1]
	insert_spider!(zxwd, bound_id, out_id, H)
	return zxwd
end

function push_gate!(zxwd::ZXWDiagram{T, P}, ::Val{:SWAP}, locs::Vector{T}) where {T, P}
	q1, q2 = locs
	push_gate!(zxwd, Val{:Z}(), q1)
	push_gate!(zxwd, Val{:Z}(), q2)
	push_gate!(zxwd, Val{:Z}(), q1)
	push_gate!(zxwd, Val{:Z}(), q2)
	v1, v2, bound_id1, bound_id2 = (sort!(spiders(zxwd)))[end-3:end]
	rem_edge!(zxwd, v1, bound_id1)
	rem_edge!(zxwd, v2, bound_id2)
	add_edge!(zxwd, v1, bound_id2)
	add_edge!(zxwd, v2, bound_id1)
	return zxwd
end

function push_gate!(zxwd::ZXWDiagram{T, P}, ::Val{:CNOT}, loc::T, ctrl::T) where {T, P}
	push_gate!(zxwd, Val{:Z}(), ctrl)
	push_gate!(zxwd, Val{:X}(), loc)
	@inbounds v1, v2 = (sort!(spiders(zxwd)))[end-1:end]
	add_edge!(zxwd, v1, v2)
	add_power!(zxwd, 1)
	return zxwd
end

function push_gate!(zxwd::ZXWDiagram{T, P}, ::Val{:CZ}, loc::T, ctrl::T) where {T, P}
	push_gate!(zxwd, Val{:Z}(), ctrl)
	push_gate!(zxwd, Val{:Z}(), loc)
	@inbounds v1, v2 = (sort!(spiders(zxwd)))[end-1:end]
	add_edge!(zxwd, v1, v2)
	insert_spider!(zxwd, v1, v2, H)
	add_power!(zxwd, 1)
	return zxwd
end

"""
	pushfirst_gate!(zxwd, ::Val{M}, loc[, phase])

Push an `M` gate to the beginning of qubit `loc` where `M` can be `:Z`, `:X`, `:H`, `:SWAP`, `:CNOT` and `:CZ`.
If `M` is `:Z` or `:X`, `phase` will be available and it will push a
rotation `M` gate with angle `phase * π`.
"""
function pushfirst_gate!(
	zxwd::ZXWDiagram{T, P},
	::Val{:Z},
	loc::T,
	phase::P = zero(P),
) where {T, P}
	in_id = get_input_idx(zxwd, loc)
	@inbounds bound_id = neighbors(zxwd, in_id)[1]
	insert_spider!(zxwd, in_id, bound_id, Z(Parameter(Val(:PiUnit), phase)))
	return zxwd
end

function pushfirst_gate!(
	zxwd::ZXWDiagram{T, P},
	::Val{:X},
	loc::T,
	phase::P = zero(P),
) where {T, P}
	in_id = get_input_idx(zxwd, loc)
	@inbounds bound_id = neighbors(zxwd, in_id)[1]
	insert_spider!(zxwd, in_id, bound_id, X(Parameter(Val(:PiUnit), phase)))
	return zxwd
end

function pushfirst_gate!(zxwd::ZXWDiagram{T, P}, ::Val{:H}, loc::T) where {T, P}
	in_id = get_input_idx(zxwd, loc)
	@inbounds bound_id = neighbors(zxwd, in_id)[1]
	insert_spider!(zxwd, in_id, bound_id, H)
	return zxwd
end

function pushfirst_gate!(zxwd::ZXWDiagram{T, P}, ::Val{:SWAP}, locs::Vector{T}) where {T, P}
	q1, q2 = locs
	pushfirst_gate!(zxwd, Val{:Z}(), q1)
	pushfirst_gate!(zxwd, Val{:Z}(), q2)
	pushfirst_gate!(zxwd, Val{:Z}(), q1)
	pushfirst_gate!(zxwd, Val{:Z}(), q2)
	@inbounds v1, v2, bound_id1, bound_id2 = (sort!(spiders(zxwd)))[end-3:end]
	rem_edge!(zxwd, v1, bound_id1)
	rem_edge!(zxwd, v2, bound_id2)
	add_edge!(zxwd, v1, bound_id2)
	add_edge!(zxwd, v2, bound_id1)
	return zxwd
end

function pushfirst_gate!(zxwd::ZXWDiagram{T, P}, ::Val{:CNOT}, loc::T, ctrl::T) where {T, P}
	pushfirst_gate!(zxwd, Val{:Z}(), ctrl)
	pushfirst_gate!(zxwd, Val{:X}(), loc)
	@inbounds v1, v2 = (sort!(spiders(zxwd)))[end-1:end]
	add_edge!(zxwd, v1, v2)
	add_power!(zxwd, 1)
	return zxwd
end

function pushfirst_gate!(zxwd::ZXWDiagram{T, P}, ::Val{:CZ}, loc::T, ctrl::T) where {T, P}
	pushfirst_gate!(zxwd, Val{:Z}(), ctrl)
	pushfirst_gate!(zxwd, Val{:Z}(), loc)
	@inbounds v1, v2 = (sort!(spiders(zxwd)))[end-1:end]
	add_edge!(zxwd, v1, v2)
	insert_spider!(zxwd, v1, v2, H)
	add_power!(zxwd, 1)
	return zxwd
end

"""

Insert W triangle on a vector of vertices

"""
function insert_wtrig!(zxwd::ZXWDiagram{T, P}, locs::Vector{T}) where {T, P}
	length(locs) < 2 && return nothing

	head = locs[1]

	for loc in locs[2:end]
		prev_w = add_spider!(zxwd, W, [head, loc])
		head = add_spider!(zxwd, W, [prev_w])
	end
	return head
end

"""
Convert ZXWDiagram that represents unitary U to U^†
"""
function dagger(zxwd::ZXWDiagram{T, P}) where {T, P}
	zxwd_dg = copy(zxwd)
	for v in vertices(zxwd_dg.mg)
		@match zxwd_dg.st[v] begin
			Input(q) => (zxwd_dg.st[v] = Output(q))
			Output(q) => (zxwd_dg.st[v] = Input(q))
			Z(p) => (zxwd_dg.st[v] = Z(inv(p)))
			X(p) => (zxwd_dg.st[v] = X(inv(p)))
			W => nothing
			H => nothing
			D => nothing
		end
	end
	for i ∈ 1:nin(zxwd_dg)
		@inbounds zxwd_dg.inputs[i] = zxwd.outputs[i]
		@inbounds zxwd_dg.outputs[i] = zxwd.inputs[i]
	end

	return zxwd_dg
end

"""
Concatenate two ZXWDiagrams, modify d1.

Remove outputs of d1 and inputs of d2. Then add edges between to vertices
that was conntecting to outputs of d1 and inputs of d2.
Assuming you don't concatenate two empty circuit ZXWDiagram
"""
function concat!(d1::ZXWDiagram{T, P}, d2::ZXWDiagram{T, P}) where {T, P}
	nout(d1) != nin(d2) &&
		error("Number of outputs of d1 and inputs of d2 must be the same")

	v2tov1 = Dict{T, T}()
	import_non_in_out!(d1, d2, v2tov1)

	for i ∈ 1:nout(d1)
		out_idx = get_output_idx(d1, i)
		# output spiders cannot be connected to multiple vertices or with multiedge
		prior_vtx = neighbors(d1, out_idx)[1]
		rem_edge!(d1, out_idx, prior_vtx)
		# d2 input vtx idx is mapped to the vtx prior to d1 output
		v2tov1[get_input_idx(d2, i)] = prior_vtx
	end

	for i ∈ 1:nout(d2)
		v2tov1[get_output_idx(d2, i)] = get_output_idx(d1, i)
	end

	import_edges!(d1, d2, v2tov1)
	add_global_phase!(d1, d2.scalar.phase)
	add_power!(d1, d2.scalar.power_of_sqrt_2)
	return d1
end

"""
Add input and outputs to diagram
"""
function add_inout!(zxwd::ZXWDiagram{T, P}, n::T) where {T, P}
	nq = nqubits(zxwd)
	for i ∈ 1:n
		idxin = add_spider!(zxwd, Input(n + nq), T[])
		push!(zxwd.inputs, idxin)
		idxout = add_spider!(zxwd, Output(n + nq), T[])
		push!(zxwd.outputs, idxout)
		add_edge!(zxwd, idxin, idxout)
	end
	return zxwd
end

"""
Stacking two ZXWDiagrams in place. Modify d1.

Performs tensor product of two ZXWDiagrams. The result is a ZXWDiagram with d1 on
lower qubit indices. Assuming number of inputs and outputs of are the same for both d1 and d2.
"""
function stack_zxwd!(d1::ZXWDiagram{T, P}, d2::ZXWDiagram{T, P}) where {T, P}
	prior_nq = nqubits(d1)
	add_inout!(d1, nqubits(d2))
	for in_vtx in d1.inputs[end-nqubits(d2)+1:end]
		rem_edge!(d1, in_vtx, neighbors(d1, in_vtx)[1])
	end

	add_global_phase!(d1, d2.scalar.phase)
	add_power!(d1, d2.scalar.power_of_sqrt_2)

	v2tov1 = Dict{T, T}()

	import_non_in_out!(d1, d2, v2tov1)

	for (i, idx) in enumerate(get_inputs(d2))
		v2tov1[idx] = get_inputs(d1)[i+prior_nq]
	end
	for (i, idx) in enumerate(get_outputs(d2))
		v2tov1[idx] = get_outputs(d1)[i+prior_nq]
	end

	import_edges!(d1, d2, v2tov1)
	return d1
end

"""
Add non input and output spiders of d2 to d1, modify d1. Record the mapping of vertex indices.
"""
function import_non_in_out!(
	d1::ZXWDiagram{T, P},
	d2::ZXWDiagram{T, P},
	v2tov1::Dict{T, T},
) where {T, P}
	for v2 in vertices(d2.mg)
		new_v = @match spider_type(d2, v2) begin
			Input(q) => nothing
			Output(q) => nothing
			(Z(_) || X(_) || W || H || D) => add_vertex!(d1.mg)[1]
			_ => error("Unknown spider type $(d2.st[v2])")
		end
		if !isnothing(new_v)
			v2tov1[v2] = new_v
			d1.st[new_v] = spider_type(d2, v2)
		end
	end
end

"""
Import edges of d2 to d1, modify d1
"""
function import_edges!(
	d1::ZXWDiagram{T, P},
	d2::ZXWDiagram{T, P},
	v2tov1::Dict{T, T},
) where {T, P}
	for edge in edges(d2.mg)
		src, dst, emul = edge.src, edge.dst, edge.mul
		add_edge!(d1.mg, v2tov1[src], v2tov1[dst], emul)
	end
end

"""
Construct ZXW Diagram for representing the expectation value circuit
"""
function expval_circ!(zxwd::ZXWDiagram{T, P}, H::String) where {T, P}
	# convert U to U H U^\dagger
	zxwd_dag = dagger(zxwd)
	for (i, h) in enumerate(H)
		if h == 'Z'
			push_gate!(zxwd, Val(:Z), i, 1.0)
		elseif h == 'X'
			push_gate!(zxwd, Val(:X), i, 1.0)
		elseif h == 'Y'
			push_gate!(zxwd, Val(:Z), i, 1.0)
			push_gate!(zxwd, Val(:X), i, 1.0)
			add_global_phase!(zxwd, P(π / 2))
		elseif h == 'I'
			continue
		else
			error("Invalid Hamiltonian, enter only Z, X, Y")
		end
	end
	concat!(zxwd, zxwd_dag)
	return zxwd
end

"""

Finds vertices of Spider that contains the parameter θ or -θ
"""
function symbol_vertices(zxwd::ZXWDiagram{T, P}, θ::Symbol; neg::Bool = false) where {T, P}
	if neg
		target = Expr(:call, :-, θ)
	else
		target = θ
	end
	matched = T[]
	for v in vertices(zxwd.mg)
		res = @match spider_type(zxwd, v) begin
			Z(p1) && if contains(p1, target)
			end => v
			X(p1) && if contains(p1, target)
			end => v
			_ => nothing
		end
		!isnothing(res) && push!(matched, v)
	end
	return matched
end

"""
Replace symbols in ZXW Diagram with specific values
"""
function substitute_variables!(
	zxwd::ZXWDiagram{T, P},
	sbd::Dict{Symbol, <:Number},
) where {T, P}
	for (θ, val) in sbd
		for negative in [false, true]
			matched_pos = symbol_vertices(zxwd, θ; neg = negative)
			val = negative ? -val : val
			for idx in matched_pos
				p = spider_type(zxwd, idx).p
				@match p begin
					PiUnit(pu, _) => set_phase!(zxwd, idx, Parameter(Val(:PiUnit), val))
					Factor(pf, _) => set_phase!(zxwd, idx, Parameter(Val(:Factor), val))
				end
			end
		end
	end
	return zxwd
end
