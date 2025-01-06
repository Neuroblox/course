# This file was generated, do not modify it. # hide
@named VAC = CorticalBlox(namespace=model_name, N_wta=10, N_exci=5,  density=0.01, weight=1)
@named AC = CorticalBlox(namespace=model_name, N_wta=10, N_exci=5, density=0.01, weight=1)
# ascending system blox, modulating frequency set to 16 Hz
@named ASC1 = NextGenerationEIBlox(namespace=model_name, Cₑ=2*26,Cᵢ=1*26, Δₑ=0.5, Δᵢ=0.5, η_0ₑ=10.0, v_synₑₑ=10.0, v_synₑᵢ=-10.0, v_synᵢₑ=10.0, v_synᵢᵢ=-10.0, alpha_invₑₑ=10.0/26, alpha_invₑᵢ=0.8/26, alpha_invᵢₑ=10.0/26, alpha_invᵢᵢ=0.8/26, kₑᵢ=0.6*26, kᵢₑ=0.6*26)

using CSV ## to read data from CSV files
using DataFrames ## to format the data into DataFrames
using Downloads ## to download image stimuli files

image_set = CSV.read(Downloads.download("raw.githubusercontent.com/Neuroblox/NeurobloxDocsHost/refs/heads/main/data/image_example.csv"), DataFrame) ## reading data into DataFrame format
image_sample = 2 ## set which image to input (from 1 to 1000)

@named stim = ImageStimulus(
    image_set[[image_sample], :],
    namespace=model_name,
    t_stimulus = 1000, ## how long the stimulus is on (in msec)
    t_pause = 0 ## how long the stimulus is off after `t_stimulus` (in msec)
);

# access the desired image sample, exclude the last row that is a category label
pixels = Array(image_set[image_sample, 1:end-1])
# reshape into 15 X 15 square image matrix
pixels = reshape(pixels, 15, 15)
# plot the image that the visual cortex 'sees'
fig = heatmap(pixels, colormap = :gray1)
save(joinpath(@OUTPUT, "image_stim.svg"), fig); # hide