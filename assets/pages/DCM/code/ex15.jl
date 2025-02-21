# This file was generated, do not modify it. # hide
p = 8
mar = mar_ml(data, p)   # maximum likelihood estimation of the MAR coefficients and noise covariance matrix
ns = size(data, 1)
freq = range(min(128, ns*dt)^-1, max(8, 2*dt)^-1, 32)
csd = mar2csd(mar, freq, dt^-1);