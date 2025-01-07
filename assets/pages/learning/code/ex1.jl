# This file was generated, do not modify it. # hide
using Neuroblox
using OrdinaryDiffEq ## to build the ODE problem and solve it, gain access to multiple solvers from this
using Random ## for generating random variables
using CairoMakie ## for customized plotting recipies for blox
using CSV ## to read data from CSV files
using DataFrames ## to format the data into DataFrames
using Downloads ## to download image stimuli files

N_trials = 5 ## number of trials
trial_dur = 1000 ## in ms

# download the stimulus images
image_set = CSV.read(Downloads.download("raw.githubusercontent.com/Neuroblox/NeurobloxDocsHost/refs/heads/main/data/stimuli_set.csv"), DataFrame) ## reading data into DataFrame format

model_name = :g
# define stimulus Blox
# t_stimulus: how long the stimulus is on (in ms)
# t_pause : how long the stimulus is off (in ms)
@named stim = ImageStimulus(image_set; namespace=model_name, t_stimulus=trial_dur, t_pause=0);

# Cortical Bloxs
@named VAC = CorticalBlox(; namespace=model_name, N_wta=4, N_exci=5,  density=0.05, weight=1)
@named AC = CorticalBlox(; namespace=model_name, N_wta=2, N_exci=5, density=0.05, weight=1)
# ascending system Blox, modulating frequency set to 16 Hz
@named ASC1 = NextGenerationEIBlox(; namespace=model_name, Cₑ=2*26,Cᵢ=1*26, alpha_invₑₑ=10.0/26, alpha_invₑᵢ=0.8/26, alpha_invᵢₑ=10.0/26, alpha_invᵢᵢ=0.8/26, kₑᵢ=0.6*26, kᵢₑ=0.6*26)

# learning rule
hebbian_cort = HebbianPlasticity(K=5e-5, W_lim=7, t_pre=trial_dur, t_post=trial_dur)

g = MetaDiGraph()

add_edge!(g, stim => VAC, weight=14)
add_edge!(g, ASC1 => VAC, weight=44)
add_edge!(g, ASC1 => AC, weight=44)
add_edge!(g, VAC => AC, weight=3, density=0.1, learning_rule = hebbian_cort) ## pass learning rule as a keyword argument

agent = Agent(g; name=model_name);
env = ClassificationEnvironment(stim, N_trials; name=:env, namespace=model_name);

fig = Figure(title="Adjacency matrix", size = (1600, 800))

adjacency(fig[1,1], agent; title="Initial weights", colorrange=(0,50))

run_experiment!(agent, env; t_warmup=200.0, alg=Vern7())

adjacency(fig[1,2], agent; title="Final weights", colorrange=(0,50))
fig
save(joinpath(@OUTPUT, "adj_open.svg"), fig); # hide