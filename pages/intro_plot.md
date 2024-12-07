# Plotting with Makie

## Introduction
Makie is a plotting ecosystem based in Julia. It comes with multiple backends for rendering and displaying plots. For this course we will be using `CairoMakie` as it has a lot of features for 2D static plots and most computers should support it as it only requires a CPU and no GPU.
Makie has a great [Getting Started page](https://docs.makie.org/stable/tutorials/getting-started). We will make use of this tutorial to introduce some basic plotting functions and labelling options.

## Plotting layouts
We'll now see how to create layouts of multiple subplots within a single window. We'll use the same data from the Makie tutorial linked above.

````julia
using CairoMakie

seconds = 0:0.1:2
measurements = [8.2, 8.4, 6.3, 9.5, 9.1, 10.5, 8.6, 8.2, 10.5, 8.5, 7.2,
        8.8, 9.7, 10.8, 12.5, 11.6, 12.1, 12.1, 15.1, 14.7, 13.1]

fig = Figure(title="Line & Scatter layout")
axs = [Axis(fig[1,1], title = "Line plot", xlabel = "Time [sec]", ylabel = "Measurement"),
        Axis(fig[2,1], title = "Scatter plot", xlabel = "Time [sec]", ylabel = "Measurement")]

lines!(axs[1], seconds, measurements)
scatter!(axs[2], seconds, measurements)

fig
````

> Note: Plot functions in Makie also work without defining a `Figure` and an `Axis` object explicitly.
> E.g. plotting with `lines(seconds, measurements)` or `scatter(seconds, measurements)` .
> However in this case we won't have all the customization options for the plot axes readily available.

Plotting layouts in Makie is quite intuitive. We can treat the `Figure` object as a matrix of (sub)plot positions. In the example above we organized the two plots on a single column on positions `fig[1,1]` and `fig[2,1]` (remember that Julia is an 1-index language!).
We then input these grid positions of the figure to the respective `Axis` object to define the 2D axes which will contain each plot.
When defining an `Axis` there are multiple options to affect its appearance and alignment, see the [Axis documentation page](https://docs.makie.org/v0.21/reference/blocks/axis) for more details.
We can also change an `Axis` after it has been constructed. For instance we could hide the x-axis label and ticks on the top plot above, since it is a duplicate of the x-axis of the bottom plot. We will keep the grid lines though, because it is easier to read the x-axis values this way.

````julia
# `grid=false` avoids hiding the x grid lines
hidexdecorations!(axs[1], grid=false)

# Now we can display the figure again with the updated axes
fig
````

---

*This page was generated using [Literate.jl](https://github.com/fredrikekre/Literate.jl).*

