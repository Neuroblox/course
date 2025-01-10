# This file was generated, do not modify it. # hide
import Neuroblox: connection_equations

function connection_equations(source::LIFNeuron, destination::IzhNeuron, weight; kwargs...)
    equation = destination.jcn ~ weight * source.G * (destination.V - source.E_syn)

    return equation
end