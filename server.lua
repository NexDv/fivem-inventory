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

local playerInventory = {}
local playerMoney = {}

local function addMoney(playerID, amount)
    if playerID and playerMoney[playerID] then
        if amount > 0 then
            playerMoney[playerID] += amount
            print("Player got $" .. amount)
            print("Updated amount of money: " .. playerMoney[playerID])
        else
            print("Money must be positive")
        end
    else
        print("Player does not exit or has not money initialized")
    end
end

local function removeMoney(playerID, amount)
    if playerID and playerMoney[playerID] then
        if amount > 0 then
            playerMoney[playerID] -= amount
            playerMoney[playerID] = math.max(0,playerMoney[playerID])
            print("Player lost $" .. amount)
            print("Updated amount of money: " .. playerMoney[playerID])
        else
            print("Money must be positive")
        end
    else
        print("Player does not exit or has not money initialized")
    end
end

local function addItem(playerID, itemName)
    local inventory = playerInventory[playerID]

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
    local inventory = playerInventory[playerID]

    if not inventory then print ("Inventory not initialized") return end

    print("====================")
    print(" INVENTORY || MONEY: " .. playerMoney[playerID])
    print("====================")

    if #inventory == 0 then print("Empty Inventory")
        else
    	    for i, item in ipairs(inventory) do
			    print(i .. ". " .. item.name .. " x" .. item.amount)
		    end
    end

end)

RegisterNetEvent("inventory:requestOpen")
AddEventHandler("inventory:requestOpen", function()
    local playerID = GetPlayerIdentifierByType(source, "license")
    local inventory = playerInventory[playerID]

    if not inventory then return end

    TriggerClientEvent("inventory:open", source, inventory)
end)


AddEventHandler('playerJoining', function()
    local playerID = GetPlayerIdentifierByType(source, "license")
    local result = MySQL.query.await("SELECT * FROM players WHERE identifier = ?", {playerID})
    print("PLAYER JOINING: " .. playerID)

    if #result == 0 then
        playerMoney[playerID] = 50000
        playerInventory[playerID] = {}
        MySQL.query.await("INSERT INTO players (identifier, money, inventory) VALUES (?, ?, ?)", {playerID, playerMoney[playerID], json.encode(playerInventory[playerID])})
    else
        playerMoney[playerID] = result[1].money
        playerInventory[playerID] = json.decode(result[1].inventory)
    end
end)

AddEventHandler('playerDropped', function()
    local playerID = GetPlayerIdentifierByType(source, "license")
    print("PLAYER DISCONNECTING: " .. playerID)

    if not playerMoney[playerID] then return end


    MySQL.query.await("UPDATE players SET money = ?, inventory = ? WHERE identifier = ?", {playerMoney[playerID], json.encode(playerInventory[playerID]), playerID})
    playerMoney[playerID] = nil
    playerInventory[playerID] = nil
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

    if not playerMoney[playerID] then
        print("Player with money not initialized")
        return
    end

    local price = Items[itemName].price

    if playerMoney[playerID] < price then
        TriggerClientEvent("notify", src, "You do not have enough money")
        return
    end

    removeMoney(playerID, price)
    addItem(playerID, itemName)
    TriggerClientEvent("notify", src, "You have bought " .. itemName .. " for $" .. price)
    TriggerClientEvent("notify", src, "Current balance: " .. playerMoney[playerID])
end)

RegisterNetEvent("inventory:useItem")
AddEventHandler("inventory:useItem", function(itemName, index)
    local src = source
    local itemData = Items[itemName]
    local playerID = GetPlayerIdentifierByType(source, "license")
    local inventory = playerInventory[playerID]

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