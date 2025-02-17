# This file was generated, do not modify it. # hide
using Neuroblox
using OrdinaryDiffEq
using Optimization ## the general interface for solving optimization problems
using CairoMakie
using SymbolicIndexingInterface ## a package to handle parameter changes in our ODEProblem on every optimization iteration
using Distributions
using Random

Random.seed!(1)

@named nm = NextGenerationEIBlox(; kₑₑ=2, kᵢᵢ=1.5, kₑᵢ=5.5, kᵢₑ=7);

sys = system(nm)

tspan = (0, 100)
t_save = first(tspan):last(tspan) ## define the exact timepoints when data/simulation will be saved

# ground truth parameter values, ideally the ones to be retrieved after optimization
p_ground_truth = [2, 1.5, 5.5, 7]
prob = ODEProblem(
    sys,
    [],
    tspan,
    [nm.kₑₑ => p_ground_truth[1], nm.kᵢᵢ => p_ground_truth[2], nm.kₑᵢ => p_ground_truth[3], nm.kᵢₑ => p_ground_truth[4]];
    saveat=t_save
)

# generate fictive data, aka the ground truth
data = solve(prob, Tsit5());