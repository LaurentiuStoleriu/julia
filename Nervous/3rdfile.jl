a, b, c = 1, 2, -3

println(a>b)

a = 1.1

if (a>1)
    println("a mai mare de 1")
end

function ifeg1(a)
    if (a>1)
        println("a mai mare de 1")
    end
end

[ifeg1(x) for x in 0:3]

function ifeg2(a, b)
    if a>b
        println("$a mai mare decat $b")
    else
        println("$a nu este mai mare decat $b")
    end
end

ifeg2(2, 22)
#################################
loopvar = 1
while (loopvar < 4)
    println("loopvar is $loopvar")
    global loopvar = loopvar + 1
end

fibnum = [1, 1]
while fibnum[end] < 10000
    push!(fibnum, (fibnum[end-1]+fibnum[end]))
end
println(fibnum)
println(length(fibnum))
################################

for loopvar in 1:4
    println(('α' + loopvar)^loopvar)
end

[ (('α' + loopvar)^loopvar) for loopvar in 1:4]

for loopvar in 1:4
    println(('α' + loopvar)^loopvar)
    loopvar = loopvar + 4
    println("loopvar is $loopvar")
end

for loopvar in 1:4
    loopvar = loopvar + 4
    println("loopvar is $loopvar")    
    println(('α' + loopvar)^loopvar)
end

#######################################
#y = [x -> x^2 for x in 1:4]
#println(y)

y = [x for x in "My A1 Jag is XJ6"]; filter(x -> x < 'a', y)

println([x^2 + 2x + 1 for x in -5:3])
println(map(x -> x^2 + 2x + 1, -5:3))