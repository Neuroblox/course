# Introduction to Differential Equations in Julia

Let us start with a simple system with a single differential equation.

````julia
# The first step is to install and import these packages
using Pkg
Pkg.add("ModelingToolkit")
Pkg.add("DifferentialEquations")
Pkg.add("CairoMakie")
using ModelingToolkit: t_nounits as t, D_nounits as D   # Define the time variable and the differentiation operator
using DifferentialEquations

# Define the time-dependent variable u
@variables u(t)

# Define the parameter a
@parameters a

# Define the differential equation du/dt = -a * u
equation = D(u) ~ -a * u

# Build the ODE system and assign it a name
@named system = ODESystem(equation, t)

# Define the initial conditions and parameters
u0 = [u => 1.0]
p = [a => 2.0]
tspan = (0.0 , 5.0)

# Set up the problem
problem = ODEProblem(complete(system), u0, tspan, p)

# Solve the problem
solution = solve(problem)

times = solution.t

# The 1 here means we're extracting the values from the first variable
values = sol[1, :]

using CairoMakie

fig, ax, plt = lines(times, values, color=:black, label="u(t)")

ax.xlabel = "Time"
ax.ylabel = "u(t)"
ax.title = "Solution of the ODE"
axislegend(ax)

# Display the figure in a new panel in VS Code
fig
````

---

*This page was generated using [Literate.jl](https://github.com/fredrikekre/Literate.jl).*

