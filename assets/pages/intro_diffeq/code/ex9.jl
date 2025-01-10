# This file was generated, do not modify it. # hide
@variables v(t)=-65 u(t)=-13 I(t)
@parameters a=0.02 b=0.2 c=-65 d=8 ## These parameter values correspond to regular spiking.

eqs = [D(v) ~ 0.04 * v ^ 2 + 5 * v + 140 - u + I,
        D(u) ~ a * (b * v - u),
        I ~ 10*sin(0.5*t)]

event = (v > 30.0) => [u ~ u + d, v ~ c]

@named izh_system = ODESystem(eqs, t, [v, u, I], [a, b, c, d]; discrete_events = event)
izh_simple = structural_simplify(izh_system)