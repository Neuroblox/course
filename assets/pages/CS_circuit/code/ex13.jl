# This file was generated, do not modify it. # hide
g = MetaDiGraph()
add_edge!(g, stim => VAC, weight=14)
add_edge!(g, ASC1 => VAC, weight=44)
add_edge!(g, ASC1 => AC, weight=44)
add_edge!(g, VAC => AC, weight=3, density=0.08)

# define system and solve
sys = system_from_graph(g, name=model_name)
prob = ODEProblem(sys, [], (0.0, 1000))
sol = solve(prob, Vern7());