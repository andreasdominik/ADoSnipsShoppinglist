#
# API function goes here, to be called by the
# skill-actions:
#

function addItemToList(item)

    slist = readSList()

    if length(slist) == 0
        Snips.publishSay(:new_list)
    end
    push!(slist, item)
    saveSList(slist)
end


function isInList(item)

    slist = readSList()
    alreadyThere = false

    for i in slist
        if uppercase(i[:item]) == uppercase(item[:item])
            alreadyThere = true
        end
    end
    return alreadyThere
end


function itemAsString(item)

    strItem = "$(item[:item])"
    if haskey(item, :unit)
        if haskey(item, :quantity) && item[:quantity] > 1
            strItem = "$(makePlural(item[:unit])) $strItem"
        else
           strItem = "$(item[:unit]) $strItem"
        end
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
                   "Tube" => "Tuben",
                   "Tüte" => "Tüten"  )
    if haskey(plurals, s)
        return plurals[s]
    else
        return s
    end
end

function readSList()

    slist = Snips.tryParseJSONfile(SLIST, quiet = true)
    if length(slist) == 0
        slist = Any[]
    end
    return slist
end

function saveSList(slist)

    open(SLIST, "w") do f
        JSON.print(f, slist, 2)
    end
end


"""
item is ONLY the name of the item! NOT the Dict
"""
function getItemFromList(itemItem)

    fromList = Dict()
    slist = readSList()
    if length(slist) > 0
        for i in slist
            if uppercase(i[:item]) == uppercase(itemItem)
                fromList = deepcopy(i)
            end
        end
    end
    return fromList
end



function deleteCompleteList(fname)

    # delete w/o careing...
    #
    try
        rm(fname)
    catch
        println("error deleting shopping list")
    end
end


function deleteItem(itemItem)

    slist = readSList()
    newList = Any[]
    deleted = false   # becomes true, if an item is deleted...

    for i in slist
        if uppercase(i[:item]) != uppercase(itemItem)
            push!(newList, deepcopy(i))
        else
            deleted = true
        end
    end

    # deleteCompleteList(SLIST)
    saveSList(newList)
    return deleted
end



function printFile(fname, printer)

    Snips.tryrun(`lp -d $printer $fname`, errorMsg = :error_printer)
    return true
end
