include("../script/zx_plot.jl")

export phase_teleportation
function phase_teleportation(cir::ZXDiagram{T, P}) where {T, P}
    ncir = copy(cir)
    zxg = ZXGraph(ncir)

    println(zxg.phase_ids)
    # simplify...
    simplify!(Rule{:lc}(), zxg)
    simplify!(Rule{:p1}(), zxg)
    simplify!(Rule{:p2}(), zxg)
    simplify!(Rule{:p3}(), zxg)
    simplify!(Rule{:lc}(), zxg)
    simplify!(Rule{:p1}(), zxg)
    match_id = match(Rule{:id}(), zxg)
    match_gf = match(Rule{:gf}(), zxg)
    while length(match_id) + length(match_gf) > 0
        rewrite!(Rule{:id}(), zxg, match_id)
        rewrite!(Rule{:gf}(), zxg, match_gf)
        simplify!(Rule{:lc}(), zxg)
        simplify!(Rule{:p1}(), zxg)
        simplify!(Rule{:p2}(), zxg)
        simplify!(Rule{:p3}(), zxg)
        simplify!(Rule{:lc}(), zxg)
        simplify!(Rule{:p1}(), zxg)
        match_id = match(Rule{:id}(), zxg)
        match_gf = match(Rule{:gf}(), zxg)
    end

    phase_ids = zxg.phase_ids
    for (v, vs) in phase_ids
        reduce_phases!(ncir, vs)
    end
    simplify!(Rule{:i1}(), ncir)
    simplify!(Rule{:i2}(), ncir)
    return ncir
end

function reduce_phases!(cir::ZXDiagram{T,P}, vs::Vector{Tuple{T, Int}}) where {T, P}
    if length(vs) > 1
        n = 1
        while n <= length(vs) && length(neighbors(cir, vs[n][1])) != 2
            n += 1
        end
        n > length(vs) && (n = 1)
        for i = 1:length(vs)
            if i != n
                cir.ps[vs[n][1]] += cir.ps[vs[i][1]] * vs[n][2]
                cir.ps[vs[i][1]] = 0
            end
        end
        rounding_phases!(cir)
    end
end
