# This file was generated, do not modify it. # hide
function connection_equations(source::IzhNeuron, destination::LIFNeuron, weight; const_current=1, kwargs...)
    equation = destination.jcn ~ weight * source.V + const_current

    return equation
end