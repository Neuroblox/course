# This file was generated, do not modify it. # hide
fig = Figure()
rasterplot(fig[1,1], n_A, sol; title = "Population A")
rasterplot(fig[1,2], n_B, sol; title = "Population B")
rasterplot(fig[2,1], n_inh, sol; color=:red, title = "Inhibitory Population")
fig
save(joinpath(@OUTPUT, "dm_raster.svg"), fig); # hide