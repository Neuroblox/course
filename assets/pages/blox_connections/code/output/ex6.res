Main.FD_SANDBOX_15604780526313532720.IzhNeuron(ModelingToolkit.ODESystem(0x000000000000200c, Symbolics.Equation[Differential(t)(V(t)) ~ 145 + jcn - u(t) + 5V(t) + 0.04(V(t)^2), Differential(t)(u(t)) ~ a*(-u(t) + b*V(t))], t, SymbolicUtils.BasicSymbolic{Real}[V(t), u(t), jcn], SymbolicUtils.BasicSymbolic{Real}[a, b, V_reset, d, θ], nothing, Dict{Any, Any}(:a => a, :b => b, :d => d, :V => V(t), :jcn => jcn, :u => u(t), :θ => θ, :V_reset => V_reset), Any[], Symbolics.Equation[], Base.RefValue{Vector{Symbolics.Num}}(Symbolics.Num[]), Base.RefValue{Any}(Matrix{Symbolics.Num}(undef, 0, 0)), Base.RefValue{Any}(Matrix{Symbolics.Num}(undef, 0, 0)), Base.RefValue{Matrix{Symbolics.Num}}(Matrix{Symbolics.Num}(undef, 0, 0)), Base.RefValue{Matrix{Symbolics.Num}}(Matrix{Symbolics.Num}(undef, 0, 0)), :izh, "", ModelingToolkit.ODESystem[], Dict{Any, Any}(a => 0.02, V_reset => -50, d => 2, u(t) => -13, V(t) => -65.0, b => 0.2, θ => 30), Dict{Any, Any}(), nothing, nothing, Symbolics.Equation[], nothing, nothing, nothing, ModelingToolkit.SymbolicContinuousCallback[], ModelingToolkit.SymbolicDiscreteCallback[condition: V(t) > θ
affects:
  u(t) ~ d + u(t)
  V(t) ~ V_reset
], Symbolics.Equation[], nothing, nothing, false, Any[], nothing, nothing, false, nothing, nothing, nothing, nothing, nothing), nothing)