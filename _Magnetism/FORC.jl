
##
using Plots
using Revise
using DataInterpolations
using RegularizationTools
using NaturalNeighbours

##
function read_custom_file(filepath::String)
    array1 = Float64[]
    array2 = Float64[]

    start_reading = false

    num_regex = r"[-+]?\d*\.?\d+(?:[eE][-+]?\d+)?"

    open(filepath, "r") do file
        for line in eachline(file)

            clean_line = strip(line)

            if startswith(clean_line, "+") || startswith(clean_line, "-")
                matches = [m.match for m in eachmatch(num_regex, clean_line)]

                if length(matches) >= 2
                    push!(array1, parse(Float64, matches[1]))
                    push!(array2, parse(Float64, matches[2]))
                end
            else
                continue
            end
        end
    end
    return array1, array2
end

##
cale = "/home/lali/TITAN-ROG-sync/julia/_Magnetism/S9283/S9283-FORC-50-1500-5s"
H_read = Float64[]
M_read = Float64[]
H_read, M_read = read_custom_file(cale * ".txt")

## Normalize
normH = 1.0e3
normM = 1.0e-3
H_read = H_read ./ normH
M_read = M_read ./ normM
H_read, M_read

##
scatter(H_read, M_read,
    title="Scatter Plot of Data",
    xlabel="H",
    ylabel="M",
    legend=false,
    markersize=3,
    markercolor=:indianred,
    markerstrokecolor=:indianred
)

## Detect FORCs (Hr, numPointsPerFORC)
Hr_read = Float64[]
numPointsPerFORC = Int[]

current_Hr = H_read[1]
push!(Hr_read, current_Hr)

counterPointsPerFORC = 1

for i in 2:(length(H_read))
    if H_read[i] < H_read[i-1]
        global current_Hr = H_read[i]
        push!(numPointsPerFORC, counterPointsPerFORC)
        global counterPointsPerFORC = 0
    end
    global counterPointsPerFORC += 1
    push!(Hr_read, current_Hr)
end
push!(numPointsPerFORC, counterPointsPerFORC)
numFORCs = length(numPointsPerFORC)

println("----------- Total $(length(numPointsPerFORC)) FORCs -----------")
println("---------  $(numPointsPerFORC[1]) first / $(numPointsPerFORC[numFORCs]) last ---------")

## Save Hr-H-M original file
n = length(Hr_read)
if length(H_read) != n || length(M_read) != n
    error("Error: All three arrays must have the same length.")
end

open(cale * "_Hr-H-M_orig.dat", "w") do file
    for i in 1:n
        println(file, "$(Hr_read[i])  $(H_read[i])  $(M_read[i])")
    end
end

##
function gimmeOneFORC(theFORC::Int64)
    contorNumPoints = 0
    H_interp = Float64[]
    M_interp = Float64[]
    #detect indexes for $(theFORC)
    if theFORC > 1
        for i in 1:theFORC-1
            contorNumPoints += numPointsPerFORC[i]
        end
    else
        contorNumPoints = 0
    end

    #myHr = Hr_read[contorNumPoints]
    startPointOnFORC = contorNumPoints + 1
    push!(H_interp, H_read[startPointOnFORC])
    push!(M_interp, M_read[startPointOnFORC])
    contorNumPoints = 1
    while (Hr_read[startPointOnFORC+contorNumPoints-1] - Hr_read[startPointOnFORC+contorNumPoints]) < 1.0e-5 #eps - compare floats
        push!(H_interp, H_read[startPointOnFORC+contorNumPoints])
        push!(M_interp, M_read[startPointOnFORC+contorNumPoints])
        contorNumPoints += 1
        if (startPointOnFORC + contorNumPoints) > length(Hr_read)
            break
        end
    end
    H_interp, M_interp
end


##
showTest = true


##
if (showTest)
    # Interpolate one FORC
    plotInterpFORC = 28 #div(numFORCs * 2, 3)
    println("----------------- Interpolating Akima $(plotInterpFORC)-th FORC ----------------")
    H_interp, M_interp = gimmeOneFORC(plotInterpFORC)
    Example = AkimaInterpolation(M_interp, H_interp)
    plot(Example)
end

##
if (showTest)
    # Smooth one FORC (N - num points after smoothing)
    t, u = gimmeOneFORC(plotInterpFORC)
    d = plotInterpFORC + 1
    A = RegularizationSmooth(u, t, d; alg=:gcv_svd)
    û = A.û
    N = plotInterpFORC #length(t)
    titp = collect(range(minimum(t), maximum(t), length=N))
    uitp = A.(titp)
    scatter(t, u, label="simulated data", legend=:top)
    plot!(titp, uitp, label="smoothed interpolation")
end

