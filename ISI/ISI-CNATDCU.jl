using CSV, DataFrames

primAuthor = "Stoleriu"
fileOwnPapers = "LS_JL_savedrecs_mine.txt"
usingPART = false
if usingPART
    fileCitations = "LS_JL_savedrecs_PART.txt"
else
    fileCitations = "LS_JL_savedrecs.txt"
end

fileOwnCSV  = "LS_JL_MINE_test.csv"
fileOwnTXT  = "LS_JL_total.txt"
fileOwnUAIC = "LS_JL_UAIC1.txt"

#root = dirname(@__FILE__)
root = dirname("/home/lali/TITAN-ROG-sync/julia/ISI/")
inputAIS = joinpath(root, "AI_factor_full_1997-2023.txt")
inputISI = joinpath(root, "IF_factor_full_1997-2023.txt")
AIFirstYear = 1997
AILastYear = 2023

ANini = 2019
ANfin = 2023

AIS = CSV.read(inputAIS, DataFrame; header=true, delim='\t')
println(AIS[8157, [1, 2, 3, 4, 5, 6,    28, 29, 30, 31]])
ISI = CSV.read(inputISI, DataFrame; header=true, delim='\t')
println(ISI[8157, [1, 2, 3, 4, 5, 6,    28, 29, 30, 31]])

inputMINE = joinpath(root, fileOwnPapers)
inputCIT = joinpath(root, fileCitations)

MINEraw = CSV.read(inputMINE, DataFrame; header=true, delim='\t')
sort!(MINEraw, [:PY], rev = true)
#eltype.(eachcol(MINEraw))
#MINE = MINEraw[:, [2, 9, 24, 30, 32, 42, 45, 46, 47, 52, 53, 54, 55]];
MINE = MINEraw[:, [2, 9, 25, 33, 44, 47, 48, 54, 55, 56, 57]];  # fara citari (col 30)
#println(eltype.(eachcol(MINE)))

rename!(MINE,:"J9" => :"Journal")
insertcols!(MINE, :NA => 0);
insertcols!(MINE, :NEFF => 0.0);
insertcols!(MINE, :PRIM => 0);
insertcols!(MINE, :AI => 0.0);
insertcols!(MINE, :AINEFF => 0.0);
insertcols!(MINE, :IF => 0.0);
insertcols!(MINE, :IFNA => 0.0);
insertcols!(MINE, :TIMESC => 0);
insertcols!(MINE, :CT => 0.0);
### 5 ani
insertcols!(MINE, :PRIM5 => 0);
insertcols!(MINE, :AINEFF5 => 0.0);
insertcols!(MINE, :IFNA5 => 0.0);
insertcols!(MINE, :TIMESC5 => 0);
insertcols!(MINE, :CT5 => 0.0);
### UAIC
insertcols!(MINE, :UAIC1 => 0.0);
insertcols!(MINE, :UAIC9 => 0.0);

for (row_index, lucrare) in enumerate(eachrow(MINE))
    MINE[row_index, :NA] = (1+count(";", lucrare[:AU]))

    if MINE[row_index, :NA] <= 5
        MINE[row_index, :NEFF] = MINE[row_index, :NA]
    elseif MINE[row_index, :NA] <= 15
        MINE[row_index, :NEFF] = (MINE[row_index, :NA] + 5.0) / 2.0
    elseif MINE[row_index, :NA] <= 75
        MINE[row_index, :NEFF] = (MINE[row_index, :NA] + 15.0) / 3.0
    else
        MINE[row_index, :NEFF] = (MINE[row_index, :NA] + 45.0) / 4.0
    end

    #println( titlecase(MINE[row_index, :AU]))
    #println(findfirst(primAuthor, titlecase(MINE[row_index, :AU]))[1])
    if findfirst(primAuthor, titlecase(MINE[row_index, :AU]))[1] == 1
        MINE[row_index, :PRIM] = 1
        if (MINE[row_index, :PY] <= ANfin) && (MINE[row_index, :PY] >= ANini)
            MINE[row_index, :PRIM5] = 1
        end
    elseif !ismissing(lucrare[:RP])
        if occursin(primAuthor, lucrare[:RP])
            MINE[row_index, :PRIM] = 1
            if (MINE[row_index, :PY] <= ANfin) && (MINE[row_index, :PY] >= ANini)
                MINE[row_index, :PRIM5] = 1
            end
        end
    end
    #println(row_index, MINE[row_index, [:NA]])
    #println(row_index, MINE[row_index, [:PRIM]])
