# This file was generated, do not modify it. # hide
import Neuroblox: generate_spike_times, connection_spike_affects

function generate_spike_times(source::BernoulliSpikes)
    t_range = source.tspan[1]:source.dt:source.tspan[2]
    t_spikes = Float64[]
    for t in t_range
        if rand(Bernoulli(source.probability_spike))
            push!(t_spikes, t)
        end
    end
    return t_spikes
end