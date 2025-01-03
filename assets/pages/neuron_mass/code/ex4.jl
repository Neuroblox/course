# This file was generated, do not modify it. # hide
fig = rasterplot(qif, sol; threshold=-40);
fig
save(joinpath(@OUTPUT, "qif_raster.svg"), fig); # hide