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

#u0 = zeros(Float64, ns);
free_ic = 1 - 1 / (1 + 1.0e5);
adsorbed_ic = (1 / (1 + 1.0e5));
u0 = [free_ic, adsorbed_ic]
tspan = (0., 4.)
tsteps = LinRange(0, 4, nt)

function p2vec(p)
    w_b = p[1:nr] .+ b0;
    # More robust reshaping that works with dual numbers
    remaining_params = p[nr + 1:end]
    w_out = reshape(remaining_params, ns, nr);
    # w_out = clamp.(w_out, -2.5, 2.5);
    w_in = clamp.(-w_out, 0, 2.5);
    return w_in, w_b, w_out
end

function display_p(p)
    w_in, w_b, w_out = p2vec(p);
    println("species (column) reaction (row)")
    println("w_in")
    show(stdout, "text/plain", round.(w_in', digits=3))

    println("\nw_b")
    show(stdout, "text/plain", round.(exp.(w_b'), digits=6))

    println("\nw_out")
    show(stdout, "text/plain", round.(w_out', digits=3))
    println("\n\n")
end

function crnn(du, u, p, t)
    w_in, w_b, w_out = p2vec(p);
    w_in_x = w_in' * @. log(clamp(u, lb, ub));
    du .= w_out * @. exp(w_in_x + w_b);
end

p = [log(1e-5*1), log(1*1), -1, 1, 1, -1]
display_p(p)

prob = ODEProblem(crnn, u0, tspan, p)

function predict_neuralode(prob, u0)
    sol = Array(solve(prob, alg, u0=u0, saveat=tsteps))
    return sol
end

sol = predict_neuralode(prob, u0)
data_matrix = hcat(tsteps, sol[1, :], sol[2, :])

# Add column headers
headers = ["Time_Steps" "Free_Sites" "Adsorbed_Sites"]

# Combine headers and data
output_data = vcat(headers, data_matrix)

# Save to CSV file
writedlm("CRNN_ipynb.csv", output_data, ',')

function target_rate(u, p)
    w_in, w_b, w_out = p2vec(p);
    w_in_x = w_in' * @. log(clamp(u, lb, ub));
    rate_all_reaction = @. exp(w_in_x + w_b);
    println(size(rate_all_reaction))
    target_rate = rate_all_reaction[2]
    return target_rate
end

function rate_wrapper(p_new)
    _prob = remake(prob, p=p_new)
    sol = predict_neuralode(_prob, u0)
    rate = Vector{eltype(p_new)}(undef, nt)  # Use eltype to handle dual numbers
    for i in 1:nt
        rate[i] = target_rate(sol[:, i], p_new)
    end
    println("Rate")
    println(rate)
    return log.(rate)
end

# Compute Jacobian with respect to all parameters
drc = ForwardDiff.jacobian(rate_wrapper, p)

# Plot only the first two columns (corresponding to the rate constants)
plt = plot()
plot!(plt, tsteps, drc[:, 1],
    linewidth=3, xlabel="Time (s)", ylabel="Degree of Rate Control",
    label="DRC-1 (rate constant 1)")
plot!(plt, tsteps, drc[:, 2], linewidth=3, 
    label="DRC-2 (rate constant 2)")
png(plt, string("DRC_CRNN"))