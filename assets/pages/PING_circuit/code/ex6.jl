# This file was generated, do not modify it. # hide
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