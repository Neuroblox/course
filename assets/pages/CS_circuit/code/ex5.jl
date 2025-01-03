# This file was generated, do not modify it. # hide
sys = system_from_graph(g, name=model_name)
prob = ODEProblem(sys, [], (0.0, 1000), [])
sol = solve(prob, Vern7())

neuron_set = get_neurons([wta1, wta2]) ## extract neurons from a composite blocks
fig = stackplot(neuron_set, sol)
save(joinpath(@OUTPUT, "wta_wta_stack.svg"), fig); # hide