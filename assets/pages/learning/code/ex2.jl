# This file was generated, do not modify it. # hide
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