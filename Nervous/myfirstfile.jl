
mystringexample1 = "Hello, world"
#println(mystringexample1)
#println("Julia " * "programming")

#println(mystringexample1[1:3])
#println(length(mystringexample1), " ", ncodeunits(mystringexample1))

#greetingarray = [char^3 for char in mystringexample1]

str = string('a', 7, +, "suggestions")
println(str)

numar = string(1972, base=2, pad=16)
println(numar)

strarray = ["a", "bb", "ccc", "dddd"]
println(join(strarray))
println(join(strarray, ", "))
println(join(strarray, ", ", " and "))