# This file was generated, do not modify it. # hide
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