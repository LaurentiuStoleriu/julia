using DifferentialEquations
using Plots

using PlotlyJS
plotlyjs()

x0 = 0; y0 = 0; z0 = 20; v0 = 10; g = 9.81; m = 1.0
theta = 30.0 * pi/180
v0x = 0.0
v0y = v0 * cos(theta) 
v0z = v0 * sin(theta)

function syst!(du,u,p,t)
    g, k, m, vv = p
    du[1] = u[2]
    du[2] = -k/m * (u[2] - vv)
    du[3] = u[4]
    du[4] = -k/m * u[4]
    du[5] = u[6]
    du[6] = -g - k/m * u[6]
end

tmax = 3

m = 1.0
vv = 5

u0 = [x0, v0x, y0, v0y, z0, v0z]
t = (0,tmax)

k = 0.0
p = [g, k, m, vv]
aruncare1 = ODEProblem(syst!, u0, t, p)
rez1 = solve(aruncare1)

k = 0.25
p = [g, k, m, vv]
aruncare2 = ODEProblem(syst!, u0, t, p)
rez2 = solve(aruncare2)

plot(rez1, vars=(1,3,5))
plot!(rez2, vars=(1,3,5))