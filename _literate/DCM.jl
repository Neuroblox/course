# # Solving Inverse Problems with Spectral Dynamic Causal Modeling
# ## Introduction
# Neuroblox provides you with a comprehensive environment for simulations as we have explored previously, but its functionality doesn't stop there.
# We will now pivot and turn our attention to a different kind of problem: 
# inferring model parameters, that is solving inverse problems, from time series. 
# The method of choice is one of the most widely spread in imaging neuroscience, spectral Dynamic Causal Modeling (spDCM)[1,2]. 
# In this tutorial we will introduce how to perform a spDCM analysis on simulated data.
# To do so we roughly reproduce the procedure in the [SPM](https://www.fil.ion.ucl.ac.uk/spm/software/spm12/) script `DEM_demo_induced_fMRI.m` in [Neuroblox](https://www.neuroblox.org/).
# This work was also presented in Hofmann et al.[2]
#
# In this session we will define a circuit of three linear neuronal mass models, all driven by an Ornstein-Uhlenbeck process.
# We will model fMRI data by a balloon model and BOLD signal on top.
# After simulation of this simple model we will use spDCM to infer some of the model parameters from the simulation time series.
# 
#!nb # ![spDCM Workflow](/assets/spectral_DCM_illustration.png)
#nb # ![spDCM Workflow](./assets/spectral_DCM_illustration.png)
# *Figure 1: Workflow for Spectral DCM analysis.*  
#
# *Figure 1* describes the procedure we will pursue:
# - define the graph and add blocks (sections A, B and C in the Figure)
# - simulate the model, instead we could also use actual data (section D in Figure)
# - compute the cross spectral density 
# - setup the DCM
# - estimate parameters
# - plot the results

# Learning goals
# - perform the entire workflow of an spDCM analysis.
# - use observer Blox to simulate experimental measurements. 

using Neuroblox
using LinearAlgebra
using StochasticDiffEq
using DataFrames
using OrderedCollections
using CairoMakie
using ModelingToolkit
using Random

# ## Define the model
# We will define a model of 3 regions. This means first of all to define a graph.
# To this graph we will add three linear neuronal mass models which constitute the (hidden) neuronal dynamics.
# These constitute three nodes of the graph.
# Next we will also need some input that stimulates the activity, we use simple Ornstein-Uhlenbeck blocks to create stochastic inputs.
# One per region.
# We want to simulate fMRI signals thus we will need to also add a BalloonModel per region.
# Note that the Ornstein-Uhlenbeck block will feed into the linear neural mass which in turn will feed into the BalloonModel blox.
# This needs to be represented by the way we define the edges.
Random.seed!(17)   # set seed for reproducibility

nr = 3             # number of regions
g = MetaDiGraph()
regions = [];      # list of neural mass blocks to then connect them to each other with an adjacency matrix `A_true`
# Now add the different blocks to each region and connect the blocks within each region. 
# For convenience we use a for loop since the type of blocks belonging to a each region repeat over regions but you could also approach building the system the same way as was shown in previous tutorials:
for i = 1:nr
    region = LinearNeuralMass(;name=Symbol("r$(i)₊lm"))
    push!(regions, region)          # store neural mass model in list. We need this list below. If you haven't seen the Julia command `push!` before [see here](http://jlhub.com/julia/manual/en/function/push-exclamation).

    ## add Ornstein-Uhlenbeck block as noisy input to the current region
    input = OUBlox(;name=Symbol("r$(i)₊ou"), σ=0.1)
    add_edge!(g, input => region, weight=1/16)   # Note that 1/16 is taken from SPM12, this stabilizes the balloon model simulation. Alternatively the noise of the Ornstein-Uhlenbeck block or the weight of the edge connecting neuronal activity and balloon model could be reduced to guarantee numerical stability.

    ## simulate fMRI signal with BalloonModel which includes the BOLD signal on top of the balloon model dynamics
    measurement = BalloonModel(;name=Symbol("r$(i)₊bm"))
    add_edge!(g, region => measurement, weight=1.0)
end
# Next we define the between-region connectivity matrix and connect regions; we use the same matrix as is defined in [3]
A_true = [[-0.5 -2 0]; [0.4 -0.5 -0.3]; [0 0.2 -0.5]]
for idx in CartesianIndices(A_true)
    add_edge!(g, regions[idx[1]] => regions[idx[2]], weight=A_true[idx[1], idx[2]])
end

# finally we compose the simulation model
@named simmodel = system_from_graph(g, split=false)

# ## Run the simulation and plot the results

# setup simulation of the model, time in seconds
tspan = (0.0, 512.0)
prob = SDEProblem(simmodel, [], tspan)
dt = 2   # 2 seconds (units are milliseconds) as measurement interval for fMRI
sol = solve(prob, ImplicitRKMil(), saveat=dt);

