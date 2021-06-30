using Plots

θ = -2π : 0.01 : 2π

plot(
    θ, [sin.(θ), cos.(θ)],
    title = "sin and cos plots",
    xlabel = "Radians",
    ylabel = "Amplitude",
    label = ["sin(θ)" "cos(θ)"],
    ylims = (-1.5, 1.5),
    xlims = (-7, 7)
)
