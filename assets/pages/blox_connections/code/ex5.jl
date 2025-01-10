# This file was generated, do not modify it. # hide
struct IzhNeuron <: Neuron
    system
    namespace

    # We keep all function arguments as keyword arguments
    # so that we can set them more conveniently as `arg = value`.
    function IzhNeuron(; name, namespace=nothing, a=0.02, b=0.2, V_reset=-50, d=2, threshold=30)
        sts = @variables V(t)=-65 [output=true] u(t)=-13 jcn [input=true]
        # Spike threshold `θ=30` is now included as a parameter.
        # Default values for all parameters are the keyword arguments from above. This way we can set them easily during construction.
        params = @parameters a=a b=b V_reset=V_reset d=d θ=threshold

        eqs = [D(V) ~ 0.04 * V ^ 2 + 5 * V + 140 - u + jcn + 5,
                D(u) ~ a * (b * V - u)]

        event = (V > θ) => [u ~ u + d, V ~ V_reset]
        sys = System(eqs, t, sts, params; name=name, discrete_events = event)

        new(sys, namespace)
    end
end