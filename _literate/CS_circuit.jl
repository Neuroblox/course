# # Biomimetic model of corticostriatal micro-assemblies
# Learnin goals
# - define a "winner-takes-all" (WTA) circuit with lateral inhibition.
# - build a Cortical Blox by connecting multiple WTAs together with feed-forward inhibition.
# - use a next-generation neural mass Blox to modulate the firing frequency of the Cortical Blox.
# - define a source of visual input (images) and simulate visual processing.

using Neuroblox
using OrdinaryDiffEq 
using Random 
using CairoMakie 

# First we will manually create a lateral inhibition circuit (the "winner-takes-all" circuit) to better understand its components. This circuit is inspired by the structure of the superficial cortical layer.

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

# As we can see, the lateral inhibition circuit is made up of 5 excitatory neurons with each one having a reciprocal connection to the same inhibitory interneuron.

@named sys = system_from_graph(g)
prob = ODEProblem(sys, [], (0.0, 1000), [])
sol = solve(prob, Vern7())
fig = stackplot([exci1, exci2, exci3, exci4, exci5, inh], sol)
save(joinpath(@OUTPUT, "wta_stack.svg"), fig); # hide
# \fig{wta_stack}

# `stackplot` stacks the voltage timeseries of each input neuron on top of each other. The y-axis scale is meaningless due to timeseries offsets, yet the plot offers a useful look into spiking patterns in a population.
# > **_Exercise:_** Try varying the size of the circuit by changing the number of excitatory neurons, while keeping the same structure (all of them connect to the inhibitory neuron and vice versa).

# The circuit we just built is implemented as a single Blox in Neuroblox. The `WinnerTakeAllBlox` is a subtype of `CompositeBlox`. All `CompositeBlox`s do not have their own dynamics, but they contain either other `CompositeBlox`s or Bloxs with dynamics such as `Neuron` and/or `NeuralMass` types.

N_exci = 5 ## number of excitatory neurons in each WTA circuit
## For a single-valued input `I_bg`, each neuron in the WTA Blox will receive a uniformly distributed random background current from 0 to `I_bg`  
@named wta1 = WinnerTakeAllBlox(namespace=model_name, I_bg=5, N_exci=N_exci)
@named wta2 = WinnerTakeAllBlox(namespace=model_name, I_bg=4, N_exci=N_exci)

g = MetaDiGraph()
add_edge!(g, wta1 => wta2, weight=1, density=0.5);

# The `density` keyword argument sets the connection probability from each excitatory neuron of `wta1` to each excitatory neuron of `wta2`.
# Whether a connection is actually made or not depends on a Bernoulli trial with probability of success equal to `density`.

sys = system_from_graph(g, name=model_name)
prob = ODEProblem(sys, [], (0.0, 1000), [])
sol = solve(prob, Vern7())

neuron_set = get_neurons([wta1, wta2]) ## extract neurons from a composite blocks 
fig = stackplot(neuron_set, sol)
save(joinpath(@OUTPUT, "wta_wta_stack.svg"), fig); # hide
# \fig{wta_wta_stack}

# Now we are ready to create a single cortical superficial layer block by connecting multiple WTA circuits

# This model is SCORT in [1] and looks like this
# ![fig4](../assets/neural_assembly_4.png)

N_wta = 10 ## number of WTA circuits
## parameters
N_exci = 5   ## number of pyramidal neurons in each lateral inhibition (WTA) circuit
G_syn_exci = 3.0 ## maximal synaptic conductance in glutamatergic (excitatory) synapses
G_syn_inhib = 4.0 ## maximal synaptic conductance in GABAergic (inhibitory) synapses from feedback interneurons
G_syn_ff_inhib = 3.5 ## maximal synaptic conductance in GABAergic (inhibitory) synapses from feedforward interneurons
I_bg = 5.0 ## background input current
density = 0.01 ## connection density between WTA circuits

## create a vector of `WinnerTakesAllBlox` using list comprehension
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

# WTA circuits connect to each other with given connection density and the feedforward interneuron connects to each WTA circuit.
# The feed-forward interneuron `n_ff_inh` receives input from the excitatory (pyramidal) cells of the WTA circuits and it is largely responsible for controlling the spiking rhythm of the ensemble of WTAs.
  
sys = system_from_graph(g, name = model_name)
prob = ODEProblem(sys, [], (0.0, 1000))
sol = solve(prob, Vern7())

wta_neurons = get_neurons(wtas) ## extract neurons from WTA circuits
neurons = vcat(wta_neurons, n_ff_inh)
fig = stackplot(neurons, sol)
save(joinpath(@OUTPUT, "cort_stack.svg"), fig); # hide
# \fig{cort_stack}

# > **_Exercise:_** Try different connection densities and weights and see how it affects the population activity. 

# The next step is to expand the cortical model we just created by adding a Blox representing an ascending system (ASC1 in [1]) to it. 
# We define the ascending system using a Next Generation Neural Mass model as described in [2]. The neural mass parameters are fixed to generate a 16 Hz modulating frequency in the cortical neurons.  

@named ASC1 = NextGenerationEIBlox(;namespace=model_name, Cₑ=2*26, Cᵢ=26, v_synₑₑ=10.0, v_synₑᵢ=-10.0, v_synᵢₑ=10.0, v_synᵢᵢ=-10.0, alpha_invₑₑ=10.0/26, alpha_invₑᵢ=0.8/26, alpha_invᵢₑ=10.0/26, alpha_invᵢᵢ=0.8/26, kₑᵢ=0.6*26, kᵢₑ=0.6*26);

