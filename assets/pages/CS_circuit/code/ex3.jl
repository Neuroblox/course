# This file was generated, do not modify it. # hide
model_name = :g

@named inh = HHNeuronInhibBlox(namespace=model_name, G_syn = 4.0) ##feedback inhibitory interneuron neuron

##creating an array of excitatory pyramidal neurons
@named exci1 = HHNeuronExciBlox(namespace=model_name, I_bg = 5*rand())
@named exci2 = HHNeuronExciBlox(namespace=model_name, I_bg = 5*rand())
@named exci3 = HHNeuronExciBlox(namespace=model_name, I_bg = 5*rand())
@named exci4 = HHNeuronExciBlox(namespace=model_name, I_bg = 5*rand())
@named exci5 = HHNeuronExciBlox(namespace=model_name, I_bg = 5*rand())

g = MetaDiGraph()

for exci_neuron in [exci1, exci2, exci3, exci4, exci5]
    add_edge!(g, inh => exci_neuron, weight = 1)
    add_edge!(g, exci_neuron => inh, weight = 1)
end