end

MINE.PY = Int64.(MINE.PY)
MINE[ismissing.(MINE[!, :PY]), [1, 6, 7, 8, 12, 14, 15, 16, 17]]

AISsubsect = filter(r -> any(occursin.(Vector(MINE[1, [:Journal]]), r.Journal)), AIS)
size(AISsubsect, 1)

for (row_index, lucrare) in enumerate(eachrow(MINE))
    #lucrare = MINE[1, :]
    if(ismissing(lucrare[:Journal]))
        continue
    end
    for AISrow in eachrow(AIS)
        if( lucrare[:Journal] == AISrow[:Journal] )
            if (lucrare[:PY] >= AIFirstYear)
                anString = string(lucrare[:PY])
            else
                anString = string(AIFirstYear)
            end
            if (lucrare[:PY] > AILastYear)
                anString = string(AILastYear)
            end
            #println(AISrow[anString])
            MINE[row_index, :AI] = AISrow[anString]
            MINE[row_index, :AINEFF] = MINE[row_index, :AI] / MINE[row_index, :NEFF]
            if (MINE[row_index, :PY] <= ANfin) && (MINE[row_index, :PY] >= ANini)
                MINE[row_index, :AINEFF5] = MINE[row_index, :AINEFF]
            end
            
        end
    end
    for ISIrow in eachrow(ISI)
        if( lucrare[:Journal] == ISIrow[:Journal] )
            if (lucrare[:PY] >= AIFirstYear)
                anString = string(lucrare[:PY])
            else
                anString = string(AIFirstYear)
            end
            if (lucrare[:PY] > AILastYear)
                anString = string(AILastYear)
            end
            #println(ISIrow[anString])
            MINE[row_index, :IF] = ISIrow[anString]
            MINE[row_index, :IFNA] = ISIrow[anString] / MINE[row_index, :NA]
            if (MINE[row_index, :PY] <= ANfin) && (MINE[row_index, :PY] >= ANini)
                MINE[row_index, :IFNA5] = MINE[row_index, :IFNA]
                MINE[row_index, :UAIC1] = (25 + 60*MINE[row_index, :IF]) / MINE[row_index, :NA]
            end
        end
    end
end

I = sum(MINE[!, :AINEFF])
P = sum(MINE[!, :PRIM] .* MINE[!, :AI])

I5 = sum(MINE[!, :AINEFF5])
P5 = sum(MINE[!, :PRIM5] .* MINE[!, :AI])

UAIC_1_1 = sum(MINE[!, :UAIC1])

#   PT	AU	BA	BE	GP	AF	BF	CA	TI	SO	SE	BS	LA	DT	CT	CY	CL	SP	HO	DE	ID	AB	C1	
#   1   2   3   4   5   6   7   8   9   10  11  12  13  14  15  16  17  18  19  20  21  22  23  

#   C3	RP	EM	RI	OI	FU	FP	FX	CR	NR	TC	Z9	U1	U2	PU	PI	PA	SN	EI	BN	J9	JI	PD	
#   24  25  26  27  28  29  30  31  32  33  34  35  36  37  38  39  40  41  42  43  44  45  46  

#   PY	VL	IS	PN	SU	SI	MA	BP	EP	AR	DI	DL	D2	EA	PG	WC	WE	SC	GA	PM	OA	HC	HP	DA	UT
#   47  48  49  50  51  52  53  54  55  56  57  58  59  60  61  62  63  64  65  66  67  68  69  70  71

#   ######  2   9   32  44  46  47  48  54  55  56  57
#   ######  AU  TI  CR  J9  PD  PY  VL  BP  EP  AR  DI



MINECITEraw = CSV.read(inputCIT, DataFrame; header=true, delim='\t');
# eliminare autocitari
MINECITEraw = filter(row -> !(occursin(primAuthor, row.AU)),  MINECITEraw);
for (row_indexCIT, lucrareCIT) in enumerate(eachrow(MINECITEraw))
    if( occursin(primAuthor, lucrareCIT.AU) )
        println(lucrareCIT.AU)
    end
end


