# This file was generated, do not modify it. # hide
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