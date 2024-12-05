# # Introduction to Differential Equations in Julia

# Let us start with a simple two-dimensional model of a neuron. This is a popular model, known as Izhikevich neuron [reference].

using ModelingToolkit: t_nounits as t, D_nounits as D
using DifferentialEquations

@variables v(t) u(t)
@parameters a b c d I

equation = [D(v) ~ 0.04 * v ^ 2 + 5 * v + 140 - u + I
           D(u) ~ a * (b * v - u)]


event = [[v ~ 30.0] => [u ~ u + d]
        [v ~ 30.0] => [v ~ c]]

@named izh_system = ODESystem(equation, t, [v, u], [a, b, c, d, I]; continuous_events = event)

# Those below can change; I'm using the parameters for a chattering dynamic
p = [a =>  0.02, b => 0.2, c => -50.0, d => 2.0, I => 10.0]

u0 = [v => -65.0, u => -13.0]

tspan = (0.0, 100.0)

izh_prob = ODEProblem(complete(izh_system), u0, tspan, p)
izh_sol = solve(izh_prob)