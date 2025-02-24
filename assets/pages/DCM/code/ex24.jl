# This file was generated, do not modify it. # hide
perturbedfp = Dict(sts .=> abs.(10^-10*rand(length(sts))))     # slight noise to avoid issues with Automatic Differentiation.