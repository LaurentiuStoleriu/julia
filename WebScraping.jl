using HTTP, Gumbo, AbstractTrees, JSON

url = "https://publons.com/api/profile/publication/1482981/?order_by=date-published&page=1&per_page=30"

r = HTTP.request("GET", url)

r_parsed = parsehtml(String(r.body))

#println(r_parsed.root[2][6])

#for elem in StatelessBFS(r_parsed.root[2]) println((elem)) end

lista = JSON.parse(r_parsed.root[2][1].text)

#println(lista["results"][i]["journal"]["name"])

for paper in lista["results"]
    println(paper["journal"]["name"])
end