# This file was generated, do not modify it. # hide
fig = Figure()
rasterplot(fig[1,1], exci, sol; threshold=20.0, title="Excitatory Neurons")
rasterplot(fig[2,1], inhib, sol; threshold=20.0, title="Inhibitory Neurons")
fig
save(joinpath(@OUTPUT, "ping_raster.svg"), fig); # hide