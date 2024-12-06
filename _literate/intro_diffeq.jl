# # Introduction to Differential Equations in Julia

# ## Lotka-Volterra system

## Import the packages we need
using ModelingToolkit ## for symbolic system definition
using ModelingToolkit: t_nounits as t, D_nounits as D ## generic symbolic time variable and derivative operator 
using OrdinaryDiffEq ## for ODE solvers

## Model variables (or states)
@variables x(t) y(t)
## Model parameters
@parameters a=1.5 b=1.0 c=3.0 d=1.0

## Model equations
eqs = [D(x) ~ a * x - b * x * y
       D(y) ~ -c * y + d * x * y]

## Model system, defined by the equations, the independent time variable, the time-dependent variables and the parameters
@named sys = ODESystem(eqs, t, [x, y], [a, b, c, d])
## Simplified system equations. Necessary step before solving!
simpsys = structural_simplify(sys)

## Simulation timespan
tspan = (0.0, 10.0)

## Initial conditions. A vector of pairs of the form `[state => initial_condition, ...]`
u0 = [x => 5, y => 2]

prob = ODEProblem(simpsys, u0, tspan)
sol = solve(prob, Tsit5())

## Izhikevich Neuron

# Let us start with a simple two-dimensional model of a neuron. This is a popular model, known as the Izhikevich neuron [1]. Even though the model appears simple, it can exhibit many different spiking patterns (e.g. regular and fast spiking, bursting, chattering) by changing its parameters.

@variables v(t) u(t)
## The following values correspond to chattering spiking.
@parameters a=0.02 b=0.2 c=-50 d=2 I=10

equation = [D(v) ~ 0.04 * v ^ 2 + 5 * v + 140 - u + I
           D(u) ~ a * (b * v - u)]

## Callbacks that are used to simulate spiking
event = [[v ~ 30.0] => [u ~ u + d]
        [v ~ 30.0] => [v ~ c]]

## Model system
@named izh_system = ODESystem(equation, t, [v, u], [a, b, c, d, I]; discrete_events = event)
## Simplify system equations. Necessary step before solving!
izh_simple = structural_simplify(izh_system)

## Initial conditions
u0 = [v => -65.0, u => -13.0]

## Simulation timespan
tspan = (0.0, 100.0)

## Problem to be solved
izh_prob = ODEProblem(izh_simple, u0, tspan, p)
## Solution of our problem
izh_sol = solve(izh_prob)

# References
# [1] : E. M. Izhikevich, "Simple model of spiking neurons," in IEEE Transactions on Neural Networks, vol. 14, no. 6, pp. 1569-1572, Nov. 2003, doi: 10.1109/TNN.2003.820440