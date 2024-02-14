using Revise
#using BenchmarkTools
using Plots

const rLow = 0.05
const rHigh = 0.10
const bondLen = 0.10
const elasticK = 1.0e0
const A = 1.0e-4
const factor = pi / (2.0*(r_high - r_low))

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

function createSystem!(x, r, spin, stare) 
    nBumpsPerParticle = 1.0
    currentX = (nBumpsPerParticle * pi / 2.0 / factor)
	startingRadius = rLow;
	
	if (stare == 1)
		startingRadius = rHigh
    end

	for i in eachindex(x)
        x[i] = currentX
        r[i] = startingRadius
        spin[i] = stare
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

    for i in 1:(length(x)-1)
		xNext = x[i + 1];
		rNext = r[i + 1];

		eBond = -bondLen + xNext - xi - ri - rNext;
		E += eBond * eBond;

		VTot += surfacePotential(xi)

		xi = xNext
		ri = rNext
        #println("[$i]    E = ", E, "  V = ", VTot)
	end
	VTot += surfacePotential(last(x))
    VTot + (elasticK / 2.0) * E
end

function main()
    Revise.revise()
    N = 10
    x = zeros(MVector{N,Float64})
    r = zeros(MVector{N,Float64})
    spin = zeros(MVector{N,Float64})
    createSystem!(x, r, spin, 0)
    totalEnergy(x, r) 

    ## GRAPHIC ##
    xGraphic = range(0-3*bondLen, last(x)+3*bondLen, length=1000)
    plot(xGraphic, map(surfacePotential, xGraphic))
    scatter!(x, map(surfacePotential, x))
    plot!(legend=:outerbottom, legendcolumns=2)
end

main()

