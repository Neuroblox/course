# This file was generated, do not modify it. # hide
Random.seed!(17)   # set seed for reproducibility

nr = 3             # number of regions
g = MetaDiGraph()
regions = [];      # list of neural mass blocks to then connect them to each other with an adjacency matrix `A_true`