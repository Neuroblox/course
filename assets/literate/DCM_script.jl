# This file was generated, do not modify it.

using Neuroblox
using LinearAlgebra
using StochasticDiffEq
using DataFrames
using OrderedCollections
using CairoMakie
using ModelingToolkit
using Random
using StatsBase
using Statistics

Random.seed!(17)   # set seed for reproducibility

nr = 3             # number of regions
g = MetaDiGraph()
regions = [];      # list of neural mass blocks to then connect them to each other with an adjacency matrix `A_true`

for i = 1:nr
    region = LinearNeuralMass(;name=Symbol("r$(i)₊lm"))
    push!(regions, region)          # store neural mass model in list. We need this list below. If you haven't seen the Julia command `push!` before [see here](http://jlhub.com/julia/manual/en/function/push-exclamation).

    input = OUBlox(;name=Symbol("r$(i)₊ou"), σ=0.2, τ=2)
    add_edge!(g, input => region, weight=1/16)

    measurement = BalloonModel(;name=Symbol("r$(i)₊bm")) ## simulate fMRI signal with BalloonModel which includes the BOLD signal on top of the balloon model dynamics
    add_edge!(g, region => measurement, weight=1.0)
end

A_true = [[-0.5 -0.2 0]; [0.4 -0.5 -0.3]; [0 0.2 -0.5]]

for idx in CartesianIndices(A_true)
    add_edge!(g, regions[idx[1]] => regions[idx[2]], weight=A_true[idx[2], idx[1]])   # Note the definition of columns as outputs and rows as inputs. For consistency with SPM we keep this notation.
end

@named simmodel = system_from_graph(g);

tspan = (0, 1022)
dt = 2   # 2 seconds as measurement interval for fMRI
prob = SDEProblem(simmodel, [], tspan)
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

dfsol = DataFrame(sol);

data = Matrix(dfsol[:, idx_m .+ 1]);    # +1 due to the additional time-dimension in the data frame.

data += randn(size(data))/4;

data .-= mean(data, dims=1);
data *= 1/std(data[:])/4;
dfsol = DataFrame(data, :auto);

_, obsvars = get_eqidx_tagged_vars(simmodel, "measurement");  # get index of equation of bold state
rename!(dfsol, Symbol.(obsvars));

p = 8
mar = mar_ml(data, p)   # maximum likelihood estimation of the MAR coefficients and noise covariance matrix
ns = size(data, 1)
freq = range(min(128, ns*dt)^-1, max(8, 2*dt)^-1, 32)
csd = mar2csd(mar, freq, dt^-1);

fig = Figure(size=(1200, 800))
grid = fig[1, 1] = GridLayout()
for i = 1:nr
    for j = 1:nr
        if i == 1 && j == 1
            ax = Axis(grid[i, j], xlabel="Frequency [Hz]", ylabel="real value of CSD")
        else
            ax = Axis(grid[i, j])
        end
        lines!(ax, freq, real.(csd[:, i, j]))
    end
end
Label(grid[1, 1:3, Top()], "Cross-spectral densities", valign = :bottom,
    font = :bold,
    fontsize = 32,
    padding = (0, 0, 5, 0))
fig
save(joinpath(@OUTPUT, "csd.svg"), fig); # hide

g = MetaDiGraph()
regions = [];   # list of neural mass blocks to then connect them to each other with an adjacency matrix `A`

@parameters lnκ=0.0 [tunable=false] lnϵ=0.0 [tunable=false] lnτ=0.0 [tunable=false];   # lnκ: decay parameter for hemodynamics; lnϵ: ratio of intra- to extra-vascular components, lnτ: transit time scale
@parameters C=1/16 [tunable=false];   # note that C=1/16 is taken from SPM12 and stabilizes the balloon model simulation. See also comment above.

for i = 1:nr
    region = LinearNeuralMass(;name=Symbol("r$(i)₊lm"))
    push!(regions, region)
    input = ExternalInput(;name=Symbol("r$(i)₊ei"))
    add_edge!(g, input => region, weight=C)

    measurement = BalloonModel(;name=Symbol("r$(i)₊bm"), lnτ=lnτ, lnκ=lnκ, lnϵ=lnϵ) ## assume fMRI signal and model them with a BalloonModel
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
@named fitmodel = system_from_graph(g, simplify=false);

untune = Dict(A[3] => false, A[7] => false, A[1] => false, A[5] => false, A[9] => false)
fitmodel = changetune(fitmodel, untune)           # 3 and 7 are not present in the simulation model
fitmodel = structural_simplify(fitmodel)          # and now simplify the euqations

max_iter = 128; # maximum number of iterations
# attribute initial conditions or default values to dynamic states of our model
sts, _ = get_dynamic_states(fitmodel);

perturbedfp = Dict(sts .=> abs.(10^-10*rand(length(sts))))     # slight noise to avoid issues with Automatic Differentiation.

pmean, pcovariance, indices = defaultprior(fitmodel, nr)

priors = (μθ_pr = pmean,
          Σθ_pr = pcovariance
         );

hyperpriors = Dict(:Πλ_pr => 128.0*ones(1, 1),   # prior metaparameter precision, needs to be a matrix
                   :μλ_pr => [8.0]               # prior metaparameter mean, needs to be a vector
                  );

csdsetup = (mar_order = p, freq = freq, dt = dt);

(state, setup) = setup_sDCM(dfsol, fitmodel, perturbedfp, csdsetup, priors, hyperpriors, indices, pmean, "fMRI");

for iter in 1:max_iter
    state.iter = iter
    run_sDCM_iteration!(state, setup)
    print("iteration: ", iter, " - F:", state.F[end], " - dF predicted:", state.dF[end], "\n")
    if iter >= 4
        criterion = state.dF[end-3:end] .< setup.tolerance
        if all(criterion)
            print("convergence\n")
            break
        end
    end
end

f1 = freeenergy(state)
save(joinpath(@OUTPUT, "freeenergy.svg"), f1); # hide

f2 = ecbarplot(state, setup, A_true)
save(joinpath(@OUTPUT, "ecbar.svg"), f2); # hide
