local_path(args...) = normpath(@__DIR__, "..", args...)
filename(i::Int) = string("ref", i, i in Plots._animation_examples ? ".gif" : ".png")

Plots.theme(:default)


function generate_reference_images(be::Symbol, overwrite::Bool = true)
    for i in eachindex(Plots._examples)
        i in Plots._backend_skips[be] || generate_reference_image(be, i, overwrite)
    end
end


function generate_reference_image(be::Symbol, i::Int, overwrite::Bool = true)
    Plots.backend(be)
    map(ex -> Base.eval(Main, ex), Plots._examples[i].exprs)

    dir = local_path("PlotDocs", string(be))
    isdir(dir) || mkpath(dir)

    fn = joinpath(dir, filename(i))
    overwrite || !isfile(fn) || return nothing

    if i in _animation_inds
        anim = @eval Main anim
        Plots.gif(anim, fn, fps = 15)
    else
        Plots.savefig(fn)
    end

    return nothing
end

_animation_inds = (2, 30)

################################################################################

# Alternative implementation of the script PlotDocs/generate_doc_images.jl
# within the module PlotReferanceImages.

# Usage:
# ```julia
# using PlotReferenceImages, StatPlots, RDatasets, ProgressMeter, DataFrames, Distributions, StatsBase, Iterators
# generate_doc_images()
# ```

# Currently this implementation has issues with the plotlyjs backend.

