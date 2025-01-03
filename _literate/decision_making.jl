# # Decision Making in a Circuit Model

# ## Introduction
# The session covers the classic article by Wang [1] which presented a circuit model for decision making. The model consists of two selective excitatory populations, one for each possible choice, a non-selective excitatory population and an inhibitory population which facilitates the competition between the two selective ones.
# Each population is comprised of Leaky Integrate-and-Fire neurons, which include dynamics for NMDA, AMPA and GABA receptors, unlike the two-dimensional `LIFNeuron` we used before.

# The decision-making task that the circuit solves is the Random Dot Motion task. The participant (our circuit model) needs to decide whether a pool of dots on a screen move towards the left or the right direction on average. The coherence of the between-dot direction of movement can vary from trial to trial, thus making some trials more ambiguous than others.

# Learning goals 
# - Use circuit models in a behavioral task with stimulus inputs and action outputs.
# - Model synaptic receptors explicitly and interventions on them.

# ## Model definition

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

## Use two distinct weight values as per Wang [1]
w₊ = 1.7 
w₋ = 1 - f * (w₊ - 1) / (1 - f)

## Use scaling factors for conductance parameters so that our abbreviated model 
## can exhibit the same competition behavior between the two selective excitatory populations
## as the larger model in Wang [1] does.
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

## background input
@named background_input = PoissonSpikeTrain(spike_rate, tspan; namespace = model_name, N_trains=1);

## stimulation inputs to selective populations A and B
@named stim_A = PoissonSpikeTrain(spike_rate_A, tspan; namespace = model_name);
@named stim_B = PoissonSpikeTrain(spike_rate_B, tspan; namespace = model_name);

@named n_A = LIFExciCircuitBlox(; namespace = model_name, N_neurons = N_E_selective, weight = w₊, exci_scaling_factor, inh_scaling_factor);
@named n_B = LIFExciCircuitBlox(; namespace = model_name, N_neurons = N_E_selective, weight = w₊, exci_scaling_factor, inh_scaling_factor) ;
@named n_ns = LIFExciCircuitBlox(; namespace = model_name, N_neurons = N_E_nonselective, weight = 1.0, exci_scaling_factor, inh_scaling_factor);
@named n_inh = LIFInhCircuitBlox(; namespace = model_name, N_neurons = N_I, weight = 1.0, exci_scaling_factor, inh_scaling_factor);

# As we can see, each selective population `n_A` and `n_B` receives a separate spike train input `stim_A` and `stim_B` respectively. These inputs model visual processing that is selective for the left and right dot directions. All Bloxs also receive background inputs of the same rate from neurons we do not explicitly model.

# ## System construction & Simulation
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
    
# ## Results

fig = Figure()
rasterplot(fig[1,1], n_A, sol; title = "Population A")
rasterplot(fig[1,2], n_B, sol; title = "Population B")
rasterplot(fig[2,1], n_inh, sol; color=:red, title = "Inhibitory Population")
fig
save(joinpath(@OUTPUT, "dm_raster.svg"), fig); # hide
# \fig{dm_raster}

# Notice how the activity of neurons in population B is quickly ramping up and the activity in population A is decreasing at the same time. The inhibitory population exhibits a contant tonic activity that facilitates the competition between A and B via the precise spike times.

fig = Figure()
ax = Axis(fig[1,1], title = "Competing Firing Rates")
frplot!(ax, n_A, sol; color=:black, win_size=50)
frplot!(ax, n_B, sol; color=:red, win_size=50)
fig
save(joinpath(@OUTPUT, "dm_fr.svg"), fig); # hide
# \fig{dm_fr}

# We observe the same result qualitatively when plotting the firing rates instead of spikes. Using a single axis we can better see the magnitude of the competition in the difference between the firing rates over time.

# ## References
# - [1]  Wang XJ. Probabilistic decision making by slow reverberation in cortical circuits. Neuron. 2002 Dec;36(5):955-968. DOI: 10.1016/s0896-6273(02)01092-9. PMID: 12467598. 