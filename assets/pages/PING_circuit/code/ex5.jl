# This file was generated, do not modify it. # hide
exci_driven = [PINGNeuronExci(name=Symbol("ED$i"), I_ext=rand(I_driveE) + rand(I_base)) for i in 1:NE_driven] ## In-line loop to create the driven excitatory neurons, named ED1, ED2, etc.
exci_other  = [PINGNeuronExci(name=Symbol("EO$i"), I_ext=rand(I_base) + rand(I_undriven)) for i in 1:NE_other] ## In-line loop to create the undriven excitatory neurons, named EO1, EO2, etc.
exci        = [exci_driven; exci_other] ## Concatenate the driven and undriven excitatory neurons into a single vector for convenience
inhib       = [PINGNeuronInhib(name=Symbol("ID$i"), I_ext=rand(I_driveI) + rand(I_base) + I_bath) for i in 1:NI_driven]; ## In-line loop to create the inhibitory neurons, named ID1, ID2, etc.