# Installing Julia

Please follow the [installation instructions](https://julialang.org/downloads/) to install Julia on any Operating System.

# Installing Neuroblox

First create a folder where you will keep all course material, that is notebooks and the Julia environment, holding all necessary packages for the course. To install Neuroblox.jl along with all other Julia packages that we will need for this course, start a Julia session in your course folder, e.g. type `julia` in a Terminal window after installing it from the instructions above, and run the following commands

```julia 
using Pkg
using Downloads

Downloads.download("raw.githubusercontent.com/Neuroblox/course/refs/heads/main/Project.toml", joinpath(@__DIR__, "Project.toml"))
pkg"registry add https://github.com/Neuroblox/NeurobloxRegistry"; # add the Neuroblox Registry to the Julia registries to have access to Neuroblox.jl
Pkg.activate(@__DIR__) # activate a Julia environment at your current directory
Pkg.instantiate() # download all packages listed in the Project.toml we downloaded above
```
> **_NOTE_:**
> If this is your first time using Julia, you *may* also need to add the General registry **before** `Pkg.instantiate()`, which can be done with `pkg"registry add General"`

`Project.toml` is a file containing a list of packages, sometimes with specified versions or version bounds. When we `Pkg.instantiate()` an environment at a directory that includes a `Project.toml` then all listed packages are installed at their most suitable versions.

# Using Jupyter Notebooks

All course sessions exist as webpages on this site and as interactive Jupyter notebooks. Using the notebooks is the recommended way of working through the course material. In notebooks we can evaluate individual code blocks, make changes to them and reevaluate their output and add new code blocks. 

Please follow the link below to download a folder containing all Jupyter notebooks for the course and **add the folder in the same directory that you instantiated the `Project.toml` above**.

*Click the link and then download the notebooks folder :* [notebooks download link](https://drive.google.com/drive/folders/1InAV38X8GN86tqsec91tZ4DZcxQhc73l)

To open a notebook, first start a Terminal (or Command Prompt) session in the same directory as above. Then run the following command

```
julia --project="." -e "using IJulia; notebook();"
```

This will start a local Jupyter server on your browser. On this new Jupyter tab that will open, navigate to your directory in the `/notebooks/` folder and choose a notebook to open. All notebook files have the `.ipynb` extension.