# Similar to `WinnerTakeAllBlox`, the cortical model we created above by connecting multiple WTAs together is implemented as a single Blox in Neuroblox. This is the `CorticalBlox` and it models a superficial layer cortical microcircuit.
# So `CorticalBlox` is a hierarchical Blox which holds a feedforward interneuron and multiple `WinnerTakeAllBlox` which in turn hold multiple excitatory neurons and one feedback interneuron each.

## number if WTA circuits = N_wta=45
## number of pyramidal neurons in each WTA circuit = N_exci = 5
@named CB = CorticalBlox(N_wta=10, N_exci=5, density=0.01, weight=1, I_bg_ar=7; namespace=model_name)

g = MetaDiGraph()
add_edge!(g, ASC1 => CB, weight=44)

## solve the system for time 0 to 1000 ms
sys = system_from_graph(g, name = model_name)
prob = ODEProblem(sys, [], (0.0, 1000)) 
sol = solve(prob, Vern7());

neuron_set = get_neurons(CB) ## extract neurons from a composite block like CorticalBlox
n_neurons = 50 ## set number of neurons to display in the stackplot
fig = stackplot(neuron_set[1:n_neurons], sol)
save(joinpath(@OUTPUT, "cort_asc_stack.svg"), fig); # hide
# \fig{cort_asc_stack}

# We can also generate plots of averaged activity in any composite Blox like `CorticalBlox` and `WinnerTakeAllBlox`. 
# For instance the meanfield of all cortical block neurons (mean membrane voltage)
fig = meanfield(CB, sol)
save(joinpath(@OUTPUT, "cort_meanfield.svg"), fig); # hide
# \fig{cort_meanfield}

# and the powerspectrum of the meanfield (average over membrane potentials)
fig = powerspectrumplot(CB, sol; sampling_rate=0.01)
save(joinpath(@OUTPUT, "cort_power.svg"), fig); # hide
# \fig{cort_power}

# Notice the peak at 16 Hz, representing beta oscillations.
# > **_Exercise:_** Try changing parameters of `ASC1` to generate different cortical rhythms.

# Finally we will simulate visual processing in our model by adding a `CorticalBlox` representing visual area cortex (VAC) and an `ImageStimulus` connected to it.

@named VAC = CorticalBlox(namespace=model_name, N_wta=10, N_exci=5,  density=0.01, weight=1) 
@named AC = CorticalBlox(namespace=model_name, N_wta=10, N_exci=5, density=0.01, weight=1) 
## ascending system blox, modulating frequency set to 16 Hz
@named ASC1 = NextGenerationEIBlox(namespace=model_name, Cₑ=2*26,Cᵢ=1*26, Δₑ=0.5, Δᵢ=0.5, η_0ₑ=10.0, v_synₑₑ=10.0, v_synₑᵢ=-10.0, v_synᵢₑ=10.0, v_synᵢᵢ=-10.0, alpha_invₑₑ=10.0/26, alpha_invₑᵢ=0.8/26, alpha_invᵢₑ=10.0/26, alpha_invᵢᵢ=0.8/26, kₑᵢ=0.6*26, kᵢₑ=0.6*26) 

using CSV ## to read data from CSV files
using DataFrames ## to format the data into DataFrames
using Downloads ## to download image stimuli files

image_set = CSV.read(Downloads.download("raw.githubusercontent.com/Neuroblox/NeurobloxDocsHost/refs/heads/main/data/image_example.csv"), DataFrame) ## reading data into DataFrame format
image_sample = 2 ## set which image to input (from 1 to 1000)

@named stim = ImageStimulus(
    image_set[[image_sample], :], 
    namespace=model_name, 
    t_stimulus = 1000, ## how long the stimulus is on (in msec)
    t_pause = 0 ## how long the stimulus is off after `t_stimulus` (in msec)
); 

## access the desired image sample, exclude the last row that is a category label
pixels = Array(image_set[image_sample, 1:end-1])
## reshape into 15 X 15 square image matrix
pixels = reshape(pixels, 15, 15)
## plot the image that the visual cortex 'sees'
fig = heatmap(pixels, colormap = :gray1)
save(joinpath(@OUTPUT, "image_stim.svg"), fig); # hide
# \fig{image_stim}

# Above we can see an example image stimulus. Each pixel of the image stimulus is a variable (`stim₊u_i`) that connects to a neuron of the visual cortex `VAC` Blox. Using `connection_rule(stim, VAC)` we can better see how this connection is implemented.

g = MetaDiGraph()
add_edge!(g, stim => VAC, weight=14) 
add_edge!(g, ASC1 => VAC, weight=44)
add_edge!(g, ASC1 => AC, weight=44)
add_edge!(g, VAC => AC, weight=3, density=0.08)

## define system and solve
sys = system_from_graph(g, name=model_name)
prob = ODEProblem(sys, [], (0.0, 1000))
sol = solve(prob, Vern7());

# > **_Exercise:_** : Use the plotting functions from above to visualize the simulation results for any Blox of your choice. 
# > Try changing the image samples and notice the change in the spatial firing patterns in VAC and AC neurons. 

# ## References
# [1] Pathak A., Brincat S., Organtzidis H., Strey H., Senneff S., Antzoulatos E., Mujica-Parodi L., Miller E., Granger R. Biomimetic model of corticostriatal micro-assemblies discovers new neural code., bioRxiv 2023.11.06.565902, 2024
# [2] Byrne Á, O'Dea RD, Forrester M, Ross J, Coombes S. Next-generation neural mass and field modeling. J Neurophysiol. 2020 Feb 1;123(2):726-742. doi: 10.1152/jn.00406.2019. Epub 2019 Nov 27. PMID: 31774370.