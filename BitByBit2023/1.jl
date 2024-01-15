using Printf

function swap(a, b)
    b, a
end

a = 3
b = 5
println(a, ", ", b)

a, b = swap(a, b)
println(a, ", ", b)