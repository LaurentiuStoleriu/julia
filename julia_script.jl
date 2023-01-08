c = 1 + 2

a = 2

function test(a=1)
    a + 2
end


test(10)

using DataFrames, RDatasets

iris = dataset("datasets", "iris")

function profile_test(n)
    for i = 1:n
        A = randn(100,100,20)
        m = maximum(A)
        Am = mapslices(sum, A; dims=2)
        B = A[:,:,5]
        Bsort = mapslices(sort, B; dims=1)
        b = rand(100)
        C = B.*b
    end
end

@profview profile_test(1)
@profview profile_test(10)