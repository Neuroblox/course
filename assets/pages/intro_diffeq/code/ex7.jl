# This file was generated, do not modify it. # hide
izh_prob = remake(izh_prob; p = [a => 0.1, b => 0.2, c => -65, d => 2])
# or we can change the initial conditions along with the parameters as
izh_prob = remake(izh_prob; p = [a => 0.1, b => 0.2, c => -65, d => 2], u0 = [v => -70, u => -10])

izh_sol = solve(izh_prob)

plot(izh_sol; idxs=[v])