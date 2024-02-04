using YaoHIR: BlockIR
using YaoHIR, YaoLocations
using Core.Compiler: IRCode

chain = Chain()
push_gate!(chain, Val(:H), 1)
push_gate!(chain, Val(:H), 2)
push_gate!(chain, Val(:H), 3)
push_gate!(chain, Val(:H), 4)
push_gate!(chain, Val(:CNOT), 4, 1)
push_gate!(chain, Val(:CNOT), 4, 3)
push_gate!(chain, Val(:X), 1)
push_gate!(chain, Val(:X), 2)
push_gate!(chain, Val(:X), 3)

bir = BlockIR(IRCode(), 4, chain)
d1 = ZXDiagram(bir)

# create second version
d2 = copy(d1)
# Push H spider with Val spidertype
push_gate!(d2, Val(:H), 1)

# FIXME @test verify_equality(d1, d1) == true
# @test verify_equality(d1, d2) == false
