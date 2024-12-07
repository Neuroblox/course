# # Introduction to Differential Equations in Julia

# ## Lotka-Volterra system

## Import the packages we need
using ModelingToolkit ## for symbolic system definition
using ModelingToolkit: t_nounits as t, D_nounits as D ## generic symbolic time variable and derivative operator 
using OrdinaryDiffEq ## for ODE solvers
using CairoMakie ## for plotting

## Time-dependent variables. 
## The assigned values are default values that will be used as initial conditions if initial conditions are not explicitly provided. 
@variables x(t)=1 y(t)=1
## Parameters with assigned values
@parameters a=1.5 b=1.0 c=3.0 d=1.0

## Model equations
eqs = [D(x) ~ a * x - b * x * y,
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


# ## Izhikevich Neuron

# ### Simulating spikes

# Let's now move on to a two-dimensional model of a neuron. This is a popular model, known as the Izhikevich neuron [1]. Even though the model appears simple, it can exhibit many different spiking patterns (e.g. regular and fast spiking, bursting, chattering) by changing its parameters.
# The Izhikevich neuron is a similar system of ODEs like the Lotka-Volterra example above. One notable difference however is the spiking mechanism.
# Spiking in the Izhikevich neuron needs to be implemented "manually". That is we need to detect when the voltage variable crosses a spiking threshold and every time this event happens we need to reset the neuron's voltage to a more polarized value and potentially alter other variables too.

@variables v(t)=-65 u(t)=-13
## The following parameter values correspond to chattering spiking.
@parameters a=0.02 b=0.2 c=-50 d=2 I=10

eqs = [D(v) ~ 0.04 * v ^ 2 + 5 * v + 140 - u + I,
        D(u) ~ a * (b * v - u)]

# Now we need to define the callback to simulate spikes. Spiking callbacks belong to the family of discrete callbacks and are defined by two parts :
# - a condition which  triggers the callback every timestep it evaluates as `true`, e.g. `v > 30` means that each time the neuron voltage `v` rises above `30` mV a spike is triggered. 
# - a list of equations that assign values to variables and/or parameters, e.g. `v ~ -50` means that when a spike is triggered the voltage is resetted to `-50` mV.
# The spiking event for this model looks like this

event = (v > 30.0) => [u ~ u + d, v ~ c]

# Now we can move on to define the system including the spiking event, create a problem and solve it.
## Model system and simplification.
@named izh_system = ODESystem(eqs, t, [v, u], [a, b, c, d, I]; discrete_events = event)
izh_simple = structural_simplify(izh_system)

## Initial conditions.
u0 = [v => -65.0, u => -13.0]

## Simulation timespan
tspan = (0.0, 400.0)

izh_prob = ODEProblem(izh_simple, u0, tspan)

izh_sol = solve(izh_prob)

plot(izh_sol)
## or if we want to plot just the voltage timeseries with its spiking pattern
plot(izh_sol; idxs=[v])

# ### Changing parameter values and initial conditions
# After defining and simulating a system we might want to run another simulation by changing either or both of the parameter values and the initial conditions. 
# The Izhikevich neuron that we simulated above has multiple spiking regimes that correspond to different parameter value combinations. If we have our `ODEProblem` already defined as the `izh_prob` variable above, we can remake it by keeping everything the same except for the fields that we choose to alter.
# Here we will change only the model parameters to change from chattering to fast spiking. 

izh_prob = remake(izh_prob; p = [a => 0.1, b => 0.2, c => -65, d => 2])
## or we can change the initial conditions along with the parameters as
izh_prob = remake(izh_prob; p = [a => 0.1, b => 0.2, c => -65, d => 2], u0 = [v => -70, u => -10])

izh_sol = solve(izh_prob)

plot(izh_sol; idxs=[v])

# Notice how the spiking pattern has changed compared to the previous simulation.

# ### Adding external currents
# Until now we have been simulating the Izhikevich neuron by injecting it with a constant external DC current `I=10`. We'll now see how we can expand the `I` input to a dynamic current, which is more realistic (currents do not remain constant in the brain for too long). 
# Since `I` will change dynamically in time, it will be a time-dependent variable of the system and not a constant parameter.
@variables v(t)=-65 u(t)=-13 I(t)
## The following parameter values correspond to regular spiking.
@parameters a=0.02 b=0.2 c=-65 d=8

eqs = [D(v) ~ 0.04 * v ^ 2 + 5 * v + 140 - u + I,
        D(u) ~ a * (b * v - u),
        I ~ 10*sin(0.5*t)]

event = (v > 30.0) => [u ~ u + d, v ~ c]

## Notice how `I` was moved from the parameter list to the variable list in the following call.
@named izh_system = ODESystem(eqs, t, [v, u, I], [a, b, c, d]; discrete_events = event)
izh_simple = structural_simplify(izh_system)

# Let's display the equations of the original and the simplified system to see the effect of `structural_simplify`. 
equations(izh_system)
# The original system contains the algebraic equation for the external current `I`.
equations(izh_simple)
# However the `I` equation has been simplified away in `izh_simple`, since it was substituted into the differential equation `D(v)`.
# This is an important functionality of `structural_simplify` as it has turned a system of Differential Algebraic Equations (DAE) to one of Ordinary Differential Equations (ODE). ODEs can be integrated (solved) much more efficiently compared to DAEs. 

tspan = (0.0, 400.0)

## We do not provide initial conditions, so the default values for `v` and `u` from above will be used.
izh_prob = ODEProblem(izh_simple, [], tspan)

izh_sol = solve(izh_prob)

plot(izh_sol; idxs=[v, I])

# Notice how the external current is slowly being accumulated in the neuron's potential `v` until the eventual spike and reset. 

# References
# [1] : E. M. Izhikevich, "Simple model of spiking neurons," in IEEE Transactions on Neural Networks, vol. 14, no. 6, pp. 1569-1572, Nov. 2003, doi: 10.1109/TNN.2003.820440