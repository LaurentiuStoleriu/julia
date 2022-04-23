using HTTP, Gumbo

url = "https://publons.com/researcher/1482981/l-stoleriu/publications/"

r = HTTP.request("GET", url)

r_parsed = parsehtml(String(r.body))

println(r_parsed.root[2][6])