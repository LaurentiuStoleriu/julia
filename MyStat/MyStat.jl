using CSV, DataFrames, Plots

fileMyStat = "/home/lali/TITAN-ROG-sync/julia/MyStat/MyStat.dat"
MyStatDF = CSV.read(fileMyStat, DataFrame; header=true, delim='\t', silencewarnings=true);
MyStatDF = coalesce.(MyStatDF, 0.0);

MyStatDF[!, "Column5"] .= MyStatDF[!, "Credits"] + MyStatDF[!, "Spent"];

kw = (; lab="", title_loc=:left)

plot(reverse(MyStatDF.Date), cumsum(reverse(MyStatDF.Column5)), xaxis="Date", xrotation=90, yaxis="Credits", color=:red; kw...)
#plot!(twinx(), reverse(MyStatDF.Date), cumsum(reverse(MyStatDF.Hours)), yaxis="Hours"; kw...)
