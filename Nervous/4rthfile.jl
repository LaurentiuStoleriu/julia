cd("/home/lali/TITAN-ROG-sync/julia/Nervous")
#fh = open("IPs.txt")
#myIPs = read(fh, String)
#close(fh)
#split(myIPs, '\n')

fh = open("IPs.txt")
myIPs = readlines(fh)
close(fh)

filter!(x->(x!="\t"), myIPs)

sampleline = myIPs[10]

samplechars = [x for x in sampleline]