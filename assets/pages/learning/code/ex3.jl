# This file was generated, do not modify it. # hide
agent = Agent(g; name=model_name, t_block = time_block_dur); ## define agent
env = ClassificationEnvironment(stim, N_trials; name=:env, namespace=model_name)

fig = Figure(title="Adjacency matrix", size = (1600, 800))

adjacency(fig[1,1], agent; title = "Before Learning", colorrange=(0,10))

trace = run_experiment!(agent, env; t_warmup=200.0, alg=Vern7(), verbose=true)