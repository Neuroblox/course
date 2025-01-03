# This file was generated, do not modify it. # hide
A_true = [[-0.5 -2 0]; [0.4 -0.5 -0.3]; [0 0.2 -0.5]]
for idx in CartesianIndices(A_true)
    add_edge!(g, regions[idx[1]] => regions[idx[2]], weight=A_true[idx[1], idx[2]])
end