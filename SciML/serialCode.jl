using StaticArrays, BenchmarkTools
A = rand(100,100)
B = rand(100,100)
C = rand(100,100)
function static_inner_alloc!(C,A,B)
  for j in 1:100, i in 1:100
    val = @SVector [A[i,j] + B[i,j]]
    C[i,j] = val[1]
  end
end
@btime static_inner_alloc!(C,A,B)