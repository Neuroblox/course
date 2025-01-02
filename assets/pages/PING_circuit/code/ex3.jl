# This file was generated, do not modify it. # hide
μ_E = 0.8 ## mean of the excitatory neurons' external current, manually tuned from the value on p. 8 of the Appendix
σ_E = 0.15 ## standard deviation of the excitatory neurons' external current, given on p. 8 of the Appendix
μ_I = 0.8 ## mean of the inhibitory neurons' external current, given on p. 9 of the Appendix
σ_I = 0.08 ## standard deviation of the inhibitory neurons' external current, given on p. 9 of the Appendix

NE_driven = 40 ## number of driven excitatory neurons, given on p. 8 of the Appendix. Note all receive constant rather than half stochastic drives.
NE_other = 120 ## number of non-driven excitatory neurons, given in the Methods section
NI_driven = 40 ## number of inhibitory neurons (all driven), given in the Methods section
N_total = NE_driven + NE_other + NI_driven ## total number of neurons in the network

N = N_total ## convenience redefinition to improve the readability of the connection weights
g_II = 0.2 ## inhibitory-inhibitory connection weight, given on p. 8 of the Appendix
g_IE = 0.6 ## inhibitory-excitatory connection weight, given on p. 8 of the Appendix
g_EI = 0.8; ## excitatory-inhibitory connection weight, manually tuned from values given on p. 8 of the Appendix