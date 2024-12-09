# This file was generated, do not modify it. # hide
# Model system and simplification.
@named izh_system = ODESystem(eqs, t, [v, u], [a, b, c, d, I]; discrete_events = event)
izh_simple = structural_simplify(izh_system)

# Initial conditions.
u0 = [v => -65.0, u => -13.0]

# Simulation timespan
tspan = (0.0, 400.0)

izh_prob = ODEProblem(izh_simple, u0, tspan)

izh_sol = solve(izh_prob)

plot(izh_sol)
# or if we want to plot just the voltage timeseries with its spiking pattern
plot(izh_sol; idxs=[v])