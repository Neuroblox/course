# This file was generated, do not modify it. # hide
for idx in CartesianIndices(A_true)
    add_edge!(g, regions[idx[1]] => regions[idx[2]], weight=A_true[idx[2], idx[1]])   # Note the definition of columns as outputs and rows as inputs. For consistency with SPM we keep this notation.
end