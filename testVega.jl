using VegaLite, VegaDatasets

dataset("cars") |>
@vlplot(
    :point,
    x=:Horsepower,
    y=:Miles_per_Gallon,
    color=:Origin,
    width=400,
    height=400
)


dataset("movies") |>
@vlplot(
    width=400,
    height=100,
    :area,
    transform=[
        {density="IMDB_Rating",bandwidth=0.3,groupby=["Major_Genre"],extent=[0, 10],counts=true,steps=50}
    ],
    x={"value:q", title="IMDB Rating"},
    y= {"density:q",stack=true},
    color={"Major_Genre:n",scale={scheme=:category20}}
)

dataset("movies") |>
@vlplot(
    :rect,
    width=300, height=200,
    x={:IMDB_Rating, bin={maxbins=60}},
    y={:Rotten_Tomatoes_Rating, bin={maxbins=40}},
    color="count()",
    config={
        range={
            heatmap={
                scheme="greenblue"
            }
        },
        view={
            stroke="transparent"
        }
    }
)


@vlplot(
    width=300,
    height=150,
    data={sequence={start=0,stop=12.7,step=0.1,as="x"}},
    transform=[
        {calculate="sin(datum.x)", as="sin(x)"},
        {calculate="cos(datum.x)", as="cos(x)"},
        {fold=["sin(x)", "cos(x)"]}
    ],
    mark=:line,
    x="x:q",
    y="value:q",
    color={"key:n",title=nothing}
)

#v = dataset("windvectors")
dataset("windvectors") |>
@vlplot(
    mark={:point, shape=:wedge},
    x={"longitude:o", axis=nothing},
    y={"latitude:o", axis=nothing},
    color={"dir:q", scale={domain=[0,360], scheme=:rainbow},legend=nothing},
    angle={"dir:q", scale={domain=[0,360], range=[180, 540]}},
    size={"speed:q", scale={domain=[0,5], range=[0, 48]}},
    config={view={step=10, fill=:black}}
)


dataset("seattle-weather") |>
@vlplot(
    width=800,
    height=600,
    transform=[{
        frame=[-15,15],
        window=[{field="temp_max",op="mean",as="rolling_mean"}]
    }]
) +
@vlplot(
    mark={:point,opacity=0.3},
    x={"date:t",title="Date"},
    y={"temp_max:q",title="Max Temperature"}
) +
@vlplot(
    mark={:line,size=3,color="red"},
    x={"date:t",title="Date"},
    y={"rolling_mean:q"}
)


