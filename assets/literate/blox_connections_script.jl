# This file was generated, do not modify it.

using Neuroblox
using OrdinaryDiffEq

@named lif = LIFNeuron()

@show typeof(lif)
@show lif isa Neuron # equivalent to typeof(lif) <: Neuron

unknowns(lif)
parameters(lif)
inputs(lif)
outputs(lif)
discrete_events(lif)
equations(lif)

@named ifn = IFNeuron() ## create an Integrate-and-Fire neuron, simpler than the `LIFNeuron`

connection_equations(lif, ifn, weight=1, connection_rule="basic")

connection_rule(lif, ifn, weight=1, connection_rule="psp")

g = MetaDiGraph()
add_edge!(g, lif => ifn, weight=1) ## add connection with specific weight value

@named sys = system_from_graph(g)
prob = ODEProblem(sys, [], (0, 200.0))
sol = solve(prob, Tsit5());

struct IzhNeuron <: Neuron
    system
    namespace

    function IzhNeuron(; name, namespace=nothing, a=0.02, b=0.2, V_reset=-50, d=2, threshold=30)
        sts = @variables V(t)=-65 [output=true] u(t)=-13 jcn [input=true]
        params = @parameters a=a b=b V_reset=V_reset d=d θ=threshold

        eqs = [D(V) ~ 0.04 * V ^ 2 + 5 * V + 140 - u + jcn + 5,
                D(u) ~ a * (b * V - u)]

        event = (V > θ) => [u ~ u + d, V ~ V_reset]
        sys = System(eqs, t, sts, params; name=name, discrete_events = event)

        new(sys, namespace)
    end
end

# In the `IzhNeuron` constructor function we keep all arguments as keyword arguments so that we can set them more conveniently as `arg = value`. Spike threshold `θ=30` is now included as a parameter. Default values for all parameters are the keyword arguments from above. This way we can set them easily during construction.

@named izh = IzhNeuron()

connection_equations(izh, lif, weight=1, connection_rule="basic") ## connection from izh to lif
connection_equations(lif, izh, weight=1, connection_rule="basic") ## connection from lif to izh

import Neuroblox: connection_equations

function connection_equations(source::LIFNeuron, destination::IzhNeuron, weight; kwargs...)
    equation = destination.jcn ~ weight * source.G * (destination.V - source.E_syn)

    return equation
end

connection_equations(lif, izh, weight=1, connection_rule="basic")

g = MetaDiGraph()
# Also set the weight value this time
add_edge!(g, izh => lif, weight = 1)

@named sys = system_from_graph(g)
prob = ODEProblem(sys, [], (0, 200.0))
sol = solve(prob, Tsit5());

function connection_equations(source::IzhNeuron, destination::LIFNeuron, weight; const_current=1, kwargs...)
    equation = destination.jcn ~ weight * source.V + const_current

    return equation
end

g = MetaDiGraph()
# Set const_current to a value that is other than its default.
add_edge!(g, izh => lif; weight = 1, const_current=20)

@named sys = system_from_graph(g)
prob = ODEProblem(sys, [], (0, 200.0))
sol = solve(prob, Tsit5());

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
