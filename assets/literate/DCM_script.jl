# This file was generated, do not modify it.

using Neuroblox
using LinearAlgebra
using StochasticDiffEq
using DataFrames
using OrderedCollections
using CairoMakie
using ModelingToolkit
using Random

Random.seed!(17)   # set seed for reproducibility

nr = 3             # number of regions
g = MetaDiGraph()
regions = [];      # list of neural mass blocks to then connect them to each other with an adjacency matrix `A_true`

for i = 1:nr
    region = LinearNeuralMass(;name=Symbol("r$(i)₊lm"))
    push!(regions, region)          # store neural mass model in list. We need this list below. If you haven't seen the Julia command `push!` before [see here](http://jlhub.com/julia/manual/en/function/push-exclamation).

    # add Ornstein-Uhlenbeck block as noisy input to the current region
    input = OUBlox(;name=Symbol("r$(i)₊ou"), σ=0.1)
    add_edge!(g, input => region, weight=1/16)   # Note that 1/16 is taken from SPM12, this stabilizes the balloon model simulation. Alternatively the noise of the Ornstein-Uhlenbeck block or the weight of the edge connecting neuronal activity and balloon model could be reduced to guarantee numerical stability.

    # simulate fMRI signal with BalloonModel which includes the BOLD signal on top of the balloon model dynamics
    measurement = BalloonModel(;name=Symbol("r$(i)₊bm"))
    add_edge!(g, region => measurement, weight=1.0)
end

A_true = [[-0.5 -2 0]; [0.4 -0.5 -0.3]; [0 0.2 -0.5]]
for idx in CartesianIndices(A_true)
    add_edge!(g, regions[idx[1]] => regions[idx[2]], weight=A_true[idx[1], idx[2]])
end

@named simmodel = system_from_graph(g, split=false)

tspan = (0.0, 512.0)
prob = SDEProblem(simmodel, [], tspan)
dt = 2   # 2 seconds (units are milliseconds) as measurement interval for fMRI
sol = solve(prob, ImplicitRKMil(), saveat=dt);

idx_m = get_idx_tagged_vars(simmodel, "measurement")    # get index of bold signal

f = Figure()
ax = Axis(f[1, 1],
    title = "fMRI time series",
    xlabel = "Time [ms]",
    ylabel = "BOLD",
)
lines!(ax, sol, idxs=idx_m)
f
save(joinpath(@OUTPUT, "fmriseries.svg"), f); # hide

dfsol = DataFrame(sol[ceil(Int, 101/dt):end]);

data = Matrix(dfsol[:, idx_m]);

p = 8
mar = mar_ml(data, p)   # maximum likelihood estimation of the MAR coefficients and noise covariance matrix
ns = size(data, 1)
freq = range(min(128, ns*dt)^-1, max(8, 2*dt)^-1, 32)
csd = mar2csd(mar, freq, dt^-1);

fig = Figure(size=(1200, 800))
grid = fig[1, 1] = GridLayout()
for i = 1:nr
    for j = 1:nr
        ax = Axis(grid[i, j])
        lines!(ax, freq, real.(csd[:, i, j]))
    end
end
fig
save(joinpath(@OUTPUT, "csd.svg"), fig); # hide

g = MetaDiGraph()
regions = [];   # list of neural mass blocks to then connect them to each other with an adjacency matrix `A`

@parameters lnκ=0.0 [tunable=false] lnϵ=0.0 [tunable=false] lnτ=0.0 [tunable=false]   # lnκ: decay parameter for hemodynamics; lnϵ: ratio of intra- to extra-vascular components, lnτ: transit time scale
@parameters C=1/16 [tunable=false]   # note that C=1/16 is taken from SPM12 and stabilizes the balloon model simulation. See also comment above.

for i = 1:nr
    region = LinearNeuralMass(;name=Symbol("r$(i)₊lm"))
    push!(regions, region)
    input = ExternalInput(;name=Symbol("r$(i)₊ei"))
    add_edge!(g, input => region, weight=C)

    # we assume fMRI signal and model them with a BalloonModel
    measurement = BalloonModel(;name=Symbol("r$(i)₊bm"), lnτ=lnτ, lnκ=lnκ, lnϵ=lnϵ)
    add_edge!(g, region => measurement, weight=1.0)
end

A_prior = 0.01*randn(nr, nr)
A_prior -= diagm(diag(A_prior))    # remove the diagonal

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
@named fitmodel = system_from_graph(g, simplify=false)

untune = Dict(A[3] => false, A[7] => false)
fitmodel = changetune(fitmodel, untune)                 # 3 and 7 are not present in the simulation model
fitmodel = structural_simplify(fitmodel, split=false)   # and now simplify the euqations; the `split` parameter is necessary for some ModelingToolkit peculiarities and will soon be removed. So don't lose time with it ;)

max_iter = 128; # maximum number of iterations
# attribute initial conditions to states
sts, _ = get_dynamic_states(fitmodel);

perturbedfp = Dict(sts .=> abs.(0.001*rand(length(sts))))     # slight noise to avoid issues with Automatic Differentiation.

pmean, pcovariance, indices = defaultprior(fitmodel, nr)

priors = (μθ_pr = pmean,
          Σθ_pr = pcovariance
         );

hyperpriors = Dict(:Πλ_pr => 128.0*ones(1, 1),   # prior metaparameter precision, needs to be a matrix
                   :μλ_pr => [8.0]               # prior metaparameter mean, needs to be a vector
                  );

csdsetup = (mar_order = p, freq = freq, dt = dt);

_, s_bold = get_eqidx_tagged_vars(fitmodel, "measurement");    # get bold signal variables

(state, setup) = setup_sDCM(dfsol[:, String.(Symbol.(s_bold))], fitmodel, perturbedfp, csdsetup, priors, hyperpriors, indices, pmean, "fMRI");

# HACK: on machines with very small amounts of RAM, Julia can run out of stack space while compiling the code called in this loop
# this should be rewritten to abuse the compiler less, but for now, an easy solution is just to run it with more allocated stack space.
with_stack(f, n) = fetch(schedule(Task(f, n)));

with_stack(5_000_000) do  # 5MB of stack space
    for iter in 1:max_iter
        state.iter = iter
        run_sDCM_iteration!(state, setup)
        print("iteration: ", iter, " - F:", state.F[end] - state.F[2], " - dF predicted:", state.dF[end], "\n")
        if iter >= 4
            criterion = state.dF[end-3:end] .< setup.tolerance
            if all(criterion)
                print("convergence\n")
                break
            end
        end
    end
end

f1 = freeenergy(state)
save(joinpath(@OUTPUT, "freeenergy.svg"), f1); # hide

f2 = ecbarplot(state, setup, A_true)
save(joinpath(@OUTPUT, "ecbar.svg"), f2); # hide
