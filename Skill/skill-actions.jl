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
    items = Snips.extractSlotValue(payload, SLOT_ITEM, multiple = true)

    if items == nothing     # no Item found!
        Snips.publishEndSession(TEXTS[:dunno])
        return true
    else if items isa AbstractString    # only one item found!
        unit = Snips.extractSlotValue(payload, SLOT_UNIT, multiple = false)
        amount = Snips.extractSlotValue(payload, SLOT_AMOUNT, multiple = false)

        if (unit != nothing) && (amount != nothing)
            Snips.publishEndSession("$(TEXETS[:i_add] $amount $unit $items)"
            addOneItem(amount, unit, items)
        else
            Snips.publishEndSession("$(TEXETS[:i_add] $items)"
            addOneItem(items)
        end
        return true
    else                      # > 1 items found!
        Snips.publishEndSession("$(TEXETS[:i_add]) $(join(items, ", "))")
        addItems(items)
    end

    return true
end
