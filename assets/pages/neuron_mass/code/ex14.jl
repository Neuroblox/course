# This file was generated, do not modify it. # hide
function connection_spike_affects(source::BernoulliSpikes, ifn::IFNeuron, w)
    eqs = [ifn.I_in ~ ifn.I_in + w]
    return eqs
end

tspan = (0, 500)
@named s = BernoulliSpikes(0.05, tspan, 5)
@named ifn = IFNeuron()

g = MetaDiGraph()
add_edge!(g, s => ifn, weight=1)
@named sys = system_from_graph(g)

prob = ODEProblem(sys, [], tspan)
sol = solve(prob, Tsit5())

fig = rasterplot(ifn, sol);
fig
save(joinpath(@OUTPUT, "ifn_input.svg"), fig); # hide