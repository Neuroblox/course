# This file was generated, do not modify it.

using Neuroblox
using OrdinaryDiffEq
using Random
using CairoMakie

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

@named sys = system_from_graph(g)
prob = ODEProblem(sys, [], (0.0, 1000), [])
sol = solve(prob, Vern7())
fig = stackplot([exci1, exci2, exci3, exci4, exci5, inh], sol)
save(joinpath(@OUTPUT, "wta_stack.svg"), fig); # hide

N_exci = 5 ## number of excitatory neurons in each WTA circuit
# For a single-valued input `I_bg`, each neuron in the WTA Blox will receive a uniformly distributed random background current from 0 to `I_bg`.
@named wta1 = WinnerTakeAllBlox(namespace=model_name, I_bg=5, N_exci=N_exci)
@named wta2 = WinnerTakeAllBlox(namespace=model_name, I_bg=4, N_exci=N_exci)

g = MetaDiGraph()
add_edge!(g, wta1 => wta2, weight=1, density=0.5);

sys = system_from_graph(g, name=model_name)
prob = ODEProblem(sys, [], (0.0, 1000), [])
sol = solve(prob, Vern7())

neuron_set = get_neurons([wta1, wta2]) ## extract neurons from a composite blocks
fig = stackplot(neuron_set, sol)
save(joinpath(@OUTPUT, "wta_wta_stack.svg"), fig); # hide

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

sys = system_from_graph(g, name = model_name)
prob = ODEProblem(sys, [], (0.0, 1000))
sol = solve(prob, Vern7())

wta_neurons = get_neurons(wtas) ## extract neurons from WTA circuits
neurons = vcat(wta_neurons, n_ff_inh)
fig = stackplot(neurons, sol)
save(joinpath(@OUTPUT, "cort_stack.svg"), fig); # hide

@named ASC1 = NextGenerationEIBlox(;namespace=model_name, Cₑ=2*26, Cᵢ=26, v_synₑₑ=10.0, v_synₑᵢ=-10.0, v_synᵢₑ=10.0, v_synᵢᵢ=-10.0, alpha_invₑₑ=10.0/26, alpha_invₑᵢ=0.8/26, alpha_invᵢₑ=10.0/26, alpha_invᵢᵢ=0.8/26, kₑᵢ=0.6*26, kᵢₑ=0.6*26);

# number if WTA circuits = N_wta=45
# number of pyramidal neurons in each WTA circuit = N_exci = 5
@named CB = CorticalBlox(N_wta=10, N_exci=5, density=0.01, weight=1, I_bg_ar=7; namespace=model_name)

g = MetaDiGraph()
add_edge!(g, ASC1 => CB, weight=44)

# solve the system for time 0 to 1000 ms
sys = system_from_graph(g, name = model_name)
prob = ODEProblem(sys, [], (0.0, 1000))
sol = solve(prob, Vern7());

neuron_set = get_neurons(CB) ## extract neurons from a composite block like CorticalBlox
n_neurons = 50 ## set number of neurons to display in the stackplot
fig = stackplot(neuron_set[1:n_neurons], sol)
save(joinpath(@OUTPUT, "cort_asc_stack.svg"), fig); # hide

fig = meanfield(CB, sol)
save(joinpath(@OUTPUT, "cort_meanfield.svg"), fig); # hide

fig = powerspectrumplot(CB, sol; sampling_rate=0.01)
save(joinpath(@OUTPUT, "cort_power.svg"), fig); # hide

@named VAC = CorticalBlox(namespace=model_name, N_wta=10, N_exci=5,  density=0.01, weight=1)
@named AC = CorticalBlox(namespace=model_name, N_wta=10, N_exci=5, density=0.01, weight=1)
# ascending system blox, modulating frequency set to 16 Hz
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

# access the desired image sample, exclude the last row that is a category label
pixels = Array(image_set[image_sample, 1:end-1])
# reshape into 15 X 15 square image matrix
pixels = reshape(pixels, 15, 15)
# plot the image that the visual cortex 'sees'
fig = heatmap(pixels, colormap = :gray1)
save(joinpath(@OUTPUT, "image_stim.svg"), fig); # hide

g = MetaDiGraph()
add_edge!(g, stim => VAC, weight=14)
add_edge!(g, ASC1 => VAC, weight=44)
add_edge!(g, ASC1 => AC, weight=44)
add_edge!(g, VAC => AC, weight=3, density=0.08)

# define system and solve
sys = system_from_graph(g, name=model_name)
prob = ODEProblem(sys, [], (0.0, 1000))
sol = solve(prob, Vern7());
