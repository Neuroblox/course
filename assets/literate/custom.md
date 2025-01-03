<!--This file was generated, do not modify it.-->
# Blox and Connections in Neuroblox
Learning goals:
- Learn about how Bloxs and their connections are structured in Neuroblox.
- Implement new Bloxs in code.
- Implement new connection rules between the new Bloxs and existing ones from Neuroblox.

Neuroblox comes with a library of many components already, which we call Blox. Such Blox are neuron models, neural masses, circuits of these, input sources, observers etc. Additionally there are connection rules that dictate how types of components connect with one another. Over the rest of this course we will encounter multiple examples of models made by Neuroblox components and connected by rules already implemented in the package.

It is also possible though to design custom Blox components and connection rules that do not exist in Neuroblox yet. This feature allows us to easily extend the capabilities of Neuroblox towards our specific needs.

Here we will learn how to define our own Blox components and write down connection rules to allow our Blox to connect to ones within Neuroblox.

## Type hierarchy
Neuroblox organizes its Bloxs into type hierarchies. There is `AbstractBlox` at the top level and then `Neuron` and `NeuralMass` that are subtypes of it. Then there are `ExciNeuron` and `InhNeuron` which are subtypes of `Neuron` specifically for Bloxs with excitatory and inhibitory dynamics respectively.
This structure is important for defining connection rules, plotting recipes and other utility functions by exploiting Julia's multiple dispatch capabilities.
For instance if we define a new Blox that is `<: Neuron` then we do not need to define all the functions necessary to connect such a Blox to other Bloxs or to plot results after simulating it.
There is a generic connection rule in Neuroblox already between `Neuron` Bloxs that will be employed if no specific rule is provided. Similarly there are recipes of how to generate raster plots, firing rate plots etc for any Blox that is a subtype of `Neuron`.

## Inspecting a Blox
Neuroblox includes several functions to inspect a Blox, its equations, variables (unknowns), parameters, inputs, outputs and events, much like a `ModelingToolkit` model. These functions are useful given that there is a great range of Bloxs in Neuroblox and we might want to utilize some of them when we build a model. So before adding Bloxs to our model we can learn more about them.
For example let's consider a `LIFNeuron`, which is a Leaky Integrate-and-Fire (LIF) neuron in Neuroblox.

````julia:ex1
using Neuroblox
using OrdinaryDiffEq

@named lif = LIFNeuron()

@show typeof(lif)
@show lif isa Neuron # equivalent to typeof(lif) <: Neuron

unknowns(lif)
parameters(lif)
inputs(lif)
outputs(lif)
discrete_events(lif)
equations(lif)
````

Using these functions we can learn everything about a Blox that will be useful when we want to use it or connect our own custom Bloxs to it.

## Inspecting a connection between Bloxs
Getting information about how two Bloxs connect is equally important to inspecting the Bloxs themselves. There are two functions in Neuroblox that help us gain more information about a connection.
The first one will print only the connection equations

````julia:ex2
@named ifn = IFNeuron() ## create an Integrate-and-Fire neuron, simpler than the `LIFNeuron`

connection_equations(lif, ifn)
````

While the second function prints out all fields that take part in the connection rule

````julia:ex3
connection_rule(lif, ifn)
````

The output of both functions now seems very similar. However `connection_rule` will be more useful later on when we start using more complex Bloxs and connection rules.

## Simulating connected Bloxs
We are now ready to define a couple of Bloxs, connect them and simulate the final model.
Every Neuroblox model starts off as a graph. Every vertex of the graph is a Blox and every edge is a connection between two Bloxs.
Let's build a simple circuit by using the two neurons we created above; `lif` connects to `ifn`.

````julia:ex4
g = MetaDiGraph()
add_edge!(g, lif => ifn)

@named sys = system_from_graph(g)
prob = ODEProblem(sys, [], (0, 200.0))
sol = solve(prob, Tsit5());
````

`system_from_graph` is the workhorse in Neuroblox that turns a graph to a system of differential equations. It performs `structural_simplify` internally too, so the rest of the lines are the same as for a `ModelingToolkit` model.

