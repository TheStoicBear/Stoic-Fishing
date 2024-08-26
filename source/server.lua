local fishData = {}

function GetRandomFishType(location)
    local fishTypes = Config.WaterTypes[location] and Config.WaterTypes[location].FishTypes or {}
    return fishTypes[math.random(#fishTypes)].name
end

function GetFishSellPrice(fishType, location)
    local waterType = Config.WaterTypes[location]
    if waterType and waterType.FishTypes then
        for _, fish in pairs(waterType.FishTypes) do
            if fish.name == fishType then
                return fish.price or 0
            end
        end
    end
    return 0
end

function StoreFishData(playerId, fishType, fishCount, sellPrice)
    local key = "fish_data_" .. playerId

    -- Load existing fish data or initialize an empty table
    local playerFishData = fishData[playerId] or {}

    -- Add the new fish data to the table
    table.insert(playerFishData, { type = fishType, count = fishCount, price = sellPrice })

    -- Save the entire array in KVP
    SetResourceKvp(key, json.encode(playerFishData))

    -- Update the global fishData table
    fishData[playerId] = playerFishData
end

function GetFishData(playerId)
    local key = "fish_data_" .. playerId

    -- Load fish data from KVP
    local encodedData = GetResourceKvpString(key)

    -- Decode JSON data
    local playerFishData = encodedData and json.decode(encodedData) or {}

    return playerFishData
end

function RemoveSoldFish(playerId)
    local key = "fish_data_" .. playerId

    -- Clear fish-related data from KVP
    SetResourceKvp(key, "")

    -- Remove the data from the global table
    fishData[playerId] = nil
end

RegisterServerEvent('fish:startFishing')
AddEventHandler('fish:startFishing', function(locationName)
    local source = source
    local player = exports.money:getaccount(source)  -- Use the money export to get the player's account

    if player then
        local fishType = GetRandomFishType(locationName)
        local fishCount = math.random(1, 5)
        local sellPrice = GetFishSellPrice(fishType, locationName)

        -- Store fishing data
        StoreFishData(source, fishType, fishCount, sellPrice)

        if Config.DebugMode then
            print("Player " .. source .. " started fishing at " .. locationName .. ". Fish type: " .. fishType .. ", Count: " .. fishCount .. ", Price: " .. sellPrice)
        end

        TriggerClientEvent('fish:catchFish', source, { type = fishType, count = fishCount, price = sellPrice })
        TriggerClientEvent('fish:fishingStarted', source)
    end
end)

RegisterServerEvent('fish:sellFish')
AddEventHandler('fish:sellFish', function()
    local source = source
    local player = exports.money:getaccount(source)  -- Use the money export to get the player's account

    if player then
        local playerFishData = GetFishData(source)

        if #playerFishData > 0 then
            local earnedMoney = 0

            -- Loop through each fish entry and calculate total earnings
            for _, fishEntry in pairs(playerFishData) do
                earnedMoney = earnedMoney + (fishEntry.price * fishEntry.count)
            end

            -- Update the player's bank account with the earnings
            local success = exports.money:updateaccount(source, { cash = player.amount, bank = player.bank + earnedMoney })

            if success then
                -- Remove the sold fish data
                RemoveSoldFish(source)

                if Config.DebugMode then
                    print("Player " .. source .. " sold fish. Earned money: $" .. earnedMoney)
                end

                TriggerClientEvent('fish:sellSuccess', source, earnedMoney)
            else
                -- Error updating money
                print("Error adding money to player " .. source)
            end
        else
            -- No fish data to sell
            TriggerClientEvent('fish:sellFailure', source)
        end
    end
end)
