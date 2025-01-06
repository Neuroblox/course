# Installing Julia

Please follow the [installation instructions](https://julialang.org/downloads/) to install Julia on any Operating System.

# Installing Neuroblox

To install Neuroblox.jl, we need to first download a `Project.toml`, that is a file containing all packages that we will be using for this course.

``` julia 
using Downloads

Downloads.download("raw.githubusercontent.com/Neuroblox/course/refs/heads/main/Project.toml", joinpath(@__DIR__, "Project.toml"))
Pkg.activate(@__DIR__)
Pkg.instantiate()
```

Now it's time to install Neuroblox in the environment we have just activated by running

```julia
using Pkg
Pkg.add(url="https://github.com/Neuroblox/Neuroblox.jl", rev="v0.5.2")
```
