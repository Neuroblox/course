# This file was generated, do not modify it. # hide
untune = Dict(A[3] => false, A[7] => false, A[1] => false, A[5] => false, A[9] => false)
fitmodel = changetune(fitmodel, untune)           # 3 and 7 are not present in the simulation model
fitmodel = structural_simplify(fitmodel)          # and now simplify the euqations