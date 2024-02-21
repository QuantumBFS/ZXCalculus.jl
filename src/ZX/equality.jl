"""
    verify_equality(zxd_1::ZXDiagram, zxd_2::ZXDiagram)

checks the equivalence of two different ZXDiagrams

"""
function verify_equality(zxd_1::ZXDiagram, zxd_2::ZXDiagram)
  merged_diagram = concat!(zxd_1, dagger(zxd_2))
  m_simple = full_reduction(merged_diagram)
  contains_only_bare_wires(m_simple)
end

function contains_only_bare_wires(zxd::Union{ZXDiagram,ZXGraph})
  all(is_in_or_out_spider(st[2]) for st in zxd.st)
end

function is_in_or_out_spider(st::SpiderType.SType)
  st == SpiderType.In || st == SpiderType.Out
end
