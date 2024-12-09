# This file was generated, do not modify it.

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

# `grid=false` avoids hiding the x grid lines
hidexdecorations!(axs[1], grid=false)

# Now we can display the figure again with the updated axes
fig
save(joinpath(@OUTPUT, "layout_hidex.svg"), fig); # hide

using ModelingToolkit
using ModelingToolkit: t_nounits as t, D_nounits as D
using OrdinaryDiffEq

@variables v(t)=-65 u(t)=-13
# Parameters for fast spiking.
@parameters a=0.1 b=0.2 c=-65 d=2 I=10

eqs = [D(v) ~ 0.04 * v ^ 2 + 5 * v + 140 - u + I,
        D(u) ~ a * (b * v - u)]

spike_threshold = 30
t_bigger_stimulation = 250
spike_event = (v > spike_threshold) => [u ~ u + d, v ~ c]
stimulation_event = [t_bigger_stimulation] => [I ~ I + 10]

@named izh_system = ODESystem(eqs, t, [v, u], [a, b, c, d, I]; discrete_events = [spike_event, stimulation_event])
izh_simple = structural_simplify(izh_system)

u0 = [v => -65.0, u => -13.0]
tspan = (0.0, 400.0)

izh_prob = ODEProblem(izh_simple, u0, tspan)
izh_sol = solve(izh_prob)

# retrieve the voltage potential variable from solution
V_izh = izh_sol[v]
# retrieve all stimulation timesteps that the integrator took to solve the ODEProblem
timepoints = izh_sol.t

# set a time window width for spike counting
t_window = 20
# split time into bins of size `t_window`
t_range = first(tspan):t_window:last(tspan)
# initialize an empty vector to hold the spike values.
spikes = zeros(length(t_range) - 1)

# loop over the timepoints at which every time window begins
for i in eachindex(t_range[1:end-1])
    # find the indices of timepoints that fall within the current time window
    idxs = findall(t -> t_range[i] <= t <= t_range[i+1], timepoints)
    # count the number of spikes within the same window
    spikes[i] = count(V_izh[idxs] .> spike_threshold) ## counts the number of True elements in a Boolean vector
end

fig = Figure()
ax = Axis(fig[1,1], xlabel="Time (sec)", ylabel="Spikes")

# plot spikes for each time window
barplot!(ax, t_range[1:end-1], spikes, label="Spikes")
# plot a vertical line to note when the change in current `I` occurred
vlines!(ax, [t_bigger_stimulation]; color=:tomato, linestyle=:dash, linewidth=4, label="Stimulation: I = I+10")

# display the legend
axislegend(position = :lt)
fig
save(joinpath(@OUTPUT, "spikes.svg"), fig); # hide
