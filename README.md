# PlotReferenceImages

Reference images for the tests in Plots.jl and related packages and the Plots.jl documentation.

## Installation

To update test reference images for Plots.jl you can develop this package with:

```julia
pkg> dev https://github.com/JuliaPlots/PlotReferenceImages.jl.git
```

---

To update images for the Plots.jl documentation make sure you have the following packages installed:

```julia
pkg> dev StatPlots, RDatasets, ProgressMeter, DataFrames, Distributions, StatsBase, Iterators
```

## Usage

Plots test images can be updated with the Plots test suite:

```julia
using Plots, Pkg
include(normpath(pathof(Plots), "..", "..", "test", "runtests.jl"))
```
If reference images differ from the previously saved images, a window opens showing both versions.
Check carefully if the changes are expected and an improvement.
In that case agree to overwrite the old image.
Otherwise it would be great if you could open an issue on Plots.jl, submit a PR with a fix for the regression or update the PR you are currently working on.
After updating all the images, make sure that all tests pass, `git add` the new files, commit and submit a PR.

---

You can update the images for a specific backend in the backends section of the Plots documentation with:

```julia
using PlotReferenceImages, StatPlots, RDatasets, ProgressMeter, DataFrames, Distributions, StatsBase, Iterators
generate_reference_images(sym)
```

Currently `sym in (:gr, :pyplot, :plotlyjs)` is supported. For PyPlot and PlotlyJS run `pyplot()` or `plotlyjs()` before to avoid world age issues.

To update the Plots documentaion images run:

```julia
using PlotReferenceImages
include(normpath(pathof(PlotReferenceImages), "..", "..", "PlotDocs", "generate_doc_images.jl"))
```

If you are satisfied with the new images, commit and submit a PR.

## Contributing

Any help to make these processes less ccomplicated or automate them is very much appreciated.
