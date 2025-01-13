# This file was generated, do not modify it. # hide
untune = Dict(A[3] => false, A[7] => false)
fitmodel = changetune(fitmodel, untune)                 # A[3] and A[7] were set to 0 in the simulation
fitmodel = structural_simplify(fitmodel, split=false)   # and now simplify the euqations; the `split` parameter is necessary for some ModelingToolkit peculiarities and will soon be removed. So don't lose time with it ;)