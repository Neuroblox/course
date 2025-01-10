# This file was generated, do not modify it. # hide
g = MetaDiGraph()
add_edge!(g, background_input => n_A; weight = 1);
add_edge!(g, background_input => n_B; weight = 1);
add_edge!(g, background_input => n_ns; weight = 1);
add_edge!(g, background_input => n_inh; weight = 1);

add_edge!(g, stim_A => n_A; weight = 1);
add_edge!(g, stim_B => n_B; weight = 1);

add_edge!(g, n_A => n_B; weight = w₋);
add_edge!(g, n_A => n_ns; weight = 1);
add_edge!(g, n_A => n_inh; weight = 1);

add_edge!(g, n_B => n_A; weight = w₋);
add_edge!(g, n_B => n_ns; weight = 1);
add_edge!(g, n_B => n_inh; weight = 1);

add_edge!(g, n_ns => n_A; weight = w₋);
add_edge!(g, n_ns => n_B; weight = w₋);
add_edge!(g, n_ns => n_inh; weight = 1);

add_edge!(g, n_inh => n_A; weight = 1);
add_edge!(g, n_inh => n_B; weight = 1);
add_edge!(g, n_inh => n_ns; weight = 1);

sys = system_from_graph(g; name=model_name, graphdynamics = true);
prob = ODEProblem(sys, [], tspan);
sol = solve(prob, Euler(); dt = 0.01);