##
if (showTest)
    # Save interpolated / smoothed file for a single FORC
    nSmooth = length(titp)
    nOrig = length(H_interp)
    n = maximum([nSmooth, nOrig])

    open(cale * "_InterpSmoothCheck.dat", "w") do file
        for i in 1:n
            if (nSmooth >= nOrig)
                if (i <= nOrig)
                    println(file, "$(t[i]), $(u[i]), $(H_interp[i]), $(M_interp[i]), $(titp[i]), $(uitp[i])")
                else
                    println(file, "       ,        ,              ,                , $(titp[i]), $(uitp[i])")
                end
            else
                if (i <= nSmooth)
                    println(file, "$(t[i]), $(u[i]), $(H_interp[i]), $(M_interp[i]), $(titp[i]), $(uitp[i])")
                else
                    println(file, "$(t[i]), $(u[i]), $(H_interp[i]), $(M_interp[i]),           ,           ")
                end
            end

        end
    end
end

##
numFORCs = length(numPointsPerFORC) + 1 # +1 pentru one-point-FORC

M_NoExtend = zeros(Float64, numFORCs, numFORCs) #matricea M
M_ExtendLine = zeros(Float64, numFORCs, numFORCs) #matricea M
M_ExtendMirror = zeros(Float64, numFORCs, numFORCs) #matricea M
Hr_NoExtend = zeros(Float64, numFORCs)
H_NoExtend = zeros(Float64, numFORCs)

H, M = gimmeOneFORC(1)
Hr_NoExtend[1] = H[end]
H_NoExtend[numFORCs] = H[end]
M_NoExtend[1, numFORCs] = M[end]
M_ExtendLine[1, numFORCs] = M[end]
M_ExtendMirror[1, numFORCs] = M[end]
for i in 1:numFORCs-1
    M_ExtendLine[1, i] = M[end]
    M_ExtendMirror[1, i] = M[end]
end

for i in 2:numFORCs
    global H, M = gimmeOneFORC(i - 1)
    Hr_NoExtend[i] = H[begin]
    H_NoExtend[numFORCs-i+1] = H[begin]
end

##
for i in 2:numFORCs
    global t, u = gimmeOneFORC(i - 1)
    if t[end] < Hr_NoExtend[1]
        t[end] = Hr_NoExtend[1]
    end

    #Example = AkimaInterpolation(M_interp, H_interp)

    global d = i+1
    global A = RegularizationSmooth(u, t, d; alg=:gcv_svd)
    global û = A.û
    global N = i #length(t)
    global titp = [Hr_NoExtend[j] for j = i:-1:1] #collect(range(minimum(t), maximum(t), length=N))
    global uitp = A.(titp)
    #println("---------- $(i)/$(numFORCs) -------------")

    for j in 1:i
        M_NoExtend[i, numFORCs-i+j] = uitp[j]
        M_ExtendLine[i, numFORCs-i+j] = uitp[j]
        M_ExtendMirror[i, numFORCs-i+j] = uitp[j]
        #println(" $(M_NoExtend[i, numFORCs-i+j]) ")
    end
    for j in 1:numFORCs-i
        M_ExtendLine[i, j] = uitp[begin]
    end
    for j in numFORCs-i+1:-1:1
        if j + (2 * (numFORCs - i + 1 - j) + 1) <= numFORCs
            M_ExtendMirror[i, j] = M_ExtendMirror[i, j+(2*(numFORCs-i+1-j)+1)]
        else
            M_ExtendMirror[i, j] = uitp[end]
        end
    end
end

##
if (showTest)
    heatmap(M_ExtendMirror, yflip=true)
end

##
if (showTest)
    scatter(H_NoExtend, transpose(M_ExtendLine), legend=false,
        markersize=3,
        markercolor=:indianred,
        markerstrokecolor=:indianred)
end

##
open(cale * ".MGRID.REGULAR.dat", "w") do file
    for i in 1:numFORCs
        for j in numFORCs-i+1:numFORCs
            println(file, "$(Hr_NoExtend[i])  $(H_NoExtend[j])  $(M_NoExtend[i, j])")
        end
        print(file, "\n")
    end
end

##
open(cale * ".MGRID.PrelungLine.dat", "w") do file
    for i in 1:numFORCs
        for j in 1:numFORCs
            println(file, "$(Hr_NoExtend[i])  $(H_NoExtend[j])  $(M_ExtendLine[i, j])")
        end
        print(file, "\n")
    end
end

##
SP = 4
FORC_NoExtend = zeros(Float64, numFORCs, numFORCs) #matricea FORC 

##
itp = interpolate(Hr_read, H_read, M_read; derivatives=true)

##
H_ForInterp = Float64[]
Hr_ForInterp = Float64[]

for i in 1:numFORCs
    for j in numFORCs-i+1:numFORCs
        push!(Hr_ForInterp, Hr_NoExtend[i])
        push!(H_ForInterp, H_NoExtend[j])
    end
end

##
sibson_1_vals = itp(Hr_ForInterp, H_ForInterp; method=Sibson(1))

##
open(cale * ".INTERP.dat", "w") do file
    for i in eachindex(Hr_ForInterp)
        println(file, "$(Hr_ForInterp[i])  $(H_ForInterp[i])  $(sibson_1_vals[i])")
    end
end