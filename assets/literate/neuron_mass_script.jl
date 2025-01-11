# This file was generated, do not modify it.

using Neuroblox
using OrdinaryDiffEq
using CairoMakie

# Set the random seed for reproducible results
using Random
Random.seed!(1)

@named nm = WilsonCowan()
# Retrieve the simplified ODESystem of the Blox
sys = system(nm)
tspan = (0, 100) # ms
prob = ODEProblem(sys, [], tspan)
sol = solve(prob, Tsit5())

fig, ax = plot(sol);
axislegend(ax) ## add legend to the plot
fig
save(joinpath(@OUTPUT, "wc_all.svg"), fig); # hide

E = state_timeseries(nm, sol, "E") ## retrieves state `E` of Blox `nm`
fig = lines(E); ## simple line plot
fig
save(joinpath(@OUTPUT, "wc_timeseries.svg"), fig); # hide

@named qif = QIFNeuron(; I_in=4)
# We can pass additional events to be included in the final system.
sys = system(qif; discrete_events = [60] => [qif.I_in ~ 10])
tspan = (0, 100) # ms
prob = ODEProblem(sys, [], tspan)
sol = solve(prob, Tsit5());

fig = rasterplot(qif, sol; threshold=-40);
fig
save(joinpath(@OUTPUT, "qif_raster.svg"), fig); # hide

fig = frplot(qif, sol; threshold=-40, win_size=20);
fig
save(joinpath(@OUTPUT, "qif_fr.svg"), fig); # hide

V = voltage_timeseries(qif, sol) ## equivalent to `state_timeseries(qif, sol, "V")`
fig = lines(V);
fig
save(joinpath(@OUTPUT, "qif_timeseries.svg"), fig); # hide

using StochasticDiffEq ## to access stochastic DE solvers

@named hh = HHNeuronExci_STN_Adam_Blox(; σ=2) ## σ is the brownian noise amplitude

sys = system(hh)
prob = SDEProblem(sys, [], (0, 1000))
sol = solve(prob, RKMil())

# Plot the powerspectrum of the solution
fig = powerspectrumplot(hh, sol; sampling_rate=0.01);
fig
save(joinpath(@OUTPUT, "hh_power.svg"), fig); # hide

@named inp = ConstantInput(; I=3)

connection_rule(inp, nm, weight=1)

g = MetaDiGraph()
add_edge!(g, inp => nm, weight = 1)

@named sys = system_from_graph(g)
prob = ODEProblem(sys, [], tspan)
sol = solve(prob, Tsit5())

fig, ax = plot(sol);
axislegend(ax)
fig
save(joinpath(@OUTPUT, "wc_input.svg"), fig); # hide

tspan = (0, 200) # ms
spike_rate = 0.01 # spikes / ms

@named spike_train_rate = PoissonSpikeTrain(spike_rate, tspan)

using Distributions

tspan = (0, 200) # ms
# Define a `NamedTuple` holding a `distribution` and a `dt` field
spike_rate = (distibution = Normal(1, 0.1), dt = 10)

@named spike_train_dist = PoissonSpikeTrain(spike_rate, tspan)

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

# Square pulse stimulus
@named stim = DBS(
                frequency=100.0, ## Hz
                amplitude=200.0, ## arbitrary units, depends on how the stimulus is used in the model
                pulse_width=0.5, ## ms
                offset=0.0,
                start_time=5.0, ## ms
                smooth=0.0 ## modulates smoothing effect
);

tspan = (0, 100) ## ms
dt = 0.001 ## ms

time = tspan[1]:dt:tspan[2]
# `stimulus` is a function that is also a field of `DBS` objects.
# It turns a time vector into a vector of stimulus values of the same length given the object's parameters.
stimulus = stim.stimulus.(time)

fig = Figure();
ax1 = Axis(fig[1,1]; xlabel = "time (ms)", ylabel = "stimulus")
lines!(ax1, time, stimulus)
fig
save(joinpath(@OUTPUT, "stim.svg"), fig); # hide

@named stim_smooth = DBS(
                frequency=100.0,
                amplitude=200.0,
                pulse_width=0.5,
                offset=0.0,
                start_time=5.0,
                smooth=1e-3
);

smooth_stimulus = stim_smooth.stimulus.(time)

fig = Figure();
ax1 = Axis(fig[1,1]; xlabel = "time (ms)", ylabel = "stimulus")
lines!(ax1, time, stimulus) ## plot the un-smoothed stimulus from above
xlims!(ax1, 4.9, 5.6) ## set the x-axis limits for better visibility of a smoothed pulse

ax2 = Axis(fig[2,1]; xlabel = "time (ms)", ylabel = "stimulus")
lines!(ax2, time, smooth_stimulus) ## plot the smoothed stimulus
xlims!(ax2, 4.9, 5.6) ## set the x-axis limits for better visibility of a smoothed pulse

fig
save(joinpath(@OUTPUT, "stim_comparison.svg"), fig); # hide

frequency = 20.0
amplitude = 1.0
pulse_width = 20.0
smooth = 3e-4
pulse_start_time = 0.01
offset = 0
pulses_per_burst = 3
bursts_per_block = 2
pre_block_time = 200.0
inter_burst_time = 200.0

@named dbs = ProtocolDBS(
                frequency=frequency,
                amplitude=amplitude,
                pulse_width=pulse_width,
                smooth=smooth,
                offset=offset,
                pulses_per_burst=pulses_per_burst,
                bursts_per_block=bursts_per_block,
                pre_block_time=pre_block_time,
                inter_burst_time=inter_burst_time,
                start_time = pulse_start_time);

t_end = get_protocol_duration(dbs)
t_end = t_end + inter_burst_time
tspan = (0.0, t_end)
dt = 0.001

time = tspan[1]:dt:tspan[2]
stimulus = dbs.stimulus.(time)

fig = Figure();
ax1 = Axis(fig[1,1]; xlabel = "time (ms)", ylabel = "stimulus")
lines!(ax1, time, stimulus)
fig
save(joinpath(@OUTPUT, "stim_protocol.svg"), fig); # hide

@named nn = HHNeuronExciBlox(I_bg=0.4)

g = MetaDiGraph()
add_edge!(g, dbs => nn, weight = 10.0)

@named sys = system_from_graph(g)
prob = ODEProblem(sys, [], tspan)

transitions_inds = detect_transitions(time, stimulus; atol=0.001)
transition_times = time[transitions_inds]
transition_values = stimulus[transitions_inds]
sol = solve(prob, Vern7(), saveat=dt, tstops = transition_times);

# Retrive the timeseries of the voltage variable (`nn₊V`) from the solution
v = voltage_timeseries(nn, sol)

# Plot the voltage and stimulation timeseries on two axes on the same window.
fig = Figure();
ax1 = Axis(fig[1,1]; xlabel = "time (ms)", ylabel = "Voltage (mV)")
lines!(ax1, sol.t, v)

ax2 = Axis(fig[2,1]; xlabel = "time (ms)", ylabel = "Stimulus (μA/cm²)")
lines!(ax2, sol.t, stimulus)
fig
save(joinpath(@OUTPUT, "stim_hh.svg"), fig); # hide
