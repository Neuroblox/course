# This file was generated, do not modify it. # hide
tspan = (0.0, 400.0)

# We do not provide initial conditions, so the default values for `v` and `u` from above will be used.
izh_prob = ODEProblem(izh_simple, [], tspan)

izh_sol = solve(izh_prob)

fig = plot(izh_sol; idxs=[v, I])
fig