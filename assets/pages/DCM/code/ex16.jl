# This file was generated, do not modify it. # hide
fig = Figure(size=(1200, 800))
grid = fig[1, 1] = GridLayout()
for i = 1:nr
    for j = 1:nr
        if i == 1 && j == 1
            ax = Axis(grid[i, j], xlabel="Frequency [Hz]", ylabel="real value of CSD")
        else
            ax = Axis(grid[i, j])
        end
        lines!(ax, freq, real.(csd[:, i, j]))
    end
end
Label(grid[1, 1:3, Top()], "Cross-spectral densities", valign = :bottom,
    font = :bold,
    fontsize = 32,
    padding = (0, 0, 5, 0))
fig