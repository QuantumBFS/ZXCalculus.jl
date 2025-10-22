using Test
using ZXCalculus.Utils: Scalar, add_power!, add_phase!

s = Scalar()
@test s * s == s
@test add_power!(s, 1) == Scalar(1, 0)
@test add_phase!(s, 1) == Scalar(1, 1)
