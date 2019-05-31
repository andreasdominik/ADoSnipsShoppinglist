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
    items = Snips.parseSlots(payload)

    if (items == nothing) || (length(items) < 1)     # no Item found!
        Snips.publishEndSession(TEXTS[:dunno])
        return true
    else
        for item in items
            if isInList(item)
                say("$(item[:item]) $(TESTS[:alredy_there])")
            else
                say("$(TESTS[:i_add]): $(itemAsString(item))")
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

            if s[:slotName] == "Amount"
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
