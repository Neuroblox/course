# This file was generated, do not modify it. # hide
A_prior = 0.01*randn(nr, nr)
A_prior -= diagm(diag(A_prior))    # remove the diagonal