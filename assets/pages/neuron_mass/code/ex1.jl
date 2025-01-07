# This file was generated, do not modify it. # hide
using Neuroblox
using OrdinaryDiffEq
using CairoMakie

# Set the random seed for reproducible results
using Random
Random.seed!(1)

@named nm = WilsonCowan()
# Retrieve the simplified ODESystem of the Blox
sys = system(nm)
tspan = (0, 100) # ms
prob = ODEProblem(sys, [], tspan)
sol = solve(prob, Tsit5())

fig, ax = plot(sol);
axislegend(ax) ## add legend to the plot
fig
save(joinpath(@OUTPUT, "wc_all.svg"), fig); # hide