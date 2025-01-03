# This file was generated, do not modify it. # hide
g = MetaDiGraph()
add_edge!(g, inp => nm, weight = 1)

@named sys = system_from_graph(g)
prob = ODEProblem(sys, [], tspan)
sol = solve(prob, Tsit5())

fig, ax = plot(sol);
axislegend(ax)
fig
save(joinpath(@OUTPUT, "wc_input.svg"), fig); # hide