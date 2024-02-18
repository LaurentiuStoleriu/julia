using Random
using StaticArrays
using Plots
using Optim
using Optim: converged, maximum, maximizer, minimizer, iterations
using DelimitedFiles

const N = 30
const rLow = 0.05
const rHigh = 0.10
const rAvg = (rLow + rHigh)/2.0
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

function computePressure(i, x, r)
	elasticF = 0.0
	if (i > 1) 
		elasticF += elasticK * (bondLen - (x[i] - x[i - 1] - r[i] - r[i - 1]))
    end
	if (i < N) 
		elasticF += elasticK * (bondLen - (x[i + 1] - x[i] - r[i] - r[i + 1]))
    end
    return elasticF
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

    vecs = SVector{N+1,Float64}[]

    createSystem!(x, r, 0)

    f(x) = totalEnergy(x, r)
    g!(G, x) = DtotalEnergy!(G, x, r)
    results = optimize(f, g!, x, BFGS()) # or ConjugateGradient()
    #results = optimize(f, g!, x, ConjugateGradient()) # or LBFGS()
    #println("minimum = $(results.minimum) with argmin = $(results.minimizer) in "*"$(results.iterations) iterations")
    
    HS = 0
    LS = N
    open("/home/lali/TITAN-ROG-sync/julia/1D-potential/10-MHL.txt", "w") do io
    end
    #temperature = 250.0
    for temperature in 100:0.1:300
        randomOrder = Random.shuffle(1:N)
        changeDone = false
        for particle in randomOrder
            localPressure = computePressure(particle, x, r)
            probabHtoL, probabLtoH = probabs(temperature, localPressure)
            if (r[particle] > rAvg) && (rand() < probabHtoL)
                r[particle] = rLow
                LS += 1
                HS -= 1
                changeDone = true
            elseif (r[particle] < rAvg) && (rand() < probabLtoH)
                r[particle] = rHigh
                LS -= 1
                HS += 1
                changeDone = true
            end
            if changeDone
                results = optimize(f, g!, x, BFGS())
                x = Optim.minimizer(results)[1:N]
                changeDone = false
            end
        end

        open("/home/lali/TITAN-ROG-sync/julia/1D-potential/10-MHL.txt", "a") do io
            #writedlm(io, [temperature; LS; x]', ',')
            writedlm(io, [temperature; LS; x[N]-x[1]]', ',')
        end
        println("T = ", temperature, "  LS = ", LS)
    end

end


main()