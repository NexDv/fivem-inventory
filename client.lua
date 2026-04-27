print("Client script initialized")

RegisterCommand("buy", function(source, args)
    local itemName = args[1]

    if not itemName then
        print("Command: /buy [item]")
        return
    end

    TriggerServerEvent("shop:buyItem", itemName)
end)

RegisterCommand("use", function(source, args)
    local itemName = args[1]

    if not itemName then
        print("Command: /use [item]")
        return
    end

    TriggerServerEvent("inventory:useItem", itemName)
end)

RegisterNetEvent("notify")
AddEventHandler("notify", function(message)
    print(message)
end)

RegisterNetEvent("inventory:open")
AddEventHandler("inventory:open", function(items)
    SendNUIMessage({
        type = "open",
        items = items
    })
end)

local inventoryOpen = false

RegisterCommand("toggleinv", function()
    inventoryOpen = not inventoryOpen

    if inventoryOpen then
        SetNuiFocus(true, true)

        TriggerServerEvent("inventory:requestOpen")
    else
        SetNuiFocus(false, false)

        SendNUIMessage({
            type = "close"
        })
    end
end, false)

RegisterKeyMapping("toggleinv", "Open Inventory", "keyboard", "i")

RegisterNUICallback("close", function(data, cb)
    SetNuiFocus(false, false)

    inventoryOpen = false

    SendNUIMessage({
        type = "close"
    })

    cb("ok")
end)

RegisterNUICallback("useItem", function(data, cb)
    local itemName = data.item
    local index = data.index
    if itemName then
        TriggerServerEvent("inventory:useItem", itemName, index)
    end


    cb("ok")
end)