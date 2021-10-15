using Random
using Plots

x_axis = x_axis = [1:1:25;]
y_axis = rand(0:100, 25)
l2 = rand(100:200 , 25)

# Line Chart
plot(x_axis , y_axis, lw = 2 , label = "First" , title = "Simple Line Chart" , color = "indianred")

# Adding Marker
scatter!(l2 , color = "black", markersize=3 , label = "")

# x and y labels
xlabel!("X axis")
ylabel!("Y axis")

# Extra Line
plot!(x_axis , l2 , label = "Second" , color = "cyan")

##############################################

x_axis = ["x","y","z","k"]
y_axis = [1204,652,978,4622]

bar(x_axis , y_axis , bar_width=0.3 , title = "Company Compare Chart" , color = "purple" , legend=:topleft)

xlabel!("Companies")
ylabel!("Sales by Month")


##############################################

