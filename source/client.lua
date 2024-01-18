local caughtFish = {}
local fishingBlips = {}
local sellNpcBlips = {}
local sellNpcHelpText = "Press [E] to sell your fish."

local isFishing = false
local hasPressedKey = false
local fishingTimer = 0
local isFishingAnimationPlaying = false
local fishingFinished = false
local hasStartedFishingNotification = false
local hasSellFishNotification = false
local fishingPoleEntity = nil
local sellNpcs = {}

local hasEnteredFishingZone = false
local hasEnteredSellZone = {}
local isFishingAnimationPlaying = false

function CreateFishingBlip(location)
    local blip = AddBlipForCoord(location.coords)

    SetBlipSprite(blip, 356)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 0.8)
    SetBlipColour(blip, 69)
    SetBlipAsShortRange(blip, true)

    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Fishing Spot")
    EndTextCommandSetBlipName(blip)

    return blip
end

function CreateSellNpcBlips(coordsList)
    local blips = {}

    for i, coords in pairs(coordsList) do
        local blip = AddBlipForCoord(coords.coords)

        SetBlipSprite(blip, 311)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, 0.8)
        SetBlipColour(blip, 69)
        SetBlipAsShortRange(blip, true)

        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Sell Fish")
        EndTextCommandSetBlipName(blip)

        table.insert(blips, blip)
        hasEnteredSellZone[i] = false
    end

    return blips
end

function CreateSellNpcs(coordsList)
    local npcs = {}

    for _, coords in pairs(coordsList) do
        RequestModel("a_m_m_hillbilly_01")
        while not HasModelLoaded("a_m_m_hillbilly_01") do
            Wait(500)
        end

        local ped = CreatePed(4, "a_m_m_hillbilly_01", coords.coords.x, coords.coords.y, coords.coords.z - 1.0, coords.heading, false, true)

        SetEntityInvincible(ped, true)
        SetEntityHasGravity(ped, true)
        SetEntityCanBeDamaged(ped, false)
        SetEntityCollision(ped, true, true)

        FreezeEntityPosition(ped, true)

        table.insert(npcs, ped)
    end

    return npcs
end

function CreateBlips()
    fishingBlips = {}
    sellNpcBlips = CreateSellNpcBlips(Config.SellNpcCoords)
    sellNpcs = CreateSellNpcs(Config.SellNpcCoords)

    for _, location in pairs(Config.FishingLocations) do
        local blip = CreateFishingBlip(location)
        table.insert(fishingBlips, blip)
    end
end

local notificationCooldown = 5000  -- 5 seconds
local lastNotificationTime = 0

function SendNotification(title, description, type)
    lib.notify({
        title = title,
        description = description,
        type = type,
        duration = 5000,
        position = 'top-right',
        style = {
            background = 'rgba(0, 0, 0, 0.8)',
            border = '1px solid #3498db',
            color = '#ffffff'
        }
    })
end

Citizen.CreateThread(function()
    CreateBlips()

    while true do
        Citizen.Wait(0)
        local playerCoords = GetEntityCoords(PlayerPedId())

        for _, location in pairs(Config.FishingLocations) do
            local distance = #(vector3(playerCoords.x, playerCoords.y, playerCoords.z) - location.coords)

            if distance < 2.0 and not hasEnteredFishingZone then
                if IsControlJustReleased(0, 38) and not hasPressedKey then
                    if not hasStartedFishingNotification then
                        StartFishing(location.name)
                        hasStartedFishingNotification = true
                        hasSellFishNotification = false
                        hasEnteredSellZone = false
                    end
                    hasPressedKey = true
                end
            end
        end

        for i, sellNpcCoords in pairs(Config.SellNpcCoords) do
            local sellNpcDistance = #(vector3(playerCoords.x, playerCoords.y, playerCoords.z) - vector3(sellNpcCoords.coords.x, sellNpcCoords.coords.y, sellNpcCoords.coords.z))

            if sellNpcDistance < 2.0 then
                if IsControlJustReleased(0, 38) and not isFishing then
                    if not hasSellFishNotification then
                        SellFish()
                        hasSellFishNotification = true
                        hasStartedFishingNotification = false
                        hasEnteredFishingZone = false
                    end
                end
            end
        end

        if not IsControlPressed(0, 38) then
            hasPressedKey = false
        end

        if isFishing then
            local currentTime = GetGameTimer()

            if currentTime >= fishingTimer then
                isFishing = false
                CheckForFishCatch()
                fishingFinished = true
                TriggerEvent('fish:stopFishingAnimation')
                TriggerServerEvent('fish:stopFishing')
            else
                DrawFishingPoleAnimation()
            end
        end
    end
end)


