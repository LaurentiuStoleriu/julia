## c
##
f = (x, y) -> 0.75 * exp(-((9 * x - 2)^2 + (9 * y - 2)^2) / 4) + 0.75 * exp(-(9 * x + 1)^2 / 49 - (9 * y + 1) / 10) + 0.5 * exp(-((9 * x - 7)^2 + (9 * y - 3)^2) / 4) - 0.2 * exp(-(9 * x - 4)^2 - (9 * y - 7)^2)
f′ = (x, y) -> [(exp(-(9 * x - 4)^2 - (9 * y - 7)^2) * (162 * x - 72)) / 5 - (3 * exp(-(9 * x - 2)^2 / 4 - (9 * y - 2)^2 / 4) * ((81 * x) / 2 - 9)) / 4 - (exp(-(9 * x - 7)^2 / 4 - (9 * y - 3)^2 / 4) * ((81 * x) / 2 - 63 / 2)) / 2 - (3 * exp(-(9 * y) / 10 - (9 * x + 1)^2 / 49 - 1 / 10) * ((162 * x) / 49 + 18 / 49)) / 4
    (exp(-(9 * x - 4)^2 - (9 * y - 7)^2) * (162 * y - 126)) / 5 - (3 * exp(-(9 * x - 2)^2 / 4 - (9 * y - 2)^2 / 4) * ((81 * y) / 2 - 9)) / 4 - (exp(-(9 * x - 7)^2 / 4 - (9 * y - 3)^2 / 4) * ((81 * y) / 2 - 27 / 2)) / 2 - (27 * exp(-(9 * y) / 10 - (9 * x + 1)^2 / 49 - 1 / 10)) / 40]
f′′ = (x, y) -> [(162*exp(-(9 * x - 4)^2 - (9 * y - 7)^2))/5-(243*exp(-(9 * y) / 10 - (9 * x + 1)^2 / 49 - 1 / 10))/98-(243*exp(-(9 * x - 2)^2 / 4 - (9 * y - 2)^2 / 4))/8-(81*exp(-(9 * x - 7)^2 / 4 - (9 * y - 3)^2 / 4))/4+(3*exp(-(9 * y) / 10 - (9 * x + 1)^2 / 49 - 1 / 10)*((162*x)/49+18/49)^2)/4+(3*exp(-(9 * x - 2)^2 / 4 - (9 * y - 2)^2 / 4)*((81*x)/2-9)^2)/4+(exp(-(9 * x - 7)^2 / 4 - (9 * y - 3)^2 / 4)*((81*x)/2-63/2)^2)/2-(exp(-(9 * x - 4)^2 - (9 * y - 7)^2)*(162*x-72)^2)/5 (27*exp(-(9 * y) / 10 - (9 * x + 1)^2 / 49 - 1 / 10)*((162*x)/49+18/49))/40+(3*exp(-(9 * x - 2)^2 / 4 - (9 * y - 2)^2 / 4)*((81*x)/2-9)*((81*y)/2-9))/4+(exp(-(9 * x - 7)^2 / 4 - (9 * y - 3)^2 / 4)*((81*x)/2-63/2)*((81*y)/2-27/2))/2-(exp(-(9 * x - 4)^2 - (9 * y - 7)^2)*(162*x-72)*(162*y-126))/5
    (27*exp(-(9 * y) / 10 - (9 * x + 1)^2 / 49 - 1 / 10)*((162*x)/49+18/49))/40+(3*exp(-(9 * x - 2)^2 / 4 - (9 * y - 2)^2 / 4)*((81*x)/2-9)*((81*y)/2-9))/4+(exp(-(9 * x - 7)^2 / 4 - (9 * y - 3)^2 / 4)*((81*x)/2-63/2)*((81*y)/2-27/2))/2-(exp(-(9 * x - 4)^2 - (9 * y - 7)^2)*(162*x-72)*(162*y-126))/5 (243*exp(-(9 * y) / 10 - (9 * x + 1)^2 / 49 - 1 / 10))/400+(162*exp(-(9 * x - 4)^2 - (9 * y - 7)^2))/5-(243*exp(-(9 * x - 2)^2 / 4 - (9 * y - 2)^2 / 4))/8-(81*exp(-(9 * x - 7)^2 / 4 - (9 * y - 3)^2 / 4))/4+(3*exp(-(9 * x - 2)^2 / 4 - (9 * y - 2)^2 / 4)*((81*y)/2-9)^2)/4+(exp(-(9 * x - 7)^2 / 4 - (9 * y - 3)^2 / 4)*((81*y)/2-27/2)^2)/2-(exp(-(9 * x - 4)^2 - (9 * y - 7)^2)*(162*y-126)^2)/5]


