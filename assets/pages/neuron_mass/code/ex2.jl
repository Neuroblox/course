# This file was generated, do not modify it. # hide
E = state_timeseries(nm, sol, "E") ## retrieves state `E` of Blox `nm`
fig = lines(E); ## simple line plot
fig
save(joinpath(@OUTPUT, "wc_timeseries.svg"), fig); # hide