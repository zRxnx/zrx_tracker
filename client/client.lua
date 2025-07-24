ACTIVE_BLIPS = {}
ACTIVE_CLIENT_BLIPS = {}
SIREN_DATA = {}

RegisterNetEvent('zrx_tracker:client:getData', function(data)
    RemoveBlips()
    Wait(10)
    CreateBlips(data)
end)

RegisterNetEvent('zrx_tracker:client:removeTracker', function(player, client)
    if client then
        RemoveBlip(ACTIVE_CLIENT_BLIPS[player])

        ACTIVE_CLIENT_BLIPS[player] = nil
    else
        RemoveBlip(ACTIVE_BLIPS[player])

        ACTIVE_BLIPS[player] = nil
    end
end)

RegisterNetEvent('zrx_tracker:client:removeAllTracker', function()
    RemoveBlips()
end)

RegisterNetEvent('zrx_tracker:client:trackPlayer', function(player)
    CreateBlips(GetBlipData())
end)

CreateThread(function()
    local water

    while true do
        water = IsEntityInWater(cache.ped)

        LocalPlayer.state:set('zrx_tracker:water', water, true)

        if Config.Disable.water and water then
            print('removeall')
            RemoveBlips()
        end

        Wait(1000)
    end
end)

CreateThread(function()
    local data

    while Config.Sync.live do
        data = GetBlipData()

        CreateBlips(data)

        Wait(Config.Sync.liveRefresh)
    end
end)

CreateThread(function()
    while Config.Blip.extra.siren do
        for player, blip in pairs(ACTIVE_CLIENT_BLIPS) do
            if not SIREN_DATA[blip] then
                goto continue
            end

            if not SIREN_DATA[blip].siren then
                goto continue
            end

            if not SIREN_DATA[blip].color then
                SIREN_DATA[blip].color = 'red'
            end

            if SIREN_DATA[blip].color == 'red' then
                SIREN_DATA[blip].color = 'blue'

                if type(Config.Blip.color.red) == 'table' then
                    SetBlipColour(blip, tonumber(('0x%02X%02X%02X%02X'):format(Config.Blip.color.red.r, Config.Blip.color.red.g, Config.Blip.color.red.b, Config.Blip.color.red.a)))
                else
                    SetBlipColour(blip, Config.Blip.color.red)
                end
            elseif SIREN_DATA[blip].color == 'blue' then
                SIREN_DATA[blip].color = 'red'

                if type(Config.Blip.color.blue) == 'table' then
                    SetBlipColour(blip, tonumber(('0x%02X%02X%02X%02X'):format(Config.Blip.color.blue.r, Config.Blip.color.blue.g, Config.Blip.color.blue.b, Config.Blip.color.blue.a)))
                else
                    SetBlipColour(blip, Config.Blip.color.blue)
                end
            end

            ::continue::
        end

        for player, blip in pairs(ACTIVE_BLIPS) do
            if not SIREN_DATA[blip] then
                goto continue
            end

            if not SIREN_DATA[blip].siren then
                goto continue
            end

            if not SIREN_DATA[blip].color then
                SIREN_DATA[blip].color = 'red'
            end

            if SIREN_DATA[blip].color == 'red' then
                SIREN_DATA[blip].color = 'blue'

                if type(Config.Blip.color.red) == 'table' then
                    SetBlipColour(blip, tonumber(('0x%02X%02X%02X%02X'):format(Config.Blip.color.red.r, Config.Blip.color.red.g, Config.Blip.color.red.b, Config.Blip.color.red.a)))
                else
                    SetBlipColour(blip, Config.Blip.color.red)
                end
            elseif SIREN_DATA[blip].color == 'blue' then
                SIREN_DATA[blip].color = 'red'

                if type(Config.Blip.color.blue) == 'table' then
                    SetBlipColour(blip, tonumber(('0x%02X%02X%02X%02X'):format(Config.Blip.color.blue.r, Config.Blip.color.blue.g, Config.Blip.color.blue.b, Config.Blip.color.blue.a)))
                else
                    SetBlipColour(blip, Config.Blip.color.blue)
                end
            end

            ::continue::
        end

        Wait(800)
    end
end)