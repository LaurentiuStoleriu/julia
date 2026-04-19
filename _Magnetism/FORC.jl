
##
using Plots
using Revise
using DataInterpolations

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

H_read = Float64[]
M_read = Float64[]
H_read, M_read = read_custom_file("/home/lali/TITAN-ROG-sync/julia/_Magnetism/S9281/S9281-FORC-100-2000-5s.txt")

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

##
# Detect FORCs (Hr, numPointsPerFORC)
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

# Save Hr-H-M original file
n = length(Hr_read)
if length(H_read) != n || length(M_read) != n
    error("Error: All three arrays must have the same length.")
end

open("/home/lali/TITAN-ROG-sync/julia/_Magnetism/S9281/S9281-FORC-100-2000-5s_Hr-H-M_orig.dat", "w") do file
    for i in 1:n
        println(file, "$(Hr_read[i]), $(H_read[i]), $(M_read[i])")
    end
end


##
function interpolateOneFORC(theFORC::Int64)
    contorNumPoints = 0
    H_interp = Float64[]
    M_interp = Float64[]
#detect indexes for $(theFORC)
    for i in 1:theFORC-1
        contorNumPoints += numPointsPerFORC[i]
    end

    myHr = Hr_read[contorNumPoints]
    startPointOnFORC = contorNumPoints + 1
    push!(H_interp, H_read[startPointOnFORC])
    push!(M_interp, M_read[startPointOnFORC])
    contorNumPoints = 1
    while (Hr_read[startPointOnFORC+contorNumPoints-1] - Hr_read[startPointOnFORC+contorNumPoints]) < 1.0e-5 #eps - compare floats
        push!(H_interp, H_read[startPointOnFORC+contorNumPoints])
        push!(M_interp, M_read[startPointOnFORC+contorNumPoints])
        contorNumPoints += 1
    end
    Example = AkimaInterpolation(M_interp, H_interp)
    plot(Example)
end


##
plotInterpFORC = div(numFORCs * 2 , 3)
println("---------------------------------------")
println("---------- Interp  $(plotInterpFORC)-th FORC ---------")
interpolateOneFORC(plotInterpFORC)