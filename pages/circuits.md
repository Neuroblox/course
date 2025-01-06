# Circuit Models in Neuroblox

## Introduction

We saw how Bloxs and their connection rules are defined and we can connect external sources to single neuron or neural mass Bloxs. Now we are ready to expand our models to resemble more closely the neuronal circuits of the brain.

This session includes two examples of circuit models
- [a biomimetic corticostriatal model of visual processing](/pages/CS_circuit)
- [a Pyramidal-Interneuron Gamma Network (PING) of Excitation-Inhibition balance](/pages/PING_circuit). 

Learning goals :
- build complex models from the systems neuroscience literature.
- introduce composite Bloxs with hierarchical structures.
- use more advanced plotting recipes to visualize complex Bloxs and circuits of them.

## Namespaces 

When defining our own Bloxs previously or when creating Blox objects we left the `namespace=nothing` keyword argument to its default value. This is because it was unnecessary to provide an explicit namespace qualifier, as we were working with "atomic" Bloxs, that is Bloxs that contained some dynamics of a neuron or a neural mass model. 

Neuroblox also contains composite Bloxs though, as subtypes of `CompositeBlox`. All `CompositeBlox` subtypes do not have their own dynamics, but they contain either other `CompositeBlox`s or Bloxs with dynamics such as `Neuron` and/or `NeuralMass` types. When working with `CompositeBlox`s with multiple layers its important to declare a `namespace` value, which will be the outermost name of our model. Neuroblox uses this `namespace` to accumulate all connection terms and match them correctly to the appropriate input variable of each Blox.

## Example
Let's consider two `WinnerTakesAllBlox` objects which are `<: CompositeBlox` and include multiple excitatory neurons and a feedback inhibitory neuron implementing lateral inhibition.

```julia
model_name = :g
wta1 = WinnerTakesAllBlox(namespace = model_name)
wta2 = WinnerTakesAllBlox(namespace = model_name)
```

then `wta1₊exci1₊V` and `wta2₊exci2₊V` are the voltage variables (membrane potentials) of  the first excitatory neuron (`HHNeuronExciBlox`) in `wta1` and `wta2` respectively. Each `₊` character adds another namespace if read from right to left. 

We have chosen `model_name = :g` as the name of our model that contains these two WTA Bloxs. This name will be given to the `name` field of `system_from_graph` that creates the final model with all connection equations and simplified structure. We provide an explicit name instead of using the `@named` macro.

```julia
g = MetaDiGraph()
add_edge!(g, wta1 => wta2, weight=10)

sys = system_from_graph(g, name = model_name)
```

so after we turn the graph into a system, the above variables will be `g₊wta1₊exci1₊V` and `g₊wta2₊exci2₊V`.

