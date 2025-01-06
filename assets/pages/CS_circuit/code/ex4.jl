# This file was generated, do not modify it. # hide
@named sys = system_from_graph(g)
prob = ODEProblem(sys, [], (0.0, 1000), [])
sol = solve(prob, Vern7())
fig = stackplot([exci1, exci2, exci3, exci4, exci5, inh], sol)
save(joinpath(@OUTPUT, "wta_stack.svg"), fig); # hide