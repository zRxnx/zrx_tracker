ACTIVE_BLIPS = {}
ACTIVE_CLIENT_BLIPS = {}
BREAK_SIREN = false

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

RegisterNetEvent('zrx_tracker:client:removeAllTracker', function(blip)
    RemoveBlips()
end)

RegisterNetEvent('zrx_tracker:client:trackPlayer', function(player)
    CreateBlips(GetBlipData())
end)

lib.callback.register('zrx_tracker:client:isInWater', function()
    return IsEntityInWater(cache.ped)
end)

CreateThread(function()
    local data

    while Config.Sync.live do
        data = GetBlipData()

        CreateBlips(data)

        Wait(Config.Sync.liveRefresh)
    end
end)