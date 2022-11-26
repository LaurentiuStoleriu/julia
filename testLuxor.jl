using Luxor

#Drawing(1000, 1000, "hello-world.png")
#origin()
#background("black")
#sethue("red")
#fontsize(50)
#text("hello world")
#finish()
#preview()

@draw begin
    setopacity(0.85)
    steps = 20
    gap   = 2
    for (n, θ) in enumerate(range(0, step=2π/steps, length=steps))
        sethue([Luxor.julia_green,
            Luxor.julia_red,
            Luxor.julia_purple,
            Luxor.julia_blue][mod1(n, 4)])
        sector(O, 50, 250 + 2n, θ, θ + 2π/steps - deg2rad(gap), :fill)
    end
end

