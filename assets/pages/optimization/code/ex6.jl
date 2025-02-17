# This file was generated, do not modify it. # hide
setter!(prob, res.u)
sol = solve(prob, Tsit5())

fig = Figure(size = (1600, 800), fontsize=22)
axs = [
    Axis(fig[1,1], title=String(Symbol(states[1]))),
    Axis(fig[1,2], title=String(Symbol(states[2]))),
    Axis(fig[2,1], title=String(Symbol(states[3]))),
    Axis(fig[2,2], title=String(Symbol(states[4]))),
    Axis(fig[3,1], title=String(Symbol(states[5]))),
    Axis(fig[3,2], title=String(Symbol(states[6]))),
    Axis(fig[4,1], title=String(Symbol(states[7]))),
    Axis(fig[4,2], title=String(Symbol(states[8])))
]
for (i,s) in enumerate(states)
    lines!(axs[i], data[s], label="Data")
    lines!(axs[i], sol[s], label="Optimized Solution")
end
colsize!(fig.layout, 1, Relative(1/2))
Legend(fig[5,1], last(axs))
fig
save(joinpath(@OUTPUT, "opt_final.svg"), fig); # hide