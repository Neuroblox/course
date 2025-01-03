# This file was generated, do not modify it. # hide
fig = powerspectrumplot(CB, sol; sampling_rate=0.01)
save(joinpath(@OUTPUT, "cort_power.svg"), fig); # hide