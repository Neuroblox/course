# This file was generated, do not modify it.

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
data = solve(prob, Tsit5())

noise_distribution = Normal(0, 0.1)
data .+= rand(noise_distribution, size(data))

# define a setter function to easily change parameter values during each optimization iteration
setter! = setp(sys, [nm.kₑₑ, nm.kᵢᵢ, nm.kₑᵢ, nm.kᵢₑ])

# initial guess for the parameters to be optimized
p0 = [0.2, 3.3, 2, 3.5]
setter!(prob, p0)
sol = solve(prob, Tsit5())

states = unknowns(sys)
fig = Figure(size = (1600, 800), fontsize=22)
axs = [
    Axis(fig[1,1], title=String(Symbol(states[1]))),
    Axis(fig[1,2], title=String(Symbol(states[2]))),
    Axis(fig[2,1], title=String(Symbol(states[3]))),
    Axis(fig[2,2], title=String(Symbol(states[4]))),
    Axis(fig[3,1], title=String(Symbol(states[5]))),
    Axis(fig[3,2], title=String(Symbol(states[6]))),
    Axis(fig[4,1], title=String(Symbol(states[7]))),
    Axis(fig[4,2], title=String(Symbol(states[8])))
]
for (i,s) in enumerate(states)
    lines!(axs[i], data[s], label="Data")
    lines!(axs[i], sol[s], label="Initial Guess")
end
colsize!(fig.layout, 1, Relative(1/2))
Legend(fig[5,1], last(axs))
fig
save(joinpath(@OUTPUT, "opt_init.svg"), fig); # hide

# define the least squares loss function
function loss(p, data, prob)
    setter!(prob, p)
    sol = solve(prob, Tsit5())

    return sum(abs2, sol .- data)
end

# Use finite differences to calculate gradients of the loss function
objective = OptimizationFunction((p, data) -> loss(p, data, prob), AutoFiniteDiff())
prob_opt = OptimizationProblem(objective, p0, data)
# run the optimization using the LBFGS optimizer
res = solve(prob_opt, Optimization.LBFGS())
# print the return code to check that the optimization was successful
@show res.retcode

println("Ground truth parameters are $(p_ground_truth)")
println("Fitted parameters are $(res.u)")

setter!(prob, res.u)
sol = solve(prob, Tsit5())

fig = Figure(size = (1600, 800), fontsize=22)
axs = [
    Axis(fig[1,1], title=String(Symbol(states[1]))),
    Axis(fig[1,2], title=String(Symbol(states[2]))),
    Axis(fig[2,1], title=String(Symbol(states[3]))),
    Axis(fig[2,2], title=String(Symbol(states[4]))),
    Axis(fig[3,1], title=String(Symbol(states[5]))),
    Axis(fig[3,2], title=String(Symbol(states[6]))),
    Axis(fig[4,1], title=String(Symbol(states[7]))),
    Axis(fig[4,2], title=String(Symbol(states[8])))
]
for (i,s) in enumerate(states)
    lines!(axs[i], data[s], label="Data")
    lines!(axs[i], sol[s], label="Optimized Solution")
end
colsize!(fig.layout, 1, Relative(1/2))
Legend(fig[5,1], last(axs))
fig
save(joinpath(@OUTPUT, "opt_final.svg"), fig); # hide
