using DifferentialEquations
using Plots

x0 = 3; y0 = 20; v0 = 10; g = 9.81
theta = 30.0 * pi/180
v0x = v0 * cos(theta) 
v0y = v0 * sin(theta)

function syst!(du,u,p,t)
    g, k, m = p
    du[1] = u[2]
    du[2] = -k/m * u[2]
    du[3] = u[4]
    du[4] = -g - k/m * u[4]
end

tmax = 3

m = 1.0

u0 = [x0, v0x, y0, v0y]
t = (0,tmax)

k = 0.0
p = [g, k, m]
aruncare1 = ODEProblem(syst!, u0, t, p)
rez1 = solve(aruncare1)

k = 0.25
p = [g, k, m]
aruncare2 = ODEProblem(syst!, u0, t, p)
rez2 = solve(aruncare2)

plot(rez1, vars=(1,3))
plot!(rez2, vars=(1,3))