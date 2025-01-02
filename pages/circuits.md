# Circuit Models in Neuroblox

We saw how Bloxs and their connection rules are defined and we can connect external sources to single neuron or neural mass Bloxs. Now we are ready to expand our models to resemble more closely the neuronal circuits of the brain.

This session includes two examples of circuit models, a biomimetic corticostriatal model of visual processing and a Pyramidal-Interneuron Gamma Network (PING) of Excitation-Inhibition balance. 

## Namespaces 

When defining our own Bloxs previously or when creating Blox objects we left the `namespace=nothing` keyword argument to its default value. This is because it was unnecessary to provide an explicit namespace qualifier, as we were working with "atomic" Bloxs, that is Bloxs that contained some dynamics of a neuron or a neural mass model. 

Neuroblox also contains composite Bloxs though, as subtypes of `CompositeBlox`. All `CompositeBlox` subtypes do not have their own dynamics, but they contain either other `CompositeBlox`s or Bloxs with dynamics such as `Neuron` and/or `NeuralMass` types. When working with `CompositeBlox`s with multiple layers its important to declare a `namespace` value, which will be the outermost name of our model.