## Custom Blox
We will implement the Izhikevich neuron from the previous session into a Blox. Every Blox is a Julia `struct` that needs to contain at least two fields
- `system` that holds the dynamics of the Blox.
- `namespace` that holds the namespace to which the object belongs. This field is not relevant for the current session and it will be left to its default value of `namespace=nothing`. Namespaces are important in hierarchical models though, where we have Bloxs that contain other Bloxs in them. We will see such an example later on.
We will only include these two fields and write an inner constructor function for our `struct IzhNeuron`.

````julia:ex5
struct IzhNeuron <: Neuron
    system
    namespace

    # We keep all function arguments as keyword arguments
    # so that we can set them more conveniently as `arg = value`.
    function IzhNeuron(; name, namespace=nothing, a=0.02, b=0.2, V_reset=-50, d=2, threshold=30)
        sts = @variables V(t)=-65 [output=true] u(t)=-13 jcn [input=true]
        # Spike threshold `θ=30` is now included as a parameter.
        # Default values for all parameters are the keyword arguments from above. This way we can set them easily during construction.
        params = @parameters a=a b=b V_reset=V_reset d=d θ=threshold

        eqs = [D(V) ~ 0.04 * V ^ 2 + 5 * V + 140 - u + jcn + 5,
                D(u) ~ a * (b * V - u)]

        event = (V > θ) => [u ~ u + d, V ~ V_reset]
        sys = System(eqs, t, sts, params; name=name, discrete_events = event)

        new(sys, namespace)
    end
end
````

> **_Note:_** In `IzhNeuron` the `jcn` variable does not get a default value, only the [input=true] tag.
> This means that other Bloxs will connect to a `IzhNeuron` through `jcn`.
>
> Neuroblox automatically initializes a `jcn ~ 0` equation and then accumulates connection terms in it.
> This happens with all input variables of Bloxs.
>
> Similarly the `[output=true]` tag designates the `V` variable as the output variable.
> It is necessary for every Blox to have one if they rely on generic connection rules that fetch the output variable and add it to the connection equation.
>
> Both input and output tags are also useful to note which variables should be used when writing connection rules to or from our Blox.

Now we are ready to define the first object of `IzhNeuron` and connect it with the `LIFNeuron` we created above.

````julia:ex6
@named izh = IzhNeuron()
````

One benefit of assigning `IzhNeuron <: Neuron` is now apparent. Without defining a new connection equation for it, `IzhNeuron` can connect to `LIFNeuron` and to any other neuron type using a generic connection equation in Neuroblox.
We can see what this equation looks like by running

````julia:ex7
connection_equations(izh, lif) ## connection from izh to lif
connection_equations(lif, izh) ## connection from lif to izh
````

We even get a warning saying that the connection rule is not specified so Neuroblox defaults to this basic weighted connection.

## Custom Connections
Often times genric connection rules are not sufficient and we need ones specialized to our custom Bloxs. There are two elements that allow for great customization variery when it comes to connection rules, connection equations and callbacks.

### Connection equations
Let's define a custom equation that connects a `LIFNeuron` to our `IzhNeuron`. The first thing we need to do is to import the `connection_equations` function from Neuroblox so that we can add a new dispatch to it.

````julia:ex8
import Neuroblox: connection_equations

function connection_equations(source::LIFNeuron, destination::IzhNeuron, weight; kwargs...)
    equation = destination.jcn ~ weight * source.G * (destination.V - source.E_syn)

    return equation
end
````

Internally Neuroblox will call the function dispatch with the most specific combination of its input arguments. Before defining the function above there was no dispatch that had `IzhNeuron` in its signature so Neuroblox defaulted to the connection we saw above.
Now that we have defined a specialized equation, we can connect the same two Bloxs in a new way.

````julia:ex9
connection_equations(lif, izh)
````

Notice how the equation has changed compared to above and it is equal to our latest `connection_equations` dispatch.
> **_Note:_** When we define a new `connection_equations` dispatch we need to include three positional arguments, the source Blox, the destination Blox and a symbolic weight parameter that is generated internally in Neuroblox and assigned to a specific connection.
>
> We also include `kwargs...` which reads as an arbitrary number of keyword arguments. This is a placeholder for additional arguments that either Neuroblox uses internally or we want to pass as equation terms. We will see an example of the latter shortly.
>
> When we call `connection_equations(lif, izh)` to print out the relevant equations we don't have to include the `weight` since it is currently not generated.

