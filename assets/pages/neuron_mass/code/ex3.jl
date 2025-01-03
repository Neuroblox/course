# This file was generated, do not modify it. # hide
@named qif = QIFNeuron(; I_in=4)
# We can pass additional events to be included in the final system.
sys = system(qif; discrete_events = [60] => [qif.I_in ~ 10])
tspan = (0, 100) # ms
prob = ODEProblem(sys, [], tspan)
sol = solve(prob, Tsit5())