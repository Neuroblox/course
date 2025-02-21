# This file was generated, do not modify it. # hide
for i = 1:nr
    region = LinearNeuralMass(;name=Symbol("r$(i)₊lm"))
    push!(regions, region)          # store neural mass model in list. We need this list below. If you haven't seen the Julia command `push!` before [see here](http://jlhub.com/julia/manual/en/function/push-exclamation).

    input = OUBlox(;name=Symbol("r$(i)₊ou"), σ=0.2, τ=2)
    add_edge!(g, input => region, weight=1/16)

    measurement = BalloonModel(;name=Symbol("r$(i)₊bm")) ## simulate fMRI signal with BalloonModel which includes the BOLD signal on top of the balloon model dynamics
    add_edge!(g, region => measurement, weight=1.0)
end