RegisterNetEvent('fish:catchFish')
AddEventHandler('fish:catchFish', function(fish)
    table.insert(caughtFish, fish)
    local fishCount = fish.count or 0

    if not isFishing then
        SendNotification("Fishing", "Fishing has finished. You caught " .. fishCount .. " " .. fish.type .. "!", "success")
        caughtFish = {}  -- Reset caughtFish array
    else
        SendNotification("Fishing", "You caught " .. fishCount .. " " .. fish.type .. "!", "success")
    end

    -- Reset fishing-related flags
    isFishing = false
    hasStartedFishingNotification = false
    hasSellFishNotification = false
    hasEnteredSellZone = false
end)

RegisterNetEvent('fish:sellSuccess')
AddEventHandler('fish:sellSuccess', function(earnedMoney)
    SendNotification("Sell Fish", "You sold your fish for $" .. earnedMoney .. "!", "success")
    caughtFish = {}
end)

RegisterNetEvent('fish:fishingStarted')
AddEventHandler('fish:fishingStarted', function()
    isFishing = true
end)

function StartFishing(location)
    if not isFishing then
        isFishing = true
        TriggerServerEvent('fish:startFishing', location)
        fishingTimer = GetGameTimer() + 5000
        fishingFinished = false
    else
        SendNotification("Fishing", "You are already fishing.", "error")
    end
end

function SellFish()
    if #caughtFish > 0 and fishingFinished then
        TriggerServerEvent('fish:sellFish')
    else
        SendNotification("Sell Fish", "You have no fish to sell.", "error")
    end
end

function AttachFishingPoleToPlayer()
    local player = GetPlayerPed(-1)
    local x, y, z = table.unpack(GetEntityCoords(player, true))
    local boneIndex = GetPedBoneIndex(player, 57005)
    local modelHash = GetHashKey("prop_fishing_rod_01")

    RequestModel(modelHash)

    while not HasModelLoaded(modelHash) do
        Wait(500)
    end

    fishingPoleEntity = CreateObject(modelHash, 0, 0, 0, true, true, false)
    AttachEntityToEntity(fishingPoleEntity, player, boneIndex, 0.1, 0.0, -0.02, -40.0, 32.0, 35.0, true, true, false, true, 1, true)
    SetEntityAsMissionEntity(fishingPoleEntity, true, true)
    SetModelAsNoLongerNeeded(modelHash)
end

function DetachFishingPoleFromPlayer()
    local player = GetPlayerPed(-1)

    if DoesEntityExist(fishingPoleEntity) then
        DetachEntity(fishingPoleEntity, true, false)
        DeleteEntity(fishingPoleEntity)
        fishingPoleEntity = nil
    end
end

function DrawFishingPoleAnimation()
    if not isFishingAnimationPlaying then
        isFishingAnimationPlaying = true
        AttachFishingPoleToPlayer()

        RequestAnimDict('amb@world_human_stand_fishing@idle_a')
        while not HasAnimDictLoaded('amb@world_human_stand_fishing@idle_a') do
            Wait(500)
        end

        TaskPlayAnim(PlayerPedId(), 'amb@world_human_stand_fishing@idle_a', 'idle_c', 1.0, -1.0, 1.0, 11, 0, 0, 0, 0)
        TriggerEvent('codex-sound:PlayOnOne', 0.5, 'fishing', 1.0)
        Citizen.Wait(3000)

        StopAnimTask(PlayerPedId(), 'amb@world_human_stand_fishing@idle_a', 'idle_c', 1.0)

        DetachFishingPoleFromPlayer()

        local entity = GetEntityAttachedTo(PlayerPedId())
        if DoesEntityExist(entity) then
            DeleteEntity(entity)
        end

        isFishingAnimationPlaying = false
    end
end

function CheckForFishCatch()
    if math.random() < 0.05 then
        local randomFishType = GetRandomFishType()
        local randomFishCount = math.random(1, 5)
        local randomSellPrice = GetFishSellPrice(randomFishType)

        TriggerServerEvent('fish:catchFish', randomFishType, randomFishCount, randomSellPrice)
    end
end

RegisterNetEvent('fish:stopFishingAnimation')
AddEventHandler('fish:stopFishingAnimation', function()
    StopAnimTask(PlayerPedId(), 'mini@tennis', 'forehand_ts_md_far', 1.0)
    StopAnimTask(PlayerPedId(), 'amb@world_human_stand_fishing@idle_a', 'idle_c', 1.0)
end)

RegisterCommand("bag", function()
    if #caughtFish > 0 then
        local fishInfo = {}
        for _, fish in ipairs(caughtFish) do
            table.insert(fishInfo, { type = fish.type, count = fish.count })
        end

        local notificationTitle = "Your Fish Bag"
        local notificationDescription = ""

        for _, info in ipairs(fishInfo) do
            notificationDescription = notificationDescription .. info.count .. " " .. info.type .. "\n"
        end

        if notificationDescription == "" then
            notificationDescription = "Your fish bag is empty."
        end

        SendNotification(notificationTitle, notificationDescription, "info")
    else
        SendNotification("Your Fish Bag", "Your fish bag is empty.", "info")
    end
end, false)