#MINECITE = MINECITEraw[:, [2, 9, 31, 43, 45, 46, 47, 53, 54, 55, 56]];


if usingPART
    ## DEJA SELECTATE COLOANELE in fisierul _PART
    MINECITE = MINECITEraw
else
    MINECITE = MINECITEraw[:, [2, 9, 32, 44, 46, 47, 48, 54, 55, 56, 57]];
end
eltype.(eachcol(MINECITE));
rename!(MINECITE,:"J9" => :"Journal");

CITES = Vector{Int64}[];
CITES_IFs = Vector{Float64}[];
CITES5 = Vector{Int64}[];
CITES5_IFs = Vector{Float64}[];
for i in 1:size(MINE)[1]
    push!(CITES, [0])
    push!(CITES_IFs, [0.0])
    push!(CITES5, [0])
    push!(CITES5_IFs, [0.0])
end

for (row_indexMINE, lucrareMINE) in enumerate(eachrow(MINE))
    calcul_cit_UAIC = 0.0
    if ( ismissing(lucrareMINE[:DI]) )
        #println("Skip paper $row_indexMINE noDOI")
        continue
    end
    #println("Analyzing paper ", lucrareMINE[:DI])
    for (row_indexCIT, lucrareCIT) in enumerate(eachrow(MINECITE))
        if ( occursin(lucrareMINE[:DI], lucrareCIT[:CR]) )
            #println("Paper $row_indexMINE cited by $row_indexCIT")
            ISI_value = 0.0
            push!(CITES[row_indexMINE], row_indexCIT)
            push!(CITES_IFs[row_indexMINE], ISI_value)
            if (( !ismissing(lucrareCIT[:PY]) ) && ( !ismissing(lucrareCIT[:Journal]) ))
                for ISIrow in eachrow(ISI)
                    if( lucrareCIT[:Journal] == ISIrow[:Journal] )
                        an_publicare_citare = lucrareCIT[:PY]
                        if (an_publicare_citare > AILastYear)
                            an_publicare_citare = AILastYear
                        end
                        if (an_publicare_citare < AIFirstYear)
                            an_publicare_citare = AIFirstYear
                        end
                        ISI_value = ISIrow[string(an_publicare_citare)]
                        push!(CITES_IFs[row_indexMINE], ISI_value)
                        #CITES_IFs[row_indexMINE, size(CITES_IFs[row_indexMINE])] = ISI_value
                        break
                    end
                end
                if (lucrareCIT[:PY] <= ANfin) && (lucrareCIT[:PY] >= ANini)
                    push!(CITES5[row_indexMINE], row_indexCIT)
                    push!(CITES5_IFs[row_indexMINE], ISI_value)
                    calcul_cit_UAIC = calcul_cit_UAIC + (10 + 20 * ISI_value) / lucrareMINE[:NA]
                end
            end
        end
    end
    MINE[row_indexMINE, :TIMESC] = size(CITES[row_indexMINE])[1]-1
    MINE[row_indexMINE, :CT] = MINE[row_indexMINE, :TIMESC] / MINE[row_indexMINE, :NEFF]
    MINE[row_indexMINE, :TIMESC5] = size(CITES5[row_indexMINE])[1]-1
    MINE[row_indexMINE, :CT5] = MINE[row_indexMINE, :TIMESC5] / MINE[row_indexMINE, :NEFF]
    MINE[row_indexMINE, :UAIC9] = calcul_cit_UAIC
end

C = sum(MINE[!, :CT])
C5 = sum(MINE[!, :CT5])
println("I = ", I, " \tP = ", P, " \tC = ", C)
println("I5 = ", I5, " \tP5 = ", P5, " \tC5 = ", C5)

UAIC_1_9 = sum(MINE[!, :UAIC9])

outputMINEcsv = joinpath(root, fileOwnCSV)
CSV.write(outputMINEcsv, MINE)

