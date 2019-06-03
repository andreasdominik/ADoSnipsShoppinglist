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
    println("[ADoSnipsShoppinglist]: action addItemAction() started.")

    # get the item(s) to add from slot:
    #
    items = parseSlots(payload)

    if (items == nothing) || (length(items) == 0)     # no Item found!
        Snips.publishEndSession(Snips.text(:dunno))
        return true
    else
        for item in items
            # println("Item: $(item[:item])")
            if isInList(item)
                Snips.publishSay("$(item[:item]) $(Snips.text(:already_there))")
            else
                Snips.publishSay("$(Snips.text(:i_add)): $(itemAsString(item))")
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
    println("[ADoSnipsShoppinglist]: action checkItemAction() started.")

    items = Snips.extractSlotValue(payload, "Item", multiple = true)

    if (items == nothing) || (length(items) == 0)     # no Item found!
        Snips.publishEndSession(TEXTS[:dunno])
        return true
    else
        for itemItem in items
            # println("Item: $itemItem)")
            i = getItemFromList(itemItem)
            if length(i) > 0
                Snips.publishSay("$(itemAsString(i)) $(Snips.text(:already_there))")
            else
                Snips.publishSay("$itemItem $(Snips.text(:not_there))")
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
    println("[ADoSnipsShoppinglist]: action readAction() started.")

    slist = readSList()

    if length(slist) == 0
        Snips.publishEndSession(Snips.text(:no_list))
    else
        Snips.publishSay(Snips.text(:the_list_reads))
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
    println("[ADoSnipsShoppinglist]: action deleteListAction() started.")

    slist = readSList()

    if length(slist) == 0
        Snips.publishEndSession(Snips.text(:no_list))
    else
        if Snips.askYesOrNo(Snips.text(:ask_delete))
            deleteCompleteList(SLIST)
            Snips.publishEndSession(Snips.text(:delete_list))
        else
            Snips.publishEndSession(Snips.text(:abort_delete))
        end
    end

    return true
end



"""
function deleteItemAction(topic, payload)

    Delete an Item from the shopping list.
"""
function deleteItemAction(topic, payload)

    # log:
    println("[ADoSnipsShoppinglist]: action deleteItemAction() started.")

    # get the item(s) to add from slot:
    #
    items = Snips.extractSlotValue(payload, SLOT_ITEM, multiple = true)

    if (items == nothing) || (length(items) == 0)     # no Item found!
        Snips.publishEndSession(Snips.text(:dunno))
        return true
    else
        for item in items
            if deleteItem(item)
                Snips.publishSay("$item $(Snips.text(:del_item))")
            else
                Snips.publishSay("$item $(Snips.text(:not_there))")
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
