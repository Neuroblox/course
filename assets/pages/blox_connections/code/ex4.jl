# This file was generated, do not modify it. # hide
g = MetaDiGraph()
add_edge!(g, lif => ifn)

@named sys = system_from_graph(g)
prob = ODEProblem(sys, [], (0, 200.0))
sol = solve(prob, Tsit5());