````julia:ex10
g = MetaDiGraph()
# Also set the weight value this time
add_edge!(g, izh => lif, weight = 1)

@named sys = system_from_graph(g)
prob = ODEProblem(sys, [], (0, 200.0))
sol = solve(prob, Tsit5());
````

We can add as many keyword arguments as we want to our `connection_equations` dispatch. Such arguments can be used as additional terms to the equations.
Here we add a constant current `const_current` to the equations above.

````julia:ex11
function connection_equations(source::IzhNeuron, destination::LIFNeuron, weight; const_current=1, kwargs...)
    equation = destination.jcn ~ weight * source.V + const_current

    return equation
end
````

Now we can set `const_current` to any value we want each time we make a connection that uses it.

````julia:ex12
g = MetaDiGraph()
# Set const_current to a value that is other than its default.
add_edge!(g, izh => lif; weight = 1, const_current=20)

@named sys = system_from_graph(g)
prob = ODEProblem(sys, [], (0, 200.0))
sol = solve(prob, Tsit5());
````

> **_Exercise:_** Define another connection equation from a `LIFNeuron` to an `IzhNeuron`,
> then create a graph with one connection of this kind and simulate it.

### Connection callbacks
Algebraic connection equations is not the only way that a blox can interact with another one. Discrete callbacks are also possible.
These callbacks will be applied at every timepoint during simulation where the callback condition is fulfilled.
This mechanism is particularly useful for neuron models like the Izhikevich and the LIF neurons we saw above that use callbacks to implement spiking.

> **_Note:_** The affect equations of a single event can change either only variables or parameters. Currenlty we can not mix variable and parameter changes within the same event.
> See the [ModelingToolkit documentation](https://docs.sciml.ai/ModelingToolkit/stable/basics/Events/#Discrete-events-support) for more details.

````julia:ex13
import Neuroblox: connection_callbacks

function connection_callbacks(source::IzhNeuron, destination::LIFNeuron; spike_conductance=1, kwargs...)
    spike_affect = (source.V > source.θ) => [destination.G ~ destination.G + spike_conductance]

    return spike_affect
end

g = MetaDiGraph()
add_edge!(g, izh => lif, weight = 1)

@named sys = system_from_graph(g)

prob = ODEProblem(sys, [], (0, 200.0))
sol = solve(prob, Tsit5());
````

Exactly like `connection_equations`, when we define a `connection_callbacks` dispatch we add `kwargs...` to be used internally by Neuroblox and any other keyword arguments that we use in our callbacks.
Here we have added `spike_conductance` as the value that increments the conductance `G` after each spike.

> **_Exercise:_** Define a `connection_callbacks` function from a `LIFNeuron` to an `IzhNeuron`
> then create a graph with one connection of this kind and simulate it.
> Consider which variable or parameter of `IzhNeuron` should be affected by such a spike.
> Hint: Look at how a `IzhNeuron` spike affects its own dynamics.

# Challenge Problems
- Implement a Morris-Lecar neuron as a new Blox and add connection rules to interface it with itself and Hodgkin-Huxley neurons from Neuroblox (`HHNeuronExciBlox` and `HHNeuronInhibBlox`).
  - Morris C, Lecar H. Voltage oscillations in the barnacle giant muscle fiber. Biophys J. 1981 Jul;35(1):193-213. doi: 10.1016/S0006-3495(81)84782-0. PMID: 7260316; PMCID: PMC1327511.
  - http://www.scholarpedia.org/article/Morris-Lecar_model

- Implement a spiking neural network of Generalized Leaky Integrate-and-Fire neurons. Section 2.1 from the paper.
  - Lorenzi RM, Geminiani A, Zerlaut Y, De Grazia M, Destexhe A, Gandini Wheeler-Kingshott CAM, Palesi F, Casellato C, D'Angelo E. A multi-layer mean-field model of the cerebellum embedding microstructure and population-specific dynamics. PLoS Comput Biol. 2023 Sep 1;19(9):e1011434. doi: 10.1371/journal.pcbi.1011434. PMID: 37656758; PMCID: PMC10501640.

- Implement a Hopf network model with stochastic dynamics.
  - Ponce-Alvarez, A., Deco, G. The Hopf whole-brain model and its linear approximation. Sci Rep 14, 2615 (2024). https://doi.org/10.1038/s41598-024-53105-0

