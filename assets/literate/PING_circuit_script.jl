# This file was generated, do not modify it.

using Neuroblox
using OrdinaryDiffEq
using Distributions
using Random
using CairoMakie

Random.seed!(42);

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

I_base = Normal(0, 0.1) ## base external current for all neurons
I_driveE = Normal(μ_E, σ_E) ## External current for driven excitatory neurons
I_driveI = Normal(μ_I, σ_I) ## External current for driven inhibitory neurons
I_undriven = Normal(0, 0.4) ## Additional noise current for undriven excitatory neurons. Manually tuned.
I_bath = -0.7; ## External inhibitory bath for inhibitory neurons - value from p. 11 of the SI Appendix

exci_driven = [PINGNeuronExci(name=Symbol("ED$i"), I_ext=rand(I_driveE) + rand(I_base)) for i in 1:NE_driven] ## In-line loop to create the driven excitatory neurons, named ED1, ED2, etc.
exci_other  = [PINGNeuronExci(name=Symbol("EO$i"), I_ext=rand(I_base) + rand(I_undriven)) for i in 1:NE_other] ## In-line loop to create the undriven excitatory neurons, named EO1, EO2, etc.
exci        = [exci_driven; exci_other] ## Concatenate the driven and undriven excitatory neurons into a single vector for convenience
inhib       = [PINGNeuronInhib(name=Symbol("ID$i"), I_ext=rand(I_driveI) + rand(I_base) + I_bath) for i in 1:NI_driven]; ## In-line loop to create the inhibitory neurons, named ID1, ID2, etc.

g = MetaDiGraph() ## Initialize the graph

# Add the E -> I and I -> E connections
for ne ∈ exci
    for ni ∈ inhib
        add_edge!(g, ne => ni; weight=g_EI/N)
        add_edge!(g, ni => ne; weight=g_IE/N)
    end
end

# Add the I -> I connections
for ni1 ∈ inhib
    for ni2 ∈ inhib
        add_edge!(g, ni1 => ni2; weight=g_II/N);
    end
end

g = MetaDiGraph() ## Initialize the graph
add_blox!.(Ref(g), [exci; inhib]) ## Add all the neurons to the graph
adj = zeros(N_total, N_total) ## Initialize the adjacency matrix
for i ∈ 1:NE_driven + NE_other
    for j ∈ 1:NI_driven
        adj[i, NE_driven + NE_other + j] = g_EI/N
        adj[NE_driven + NE_other + j, i] = g_IE/N
    end
end
for i ∈ 1:NI_driven
    for j ∈ 1:NI_driven
        adj[NE_driven + NE_other + i, NE_driven + NE_other + j] = g_II/N
    end
end
create_adjacency_edges!(g, adj);

tspan = (0.0, 300.0) ## Time span for the simulation - run for 300ms to match the Börgers et al. [1] Figure 1.
@named sys = system_from_graph(g, graphdynamics=true)
prob = ODEProblem(sys, [], tspan) ## Create the problem to solve
sol = solve(prob, Tsit5(), saveat=0.1); ## Solve the problem and save at 0.1ms resolution.

fig = Figure()
rasterplot(fig[1,1], exci, sol; threshold=20.0, title="Excitatory Neurons")
rasterplot(fig[2,1], inhib, sol; threshold=20.0, title="Inhibitory Neurons")
fig
save(joinpath(@OUTPUT, "ping_raster.svg"), fig); # hide
