#
# actions called by the main callback()
# provide one function for each intent, defined in the Snips Console.
#
# ... and link the function with the intent name as shown in config.jl
#
# The functions will be called by the main callback function with
# 2 arguments:
# * MQTT-Topic as String
# * MQTT-Payload (The JSON part) as a nested dictionary, with all keys
#   as Symbols (Julia-style)
#
"""
function addItemAction(topic, payload)

    Add an Item to the shopping list.
    Amount, unit and Item is stired if only ONE Item is in the
    intent. If more (>1 slots of type "Item"), only the Items
    are added w/o amountand unit.
"""
function addItemAction(topic, payload)

    # log:
    Snips.printLog("action addItemAction() started.")

    # get the item(s) to add from slot:
    #
    items = parseSlots(payload)

    if (items == nothing) || (length(items) == 0)     # no Item found!
        Snips.publishEndSession(:dunno)
        return true
    else
        for item in items
            # println("Item: $(item[:item])")
            if isInList(item)
                Snips.publishSay("$(item[:item]) $(Snips.langText(:already_there))")
            else
                Snips.publishSay("$(Snips.langText(:i_add)): $(itemAsString(item))")
                addItemToList(item)
            end
        end
        Snips.publishEndSession("")
    end

    return true
end


function parseSlots(payload)

    items = Dict[]

    # iterate all slots and populate items step by step:
    #
    if haskey(payload, :slots)
        item = Dict()
        for s in payload[:slots]

            if s[:slotName] == "Quantity"
                item[:quantity] = s[:value][:value]
            elseif s[:slotName] == "Unit"
                item[:unit] = s[:value][:value]
            elseif s[:slotName] == "Item"
                item[:item] = s[:value][:value]

                push!(items, deepcopy(item))
                item = Dict()
            end
        end
    end
    return items
end



"""
    checkItemAction(topic, payload)

Check, if an item is already on the list, and read the full entry.
"""
function checkItemAction(topic, payload)

    # log:
    Snips.printLog("action checkItemAction() started.")

    items = Snips.extractSlotValue(payload, "Item", multiple = true)

    if (items == nothing) || (length(items) == 0)     # no Item found!
        Snips.publishEndSession(:dunno)
        return true
    else
        for itemItem in items
            # println("Item: $itemItem)")
            i = getItemFromList(itemItem)
            if length(i) > 0
                Snips.publishSay("$(itemAsString(i)) $(Snips.langText(:already_there))")
            else
                Snips.publishSay("$itemItem $(Snips.langText(:not_there))")
            end
        end
    end
    Snips.publishEndSession("")
    return true
end


"""
    readAction(topic, payload)

Read the shopping list.
"""
function readAction(topic, payload)

    # log:
    Snips.printLog("action readAction() started.")

    slist = readSList()

    if length(slist) == 0
        Snips.publishEndSession(:no_list)
    else
        Snips.publishSay(:the_list_reads)
        for item in slist
            # println("Item: $(item[:item])")
            Snips.publishSay("$(itemAsString(item))")
        end
        Snips.publishEndSession("")
    end

    return true
end



"""
    deleteListAction(topic, payload)

Delete the complete shoppinglist.
"""
function deleteListAction(topic, payload)

    # log:
    Snips.printLog("action deleteListAction() started.")

    slist = readSList()

    if length(slist) == 0
        Snips.publishEndSession(:no_list)
    else
        if Snips.askYesOrNo(:ask_delete)
            deleteCompleteList(SLIST)
            Snips.publishEndSession(:delete_list)
        else
            Snips.publishEndSession(:abort_delete)
        end
    end

    return true
end



"""
    deleteItemAction(topic, payload)

Delete an Item from the shopping list.
"""
function deleteItemAction(topic, payload)

    # log:
    Snips.printLog("action deleteItemAction() started.")

    # get the item(s) to add from slot:
    #
    items = Snips.extractSlotValue(payload, SLOT_ITEM, multiple = true)

    if (items == nothing) || (length(items) == 0)     # no Item found!
        Snips.publishEndSession(:dunno)
        return true
    else
        for item in items
            if deleteItem(item)
                Snips.publishSay("$item $(Snips.langText(:del_item))")
            else
                Snips.publishSay("$item $(Snips.langText(:not_there))")
            end
        end
        Snips.publishEndSession("")
    end

    return true
end


function parseSlots(payload)

    items = Dict[]

    # iterate all slots and populate items step by step:
    #
    if haskey(payload, :slots)
        item = Dict()
        for s in payload[:slots]

            if s[:slotName] == "Quantity"
                item[:quantity] = s[:value][:value]
            elseif s[:slotName] == "Unit"
                item[:unit] = s[:value][:value]
            elseif s[:slotName] == "Item"
                item[:item] = s[:value][:value]

                push!(items, deepcopy(item))
                item = Dict()
            end
        end
    end
    return items
end



"""
    printListAction(topic, payload)
"""
function printListAction(topic, payload)


    if !Snips.isConfigValid(INI_PRINTER)
        Snips.publishEndSession(:no_printer)
        return true
    end
    printer = Snips.getConfig(INI_PRINTER)

    slist = readSList()
    if length(slist) == 0
        Snips.publishEndSession(:no_list)
        return false
    end

    # write temp file:
    #
    TMP_FILE = "/tmp/slist.txt"
    open(TMP_FILE, "w") do f
        println(f, "Shopping list of: $(Snips.readableDateTime(Dates.now.())))")
        println(f, " ")

        for item in slist
            println(f, itemAsString(item))
        end
    end


    if printer == nothing
        Snips.publishEndSession(:no_printer)
    else
        if printFile(TMP_FILE, printer)
            Snips.publishEndSession(:i_print)
        else
            Snips.publishEndSession("")
        end
    end
    return false
end
