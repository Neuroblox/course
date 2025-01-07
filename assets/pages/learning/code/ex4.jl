# This file was generated, do not modify it. # hide
trace.trial ## trial indices
trace.correct ## whether the response was correct or not on each trial
trace.action; ## what responce was made on each trial, 1 is left and 2 is right

adjacency(fig[1,2], agent; title = "After Learning", colorrange=(0,10))
fig
save(joinpath(@OUTPUT, "adj_RL.svg"), fig); # hide