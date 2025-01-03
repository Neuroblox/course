# This file was generated, do not modify it. # hide
fig = Figure()
ax = Axis(fig[1,1], title = "Competing Firing Rates")
frplot!(ax, n_A, sol; color=:black, win_size=50)
frplot!(ax, n_B, sol; color=:red, win_size=50)
fig
save(joinpath(@OUTPUT, "dm_fr.svg"), fig); # hide