# This file was generated, do not modify it. # hide
fig = frplot(qif, sol; threshold=-40, win_size=20);
fig
save(joinpath(@OUTPUT, "qif_fr.svg"), fig); # hide