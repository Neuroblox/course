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