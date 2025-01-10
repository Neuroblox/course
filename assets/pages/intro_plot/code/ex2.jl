# This file was generated, do not modify it. # hide
hidexdecorations!(axs[1], grid=false) ## `grid=false` avoids hiding the x grid lines

# Now we can display the figure again with the updated axes
fig
save(joinpath(@OUTPUT, "layout_hidex.svg"), fig); # hide