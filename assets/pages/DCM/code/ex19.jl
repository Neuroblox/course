# This file was generated, do not modify it. # hide
for i = 1:nr
    region = LinearNeuralMass(;name=Symbol("r$(i)₊lm"))
    push!(regions, region)
    input = ExternalInput(;name=Symbol("r$(i)₊ei"))
    add_edge!(g, input => region, weight=C)

    measurement = BalloonModel(;name=Symbol("r$(i)₊bm"), lnτ=lnτ, lnκ=lnκ, lnϵ=lnϵ) ## assume fMRI signal and model them with a BalloonModel
    add_edge!(g, region => measurement, weight=1.0)
end