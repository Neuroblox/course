# This file was generated, do not modify it. # hide
A = []
for (i, a) in enumerate(vec(A_prior))
    symb = Symbol("A$(i)")
    push!(A, only(@parameters $symb = a))
end

for (i, idx) in enumerate(CartesianIndices(A_prior))
    if idx[1] == idx[2]
        add_edge!(g, regions[idx[1]] => regions[idx[2]], weight=-exp(A[i])/2)  ## -exp(A[i])/2: treatement of diagonal elements in SPM12 to make diagonal dominance (see Gershgorin Theorem) more likely but it is not guaranteed
    else
        add_edge!(g, regions[idx[2]] => regions[idx[1]], weight=A[i])
    end
end
# Avoid simplification of the model in order to be able to exclude some parameters from fitting
@named fitmodel = system_from_graph(g, simplify=false);