# This file was generated, do not modify it. # hide
(state, setup) = setup_sDCM(dfsol[:, String.(Symbol.(s_bold))], fitmodel, perturbedfp, csdsetup, priors, hyperpriors, indices, pmean, "fMRI");

# HACK: on machines with very small amounts of RAM, Julia can run out of stack space while compiling the code called in this loop
# this should be rewritten to abuse the compiler less, but for now, an easy solution is just to run it with more allocated stack space.
with_stack(f, n) = fetch(schedule(Task(f, n)));