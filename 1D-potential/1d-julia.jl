#using Revise
#using BenchmarkTools
using StaticArrays
using Plots
using Optim
using Optim: converged, maximum, maximizer, minimizer, iterations

const N = 10
const rLow = 0.05
const rHigh = 0.10
const bondLen = 0.10
const elasticK = 1.0e2
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
    currentX = (nBumpsPerParticle * pi / 2.0 / factor)
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
	xi = x[1]
	ri = r[1]
    for i in 1:(N-1)
		xNext = x[i + 1]
		rNext = r[i + 1]
		eBond = -bondLen + xNext - xi - ri - rNext
		E += eBond * eBond
		VTot += surfacePotential(xi)
		xi = xNext
		ri = rNext
        #println("[$i]    E = ", E, "  V = ", VTot)
	end
	VTot += surfacePotential(x[N])
    VTot + (elasticK / 2.0) * E
end

function DtotalEnergy!(G, x, r) 
	VTot = 0.0
    E = 0.0
	xi = x[1]
	ri = r[1]
    xNext = x[2]
    rNext = r[2]
    VTot = surfacePotential(xi)
    E = -elasticK * (-bondLen + xNext - xi - ri - rNext)
    G[1] = VTot + E
    for i in 2:(N-1)
        xPrev = xi
        rPrev = ri
        xi = xNext
        ri = rNext
		xNext = x[i + 1]
		rNext = r[i + 1]
        VTot = surfacePotential(xi)
		E = elasticK * (-xNext - xPrev + 2*xi - rPrev + rNext)
        G[i] = VTot + E
	end
    xPrev = xi
    rPrev = ri
    xi = xNext
    ri = rNext
    VTot = surfacePotential(xi)
    E = elasticK * (-bondLen - xPrev + xi - ri - rPrev)
    G[N] = VTot + E
end

function main()
    #Revise.revise()
    #particles = Vector{particle}(undef, N)

    x = @MVector zeros(N)
    r = @MVector zeros(N)  

    createSystem!(x, r, 0)
    totalEnergy(x, r) 

    ## GRAPHIC ##
    xGraphic = range(0-3*bondLen, x[N]+3*bondLen, length=1000)
    plot(xGraphic, map(surfacePotential, xGraphic))
    xCoords = x[1:N]
    scatter!(xCoords, map(surfacePotential, xCoords))
    plot!(legend=:outerbottom, legendcolumns=2)

    r[5] = rHigh

    println(x)
    println(r)

    f(x) = totalEnergy(x, r)
    g!(G, x) = DtotalEnergy!(G, x, r)

    results = optimize(f, x, LBFGS()) # or ConjugateGradient()
    #println("minimum = $(results.minimum) with argmin = $(results.minimizer) in "*"$(results.iterations) iterations")
    
    xNew = Optim.minimizer(results)[1:N]
    println(Optim.minimizer(results), "  ", Optim.converged(results))
    println(r)

    xGraphic = range(0-3*bondLen, xNew[N]+3*bondLen, length=1000)
    plot(xGraphic, map(surfacePotential, xGraphic))
    xCoords = xNew[1:N]
    scatter!(xCoords, map(surfacePotential, xCoords))
    plot!(legend=:outerbottom, legendcolumns=2)
end

main()

