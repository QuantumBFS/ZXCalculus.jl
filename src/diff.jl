using ZXCalculus: contains, dagger, concat!, stack


"""
Integrate over the Spiders at locs with respect to the parameter θ.

User need to check that the parameters are indeed in the form of k * θ where k is Int
"""
function integrate!(zxwd::ZXWDiagram{T,P}, locs::Vector{T}) where {T,P}
    length(locs) == 2 && return integrate2!(zxwd, locs[1], locs[2])
    length(locs) == 4 && return integrate4!(zxwd, locs[1], locs[2], locs[3], locs[4])
end

function integrate2!(zxwd::ZXWDiagram{T,P}, loc1::T, loc2::T) where {T,P}
    loc1 = int_prep!(zxwd, loc1)
    loc2 = int_prep!(zxwd, loc2)
    add_edge!(zxwd.mg, loc1, loc2)
    return zxwd
end

"""
Integrate two pairs of +/- parameter. Theorem 23 of https://arxiv.org/abs/2201.13250
"""
function integrate4!(zxwd::ZXWDiagram{T,P}, loca::T, locb::T, locc::T, locd::T) where {T,P}
    loca = int_prep!(zxwd, loca)
    locb = int_prep!(zxwd, locb)
    locc = int_prep!(zxwd, locc)
    locd = int_prep!(zxwd, locd)

    # a, b = + , - \theta
    # c, d = + , - \theta
    loca = add_spider!(zxwd, Z(Parameter(Val(:PiUnit), 0)), [loca])
    locb = add_spider!(zxwd, Z(Parameter(Val(:PiUnit), 0)), [locb])
    locc = add_spider!(zxwd, X(Parameter(Val(:PiUnit), 0)), [locc])
    locd = add_spider!(zxwd, X(Parameter(Val(:PiUnit), 0)), [locd])

    add_edge!(zxwd, loca, locc)
    add_edge!(zxwd, locb, locd)

    locm = add_spider!(zxwd, X(Parameter(Val(:PiUnit), 0)), [loca, locb])
    locm = add_spider!(zxwd, D, [locm])
    locm = add_spider!(zxwd, X(Parameter(Val(:PiUnit), 1.0)), [locm])
    add_spider!(zxwd, Z(Parameter(Val(:PiUnit), 0)), [locm, locc, locd])

    # pink spider is different from red spider, we had three of them
    # each with three legs, 3 * (3-2)/2 powers of 2 need to be added
    # see 2307.01803
    add_power!(zxwd,3)
    return zxwd
end

"""
Prepare spider at loc for integration.

Perform the simplified step of zeroing out phase of spider
and readying it for integration
1. If target spider is X spider, turn it to Z by adding H to all its legs
2. Pull out the Phase of the spider
3. zero out the phase
4. change the current spider back to its original type if necessary,
 will generate one extra H spider.
"""
function int_prep!(zxwd::ZXWDiagram{T,P}, loc::T) where {T,P}
    set_phase!(zxwd, loc, Parameter(Val(:PiUnit), 0.0))

    new_loc = @match spider_type(zxwd, loc) begin
        X(_) => add_spider!(zxwd, H, [loc])
        Z(_) => loc
        _ => error("Not a valid Spider to integrate over")
    end
    return new_loc
end
