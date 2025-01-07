# This file was generated, do not modify it. # hide
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