# # Introduction to Differential Equations in Julia

# ## Lotka-Volterra system

## Import the packages we need
using ModelingToolkit ## for symbolic system definition
using ModelingToolkit: t_nounits as t, D_nounits as D ## generic symbolic time variable and derivative operator 
using OrdinaryDiffEq ## for ODE solvers
using CairoMakie ## for plotting

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

## Problem to be solved
prob = ODEProblem(simpsys, u0, tspan)
## Solution of the problem using the Tsit5 solver
sol = solve(prob, Tsit5())

# The solution object contains the values of every variable of the system (`x` and `y`) for every simulated timestep. One can easily access the values of a specific variable using its symbolic name
sol[x] ## or similarly sol[y]

# Finally we can plot the timeseries of both variables of the solution in a line plot using
plot(sol)
# We will shortly see more plot types and options.


## Izhikevich Neuron

# Let's now move on to a two-dimensional model of a neuron. This is a popular model, known as the Izhikevich neuron [1]. Even though the model appears simple, it can exhibit many different spiking patterns (e.g. regular and fast spiking, bursting, chattering) by changing its parameters.
# The Izhikevich neuron is a similar system of ODEs like the Lotka-Volterra example above. One notable difference however is the spiking mechanism.
# Spiking in the Izhikevich neuron needs to be implemented "manually". That is we need to detect when the voltage variable crosses a spiking threshold and every time this event happens we need to reset the neuron's voltage to a more polarized value and potentially alter other variables too.

@variables v(t) u(t)
## The following parameter values correspond to chattering spiking.
@parameters a=0.02 b=0.2 c=-50 d=2 I=10

equation = [D(v) ~ 0.04 * v ^ 2 + 5 * v + 140 - u + I
           D(u) ~ a * (b * v - u)]

# Now we need to define the callback to simulate spikes. Spiking callbacks belong to the family of discrete callbacks and are defined by two parts :
# - a condition which  triggers the callback every timestep it evaluates as `true`, e.g. `v > 30` means that each time the neuron voltage `v` rises above `30` mV a spike is triggered. 
# - a list of equations that assign values to variables and/or parameters, e.g. `v ~ -50` means that when a spike is triggered the voltage is resetted to `-50` mV.
# The spiking event for this model looks like this

event = (v > 30.0) => [u ~ u + d, v ~ c]

# Now we can move on to define the system including the spiking event, create a problem and solve it.
## Model system and simplification.
@named izh_system = ODESystem(equation, t, [v, u], [a, b, c, d, I]; discrete_events = event)
izh_simple = structural_simplify(izh_system)

## Initial conditions
u0 = [v => -65.0, u => -13.0]

## Simulation timespan
tspan = (0.0, 100.0)

izh_prob = ODEProblem(izh_simple, u0, tspan)

izh_sol = solve(izh_prob)

plot(izh_sol)

# References
# [1] : E. M. Izhikevich, "Simple model of spiking neurons," in IEEE Transactions on Neural Networks, vol. 14, no. 6, pp. 1569-1572, Nov. 2003, doi: 10.1109/TNN.2003.820440