# This file was generated, do not modify it. # hide
# define the least squares loss function
function loss(p, data, prob)
    setter!(prob, p)
    sol = solve(prob, Tsit5())

    return sum(abs2, sol .- data)
end

# Use finite differences to calculate gradients of the loss function
objective = OptimizationFunction((p, data) -> loss(p, data, prob), AutoFiniteDiff())
prob_opt = OptimizationProblem(objective, p0, data)
# run the optimization using the LBFGS optimizer
res = solve(prob_opt, Optimization.LBFGS())
# print the return code to check that the optimization was successful
@show res.retcode