##
using CairoMakie
CairoMakie.activate!(type="svg")

##
function plot_f(fig, x, y, vals, title, i, show_3d=true, zlabel="z")
    ax = Axis(fig[1, i], xlabel="x", ylabel="y", width=600, height=600, title=title, titlealign=:left)
    c = contourf!(ax, x, y, vals, colormap=:viridis, extendhigh=:auto)
    if show_3d
        ax = Axis3(fig[2, i], xlabel="x", ylabel="y", zlabel=zlabel, width=600, height=600, title=" ", titlealign=:left, azimuth=0.49)
        surface!(ax, x, y, vals, color=vals, colormap=:viridis)
    end
    return c
end

##
x = LinRange(0, 1, 100)
y = LinRange(0, 1, 100)
z = [f(x, y) for x in x, y in y]
∇ = [f′(x, y) for x in x, y in y]
∇₁ = first.(∇)
∇₂ = last.(∇)
H = [f′′(x, y) for x in x, y in y]
#H₁₁ = getindex.(H, 1)
H₁₂ = getindex.(H, 2)
#H₂₂ = getindex.(H, 4)

#fig = Figure(fontsize=36)
#plot_f(fig, x, y, z, "(a): f", 1, true, "z")
#plot_f(fig, x, y, ∇₁, "(b): ∂f/∂x", 2, true, "∂f/∂x")
#plot_f(fig, x, y, ∇₂, "(c): ∂f/∂y", 3, true, "∂f/∂y")
##plot_f(fig, x, y, H₁₁, "(d): ∂²f/∂x²", 4, true, "∂²f/∂x²")
#plot_f(fig, x, y, H₂₂, "(f): ∂²f/∂y²", 5, true, "∂²f/∂y²")
#plot_f(fig, x, y, H₁₂, "(e): ∂²f/∂x∂y", 6, true, "∂²f/∂x∂y")
#resize_to_layout!(fig)
#fig

##
using StableRNGs
using DelaunayTriangulation
using CairoMakie
rng = StableRNG(9199)
x = rand(rng, 500)
y = rand(rng, 500)
z = f.(x, y)
tri = triangulate([x'; y'])
vorn = voronoi(tri)

#fig = Figure(fontsize=36, size=(1800, 600))
#ax = Axis(fig[1, 1], xlabel="x", ylabel="y", width=600, height=600, title="(a): Data and triangulation", titlealign=:left)
#scatter!(ax, x, y, color=:black, markersize=9)
#triplot!(ax, tri, strokecolor=:black, strokewidth=2, show_convex_hull=false)
#voronoiplot!(ax, vorn, strokecolor=:blue)
#xlims!(ax, 0, 1)
#ylims!(ax, 0, 1)

#ax = Axis3(fig[1, 2], xlabel="x", ylabel="y", zlabel="z", width=600, height=600, azimuth=0.25, title="(b): Function values", titlealign=:left)
#triangles = [T[j] for T in each_solid_triangle(tri), j in 1:3]
#surface!(ax, x, y, z)
#scatter!(ax, x, y, z, color=:black, markersize=9)

#colgap!(fig.layout, 1, 75)
#resize_to_layout!(fig)
#fig


##
using NaturalNeighbours
using DelaunayTriangulation
using CairoMakie
using LinearAlgebra

