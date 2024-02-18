# using Revise
# using BenchmarkTools
# using Profile
using StaticArrays
using Plots
using Optim
using Optim: converged, maximum, maximizer, minimizer, iterations

const N = 10
const rLow = 0.05
const rHigh = 0.10
const bondLen = 0.10
const elasticK = 1.0e0
const A = 1.0e-4
const factor = pi / (2.0*(rHigh - rLow))

const kB = 1.0
const tau = 100.0
const D = 1000.0
const g = 8.0
const Ea = 100.0
const k = 1500.0
const unuPeTau = 1.0 / tau
const kBg = kB * g
const doikB = 2.0 * kB

function probabs(T, p)
	DkBTpeDoikBT = (D - kBg * T) / (doikB * T)
	HtoL = unuPeTau * exp(DkBTpeDoikBT) * exp(-(Ea - k * p) / (kB * T))
	LtoH = unuPeTau * exp(-DkBTpeDoikBT) * exp(-(Ea + k * p) / (kB * T))
    [HtoL, LtoH]
end

function createSystem!(x, r, stare) 
    nBumpsPerParticle = 1.0
    currentX = nBumpsPerParticle * (pi / 2.0 / factor)
	startingRadius = rLow;
	if (stare == 1)
		startingRadius = rHigh
    end
	for i in 1:N
        x[i] = currentX
        r[i] = startingRadius
        currentX += (bondLen + 2.0 * startingRadius)
    end
end

function surfacePotential(coord::Float64)
    A * (1.0 - sin(factor * coord)) / 2.0
end

function totalEnergy(x, r) 
	VTot = 0.0
    E = 0.0
    for i in 1:(N-1)
		eBond = -bondLen + x[i + 1] - x[i] - r[i] - r[i + 1]
		E += eBond * eBond
		VTot += surfacePotential(x[i])
	end
	VTot += surfacePotential(x[N])
    VTot + (elasticK / 2.0) * E
end

function DtotalEnergy!(G, x, r) 
    G[1] = surfacePotential(x[1]) - elasticK * (-bondLen + x[2] - x[1] - r[1] - r[2])
    for i in 2:(N-1)
        G[i] = surfacePotential(x[i]) + elasticK * (-x[i + 1] - x[i - 1] + 2*x[i] - r[i - 1] + r[i + 1])
	end
    G[N] = surfacePotential(x[N]) + elasticK * (-bondLen - x[N-1] + x[N] - r[N] - r[N-1])
end

function plotSystem(x, r)
    xGraphic = range(0-3*bondLen, x[N]+3*bondLen, length=1000)
    plot(xGraphic, map(surfacePotential, xGraphic))
    xCoords = x[1:N]
    xColors = r
    xSizes = 50 .* r
    plot!(xCoords, map(surfacePotential, xCoords), seriestype=:scatter, label="particles",zcolor=xColors, markersize=xSizes, color=reverse(cgrad(:blackbody)))
    plot!(legend=:outerbottom, legendcolumns=2)
end


function main()
    x = @MVector zeros(N)
    r = @MVector zeros(N)  

    createSystem!(x, r, 0)
    # totalEnergy(x, r) 

    r[4] = rHigh
    r[5] = rHigh
    r[6] = rHigh

    f(x) = totalEnergy(x, r)
    g!(G, x) = DtotalEnergy!(G, x, r)
    results = optimize(f, g!, x, LBFGS()) # or ConjugateGradient()
    #results = optimize(f, x, ConjugateGradient()) # or LBFGS()
    #println("minimum = $(results.minimum) with argmin = $(results.minimizer) in "*"$(results.iterations) iterations")
    
    xNew = Optim.minimizer(results)[1:N]
    #println(Optim.minimizer(results), "  ", Optim.converged(results))
    #println(r)

    plotSystem(xNew, r)
end

# @benchmark main()
# @profile main()
# Profile.print()

main()