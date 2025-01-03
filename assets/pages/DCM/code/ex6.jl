# This file was generated, do not modify it. # hide
tspan = (0.0, 512.0)
prob = SDEProblem(simmodel, [], tspan)
dt = 2   # 2 seconds (units are milliseconds) as measurement interval for fMRI
sol = solve(prob, ImplicitRKMil(), saveat=dt);