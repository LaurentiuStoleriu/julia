#println(√2)

#println([bitstring(ch) for ch in "aα±"])

#println([bitstring(num) for num in [1.0, 0.1, 1.1]])

#function spin(str)
#    y = str[end:-1:1]
#    return y
#end

spin(str) = str[end:-1:1]

function spin(str, k)
    init = str[1:k]
    fin = str[end-k+1:end]
    mid = str[k+1:end-k]
    y = join([init, spin(mid), fin])
    return y
end

println(spin("123456789"))
println(spin("123456789", 4))

showtype(x::Int64, y) = println("x Int64, y Any")
showtype(x, y::Int64) = println("x Any, y Int64")

showtype(7.0, 7)
showtype(7, 7.0)
#showtype(7.0, 7.0) #No method
#showtype(7, 7)  #Ambiguous

### SCOPE

xyz = "abcd"
xyzvec = [locvar^4 for locvar in xyz]

#println(locvar)    #Not defined

eg1(x) = x+y
eg2(x, y) = x+y

x, y = 2, 3
println(eg1(x))
println(eg2(x, y))

function eg1(x)
    z = x+y
    global y = 11
    return z
end

function eg2(x, y)
    z = x+y
    y = 11
    return z
end


function modaa()
    aa = 7
end

function modbb()
    bb[2] = 7
end

aa, bb = 369, [-4, -3, 8]
#modaa()
#modbb()

aa = 2
bb = aa
bb = 3
println("$aa, \t $bb")

aa = [1, 2, 3]
bb = aa
bb[2] = 99
println("$aa, \t $bb")