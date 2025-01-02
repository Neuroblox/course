using Literate

function to_markdown(path="./_literate/")
    files = readdir(path; join=true)
    filter!(x -> occursin(".jl", x), files)

    Literate.markdown.(files, "./pages"; flavor = Literate.FranklinFlavor())
end