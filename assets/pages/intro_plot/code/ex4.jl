# This file was generated, do not modify it. # hide
for i in eachindex(t_range[1:end-1])
    idxs = findall(t -> t_range[i] <= t <= t_range[i+1], timepoints)

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