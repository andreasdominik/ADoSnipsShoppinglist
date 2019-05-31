#
# API function goes here, to be called by the
# skill-actions:
#

function addItemToList(item)

    slist = readSList()
    push!(slist, Dict(:item => item, :amount => amount, :unit => unit))
    saveSList(slist)
end



function itemToString(item)

    strItem = item[:item]
    if haskey(item, :unit)
        if haskey(item, :quantity) && item[:quantity] > 1
            item[:unit] = makePlural(item[:unit])
        end
        strItem = "$(item[:unit]) $strItem"
    end
    if haskey(item, :quantity)
        strItem = "$(item[:quantity]) $strItem"
    end

    return strItem
end

function makePlural(s)

    plurals = Dict("Glas" => "Gläser",
                   "Schachtel" => "Schachteln",
                   "Stück" => "Stücke",
                   "Flasche" => "Flaschen",
                   "Kasten" => "Kästen",
                   "Packung" => "Packungen",
                   "Dose" => "Dosen",
                   "Tafel" => "Tafeln",
                   "Tüte" => "Tüten"  )
    if haskey(plurals, s)
        return plurals[s]
    else
        return s
    end
end
