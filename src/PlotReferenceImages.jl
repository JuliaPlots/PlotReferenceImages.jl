module PlotReferenceImages
# A module is required for `pathof(PlotReferenceImages)` to work.

using DataStructures
using StatsPlots, RDatasets, ProgressMeter, DataFrames, Distributions, StatsBase

# import and initialize plotting backends
import PyPlot, PlotlyJS, ORCA, PGFPlots
PyPlot.ioff()

# ------------------------------------------------------------------------------
# Plots docs and tests reference images
theme(:default)

include("plotdocs.jl")

export generate_doc_image, generate_doc_images, generate_reference_image, generate_reference_images

end # module
