print("Server script initialized")

local Items = {
    ak47 = {
        price = 2500,
        type = "weapon",
        stackable = false,

    },
    drug = {
        price = 350,
        maxStack = 5,
        type = "consumable",
        effect = "heal",
        stackable = true,
    }
}

local playerData = {
    money = 50000,
    inventory = {}
}

local function addMoney(playerID, amount)
    if playerID and playerData[playerID].money then
        if amount > 0 then
            playerData[playerID].money += amount
            print("Player got $" .. amount)
            print("Updated amount of money: " .. playerData[playerID].money)
        else
            print("Money must be positive")
        end
    else
        print("Player does not exit or has not money initialized")
    end
end

local function removeMoney(playerID, amount)
    if playerID and playerData[playerID].money then
        if amount > 0 then
            playerData[playerID].money -= amount
            playerData[playerID].money = math.max(0,playerData[playerID].money)
            print("Player lost $" .. amount)
            print("Updated amount of money: " .. playerData[playerID].money)
        else
            print("Money must be positive")
        end
    else
        print("Player does not exit or has not money initialized")
    end
end

local function addItem(playerID, itemName)
    local inventory = playerData[playerID].inventory

    if not inventory then return end

    local itemData = Items[itemName]
    if not itemData then
        print("Invalid Item")
        return
    end

    -- Not stackable
    if not itemData.stackable then
        table.insert(inventory, {
            name = itemName,
            amount = 1
        })
        return
    end

    -- Search stack
    for _, item in pairs(inventory) do
        if item.name == itemName and (item.amount or 1) < itemData.maxStack then
            item.amount = (item.amount or 1) + 1
            return
        end
    end

    -- Create new stack
    table.insert(inventory, {
        name = itemName,
        amount = 1
    })
end

RegisterCommand("add", function(source, args)
    local amount = tonumber(args[1])
    addMoney(source, amount)
end)

RegisterCommand("remove", function(source, args)
    local amount = tonumber(args[1])
    removeMoney(source, amount)
end)

RegisterCommand("inv", function(source)
    local playerID = GetPlayerIdentifierByType(source, "license")
    local inventory = playerData[playerID].inventory

    if not inventory then print ("Inventory not initialized") return end

    print("====================")
    print(" INVENTORY || MONEY: " .. playerData[playerID].money)
    print("====================")

    if #inventory == 0 then print("Empty Inventory")
        else
    	    for i, item in ipairs(inventory) do
			    print(i .. ". " .. item.name .. " x" .. item.amount)
		    end
    end

end)

RegisterCommand("init", function (source)
    local playerID = GetPlayerIdentifierByType(source, "license")
    playerData[playerID] = {
    money = 50000,
    inventory = {}
}

end)

RegisterNetEvent("inventory:requestOpen")
AddEventHandler("inventory:requestOpen", function()
    local playerID = GetPlayerIdentifierByType(source, "license")
    local inventory = playerData[playerID].inventory

    if not inventory then return end

    TriggerClientEvent("inventory:open", source, inventory)
end)


AddEventHandler('playerJoining', function()
    local playerID = GetPlayerIdentifierByType(source, "license")
    local result = MySQL.query.await("SELECT * FROM players WHERE identifier = ?", {playerID})
    print("PLAYER JOINING: " .. playerID)

    if #result == 0 then
        playerData[playerID] = {
            money = 50000,
            inventory = {}
        }
        MySQL.query.await("INSERT INTO players (identifier, money, inventory) VALUES (?, ?, ?)", {playerID, playerData[playerID].money, json.encode(playerData[playerID].inventory)})
    else
        playerData[playerID].money = result[1].money
        playerData[playerID].inventory = json.decode(result[1].inventory)
    end
end)

AddEventHandler('playerDropped', function()
    local playerID = GetPlayerIdentifierByType(source, "license")
    print("PLAYER DISCONNECTING: " .. playerID)

    if not playerData[playerID].money or not playerData[playerID].inventory then return end


    MySQL.query.await("UPDATE players SET money = ?, inventory = ? WHERE identifier = ?", {playerData[playerID].money, json.encode(playerData[playerID].inventory), playerID})
    playerData[playerID].money = nil
    playerData[playerID].inventory = nil
end)

RegisterNetEvent("shop:buyItem")
AddEventHandler("shop:buyItem", function(itemName)
    local src = source
    local playerID = GetPlayerIdentifierByType(source, "license")

    if not itemName then
        TriggerClientEvent("notify", src, "Invalid Item")
        return
    end

    if not Items[itemName] then
        TriggerClientEvent("notify", src, "Non existent Item")
        return
    end

    if not playerData[playerID].money then
        print("Player with money not initialized")
        return
    end

    local price = Items[itemName].price

    if playerData[playerID].money < price then
        TriggerClientEvent("notify", src, "You do not have enough money")
        return
    end

    removeMoney(playerID, price)
    addItem(playerID, itemName)
    TriggerClientEvent("notify", src, "You have bought " .. itemName .. " for $" .. price)
    TriggerClientEvent("notify", src, "Current balance: " .. playerData[playerID].money)
end)

RegisterNetEvent("inventory:useItem")
AddEventHandler("inventory:useItem", function(itemName, index)
    local src = source
    local itemData = Items[itemName]
    local playerID = GetPlayerIdentifierByType(source, "license")
    local inventory = playerData[playerID].inventory

    if not itemData then
        TriggerClientEvent("notify", src, "Invalid Item")
        return
    end

    if not inventory then
        print("The player has no inventory initialized")
        return
    end

    local invItem = inventory[index + 1]

	if not invItem then
        TriggerClientEvent("notify", src, "You do not have that Item")
		return
	end

    if itemData.type == "consumable" then
        if itemData.effect == "heal" then
            TriggerClientEvent("notify", src, "You have healed 50HP")
		end

		print("Usaste " .. itemName)

		invItem.amount = invItem.amount - 1

		if invItem.amount <= 0 then
			table.remove(inventory, index + 1)
		end

        TriggerClientEvent("inventory:open", src, inventory)

		return
    end

	if itemData.type == "weapon" then
        TriggerClientEvent("notify", src, "You equipped ".. itemName)
	end


end)