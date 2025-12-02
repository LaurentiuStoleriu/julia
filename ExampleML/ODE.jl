using DifferentialEquations
using Plots
using DiffEqSensitivity, ForwardDiff, DelimitedFiles

ns = 2
nr = 2
k = [1e-5, 1]
alg = RK4()
b0 = 0
lb = 1e-5
ub = 1e1
nt = 15

function trueODEfunc(dydt, y, k, t)
    aA = 1
    aB = 1
    kr = 0
    dydt[1] = -k[1] * aA * y[1] + kr * y[2] + k[2] * aB * y[2];
    dydt[2] = -dydt[1]
    #dydt[2] = k[1] * aA * y[1] - k[2] * y[2] - k3 * aB * y[2];
end

#u0 = zeros(Float64, ns);
free_ic = 1 - 1 / (1 + 1.0e5);
adsorbed_ic = (1 / (1 + 1.0e5));
u0 = [free_ic, adsorbed_ic]
tspan = (0., 4.)
tsteps = LinRange(0, 4, nt)

prob = ODEProblem(trueODEfunc, u0, tspan, k);
ode_sol = Array(solve(prob, alg, saveat=tsteps))
data_matrix = hcat(tsteps, ode_sol[1, :], ode_sol[2, :])

# Add column headers
headers = ["Time_Steps" "Free_Sites" "Adsorbed_Sites"]

# Combine headers and data
output_data = vcat(headers, data_matrix)

# Save to CSV file
writedlm("ODE_ipynb.csv", output_data, ',')

function target_rate(y, k)
    aB = 1
    rate = y[2] * k[2] * aB
    return rate
end

function rate_wrapper(lnk)
    k = exp.(lnk)
    _prob = remake(prob, p=k)
    sol = Array(solve(_prob, alg, saveat=tsteps, sensealg=ForwardDiffSensitivity()))
    println(size(sol))
    k_matrix = reshape(k, 1, size(k, 1))
    k_repeat = repeat(k_matrix, nt, 1)
    rate = Array{Real, 2}(undef, nt, 1)
    for i in 1:nt
        rate[i, 1] = target_rate(sol[:, i], k_repeat[i, :])
    end
    println("Rate")
    println(rate)
    return log.(rate)
end

drc = ForwardDiff.jacobian(rate_wrapper, log.(k))

plt = plot()
plot!(plt, tsteps, drc[:, 1],
    linewidth=3, xlabel="Time (s)", ylabel="Degree of Rate Control",
    label="DRC-1")
plot!(plt, tsteps, drc[:, 2], linewidth=3, label="DRC-2")
png(plt, string("DRC_ODE"))