---@diagnostic disable: param-type-mismatch
RemoveBlips = function()
    for player, blip in pairs(ACTIVE_BLIPS) do
        RemoveBlip(blip)
    end

    ACTIVE_BLIPS = {}
end

CreateBlips = function(data)
    local sprite, color, blip, string, entBlip
    local sharedColor = {}

    for player, blipData in pairs(data) do
        sharedColor = {}
        if player == cache.serverId and Config.Blip.changeOwn then
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

        if not SIREN_DATA[blip] then
            SIREN_DATA[blip] = {}
        end

        sprite = Config.Blip.types.main
        color = Config.Blip.color.default
        string = ('[%s] %s'):format(player, blipData.name)

        if blipData.vehType ~= '' then
            color = Config.Blip.color.vehicle
            sprite = Config.Blip.types[blipData.vehType]
        end

        if blipData.water then
            color = Config.Blip.color.water
            sprite = Config.Blip.types.water
        end

        if blipData.death then
            color = Config.Blip.color.death
            sprite = Config.Blip.types.death
        end

        SetBlipSprite(blip, sprite)

        if blipData.siren then
            SIREN_DATA[blip].siren = true
        else
            SIREN_DATA[blip].siren = false

            if type(color) == 'table' then
                SetBlipColour(blip, tonumber(('0x%02X%02X%02X%02X'):format(color.r, color.g, color.b, color.a)))
            else
                SetBlipColour(blip, color)
            end
        end

        if blipData.shared then
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

        TriggerEvent('zrx_tracker:client:onSend', {
            player = player,
            playerJob = blipData.job,
            data = blipData
        })

        ::continue::
    end
end

GetBlipData = function()
    local player, playerPed, jobIndex, job, name, hasItem
    local water, deathStatus, vehicle = false, false, 0
    local toReturn = {}

    for index, playerId in pairs(GetActivePlayers()) do
        player = GetPlayerServerId(playerId)
        playerPed = GetPlayerPed(playerId)
        job = Player(player)?.state?.job?.name or 'undefined'
        name = Player(player)?.state?.name or GetPlayerName(player)
        hasItem = Player(player)?.state?['zrx_tracker:hasItem'] or true

        if player == cache.serverId then
            goto continue
        end

        if (Config.Jobs.__MODE__ == 'whitelist' and not Config.Jobs[job]) or Config.Jobs[job] then
            goto continue
        end

        jobIndex = FindJobInTable(job)
        if not jobIndex then
            if LocalPlayer.state.job.name ~= job then
                goto continue
            end
        end
        
        if Player(player).state['zrx_tracker:disable'] then
            goto continue
        end

        if not Config.ShowPlayer(player) then
            goto continue
        end

        if not hasItem then
            goto continue
        end
        

        toReturn[player] = {}

        water = IsEntityInWater(playerPed)

        if water then
            if Config.Disable.water then
                toReturn[player] = nil
                goto continue
            end

            toReturn[player].water = true
        end

        deathStatus = Config.GetDeathStatus(player)

        if deathStatus then
            if Config.Disable.death then
                toReturn[player] = nil
                goto continue
            end

            toReturn[player].death = true
        end

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