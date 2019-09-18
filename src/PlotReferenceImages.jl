module PlotReferenceImages


local_path(args...) = normpath(@__DIR__, "..", args...)


"""
    reference_file(backend::Symbol, i::Int, version::String)

Find the latest version of the reference image file for the reference image `i` and the backend `be`.
This returns a path to the file in the folder of the latest version.
If no file is found, a path pointing to the file of the folder specified by `version` is returned.
"""
function reference_file(backend, i, version)
    refdir = local_path("Plots", string(backend))
    fn = "ref$i.png"
    versions = sort(VersionNumber.(readdir(refdir)), rev = true)

    reffn = joinpath(refdir, string(version), fn)
    for v in versions
        tmpfn = joinpath(refdir, string(v), fn)
        if isfile(tmpfn)
            reffn = tmpfn
            break
        end
    end

    return reffn
end


reference_path(backend, version) = local_path("Plots", string(backend), string(version))

export reference_file, reference_path

end # module
