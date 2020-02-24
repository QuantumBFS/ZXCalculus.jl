using LightGraphs, MetaGraphs

export ZXGraph
# struct ZXGraph
#     mg::MetaGraph
# end

function ZXGraph(zxd0::ZXDiagram)
    zxd = copy(zxd0)

    for v in nv(zxd):-1:1
        if check_rule_i1(zxd, v) == true
            rule_i1!(zxd, v)
        end
    end

    for v in ZX.find_spiders(zxd, X)
        rule_h!(zxd, v)
    end

    vH = ZX.find_spiders(zxd, H)
    while length(vH) > 0
        v1 = pop!(vH)
        nb = outneighbors(zxd, v1)
        v2 = v1
        if nb[1] in vH
            v2 = nb[1]
        elseif nb[2] in vH
            v2 = nb[2]
        end

        setdiff!(vH, v2)
        if v1 != v2
            vmap = rule_i2!(zxd, v1, v2)
            vH = [findfirst(x->x==v, vmap) for v in vH]
        end
    end

    

    zxd
end
