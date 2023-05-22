using Printf

function twoTimesTable()
    for i = 1:3, j = 1:5
        print("($i,$j) ")
        if j == 5 println() end
    end
end # twoTimesTable

twoTimesTable()