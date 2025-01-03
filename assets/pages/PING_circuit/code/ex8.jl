# This file was generated, do not modify it. # hide
tspan = (0.0, 300.0) ## Time span for the simulation - run for 300ms to match the Börgers et al. [1] Figure 1.
@named sys = system_from_graph(g, graphdynamics=true)
prob = ODEProblem(sys, [], tspan) ## Create the problem to solve
sol = solve(prob, Tsit5(), saveat=0.1); ## Solve the problem and save at 0.1ms resolution.