# This file was generated, do not modify it.

using Neuroblox
using OrdinaryDiffEq
using Distributions
using CairoMakie
using Random

Random.seed!(1)

model_name = :g
tspan = (0, 1000) ## Simulation time span [ms]
spike_rate = 2.4 ## spikes / ms

N = 150 ## total number of neurons
f = 0.15 ## ratio of selective excitatory to non-selective excitatory neurons
f_inh = 0.2 ## ratio of inhibitory neurons to all neurons
N_E = Int(N * (1 - f_inh))
N_I = Int(ceil(N * f_inh)) ## total number of inhibitory neurons
N_E_selective = Int(ceil(f * N_E)) ## number of selective excitatory neurons
N_E_nonselective = N_E - 2 * N_E_selective ## number of non-selective excitatory neurons

# We use two distinct weight values as per Wang [1]
w₊ = 1.7
w₋ = 1 - f * (w₊ - 1) / (1 - f)

exci_scaling_factor = 1600 / N_E
inh_scaling_factor = 400 / N_I

coherence = 0 # random dot motion coherence [%]
dt_spike_rate = 50 # update interval for the stimulus spike rate [ms]
μ_0 = 40e-3 # mean stimulus spike rate [spikes / ms]
ρ_A = ρ_B = μ_0 / 100
μ_A = μ_0 + ρ_A * coherence
μ_B = μ_0 + ρ_B * coherence
σ = 4e-3 # standard deviation of stimulus spike rate [spikes / ms]

spike_rate_A = (distribution=Normal(μ_A, σ), dt=dt_spike_rate) # spike rate distribution for selective population A
spike_rate_B = (distribution=Normal(μ_B, σ), dt=dt_spike_rate) # spike rate distribution for selective population B

@named background_input = PoissonSpikeTrain(spike_rate, tspan; namespace = model_name); ## background input

@named stim_A = PoissonSpikeTrain(spike_rate_A, tspan; namespace = model_name); ## stimulation inputs to selective population A
@named stim_B = PoissonSpikeTrain(spike_rate_B, tspan; namespace = model_name); ## stimulation inputs to selective population B

@named n_A = LIFExciCircuitBlox(; namespace = model_name, N_neurons = N_E_selective, weight = w₊, exci_scaling_factor, inh_scaling_factor);
@named n_B = LIFExciCircuitBlox(; namespace = model_name, N_neurons = N_E_selective, weight = w₊, exci_scaling_factor, inh_scaling_factor) ;
@named n_ns = LIFExciCircuitBlox(; namespace = model_name, N_neurons = N_E_nonselective, weight = 1.0, exci_scaling_factor, inh_scaling_factor);
@named n_inh = LIFInhCircuitBlox(; namespace = model_name, N_neurons = N_I, weight = 1.0, exci_scaling_factor, inh_scaling_factor);

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

fig = Figure()
rasterplot(fig[1,1], n_A, sol; title = "Population A")
rasterplot(fig[1,2], n_B, sol; title = "Population B")
rasterplot(fig[2,1], n_inh, sol; color=:red, title = "Inhibitory Population")
fig
save(joinpath(@OUTPUT, "dm_raster.svg"), fig); # hide

fig = Figure()
ax = Axis(fig[1,1])
frplot!(ax, n_A, sol; color=:black, win_size=50, label="Population A")
frplot!(ax, n_B, sol; color=:red, win_size=50, label="Population B", title = "Competing Firing Rates")
axislegend(position=:lt)
fig
save(joinpath(@OUTPUT, "dm_fr.svg"), fig); # hide
