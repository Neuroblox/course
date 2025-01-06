# This file was generated, do not modify it. # hide
N_wta = 10 ## number of WTA circuits
# parameters
N_exci = 5   ## number of pyramidal neurons in each lateral inhibition (WTA) circuit
G_syn_exci = 3.0 ## maximal synaptic conductance in glutamatergic (excitatory) synapses
G_syn_inhib = 4.0 ## maximal synaptic conductance in GABAergic (inhibitory) synapses from feedback interneurons
G_syn_ff_inhib = 3.5 ## maximal synaptic conductance in GABAergic (inhibitory) synapses from feedforward interneurons
I_bg = 5.0 ## background input current
density = 0.01 ## connection density between WTA circuits

# create a vector of `WinnerTakesAllBlox` using list comprehension
wtas = [WinnerTakeAllBlox(;
                        name=Symbol("wta$i"), ## manually add a name instead of using the @named macro
                        namespace=model_name,
                        N_exci=N_exci,
                        G_syn_exci=G_syn_exci,
                        G_syn_inhib=G_syn_inhib,
                        I_bg = I_bg
                        )
for i = 1:N_wta]

@named n_ff_inh = HHNeuronInhibBlox(; namespace=model_name, G_syn=G_syn_ff_inhib)

g = MetaDiGraph()

for i in 1:N_wta
    for j in 1:N_wta
        if j != i
            add_edge!(g, wtas[i] => wtas[j], weight=1, density=density);
        end
    end
    add_edge!(g, n_ff_inh => wtas[i], weight=1);
end