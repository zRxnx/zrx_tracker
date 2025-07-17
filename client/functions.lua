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
    local ped

    BREAK_SIREN = true

    for player, blipData in pairs(data) do
        print('blipData', player)
        if player == cache.serverId and Config.Blip.changeOwn then
            print('own')
            blip = GetMainPlayerBlipId()
        elseif player ~= cache.serverId then
            print('other')
            blip = AddBlipForCoord(blipData.coords.x, blipData.coords.y, blipData.coords.z)
        end

        ACTIVE_BLIPS[player] = blip
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
    end

    if Config.Blip.extra.siren then
        StartSirenThread(data)
    end
end

local BREAK = false
StartSirenThread = function(data)
    BREAK = true
    Wait(500)
    BREAK = false

    while true do
        if BREAK then
            return
        end

        print('loop')
        for player, blipData in pairs(data) do
            if not blipData.siren then
                print('active')
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