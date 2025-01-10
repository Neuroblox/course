# This file was generated, do not modify it. # hide
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