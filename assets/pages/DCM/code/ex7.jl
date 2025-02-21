# This file was generated, do not modify it. # hide
tspan = (0, 1022)
dt = 2   # 2 seconds as measurement interval for fMRI
prob = SDEProblem(simmodel, [], tspan)
sol = solve(prob, ImplicitRKMil(), saveat=dt);