# This file was generated, do not modify it. # hide
data .-= mean(data, dims=1);
data *= 1/std(data[:])/4;
dfsol = DataFrame(data, :auto);