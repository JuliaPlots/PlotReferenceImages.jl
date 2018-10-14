module PlotReferenceImages
# A module is required for `pathof(PlotReferenceImages)` to work.

using Requires


# ------------------------------------------------------------------------------
# Plots docs and tests reference images

function __init__()
    @require Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80" include("plotdocs.jl")
end

end # module
