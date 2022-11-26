using Plots

x0 = 3; y0 = 20; v0 = 10; g = 9.81
theta = 30.0 * pi/180
v0x = v0 * cos(theta) 
v0y = v0 * sin(theta)

function trajectory(t)
    global x0, y0, v0x, v0y, g
    return[(x0 + v0x * t), (y0 + v0y*t - g*t*t/2)]
end

tmax = 2
numpoints = 100

t = range(start=0, length=numpoints, stop=tmax)
rez = trajectory.(t)

rez2D = hcat(rez...)

plot(rez2D[1,:], rez2D[2,:])