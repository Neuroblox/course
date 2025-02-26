# This file was generated, do not modify it. # hide
f2 = ecbarplot(state, setup, A_true)
axislegend(position=:lt)
save(joinpath(@OUTPUT, "ecbar.svg"), f2); # hide