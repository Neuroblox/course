# This file was generated, do not modify it. # hide
import Neuroblox: connection_callbacks

function connection_callbacks(source::IzhNeuron, destination::LIFNeuron; spike_conductance=1, kwargs...)
    spike_affect = (source.V > source.θ) => [destination.G ~ destination.G + spike_conductance]

    return spike_affect
end

g = MetaDiGraph()
add_edge!(g, izh => lif, weight = 1)

@named sys = system_from_graph(g)

prob = ODEProblem(sys, [], (0, 200.0))
sol = solve(prob, Tsit5());