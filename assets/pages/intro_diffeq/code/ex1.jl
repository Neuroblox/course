# This file was generated, do not modify it. # hide
# Import the packages we need
using ModelingToolkit ## for symbolic system definition
using ModelingToolkit: t_nounits as t, D_nounits as D ## generic symbolic time variable and derivative operator
using OrdinaryDiffEq ## for ODE solvers
using CairoMakie ## for plotting

# Time-dependent variables.
# The assigned values are default values that will be used as initial conditions if initial conditions are not explicitly provided.
@variables x(t)=1 y(t)=1
# Parameters with assigned values
@parameters a=1.5 b=1.0 c=3.0 d=1.0

# Model equations
eqs = [D(x) ~ a * x - b * x * y,
       D(y) ~ -c * y + d * x * y]

# Model system, defined by the equations, the independent time variable, the time-dependent variables and the parameters
@named sys = ODESystem(eqs, t, [x, y], [a, b, c, d])
# Simplified system equations. Necessary step before solving!
simpsys = structural_simplify(sys)

# Simulation timespan
tspan = (0.0, 10.0)

# Initial conditions. A vector of pairs of the form `[state => initial_condition, ...]`
u0 = [x => 5, y => 2]

# Problem to be solved
prob = ODEProblem(simpsys, u0, tspan)
# Solution of the problem using the Tsit5 solver
sol = solve(prob, Tsit5())