# This file was generated, do not modify it. # hide
V = voltage_timeseries(qif, sol) ## equivalent to `state_timeseries(qif, sol, "V")`
fig = lines(V);
fig
save(joinpath(@OUTPUT, "qif_timeseries.svg"), fig); # hide