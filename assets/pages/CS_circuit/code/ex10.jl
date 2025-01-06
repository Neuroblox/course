# This file was generated, do not modify it. # hide
# number if WTA circuits = N_wta=45
# number of pyramidal neurons in each WTA circuit = N_exci = 5
@named CB = CorticalBlox(N_wta=10, N_exci=5, density=0.01, weight=1, I_bg_ar=7; namespace=model_name)

g = MetaDiGraph()
add_edge!(g, ASC1 => CB, weight=44)

# solve the system for time 0 to 1000 ms
sys = system_from_graph(g, name = model_name)
prob = ODEProblem(sys, [], (0.0, 1000))
sol = solve(prob, Vern7());

neuron_set = get_neurons(CB) ## extract neurons from a composite block like CorticalBlox
n_neurons = 50 ## set number of neurons to display in the stackplot
fig = stackplot(neuron_set[1:n_neurons], sol)
save(joinpath(@OUTPUT, "cort_asc_stack.svg"), fig); # hide