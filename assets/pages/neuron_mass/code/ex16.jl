# This file was generated, do not modify it. # hide
@named nn = HHNeuronExciBlox(I_bg=0.4)

g = MetaDiGraph()
add_edge!(g, dbs => nn, weight = 10.0)

@named sys = system_from_graph(g)
prob = ODEProblem(sys, [], tspan)

transitions_inds = detect_transitions(time, stimulus; atol=0.001)
transition_times = time[transitions_inds]
transition_values = stimulus[transitions_inds]
sol = solve(prob, Vern7(), saveat=dt, tstops = transition_times);