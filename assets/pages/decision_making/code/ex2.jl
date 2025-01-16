# This file was generated, do not modify it. # hide
exci_scaling_factor = 1600 / N_E
inh_scaling_factor = 400 / N_I

coherence = 0 # random dot motion coherence [%]
dt_spike_rate = 50 # update interval for the stimulus spike rate [ms]
μ_0 = 40e-3 # mean stimulus spike rate [spikes / ms]
ρ_A = ρ_B = μ_0 / 100
μ_A = μ_0 + ρ_A * coherence
μ_B = μ_0 - ρ_B * coherence
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