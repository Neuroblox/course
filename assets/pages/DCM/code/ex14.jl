# This file was generated, do not modify it. # hide
_, obsvars = get_eqidx_tagged_vars(simmodel, "measurement");  # get index of equation of bold state
rename!(dfsol, Symbol.(obsvars))