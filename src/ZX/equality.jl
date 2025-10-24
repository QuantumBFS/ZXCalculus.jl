"""
    verify_equality(zxd_1::ZXDiagram, zxd_2::ZXDiagram)

checks the equivalence of two different ZXDiagrams
"""
function verify_equality(zxd_1::ZXDiagram, zxd_2::ZXDiagram)
    merged_diagram = copy(zxd_1)
    merged_diagram = concat!(merged_diagram, dagger(zxd_2))
    m_simple = full_reduction(merged_diagram)
    return contains_only_bare_wires(m_simple)
end

function contains_only_bare_wires(zxd::Union{ZXDiagram, ZXGraph})
    return all(is_in_or_out_spider(st[2]) for st in zxd.st)
end
contains_only_bare_wires(zxd::ZXCircuit) = contains_only_bare_wires(zxd.zx_graph)

function is_in_or_out_spider(st::SpiderType.SType)
    return st == SpiderType.In || st == SpiderType.Out
end
