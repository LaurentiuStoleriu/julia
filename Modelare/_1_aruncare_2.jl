using DifferentialEquations
using Plots

x0 = 3; y0 = 20; v0 = 10; g = 9.81
theta = 30.0 * pi/180
v0x = v0 * cos(theta) 
v0y = v0 * sin(theta)

function syst!(du,u,p,t)
    g = p[1]
    du[1] = u[2]
    du[2] = 0
    du[3] = u[4]
    du[4] = -g
end

tmax = 2
numpoints = 100

u0 = [x0, v0x, y0, v0y]
t = (0,tmax)
p = [g]

aruncare = ODEProblem(syst!, u0, t, p)

print(aruncare)

rez = solve(aruncare)

plot(rez, vars=(1,3))