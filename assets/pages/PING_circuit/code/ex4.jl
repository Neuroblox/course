# This file was generated, do not modify it. # hide
I_base = Normal(0, 0.1) ## base external current for all neurons
I_driveE = Normal(μ_E, σ_E) ## External current for driven excitatory neurons
I_driveI = Normal(μ_I, σ_I) ## External current for driven inhibitory neurons
I_undriven = Normal(0, 0.4) ## Additional noise current for undriven excitatory neurons. Manually tuned.
I_bath = -0.7; ## External inhibitory bath for inhibitory neurons - value from p. 11 of the SI Appendix