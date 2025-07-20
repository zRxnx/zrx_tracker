---@diagnostic disable: param-type-mismatch
RemoveBlips = function()
    for player, blip in pairs(ACTIVE_BLIPS) do
        RemoveBlip(blip)
        ACTIVE_BLIPS[player] = nil
    end
end

CreateBlips = function(data)
    --print(json.encode(data, { indent = true }))
    local sprite
    local color
    local blip
    local string
    local entBlip
    local sharedColor = {}

    BREAK_SIREN = true

    for player, blipData in pairs(data) do
        sharedColor = {}
        --print('blipData', player)
        --print(json.encode(blipData, {indent = true}))
        if player == cache.serverId and Config.Blip.changeOwn then
            --print('own')
            blip = GetMainPlayerBlipId()
        elseif blipData.isNear then
            entBlip = GetBlipFromEntity(blipData.entity)
            if DoesBlipExist(entBlip) then
                blip = entBlip
            else
                blip = AddBlipForEntity(blipData.entity)
                ACTIVE_CLIENT_BLIPS[player] = blip
            end
        elseif player ~= cache.serverId then
            --print('other', player)
            print(#(vec3(blipData.coords.x, blipData.coords.y, blipData.coords.z) - GetEntityCoords(cache.ped)))
            if #(blipData.coords - GetEntityCoords(cache.ped)) < 424 then
                goto continue
            end

            if DoesBlipExist(ACTIVE_BLIPS[player]) then
                goto continue
            end

            blip = AddBlipForCoord(blipData.coords.x, blipData.coords.y, blipData.coords.z)
            ACTIVE_BLIPS[player] = blip
        else
            goto continue
        end

        sprite = Config.Blip.types.main
        color = Config.Blip.color.default
        string = ('[%s] %s'):format(player, blipData.name)

        if blipData.vehType ~= '' then
            color = Config.Blip.color.vehicle
            sprite = Config.Blip.types[blipData.vehType]
        end

        if blipData.isInWater then
            color = Config.Blip.color.water
            sprite = Config.Blip.types.water
        end

        if blipData.death then
            color = Config.Blip.color.death
            sprite = Config.Blip.types.death
        end

        SetBlipSprite(blip, sprite)

        if type(color) == 'table' then
            SetBlipColour(blip, tonumber(('0x%02X%02X%02X%02X'):format(color.r, color.g, color.b, color.a)))
        else
            SetBlipColour(blip, color)
        end

        if blipData.shared then
            --print('shared', player, blipData.sharedIndex, blipData.job)
            sharedColor = Config.SharedJobs[blipData.sharedIndex][blipData.job]

            ShowCrewIndicatorOnBlip(blip, blipData.shared)
            SetBlipSecondaryColour(blip, sharedColor.r, sharedColor.g, sharedColor.b)
        end

        SetBlipScale(blip, Config.Blip.extra.scale)
        SetBlipAlpha(blip, Config.Blip.extra.alpha)
        SetBlipAsShortRange(blip, Config.Blip.extra.short)
        SetBlipRotation(blip, math.ceil(blipData.heading))
        SetBlipShowCone(blip, Config.Blip.extra.vision)
        SetBlipCategory(blip, Config.Blip.extra.category)
        SetBlipPriority(blip, Config.Blip.extra.priority)
        SetBlipFlashes(blip, Config.Blip.extra.flash)
        SetBlipFlashInterval(blip, Config.Blip.extra.flashInt)

        ShowHeightOnBlip(blip, Config.Blip.extra.height)
        ShowFriendIndicatorOnBlip(blip, Config.Blip.extra.friendly)
        ShowHeadingIndicatorOnBlip(blip, Config.Blip.extra.heading)

        BeginTextCommandSetBlipName('STRING')
        AddTextComponentSubstringPlayerName(string)
        EndTextCommandSetBlipName(blip)

        ::continue::
    end

    if Config.Blip.extra.siren then
        CreateThread(function()
            StartSirenThread(data)
        end)
    end
end

GetBlipData = function()
    local player
    local playerPed
    local toReturn = {}
    local isInWater = false
    local deathStatus = false
    local jobIndex
    local vehicle = 0
    local job
    local name
    local hasItem

    for index, playerId in pairs(GetActivePlayers()) do
        player = GetPlayerServerId(playerId)
        playerPed = GetPlayerPed(playerId)
        job = Player(player)?.state?.job?.name or 'undefined'
        name = Player(player)?.state?.name or GetPlayerName(player)
        hasItem = Player(player)?.state?['zrx_tracker:hasItem'] or true

        if player == cache.serverId then
            goto continue
        end

        if ZRX_UTIL.fwObj.PlayerData.job.name ~= job then
            goto continue
        end

        if not Config.ShowPlayer(player) then
            goto continue
        end

        if not hasItem then
            goto continue
        end

        toReturn[player] = {}

        isInWater = IsEntityInWater(playerPed)

        if isInWater then
            if Config.Disable.water then
                toReturn[player] = nil
                goto continue
            end

            toReturn[player].isInWater = true
        end

        deathStatus = Config.GetDeathStatus(player)

        if deathStatus then
            if Config.Disable.death then
                toReturn[player] = nil
                goto continue
            end

            toReturn[player].death = true
        end

        jobIndex = FindJobInTable(job)
        if jobIndex then
            toReturn[player].shared = true
            toReturn[player].sharedIndex = jobIndex
        end

        toReturn[player].coords = GetEntityCoords(playerPed)
        toReturn[player].heading = GetEntityHeading(playerPed)
        toReturn[player].name = name
        toReturn[player].job = job
        toReturn[player].isNear = true
        toReturn[player].entity = playerPed
        vehicle = GetVehiclePedIsIn(playerPed, false)

        toReturn[player].vehType = ''
        if DoesEntityExist(vehicle) and not toReturn[player].death then
            toReturn[player].vehType = GetVehicleType(vehicle)

            toReturn[player].siren = false
            if Config.Blip.extra.siren then
                toReturn[player].siren = IsVehicleSirenOn(vehicle)
            end
        end

        ::continue::
    end

    return toReturn
end

StartSirenThread = function(data)
    BREAK_SIREN = true
    Wait(500)
    BREAK_SIREN = false

    while true do
        if BREAK_SIREN then
            return
        end

        for player, blipData in pairs(data) do
            if not blipData.siren then
                goto continue
            end

            print(data[player].sirenColor)
            if data[player].sirenColor then
                data[player].sirenColor = false

                if type(Config.Blip.color.blue) == 'table' then
                    SetBlipColour(ACTIVE_BLIPS[player], tonumber(('0x%02X%02X%02X%02X'):format(Config.Blip.color.blue.r, Config.Blip.color.blue.g, Config.Blip.color.blue.b, Config.Blip.color.blue.a)))
                else
                    SetBlipColour(ACTIVE_BLIPS[player], Config.Blip.color.blue)
                end
            else
                data[player].sirenColor = true

                if type(Config.Blip.color.red) == 'table' then
                    SetBlipColour(ACTIVE_BLIPS[player], tonumber(('0x%02X%02X%02X%02X'):format(Config.Blip.color.red.r, Config.Blip.color.red.g, Config.Blip.color.red.b, Config.Blip.color.red.a)))
                else
                    SetBlipColour(ACTIVE_BLIPS[player], Config.Blip.color.red)
                end
            end

            ::continue::
        end

        Wait(800)
    end
end