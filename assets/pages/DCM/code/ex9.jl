# This file was generated, do not modify it. # hide
f = Figure()
ax = Axis(f[1, 1],
    title = "fMRI time series",
    xlabel = "Time [ms]",
    ylabel = "BOLD",
)
lines!(ax, sol, idxs=idx_m)
f
save(joinpath(@OUTPUT, "fmriseries.svg"), f); # hide