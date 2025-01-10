# This file was generated, do not modify it.

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
sol = solve(prob, Tsit5());

sol[x] ## or similarly sol[y]

fig = plot(sol)
# display the figure
fig
save(joinpath(@OUTPUT, "mtk1.svg"), fig); # hide

@variables v(t)=-65 u(t)=-13
# The following parameter values correspond to chattering spiking.
@parameters a=0.02 b=0.2 c=-50 d=2 I=10

eqs = [D(v) ~ 0.04 * v ^ 2 + 5 * v + 140 - u + I,
        D(u) ~ a * (b * v - u)]

event = (v > 30.0) => [u ~ u + d, v ~ c]

# Model system and simplification.
@named izh_system = ODESystem(eqs, t, [v, u], [a, b, c, d, I]; discrete_events = event)
izh_simple = structural_simplify(izh_system)

# Initial conditions.
u0 = [v => -65.0, u => -13.0]

# Simulation timespan
tspan = (0.0, 400.0)

izh_prob = ODEProblem(izh_simple, u0, tspan)

izh_sol = solve(izh_prob)

fig = plot(izh_sol)
fig
save(joinpath(@OUTPUT, "mtk2.svg"), fig); # hide

fig = plot(izh_sol; idxs=[v])
fig
save(joinpath(@OUTPUT, "mtk3.svg"), fig); # hide

izh_prob = remake(izh_prob; p = [a => 0.1, b => 0.2, c => -65, d => 2])
# or we can change the initial conditions along with the parameters as
izh_prob = remake(izh_prob; p = [a => 0.1, b => 0.2, c => -65, d => 2], u0 = [v => -70, u => -10])

izh_sol = solve(izh_prob)

fig = plot(izh_sol; idxs=[v])
fig
save(joinpath(@OUTPUT, "mtk4.svg"), fig); # hide

@variables v(t)=-65 u(t)=-13 I(t)
@parameters a=0.02 b=0.2 c=-65 d=8 ## These parameter values correspond to regular spiking.

eqs = [D(v) ~ 0.04 * v ^ 2 + 5 * v + 140 - u + I,
        D(u) ~ a * (b * v - u),
        I ~ 10*sin(0.5*t)]

event = (v > 30.0) => [u ~ u + d, v ~ c]

@named izh_system = ODESystem(eqs, t, [v, u, I], [a, b, c, d]; discrete_events = event)
izh_simple = structural_simplify(izh_system)

equations(izh_system)

equations(izh_simple)

tspan = (0.0, 400.0)

# We do not provide initial conditions, so the default values for `v` and `u` from above will be used.
izh_prob = ODEProblem(izh_simple, [], tspan)

izh_sol = solve(izh_prob)

fig = plot(izh_sol; idxs=[v, I])
fig
save(joinpath(@OUTPUT, "mtk5.svg"), fig); # hide
