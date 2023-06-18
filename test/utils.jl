using .ZXCalculus: Phase, _round_phase_dict!

ps = Dict(1 => -1, 2 => Rational(-100, 3), 3 => Phase(-7))
_round_phase_dict!(ps)
@test ps == Dict(1 => 1, 2 => 2 // 3, 3 => Phase(1))
