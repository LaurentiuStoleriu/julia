using Optim
using Optim: converged, maximum, maximizer, minimizer, iterations #some extra functions

f(x) = (1.0 - x[1])^2 + 100.0 * (x[2] - x[1]^2)^2
x_iv = [0.0, 0.0]

#results = optimize(f, x_iv) # i.e. optimize(f, x_iv, NelderMead())

#results = optimize(f, x_iv, LBFGS())
#println("minimum = $(results.minimum) with argmin = $(results.minimizer) in "*"$(results.iterations) iterations")

function g!(G, x)
    G[1] = -2.0 * (1.0 - x[1]) - 400.0 * (x[2] - x[1]^2) * x[1]
    G[2] = 200.0 * (x[2] - x[1]^2)
end

results = optimize(f, g!, x_iv, LBFGS()) # or ConjugateGradient()
println("minimum = $(results.minimum) with argmin = $(results.minimizer) in "*"$(results.iterations) iterations")