function plot_f2(fig, x, y, vals, title, i, tri, levels, show_3d=true, zlabel="z")
    triangles = [T[j] for T in each_solid_triangle(tri), j in 1:3]
    ax = Axis(fig[1, i], xlabel="x", ylabel="y", width=600, height=600, title=title, titlealign=:left)
    c = tricontourf!(ax, x, y, vals, triangulation=triangles', colormap=:viridis, extendhigh=:auto, levels=levels)
    if show_3d
        ax = Axis3(fig[2, i], xlabel="x", ylabel="y", zlabel=zlabel, width=600, height=600, title=" ", titlealign=:left, azimuth=0.49)
        mesh!(ax, hcat(x, y, vals), triangles, color=vals, colormap=:viridis, colorrange=extrema(levels))
    end
    return c
end

function plot_gradients(∇g, tri, f′, x, y)
    ∇g1 = first.(∇g)
    ∇g2 = last.(∇g)
    fig = Figure(fontsize=36, size=(2400, 600))
    plot_f2(fig, x, y, ∇g1, "(a): ∂f̂/∂x", 1, tri, -3.5:0.5:3.0, true, "∂f̂/∂x")
    plot_f2(fig, x, y, ∇g2, "(b): ∂f̂/∂y", 3, tri, -3.5:0.5:3.0, true, "∂f̂/∂y")
    plot_f2(fig, x, y, getindex.(f′.(x, y), 1), "(c): ∂f/∂x", 2, tri, -3.5:0.5:3.0, true, "∂f/∂x")
    plot_f2(fig, x, y, getindex.(f′.(x, y), 2), "(d): ∂f/∂y", 4, tri, -3.5:0.5:3.0, true, "∂f/∂y")
    plot_f2(fig, x, y, norm.(collect.(∇g) .- f′.(x, y)), "(e): Gradient error", 5, tri, 0:0.1:0.5, true, "|∇ε|")
    resize_to_layout!(fig)
    ε = 100sqrt(sum((norm.(collect.(∇g) .- f′.(x, y))) .^ 2) / sum(norm.(∇g) .^ 2))
    return fig, ε
end

points = [x'; y']
z = f.(x, y)
tri = triangulate(points)
∇g = generate_gradients(tri, z)
#fig, ε = plot_gradients(∇g, tri, f′, x, y)
#fig

##
∇gr, _ = generate_derivatives(tri, z; method=Direct())
#fig, ε = plot_gradients(∇gr, tri, f′, x, y)
#fig


##
to_mat(H::NTuple{3,Float64}) = [H[1] H[3]; H[3] H[2]]
function plot_hessians(H, tri, f′′, x, y)
    H₁₁ = getindex.(H, 1)
    H₁₂ = getindex.(H, 3)
    H₂₂ = getindex.(H, 2)

    fig = Figure(fontsize=36, size=(2400, 600))
    #plot_f2(fig, x, y, H₁₁, "(a): ∂²f̂/∂x²", 1, tri, -35:5:30, true, "∂²f̂/∂x²")
    #plot_f2(fig, x, y, H₂₂, "(c): ∂²f̂/∂y²", 3, tri, -35:5:30, true, "∂²f̂/∂y²")
    plot_f2(fig, x, y, H₁₂, "(e): ∂²f̂/∂x∂y", 5, tri, -35:5:30, true, "∂²f̂/∂x∂y")
    #plot_f2(fig, x, y, getindex.(f′′.(x, y), 1), "(b): ∂²f/∂x²", 2, tri, -35:5:30, true, "∂²f/∂x²")
    #plot_f2(fig, x, y, getindex.(f′′.(x, y), 4), "(d): ∂²f/∂y²", 4, tri, -35:5:30, true, "∂²f/∂y²")
    plot_f2(fig, x, y, getindex.(f′′.(x, y), 2), "(f): ∂²f/∂x∂y", 6, tri, -35:5:30, true, "∂²f/∂x∂y")
    resize_to_layout!(fig)
    ε = 100sqrt(sum((norm.(to_mat.(H) .- f′′.(x, y))) .^ 2) / sum(norm.(to_mat.(H)) .^ 2))
    return fig, ε
end
_, Hg = generate_derivatives(tri, z)
fig, ε = plot_hessians(Hg, tri, f′′, x, y)
fig


##
_, Hg = generate_derivatives(tri, z, use_cubic_terms=false)
fig, ε = plot_hessians(Hg, tri, f′′, x, y)
fig


##
_, Hg = generate_derivatives(tri, z, method=Iterative()) # the gradients will be generated first automatically
fig, ε = plot_hessians(Hg, tri, f′′, x, y)
fig