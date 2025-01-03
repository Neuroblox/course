# This file was generated, do not modify it. # hide
g = MetaDiGraph()
# Set const_current to a value that is other than its default.
add_edge!(g, izh => lif; weight = 1, const_current=20)

@named sys = system_from_graph(g)
prob = ODEProblem(sys, [], (0, 200.0))
sol = solve(prob, Tsit5());