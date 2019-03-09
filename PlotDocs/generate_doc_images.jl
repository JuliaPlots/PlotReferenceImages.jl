
using StatPlots, StatsBase, DataFrames, RDatasets, Distributions, ProgressMeter#, Iterators

doc_path(args...) = joinpath(@__DIR__, args...)

# ------------------------------------------------------------------------------

gr()
# define the Lorenz attractor
mutable struct Lorenz
    dt; σ; ρ; β; x; y; z
end

function step!(l::Lorenz)
    dx = l.σ*(l.y - l.x)       ; l.x += l.dt * dx
    dy = l.x*(l.ρ - l.z) - l.y ; l.y += l.dt * dy
    dz = l.x*l.y - l.β*l.z     ; l.z += l.dt * dz
end

attractor = Lorenz((dt = 0.02, σ = 10., ρ = 28., β = 8//3, x = 1., y = 1., z = 1.)...)


# initialize a 3D plot with 1 empty series
plt = plot3d(1, xlim=(-25,25), ylim=(-25,25), zlim=(0,50),
            title = "Lorenz Attractor", marker = 2)

# build an animated gif by pushing new points to the plot, saving every 10th frame
anim = @gif for i=1:1500
    step!(attractor)
    push!(plt, attractor.x, attractor.y, attractor.z)
end every 10

mv(anim.filename, doc_path("index", "lorenz_attractor.gif"), force = true)


# ------------------------------------------------------------------------------

pyplot(leg=false, ticks=nothing) #change to the pyplot backend and define some defaults
x = y = range(-5, stop = 5, length = 40)
zs = zeros(0,40)
n = 100

# create a progress bar for tracking the animation generation
prog = Progress(n,1)

anim = @gif for i in range(0, stop = 2π, length = n)
    f(x,y) = sin(x + 10sin(i)) + cos(y)

    # create a plot with 3 subplots and a custom layout
    l = Plots.@layout [a{0.7w} b; c{0.2h}]
    p = plot(x, y, f, st = [:surface, :contourf], layout=l)

    # induce a slight oscillating camera angle sweep, in degrees (azimuth, altitude)
    plot!(p[1], camera=(15*cos(i), 40))

    # add a tracking line
    fixed_x = zeros(40)
    z = map(f, fixed_x, y)
    plot!(p[1], fixed_x, y, z, line = (:black, 5, 0.2))
    vline!(p[2], [0], line = (:black, 5))

    # add to and show the tracked values over time
    global zs = vcat(zs, z')
    plot!(p[3], zs, alpha = 0.2, palette = cgrad(:blues).colors)

    # increment the progress bar
    next!(prog)
end

mv(anim.filename, doc_path("index", "waves.gif"), force = true)


# ------------------------------------------------------------------------------

# create decision boundary video (for index page)
gr()
Random.seed!(7) # for a consistent result

P = 40;  R = 50;  N = P*R;  r = 0:0.004:1
points = rand(ComplexF64, P, R)
grad = cgrad(cgrad(:lighttest).colors[[1:end; 1]])

mp4(@animate(for t = 0:0.03:13
    # create a simple classifier to return the region for any point (x, y)
    midpoints = sum(points; dims=1)[:] / P
    classify(x, y) = argmin(abs.(x + y*im .- midpoints))

    # draw decision boundary and points
    contour(r, r, classify, c=grad, fill=true, nlev=R, leg=:none)
    scatter!(reim(points)..., c=cvec(grad, R)', lims=(0,1))

    # poster image, shown before video starts
    t ≈ 7.5 && png(doc_path("index", "decision-poster.png"))

    # update position of points
    target(d) = 0.65*cis(4*sin(t/2+d)+d) + 0.5 + 0.5im
    points[:] .+= 0.01*(target.(0:2π/(N-1):2π) .- points[:])
end), doc_path("index", "decision.mp4"), fps = 30)


# ------------------------------------------------------------------------------

gr(leg=false, bg=:lightgrey)

# Create a filled contour and boxplot side by side.
plot(contourf(randn(10,20)), boxplot(rand(1:4,1000),randn(1000)))

# Add a histogram inset on the heatmap.
# We set the (optional) position relative to bottom-right of the 1st subplot.
# The call is `bbox(x, y, width, height, origin...)`, where numbers are treated as "percent of parent"
histogram!(randn(1000), inset = (1, bbox(0.05,0.05,0.5,0.25,:bottom,:right)), ticks=nothing, subplot=3, bg_inside=nothing)

# Add sticks floating in the window (inset relative to the window, as opposed to being relative to a subplot)
sticks!(randn(100), inset = bbox(0,-0.2,200Plots.px,100Plots.px,:center), ticks=nothing, subplot=4)
png(doc_path("layout", "layout_5"))
theme(:default)

# ------------------------------------------------------------------------------

gr()
# load a dataset
iris = dataset("datasets", "iris");

# Scatter plot with some custom settings
@df iris scatter(:SepalLength, :SepalWidth, group=:Species,
    title = "My awesome plot",
    xlabel = "Length", ylabel = "Width",
    m=(0.5, [:cross :hex :star7], 12),
    bg=RGB(.2,.2,.2))

png(doc_path("index", "iris"))


# ------------------------------------------------------------------

# iris = dataset("datasets","iris")
@df iris marginalhist(:PetalLength, :PetalWidth)
png(doc_path("tutorial", "plot_recipes"))


# ------------------------------------------------------------------

@df iris scatter(:SepalLength, :SepalWidth, group=:Species,
    m=(0.5, [:+ :h :star7], 12), bg=RGB(.2,.2,.2))
png(doc_path("input", "dataframes"))


# ------------------------------------------------------------------------------

dfr = DataFrame(a = 1:10, b = 10*rand(10), c = 10 * rand(10))
# Plot the DataFrame by declaring the points by the column names
@df dfr plot(:a, [:b :c]) # x = :a, y = [:b :c]. Notice this is two columns!
png(doc_path("tutorial", "user_recipes_1"))


# ------------------------------------------------------------------------------

@df dfr scatter(:a, :b, title="My DataFrame Scatter Plot!") # x = :a, y = :b
png(doc_path("tutorial", "user_recipes_2"))


# ------------------------------------------------------------------------------

gr()
x = 1:10; y = rand(10); # These are the plotting data
plot(x,y)
png(doc_path("tutorial", "lines_1"))


# ------------------------------------------------------------------------------

x = 1:10; y = rand(10,2) # 2 columns means two lines
plot(x,y)
png(doc_path("tutorial", "lines_2"))


# ------------------------------------------------------------------------------

z = rand(10)
plot!(x,z)
png(doc_path("tutorial", "lines_3"))


# ------------------------------------------------------------------------------

x = 1:10; y = rand(10,2) # 2 columns means two lines
p = plot(x,y)
z = rand(10)
plot!(p,x,z)
png(doc_path("tutorial", "lines_4"))


# ------------------------------------------------------------------------------

x = 1:10; y = rand(10,2) # 2 columns means two lines
plot(x,y,title="Two Lines",label=["Line 1" "Line 2"],lw=3)
png(doc_path("tutorial", "attr_1"))


# ------------------------------------------------------------------------------

xlabel!("My x label")
png(doc_path("tutorial", "attr_2"))


# ------------------------------------------------------------------------------

x = 1:10; y = rand(10,2) # 2 columns means two lines
plotlyjs() # Set the backend to Plotly
plot(x,y,title="This is Plotted using Plotly")
png(doc_path("tutorial", "backends_1"))


# ------------------------------------------------------------------------------

gr() # Set the backend to GR
plot(x,y,title="This is Plotted using GR") # This plots using GR
png(doc_path("tutorial", "backends_2"))


# ------------------------------------------------------------------------------

gr() # We will continue onward using the GR backend
plot(x,y,seriestype=:scatter,title="My Scatter Plot")
png(doc_path("tutorial", "scatter_1"))


# ------------------------------------------------------------------------------

gr()
scatter(x,y,title="My Scatter Plot")
png(doc_path("tutorial", "scatter_2"))


# ------------------------------------------------------------------------------

y = rand(10,4)
plot(x,y,layout=(4,1))
png(doc_path("tutorial", "subplots_1"))


# ------------------------------------------------------------------------------

p1 = plot(x,y) # Make a line plot
p2 = scatter(x,y) # Make a scatter plot
p3 = plot(x,y,xlabel="This one is labelled",lw=3,title="Subtitle")
p4 = histogram(x,y) # Four histograms each with 10 points? Why not!
plot(p1,p2,p3,p4,layout=(2,2),legend=false)
png(doc_path("tutorial", "subplots_2"))


# ------------------------------------------------------------------------------

plot(Normal(3,5),lw=3)
png(doc_path("tutorial", "type_recipes"))


# ------------------------------------------------------------------------------

y = rand(100,4) # Four series of 100 points each
violin(["Series 1" "Series 2" "Series 3" "Series 4"],y,leg=false)
png(doc_path("tutorial", "series_recipes_1"))


# ------------------------------------------------------------------------------

boxplot!(["Series 1" "Series 2" "Series 3" "Series 4"],y,leg=false)
png(doc_path("tutorial", "series_recipes_2"))


# ------------------------------------------------------------------------------

gr()

# 10 data points in 4 series
xs = 0 : 2π/10 : 2π
data = [sin.(xs) cos.(xs) 2sin.(xs) 2cos.(xs)]

# We put labels in a row vector: applies to each series
labels = ["Apples" "Oranges" "Hats" "Shoes"]

# Marker shapes in a column vector: applies to data points
markershapes = [:circle, :star5]

# Marker colors in a matrix: applies to series and data points
markercolors = [:green :orange :black :purple
            :red   :yellow :brown :white]

plot(xs, data, label = labels, shape = markershapes, color = markercolors,
 markersize = 10)

png(doc_path("input", "columns_are_series"))


# ------------------------------------------------------------------------------

plotlyjs()

function rectangle_from_coords(xb,yb,xt,yt)
    [
        xb yb
        xt yb
        xt yt
        xb yt
        xb yb
        NaN NaN
    ]
end

some_rects=[
    rectangle_from_coords(1 ,1 ,5 ,5 )
    rectangle_from_coords(10,10,15,15)
    ]
other_rects=[
    rectangle_from_coords(1 ,10,5 ,15)
    rectangle_from_coords(10,1 ,15,5 )
    ]

plot(some_rects[:,1], some_rects[:,2],label="some group")
plot!(other_rects[:,1], other_rects[:,2],label="other group")

png(doc_path("input", "unconnected"))


# ------------------------------------------------------------------------------

# itr = repeatedly(()->rand(10), 20)
# anim = animate(itr, ylims=(0,1), c=:red, fps=5)
# gif(anim, doc_path("animations", "rand_anim.gif"), fps = 15)


# ------------------------------------------------------------------------------

gr(size=(300,300), leg=false)

@userplot MyCount
Plots.@recipe function f(mc::MyCount)
    # get the array from the args field
    arr = mc.args[1]

    T = typeof(arr)
    if T.parameters[1] == Float64
        seriestype := :histogram
        arr
    else
        seriestype := :bar
        cm = countmap(arr)
        x = sort!(collect(keys(cm)))
        y = [cm[xi] for xi=x]
        x, y
    end
end
mycount(rand(500))

png(doc_path("contributing", "my_count_1"))


# ------------------------------------------------------------------------------

mycount(rand(["A","B","C"],100))
png(doc_path("contributing", "my_count_2"))


# ------------------------------------------------------------------------------

mycount(rand(1:500, 500))
png(doc_path("contributing", "my_count_3"))



# ------------------------------------------------------------------------------

pyplot()
plot(x, y, line = (0.5, [4 1 0], [:path :scatter :density]),
    marker=(10, 0.5, [:none :+ :none]), fill=0.5,
    orientation = :h, title = "My title")
png(doc_path("pipeline", "pipeline_1"))


# ------------------------------------------------------------------------------

gr()
mutable struct MyVecWrapper
    v::Vector{Float64}
end
mvw = MyVecWrapper(rand(100))

@recipe function f(mvw::MyVecWrapper)
    markershape --> :circle
    markersize  --> 30
    mvw.v
end

plot(
    plot(mvw.v),
    plot(mvw)
    )

png(doc_path("pipeline", "pipeline_2"))


# ------------------------------------------------------------------------------

scatter(rand(100), group = rand(1:3, 100), marker = (10,0.3,[:s :o :x]))
png(doc_path("pipeline", "pipeline_3"))


# ------------------------------------------------------------------------------

# create a 2x2 grid, and map each of the 4 series to one of the subplots
plot(rand(100,4), layout = 4)
png(doc_path("layout", "layout_1"))


# ------------------------------------------------------------------------------

# create a 4x1 grid, and map each of the 4 series to one of the subplots
plot(rand(100,4), layout = (4,1))
png(doc_path("layout", "layout_2"))


# ------------------------------------------------------------------------------

plot(rand(100,4), layout = grid(4,1,heights=[0.1,0.4,0.4,0.1]))
png(doc_path("layout", "layout_3"))


# ------------------------------------------------------------------------------

l = Plots.@layout [  a{0.3w} [grid(3,3)
                                 b{0.2h} ]]
plot(
    rand(10,11),
    layout = l, label = "", seriestype = [:bar :scatter :path],
    title = ["($i)" for j = 1:1, i=1:11], titleloc = :right, titlefont = font(8)
    )
png(doc_path("layout", "layout_4"))
