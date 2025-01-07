# Adapted with minor changes from DataScienceTutorials.jl : 
# https://github.com/JuliaAI/DataScienceTutorials.jl/blob/5e24796b3621722fefd49465dd0c902c835d68a7/deploy.jl

using Literate

function pre_process_script(io, s)
    chunks = Literate.parse(Literate.FranklinFlavor(), s)

    remove = Int[]
    rx  = r".*?#\s*?(?i)hideall.*?"
    rx2 = r".*?#\s*?(?i)hide.*?" # note: superset, doesn't matter

    for (i, c) in enumerate(chunks)
       c isa Literate.CodeChunk || continue
       remove_lines = Int[]
       hideall = false
       for (j, l) in enumerate(c.lines)
          if match(rx, l) !== nothing
             push!(remove, i)
             hideall = true
             break
          end
          if match(rx2, l) !== nothing
             push!(remove_lines, j)
          end
       end
       !hideall && deleteat!(c.lines, remove_lines)
    end
    deleteat!(chunks, remove)

    for c in chunks
       if c isa Literate.CodeChunk
          for l in c.lines
             println(io, l)
          end
       else
          for l in c.lines
             println(io, "# ", l.second)
          end
       end
       println(io, "")
    end
    return
 end

 path = "./notebooks/"
 for script in readdir("_literate")
    
    temp_script = tempname()
    open(temp_script, "w") do ts
        s = read(joinpath("./_literate", script), String)
        pre_process_script(ts, s)
    end
    script_name = String(first(split(script, ".")))
    # Notebook
    Literate.notebook(temp_script, path, name=script_name,
                      execute=false, documenter=false)
    
    #=
    # Unnecessary to generate these for now.
    # Need to change `path` above if we want to store these too.
    # Annotated script
    Literate.script(temp_script, path, name=script_name,
                    keep_comments=true, documenter=false)
 
    # Stripped script
    Literate.script(temp_script, path, name=script_name,
                     keep_comments=false, documenter=false)
    =#
 end