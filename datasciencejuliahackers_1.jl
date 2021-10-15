
begin
    using Plots
    sequence = [0, 1, 1, 2, 3, 5, 8, 13, 21, 34]
    plot(sequence, xlabel="x", ylabel="Fibonacci", linewidth=3, label=false, color="green", size=(450, 300))
    scatter!(sequence, xlabel="n", ylabel="Fibonacci(n)", color="purple", label=false, size=(450, 300))
end