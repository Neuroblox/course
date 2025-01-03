# This file was generated, do not modify it. # hide
using Distributions

tspan = (0, 200) # ms
# Define a `NamedTuple` holding a `distribution` and a `dt` field
spike_rate = (distibution = Normal(1, 0.1), dt = 10)

@named spike_train_dist = PoissonSpikeTrain(spike_rate, tspan)