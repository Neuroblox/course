# This file was generated, do not modify it. # hide
using StochasticDiffEq ## to access stochastic DE solvers

@named hh = HHNeuronExci_STN_Adam_Blox(; σ=2) ## σ is the brownian noise amplitude

sys = system(hh)
prob = SDEProblem(sys, [], (0, 1000))
sol = solve(prob, RKMil())

# Plot the powerspectrum of the solution
fig = powerspectrumplot(hh, sol; samplig_rate=0.01);
fig
save(joinpath(@OUTPUT, "hh_power.svg"), fig); # hide