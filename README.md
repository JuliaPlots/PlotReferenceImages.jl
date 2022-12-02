# PlotReferenceImages

[![Build Status](https://travis-ci.org/JuliaPlots/PlotReferenceImages.jl.svg?branch=master)](https://travis-ci.org/JuliaPlots/PlotReferenceImages.jl)

This package holds the reference images for the [Plots.jl](https://github.com/JuliaPlots/Plots.jl) test suite.

## Installation

To update test reference images for Plots.jl you can develop this package with:

```julia
julia> ]

pkg> dev PlotReferenceImages
```

## Usage

Plots test images can be updated with the Plots test suite:

```julia
julia> ]

pkg> test Plots
```
If reference images differ from the previously saved images, a window opens showing both versions.
Check carefully if the changes are expected and an improvement.
In that case agree to overwrite the old image.
Otherwise it would be great if you could open an issue on Plots.jl, submit a PR with a fix for the regression or update the PR you are currently working on.
After updating all the images, make sure that all tests pass, `git add` the new files, commit and submit a PR.
You can update the images for a specific backend by editing `test/runtests.jl` in Plots.

## Update tags

On new `Plots` releases, tag a new version in `PlotReferenceImages`, using the github interface or git in cli:
```console
$ git tag -a -m 'v1.36.6' v1.36.6 523ec5f4f4ce785815c346ccc3b1e73788b14618
$ git push upstream --follow-tags
```

## Contributing

Any help to make these processes less complicated or automate them is very much appreciated.
