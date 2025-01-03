# This file was generated, do not modify it. # hide
sys = system_from_graph(g, name = model_name)
prob = ODEProblem(sys, [], (0.0, 1000))
sol = solve(prob, Vern7())

wta_neurons = get_neurons(wtas) ## extract neurons from WTA circuits
neurons = vcat(wta_neurons, n_ff_inh)
fig = stackplot(neurons, sol)
save(joinpath(@OUTPUT, "cort_stack.svg"), fig); # hide