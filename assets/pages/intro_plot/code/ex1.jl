# This file was generated, do not modify it. # hide
using CairoMakie

seconds = 0:0.1:2
measurements = [8.2, 8.4, 6.3, 9.5, 9.1, 10.5, 8.6, 8.2, 10.5, 8.5, 7.2,
        8.8, 9.7, 10.8, 12.5, 11.6, 12.1, 12.1, 15.1, 14.7, 13.1]

fig = Figure(title="Line & Scatter layout")
axs = [Axis(fig[1,1], title = "Line plot", xlabel = "Time [sec]", ylabel = "Measurement"),
        Axis(fig[2,1], title = "Scatter plot", xlabel = "Time [sec]", ylabel = "Measurement")]

lines!(axs[1], seconds, measurements)
scatter!(axs[2], seconds, measurements)

fig
save(joinpath(@OUTPUT, "layout.svg"), fig); # hide