#
# _doc_images = Dict(
#     "lorenz_attractor" => [:(begin
#         using Plots
#         gr()
#         # define the Lorenz attractor
#         mutable struct Lorenz
#         dt; σ; ρ; β; x; y; z
#         end
#
#         function step!(l::Lorenz)
#         dx = l.σ*(l.y - l.x)       ; l.x += l.dt * dx
#         dy = l.x*(l.ρ - l.z) - l.y ; l.y += l.dt * dy
#         dz = l.x*l.y - l.β*l.z     ; l.z += l.dt * dz
#         end
#
#         attractor = Lorenz((dt = 0.02, σ = 10., ρ = 28., β = 8//3, x = 1., y = 1., z = 1.)...)
#
#
#         # initialize a 3D plot with 1 empty series
#         plt = plot3d(1, xlim=(-25,25), ylim=(-25,25), zlim=(0,50),
#                     title = "Lorenz Attractor", marker = 2)
#
#         # build an animated gif by pushing new points to the plot, saving every 10th frame
#         anim = @gif for i=1:1500
#         step!(attractor)
#         push!(plt, attractor.x, attractor.y, attractor.z)
#         end every 10
#     end)],
#     "waves" => [:(begin
#     using Plots, ProgressMeter
#         pyplot(leg=false, ticks=nothing) #change to the pyplot backend and define some defaults
#         x = y = range(-5, stop = 5, length = 40)
#         zs = zeros(0,40)
#         n = 100
#
#         # create a progress bar for tracking the animation generation
#         prog = Progress(n,1)
#
#         anim = @gif for i in range(0, stop = 2π, length = n)
#         f(x,y) = sin(x + 10sin(i)) + cos(y)
#
#         # create a plot with 3 subplots and a custom layout
#         l = @layout [a{0.7w} b; c{0.2h}]
#         p = plot(x, y, f, st = [:surface, :contourf], layout=l)
#
#         # induce a slight oscillating camera angle sweep, in degrees (azimuth, altitude)
#         plot!(p[1], camera=(15*cos(i), 40))
#
#         # add a tracking line
#         fixed_x = zeros(40)
#         z = map(f, fixed_x, y)
#         plot!(p[1], fixed_x, y, z, line = (:black, 5, 0.2))
#         vline!(p[2], [0], line = (:black, 5))
#
#         # add to and show the tracked values over time
#         global zs = vcat(zs, z')
#         plot!(p[3], zs, alpha = 0.2, palette = cgrad(:blues).colors)
#
#         # increment the progress bar
#         next!(prog)
#         end
#     end)],
#     "iris" => [:(begin
#         gr()
#         # load a dataset
#         using RDatasets
#         iris = dataset("datasets", "iris");
#
#         # load the StatPlots recipes (for DataFrames) available via:
#         # Pkg.add("StatPlots")
#         using StatPlots
#         gr()
#
#         # Scatter plot with some custom settings
#         @df iris scatter(:SepalLength, :SepalWidth, group=:Species,
#             title = "My awesome plot",
#             xlabel = "Length", ylabel = "Width",
#             m=(0.5, [:cross :hex :star7], 12),
#             bg=RGB(.2,.2,.2))
#     end)],
#     "lines_1" => [:(begin
#         using Plots; gr()
#         x = 1:10; y = rand(10); # These are the plotting data
#         plot(x,y)
#     end)],
#     "lines_2" => [:(begin
#         x = 1:10; y = rand(10,2) # 2 columns means two lines
#         plot(x,y)
#     end)],
#     "lines_3" => [:(begin
#         z = rand(10)
#         plot!(x,z)
#     end)],
#     "lines_4" => [:(begin
#         x = 1:10; y = rand(10,2) # 2 columns means two lines
#         p = plot(x,y)
#         z = rand(10)
#         plot!(p,x,z)
#     end)],
#     "attr_1" => [:(begin
#         x = 1:10; y = rand(10,2) # 2 columns means two lines
#         plot(x,y,title="Two Lines",label=["Line 1" "Line 2"],lw=3)
#     end)],
#     "attr_2" => [:(begin
#         xlabel!("My x label")
#     end)],
#     "backends_1" => [:(begin
#         x = 1:10; y = rand(10,2) # 2 columns means two lines
#         plotlyjs() # Set the backend to Plotly
#         using ORCA
#         plot(x,y,title="This is Plotted using Plotly")
#     end)],
#     "backends_2" => [:(begin
#         gr() # Set the backend to GR
#         plot(x,y,title="This is Plotted using GR") # This plots using GR
#     end)],
#     "scatter_1" => [:(begin
#         gr() # We will continue onward using the GR backend
#         plot(x,y,seriestype=:scatter,title="My Scatter Plot")
#     end)],
#     "scatter_2" => [:(begin
#         gr()
#         scatter(x,y,title="My Scatter Plot")
#     end)],
#     "subplots_1" => [:(begin
#         y = rand(10,4)
#         plot(x,y,layout=(4,1))
#     end)],
#     "subplots_2" => [:(begin
#         p1 = plot(x,y) # Make a line plot
#         p2 = scatter(x,y) # Make a scatter plot
#         p3 = plot(x,y,xlabel="This one is labelled",lw=3,title="Subtitle")
#         p4 = histogram(x,y) # Four histograms each with 10 points? Why not!
#         plot(p1,p2,p3,p4,layout=(2,2),legend=false)
#     end)],
#     "user_recipes_1" => [:(begin
#         # Pkg.add("StatPlots")
#         using StatPlots # Required for the DataFrame user recipe
#         # Now let's create the DataFrame
#         using DataFrames
#         df = DataFrame(a = 1:10, b = 10*rand(10), c = 10 * rand(10))
#         # Plot the DataFrame by declaring the points by the column names
#         @df df plot(:a, [:b :c]) # x = :a, y = [:b :c]. Notice this is two columns!
#     end)],
#     "user_recipes_2" => [:(begin
#         @df df scatter(:a, :b, title="My DataFrame Scatter Plot!") # x = :a, y = :b
#     end)],
#     "type_recipes" => [:(begin
#         using Distributions
#         plot(Normal(3,5),lw=3)
#     end)],
#     "plot_recipes" => [:(begin
#         #Pkg.add("RDatasets")
#         using RDatasets
#         iris = dataset("datasets","iris")
#     end)],
#     "series_recipes_1" => [:(begin
#         y = rand(100,4) # Four series of 100 points each
#         violin(["Series 1" "Series 2" "Series 3" "Series 4"],y,leg=false)
#     end)],
#     "series_recipes_2" => [:(begin
#         boxplot!(["Series 1" "Series 2" "Series 3" "Series 4"],y,leg=false)
#     end)],
#     "columns_are_series" => [:(begin
#         using Plots; gr()
#
#         # 10 data points in 4 series
#         xs = 0 : 2π/10 : 2π
#         data = [sin.(xs) cos.(xs) 2sin.(xs) 2cos.(xs)]
#
#         # We put labels in a row vector: applies to each series
#         labels = ["Apples" "Oranges" "Hats" "Shoes"]
#
#         # Marker shapes in a column vector: applies to data points
#         markershapes = [:circle, :star5]
#
#         # Marker colors in a matrix: applies to series and data points
#         markercolors = [:green :orange :black :purple
#                     :red   :yellow :brown :white]
#
#         plot(xs, data, label = labels, shape = markershapes, color = markercolors,
#          markersize = 10)
#     end)],
#     "groups" => [:(begin
#         using Plots; plotlyjs()
#
#         function rectangle_from_coords(xb,yb,xt,yt)
#         [
#             xb yb
#             xt yb
#             xt yt
#             xb yt
#             xb yb
#             NaN NaN
#         ]
#         end
#
#         some_rects=[
#         rectangle_from_coords(1 ,1 ,5 ,5 )
#         rectangle_from_coords(10,10,15,15)
#         ]
#         other_rects=[
#         rectangle_from_coords(1 ,10,5 ,15)
#         rectangle_from_coords(10,1 ,15,5 )
#         ]
#
#         plot(some_rects[:,1], some_rects[:,2],label="some group")
#         plot!(other_rects[:,1], other_rects[:,2],label="other group")
#     end)],
#     "dataframes" => [:(begin
#         gr() # maybe remove again
#         using StatPlots, RDatasets
#         iris = dataset("datasets", "iris")
#         @df iris scatter(:SepalLength, :SepalWidth, group=:Species,
#             m=(0.5, [:+ :h :star7], 12), bg=RGB(.2,.2,.2))
#     end)],
#     "rand_anim" => [:(begin
#         using Plots, Iterators
#
#         itr = repeatedly(()->rand(10), 20)
#         anim = animate(itr, ylims=(0,1), c=:red, fps=5)
#     end)],
#     "my_count_1" => [:(begin
#         using Plots, StatsBase
#         gr(size=(300,300), leg=false)
#
#         @userplot MyCount
#         @recipe function f(mc::MyCount)
#             # get the array from the args field
#             arr = mc.args[1]
#
#             T = typeof(arr)
#             if T.parameters[1] == Float64
#                 seriestype := :histogram
#                 arr
#             else
#                 seriestype := :bar
#                 cm = countmap(arr)
#                 x = sort!(collect(keys(cm)))
#                 y = [cm[xi] for xi=x]
#                 x, y
#             end
#         end
#         mycount(rand(500))
#     end)],
#     "my_count_2" => [:(begin
#         mycount(rand(["A","B","C"],100))
#     end)],
#     "my_count_3" => [:(begin
#         mycount(rand(1:500, 500))
#     end)],
#     "pipeline_1" => [:(begin
#         using Plots; pyplot()
#         plot(x, y, line = (0.5, [4 1 0], [:path :scatter :density]),
#         marker=(10, 0.5, [:none :+ :none]), fill=0.5,
#         orientation = :h, title = "My title")
#     end)],
#     "pipeline_2" => [:(begin
#         gr()
#         mutable struct MyVecWrapper
#             v::Vector{Float64}
#         end
#         mv = MyVecWrapper(rand(100))
#
#         @recipe function f(mv::MyVecWrapper)
#             markershape --> :circle
#             markersize  --> 30
#             mv.v
#         end
#
#         plot(
#             plot(mv.v),
#             plot(mv)
#         )
#     end)],
#     "pipeline_3" => [:(begin
#         scatter(rand(100), group = rand(1:3, 100), marker = (10,0.3,[:s :o :x]))
#     end)],
#     "layout_1" => [:(begin
#         # create a 2x2 grid, and map each of the 4 series to one of the subplots
#         plot(rand(100,4), layout = 4)
#     end)],
#     "layout_2" => [:(begin
#         # create a 4x1 grid, and map each of the 4 series to one of the subplots
#         plot(rand(100,4), layout = (4,1))
#     end)],
#     "layout_3" => [:(begin
#         plot(rand(100,4), layout = grid(4,1,heights=[0.1,0.4,0.4,0.1]))
#     end)],
#     "layout_4" => [:(begin
#         l = @layout [  a{0.3w} [grid(3,3)
#                                          b{0.2h} ]]
#         plot(
#             rand(10,11),
#             layout = l, legend = false, seriestype = [:bar :scatter :path],
#             title = ["($i)" for j = 1:1, i=1:11], titleloc = :right, titlefont = font(8)
#         )
#     end)],
#     "layout_5" => [:(begin
#         # boxplot is defined in StatPlots
#         using StatPlots
#         gr(leg=false, bg=:lightgrey)
#
#         # Create a filled contour and boxplot side by side.
#         plot(contourf(randn(10,20)), boxplot(rand(1:4,1000),randn(1000)))
#
#         # Add a histogram inset on the heatmap.
#         # We set the (optional) position relative to bottom-right of the 1st subplot.
#         # The call is `bbox(x, y, width, height, origin...)`, where numbers are treated as "percent of parent"
#         histogram!(randn(1000), inset = (1, bbox(0.05,0.05,0.5,0.25,:bottom,:right)), ticks=nothing, subplot=3, bg_inside=nothing)
#
#         # Add sticks floating in the window (inset relative to the window, as opposed to being relative to a subplot)
#         sticks!(randn(100), inset = bbox(0,-0.2,200Plots.px,100Plots.px,:center), ticks=nothing, subplot=4)
#     end)],
# )
#
# _animation_imgs = ["lorenz_attractor", "waves", "rand_anim"]
#
# _doc_img_files = Dict(
#     "lorenz_attractor" => "index",
#     "waves" => "index",
#     "iris" => "index",
#     "lines_1" => "tutorial",
#     "lines_2" => "tutorial",
#     "lines_3" => "tutorial",
#     "lines_4" => "tutorial",
#     "attr_1" => "tutorial",
#     "attr_2" => "tutorial",
#     "backends_1" => "tutorial",
#     "backends_2" => "tutorial",
#     "scatter_1" => "tutorial",
#     "scatter_2" => "tutorial",
#     "subplots_1" => "tutorial",
#     "subplots_2" => "tutorial",
#     "user_recipes_1" => "tutorial",
#     "user_recipes_2" => "tutorial",
#     "type_recipes" => "tutorial",
#     "plot_recipes" => "tutorial",
#     "series_recipes_1" => "tutorial",
#     "series_recipes_2" => "tutorial",
#     "columns_are_series" => "input",
#     "groups" => "input",
#     "dataframes" => "input",
#     "rand_anim" => "animations",
#     "my_count_1" => "contributing",
#     "my_count_2" => "contributing",
#     "my_count_3" => "contributing",
#     "pipeline_1" => "pipeline",
#     "pipeline_2" => "pipeline",
#     "pipeline_3" => "pipeline",
#     "layout_1" => "layout",
#     "layout_2" => "layout",
#     "layout_3" => "layout",
#     "layout_4" => "layout",
#     "layout_5" => "layout",
# )
#
# _doc_img_names = [
#     "lorenz_attractor",
#     "waves",
#     "iris",
#     "lines_1",
#     "lines_2",
#     "lines_3",
#     "lines_4",
#     "attr_1",
#     "attr_2",
#     "backends_1",
#     "backends_2",
#     "scatter_1",
#     "scatter_2",
#     "subplots_1",
#     "subplots_2",
#     "user_recipes_1",
#     "user_recipes_2",
#     "type_recipes",
#     "plot_recipes",
#     "series_recipes_1",
#     "series_recipes_2",
#     "columns_are_series",
#     "groups",
#     "dataframes",
#     # "rand_anim", # requires Iterators to work
#     "my_count_1",
#     "my_count_2",
#     "my_count_3",
#     "pipeline_1",
#     "pipeline_2",
#     "pipeline_3",
#     "layout_1",
#     "layout_2",
#     "layout_3",
#     "layout_4",
#     "layout_5",
# ]
#
# function generate_doc_images()
#     for id in _doc_img_names
#         generate_doc_image(id)
#     end
# end
#
# function generate_doc_image(id::AbstractString)
#     map(ex -> Base.eval(Main, ex), _doc_images[id])
#
#     dir = local_path("PlotDocs", _doc_img_files[id])
#     isdir(dir) || mkpath(dir)
#
#     if id in _animation_imgs
#         fn = joinpath(dir, string(id, ".gif"))
#         anim = @eval Main anim
#         if typeof(anim) <: Plots.AnimatedGif
#             mv(anim.filename, fn, force = true)
#         else
#             Plots.gif(anim, fn, fps = 15)
#         end
#     else
#         fn = joinpath(dir, string(id, ".png"))
#         Plots.savefig(fn)
#     end
# end
