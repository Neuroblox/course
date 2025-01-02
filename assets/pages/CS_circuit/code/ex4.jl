# This file was generated, do not modify it. # hide
N_exci = 5 ## number of excitatory neurons in each WTA circuit
# For a single-valued input `I_bg`, each neuron in the WTA Blox will receive a uniformly distributed random background current from 0 to `I_bg`
@named wta1 = WinnerTakeAllBlox(namespace=model_name, I_bg=5, N_exci=N_exci)
@named wta2 = WinnerTakeAllBlox(namespace=model_name, I_bg=4, N_exci=N_exci)

g = MetaDiGraph()
add_edge!(g, wta1 => wta2, weight=1, density=0.5);