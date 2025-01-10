# This file was generated, do not modify it. # hide
g = MetaDiGraph() ## Initialize the graph

for ne ∈ exci
    for ni ∈ inhib
        add_edge!(g, ne => ni; weight=g_EI/N) ## Add the E -> I connections
        add_edge!(g, ni => ne; weight=g_IE/N) ## Add the I -> E connections
    end
end

for ni1 ∈ inhib
    for ni2 ∈ inhib
        add_edge!(g, ni1 => ni2; weight=g_II/N); ## Add the I -> I connections
    end
end