# we now want to extract all the variables in our model which carry the tag "measurement". For this purpose we can use the Neuroblox function `get_idx_tagged_vars`
# the observable quantity in our model is the BOLD signal, the variable of the Blox `BalloonModel` that represents the BOLD signal is tagged with "measurement" tag.
# other tags that are defined are "input" which denotes variables representing a stimulus, like for instance an `OUBlox`.
idx_m = get_idx_tagged_vars(simmodel, "measurement")    # get index of bold signal
# plot bold signal time series
f = Figure()
ax = Axis(f[1, 1],
    title = "fMRI time series",
    xlabel = "Time [ms]",
    ylabel = "BOLD",
)
lines!(ax, sol, idxs=idx_m)
f
save(joinpath(@OUTPUT, "fmriseries.svg"), f); # hide
# \fig{fmriseries}

# We note that the initial spike is not meaningful and a result of the equilibration of the stochastic process thus we remove it.
dfsol = DataFrame(sol[ceil(Int, 101/dt):end]);

# ## Estimate and plot the cross-spectral densities
data = Matrix(dfsol[:, idx_m]);
# We compute the cross-spectral density by fitting a linear model of order `p` and then compute the csd analytically from the parameters of the multivariate autoregressive model
p = 8
mar = mar_ml(data, p)   # maximum likelihood estimation of the MAR coefficients and noise covariance matrix
ns = size(data, 1)
freq = range(min(128, ns*dt)^-1, max(8, 2*dt)^-1, 32)
csd = mar2csd(mar, freq, dt^-1);
# Now plot the cross-spectrum:
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
# \fig{csd}

# ## Model Inference

# We will now assemble a new model that is used for fitting the previous simulations.
# This procedure is similar to before with the difference that we will define global parameters and use tags such as [tunable=false/true] to define which parameters we will want to estimate.
# Note that parameters are tunable by default.
g = MetaDiGraph()
regions = [];   # list of neural mass blocks to then connect them to each other with an adjacency matrix `A`
# Note that parameters are typically defined within a Blox and thus not immediately visible to the user. 
# Since we want some parameters to be shared across several regions we define them outside of the regions.
# For this purpose use the ModelingToolkit macro `@parameters` which is used to define symbolic parameters for models.
# Note that we can set the tunable flag right away thereby defining whether we will include this parameter in the optimization procedure or rather keep it fixed to its predefined value.
@parameters lnκ=0.0 [tunable=false] lnϵ=0.0 [tunable=false] lnτ=0.0 [tunable=false]   # lnκ: decay parameter for hemodynamics; lnϵ: ratio of intra- to extra-vascular components, lnτ: transit time scale
@parameters C=1/16 [tunable=false]   # note that C=1/16 is taken from SPM12 and stabilizes the balloon model simulation. See also comment above.
# We now define a similar model as above for the simulation but instead of using an actual stimulus Blox we here add ExternalInput which represents a simple linear external input that is not specified any further.
# We simply say that our model gets some input with a proportional factor $C$. This is mostly only to make sure that our results are consistent with those produced by SPM
for i = 1:nr
    region = LinearNeuralMass(;name=Symbol("r$(i)₊lm"))
    push!(regions, region)
    input = ExternalInput(;name=Symbol("r$(i)₊ei"))
    add_edge!(g, input => region, weight=C)

    ## we assume fMRI signal and model them with a BalloonModel
    measurement = BalloonModel(;name=Symbol("r$(i)₊bm"), lnτ=lnτ, lnκ=lnκ, lnϵ=lnϵ)
    add_edge!(g, region => measurement, weight=1.0)
end

# Here we define the prior expectation values of the effective connectivity matrix we wish to infer:
A_prior = 0.01*randn(nr, nr)
A_prior -= diagm(diag(A_prior))    # remove the diagonal
# Since we want to optimize these weights we turn them into symbolic parameters:
# Add the symbolic weights to the edges and connect regions.
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
## Avoid simplification of the model in order to be able to exclude some parameters from fitting
@named fitmodel = system_from_graph(g, simplify=false)
# With the function `changetune` we can provide a dictionary of parameters whose tunable flag should be changed, for instance set to false to exclude them from the optimizatoin procedure.
# For instance the the effective connections that are set to zero in the simulation:
untune = Dict(A[3] => false, A[7] => false)
fitmodel = changetune(fitmodel, untune)                 # 3 and 7 are not present in the simulation model
fitmodel = structural_simplify(fitmodel, split=false)   # and now simplify the euqations; the `split` parameter is necessary for some ModelingToolkit peculiarities and will soon be removed. So don't lose time with it ;)

