# This file was generated, do not modify it.

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
add_edge!(g, VAC => AC, weight=3, density=0.1, learning_rule = hebbian_cort) ## give learning rule as parameter

agent = Agent(g; name=model_name);
env = ClassificationEnvironment(stim, N_trials; name=:env, namespace=model_name);

fig = Figure(title="Adjacency matrix", size = (1600, 800))

adjacency(fig[1,1], agent; title="Initial weights")

run_experiment!(agent, env; t_warmup=200.0, alg=Vern7(), verbose=true)

adjacency(fig[1,2], agent; title="Final weights")
fig
save(joinpath(@OUTPUT, "adj_open.svg"), fig); # hide

time_block_dur = 90.0 ## ms (size of discrete time blocks)
N_trials = 100 ## number of trials
trial_dur = 1000 ## ms

image_set = CSV.read(Downloads.download("raw.githubusercontent.com/Neuroblox/NeurobloxDocsHost/refs/heads/main/data/stimuli_set.csv"), DataFrame) ## reading data into DataFrame format

# additional Striatum Bloxs
@named STR1 = Striatum(; namespace=model_name, N_inhib=5)
@named STR2 = Striatum(; namespace=model_name, N_inhib=5)

@named tan_pop1 = TAN(κ=10; namespace=model_name)
@named tan_pop2 = TAN(κ=10; namespace=model_name)

@named SNcb = SNc(κ_DA=1; namespace=model_name)

# action selection Blox, necessary for making a choice
@named AS = GreedyPolicy(; namespace=model_name, t_decision=2*time_block_dur)

# learning rules
hebbian_mod = HebbianModulationPlasticity(K=0.05, decay=0.01, α=2.5, θₘ=1, modulator=SNcb, t_pre=trial_dur, t_post=trial_dur, t_mod=time_block_dur)
hebbian_cort = HebbianPlasticity(K=5e-4, W_lim=7, t_pre=trial_dur, t_post=trial_dur)

g = MetaDiGraph()

add_edge!(g, stim => VAC, weight=14)
add_edge!(g, ASC1 => VAC, weight=44)
add_edge!(g, ASC1 => AC, weight=44)
add_edge!(g, VAC => AC, weight=3, density=0.1, learning_rule = hebbian_cort)
add_edge!(g, AC => STR1, weight = 0.075, density =  0.04, learning_rule =  hebbian_mod)
add_edge!(g, AC => STR2, weight =  0.075, density =  0.04, learning_rule =  hebbian_mod)
add_edge!(g, tan_pop1 => STR1, weight = 1, t_event = time_block_dur)
add_edge!(g, tan_pop2 => STR2, weight = 1, t_event = time_block_dur)
add_edge!(g, STR1 => tan_pop1, weight = 1)
add_edge!(g, STR2 => tan_pop1, weight = 1)
add_edge!(g, STR1 => tan_pop2, weight = 1)
add_edge!(g, STR2 => tan_pop2, weight = 1)
add_edge!(g, STR1 => STR2, weight = 1, t_event = 2*time_block_dur)
add_edge!(g, STR2 => STR1, weight = 1, t_event = 2*time_block_dur)
add_edge!(g, STR1 => SNcb, weight = 1)
add_edge!(g, STR2 => SNcb, weight = 1)
# action selection connections
add_edge!(g, STR1 => AS);
add_edge!(g, STR2 => AS);

agent = Agent(g; name=model_name, t_block = time_block_dur); ## define agent
env = ClassificationEnvironment(stim, N_trials; name=:env, namespace=model_name)

fig = Figure(title="Adjacency matrix", size = (1600, 800))

adjacency(fig[1,1], agent; title = "Before Learning")

trace = run_experiment!(agent, env; t_warmup=200.0, alg=Vern7(), verbose=true)

trace.trial ## trial indices
trace.correct ## whether the response was correct or not on each trial
trace.action; ## what responce was made on each trial, 1 is left and 2 is right

adjacency(fig[1,2], agent; title = "After Learning")
fig
save(joinpath(@OUTPUT, "adj_RL.svg"), fig); # hide
