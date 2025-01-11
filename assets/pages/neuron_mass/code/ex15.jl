# This file was generated, do not modify it. # hide
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