# ## Setup spectral DCM
max_iter = 128; # maximum number of iterations
## attribute initial conditions to states
sts, _ = get_dynamic_states(fitmodel);
# the following step is needed if the model's Jacobian would give degenerate eigenvalues when expanded around the fixed point 0 (which is the default expansion). We simply add small random values to avoid this degeneracy:
perturbedfp = Dict(sts .=> abs.(0.001*rand(length(sts))))     # slight noise to avoid issues with Automatic Differentiation.
# For convenience we can use the default prior function to use standardized prior values as given in SPM:
pmean, pcovariance, indices = defaultprior(fitmodel, nr)

priors = (μθ_pr = pmean,
          Σθ_pr = pcovariance
         );
# Setup hyper parameter prior as well:
hyperpriors = Dict(:Πλ_pr => 128.0*ones(1, 1),   # prior metaparameter precision, needs to be a matrix
                   :μλ_pr => [8.0]               # prior metaparameter mean, needs to be a vector
                  );
# To compute the cross spectral densities we need to provide the sampling interval of the time series, the frequency axis and the order of the multivariate autoregressive model:
csdsetup = (mar_order = p, freq = freq, dt = dt);
# earlier we used the function `get_idx_tagged_vars` to get the indices of tagged variables. Here we don't want to get the indices but rather the symbolic variable names themselves.
# and in particular we need to get the measurement variables in the same ordering as the model equations are defined.
_, s_bold = get_eqidx_tagged_vars(fitmodel, "measurement");    # get bold signal variables
# Prepare the DCM. This function will setup the computation of the Dynamic Causal Model. The last parameter specifies that wer are using fMRI time series as opposed to LFPs.
(state, setup) = setup_sDCM(dfsol[:, String.(Symbol.(s_bold))], fitmodel, perturbedfp, csdsetup, priors, hyperpriors, indices, pmean, "fMRI");

## HACK: on machines with very small amounts of RAM, Julia can run out of stack space while compiling the code called in this loop
## this should be rewritten to abuse the compiler less, but for now, an easy solution is just to run it with more allocated stack space.
with_stack(f, n) = fetch(schedule(Task(f, n)));

# We are now ready to run the optimization procedure! :)
# That is we loop over run_sDCM_iteration! which will alter `state` after each optimization iteration. It essentially computes the Variational Laplace estimation of expectation and variance of the tunable parameters. 
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

# ## Results
# Free energy is the objective function of the optimization scheme of spectral DCM. Note that in the machine learning literature this it is called Evidence Lower Bound (ELBO). 
# Plot the free energy evolution over optimization iterations to see how the algorithm converges towards a (potentially local) optimum:
freeenergy(state)

# Plot the estimated posterior of the effective connectivity and compare that to the true parameter values.
# Bar hight are the posterior mean and error bars are the standard deviation of the posterior.
ecbarplot(state, setup, A_true)

# ## Challenge Problems
# - **Explore susceptibility with respect to noise.** Run the script again with a different random seed and observe how the results change. Given that we didn’t change any parameters of the ground truth, what is your take on parameter inference with this setup? How reliable is model selection based on free energy (compare the different free energies of the models and their respective parameter values with ground truth)?
# - **Averaging over patients.** Now repeat the simulation and inference again with 10 different seeds (you can just remove the number in Random.seed() to use current time stamps as seeds) and store the results of each run, such that you get several models based on the same ground truth but with different instances of the noise. Can you extract the average value of the effective connectivity from the ensemble?
# - Changing neuronal dynamics model. Now change the model and test the whole procedure with a different underlying neuronal mass model, for instance the Jansen-Rit model. Note that there are no default priors for the Jansen-Rit model, you will have to provide priors for the extra parameters or remove them from the optimization procedure by setting their tunable to false.

# ## References
# - [1] [Novelli, Leonardo, Karl Friston, and Adeel Razi. “Spectral Dynamic Causal Modeling: A Didactic Introduction and Its Relationship with Functional Connectivity.” Network Neuroscience 8, no. 1 (April 1, 2024): 178–202.](https://doi.org/10.1162/netn_a_00348) \
# - [2] [Hofmann, David, Anthony G. Chesebro, Chris Rackauckas, Lilianne R. Mujica-Parodi, Karl J. Friston, Alan Edelman, and Helmut H. Strey. “Leveraging Julia’s Automated Differentiation and Symbolic Computation to Increase Spectral DCM Flexibility and Speed.” bioRxiv: The Preprint Server for Biology, 2023.](https://doi.org/10.1101/2023.10.27.564407) \
# - [3] [Friston, Karl J., Joshua Kahan, Bharat Biswal, and Adeel Razi. “A DCM for Resting State fMRI.” NeuroImage 94 (July 2014): 396–407.](https://linkinghub.elsevier.com/retrieve/pii/S1053811913012135)