using Printf
outputMINEtxt = joinpath(root, fileOwnUAIC)
open(outputMINEtxt, "w") do file
    for (row_indexMINE, lucrareMINE) in enumerate(eachrow(MINE))
        if ( !ismissing(lucrareMINE.BP) )
            write(file, "[$row_indexMINE] \t $(lucrareMINE.AU); $(lucrareMINE.TI); $(lucrareMINE.Journal), vol.$(lucrareMINE.VL), pp.$(lucrareMINE.BP)-$(lucrareMINE.EP) ($(lucrareMINE.PY)), DOI:$(lucrareMINE.DI) \n")
        else
            write(file, "[$row_indexMINE] \t $(lucrareMINE.AU); $(lucrareMINE.TI); $(lucrareMINE.Journal), vol.$(lucrareMINE.VL), art.no.$(lucrareMINE.AR) ($(lucrareMINE.PY)), DOI:$(lucrareMINE.DI) \n")
        end
        contor = 1
        for (idx_citare, citare) in enumerate(CITES5[row_indexMINE])
            if (citare == 0)
                continue
            end
            write(file, "\t\t[$row_indexMINE.$contor] $(MINECITE[citare,:].AU); $(MINECITE[citare,:].TI); $(MINECITE[citare,:].Journal), vol.$(MINECITE[citare,:].VL) ($(MINECITE[citare,:].PY)), DOI:$(MINECITE[citare,:].DI) \n")
            write(file, "\t\t\tIF citare: $(CITES5_IFs[row_indexMINE][idx_citare])\n")
            contor = contor + 1
        end
        write(file, "nr.autori: $(lucrareMINE.NA) \t\t IF: $(lucrareMINE.IF) \t\t UAIC I.1(ISI): $(@sprintf("%8.4f", lucrareMINE.UAIC1)) \t\t nr.citari: $(lucrareMINE.TIMESC5) \t\t UAIC I.9(Citari): $(@sprintf("%9.4f", lucrareMINE.UAIC9)) \n")
        write(file, '-'^400, '\n')
    end
    write(file, '-'^400, '\n')
    write(file, '-'^400, '\n')
    write(file, "Total criteriul I.1(UAIC) = $(@sprintf("%9.4f", UAIC_1_1))\t\t\tTotal criteriul I.9(UAIC) = $(@sprintf("%9.4f", UAIC_1_9))")
end

outputMINEtxt = joinpath(root, fileOwnTXT)
open(outputMINEtxt, "w") do file
    for (row_indexMINE, lucrareMINE) in enumerate(eachrow(MINE))
        if ( !ismissing(lucrareMINE.BP) )
            write(file, "[$row_indexMINE] \t $(lucrareMINE.AU); $(lucrareMINE.TI); $(lucrareMINE.Journal), vol.$(lucrareMINE.VL), pp.$(lucrareMINE.BP)-$(lucrareMINE.EP) ($(lucrareMINE.PY)), DOI:$(lucrareMINE.DI) \n")
        else
            write(file, "[$row_indexMINE] \t $(lucrareMINE.AU); $(lucrareMINE.TI); $(lucrareMINE.Journal), vol.$(lucrareMINE.VL), art.no.$(lucrareMINE.AR) ($(lucrareMINE.PY)), DOI:$(lucrareMINE.DI) \n")
        end
        contor = 1
        for (idx_citare, citare) in enumerate(CITES[row_indexMINE])
            if (citare == 0)
                continue
            end
            write(file, "\t\t[$row_indexMINE.$contor] $(MINECITE[citare,:].AU); $(MINECITE[citare,:].TI); $(MINECITE[citare,:].Journal), vol.$(MINECITE[citare,:].VL) ($(MINECITE[citare,:].PY)), DOI:$(MINECITE[citare,:].DI) \n")
            #write(file, "\t\t\tIF citare: $(CITES5_IFs[row_indexMINE][idx_citare])\n")
            contor = contor + 1
        end
        write(file, "autori=$(lucrareMINE.NA) \t autori_eff=$(lucrareMINE.NEFF) \t AIS=$(lucrareMINE.AI) \t prim=$(@sprintf("%5.3f", lucrareMINE.PRIM)) \t inf=$(@sprintf("%5.3f", lucrareMINE.AINEFF)) \t citari=$(lucrareMINE.TIMESC) \t cit=$(@sprintf("%5.3f", lucrareMINE.CT)) \n")
        write(file, '-'^400, '\n')
    end
    write(file, '*'^120, '\n')
    write(file, "P = $(@sprintf("%9.4f", P)) \t\t\t I = $(@sprintf("%9.4f", I)) \t\t\t C = $(@sprintf("%9.4f", C)) \n")
    write(file, '*'^120, '\n')
end