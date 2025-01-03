# This file was generated, do not modify it. # hide
struct BernoulliSpikes <: SpikeSource
    name ## necessary field
    namespace ## necessary field
    tspan ## necessary field
    probability_spike
    dt
    function BernoulliSpikes(probability_spike, tspan, dt; name, namespace=nothing)
        new(name, namespace, tspan, probability_spike, dt)
    end
end

import Neuroblox: generate_spike_times, connection_spike_affects

function generate_spike_times(source::BernoulliSpikes)
    # Write a function that generates and returns a vector of spike times.

    t_range = source.tspan[1]:source.dt:source.tspan[2]
    t_spikes = Float64[]
    for t in t_range
        if rand(Bernoulli(source.probability_spike))
            push!(t_spikes, t)
        end
    end
    return t_spikes
end

function connection_spike_affects(source::BernoulliSpikes, ifn::IFNeuron, w)
    # Write all equations that should be evaluated each time `source` spikes.
    # `w` is the symbolic connection weight, same as in `connection_equations`.

    eqs = [ifn.I_in ~ ifn.I_in + w]
    return eqs
end

tspan = (0, 500)
@named s = BernoulliSpikes(0.05, tspan, 5)
@named ifn = IFNeuron()

g = MetaDiGraph()
add_edge!(g, s => ifn, weight=1)
@named sys = system_from_graph(g)

prob = ODEProblem(sys, [], tspan)
sol = solve(prob, Tsit5())

fig = rasterplot(ifn, sol);
fig
save(joinpath(@OUTPUT, "ifn_input.svg"), fig); # hide