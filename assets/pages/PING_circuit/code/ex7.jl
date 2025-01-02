# This file was generated, do not modify it. # hide
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