# This file was generated, do not modify it. # hide
g = MetaDiGraph()
# Also set the weight value this time
add_edge!(g, izh => lif, weight = 1)

@named sys = system_from_graph(g)
prob = ODEProblem(sys, [], (0, 200.0))
sol = solve(prob, Tsit5());