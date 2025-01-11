# This file was generated, do not modify it. # hide
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