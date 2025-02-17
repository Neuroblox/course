# This file was generated, do not modify it. # hide
noise_distribution = Normal(0, 0.1)
data .+= rand(noise_distribution, size(data))