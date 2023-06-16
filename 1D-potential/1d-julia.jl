
function create_system!(x::Vector{Float64}, r::Vector{Float64}, spin::Vector{Float64}, stare, r_low, r_high, bond_length) 
    term = pi / (2.0*(r_high - r_low))
    current_x = (3.0 * pi / 2.0 / term)
	starting_radius = r_low;
	
	if (stare == 1)
		starting_radius = r_high
    end

	for i in eachindex(x)
        x[i] = current_x
        r[i] = starting_radius
        spin[i] = stare
        current_x += (bond_length + 2.0 * starting_radius)
    end

end

function main()
    N = 10
    x = zeros(Float64,N)
    r = zeros(Float64,N)
    spin = zeros(Float64,N)
    create_system!(x, r, spin, 0, 0.05, 0.1, 0.1)

    println(x)
    println(r)
    println(spin)

end

main()