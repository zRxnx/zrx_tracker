ACTIVE_BLIPS = {}
BREAK_SIREN = false

RegisterNetEvent('zrx_tracker:client:getData', function(data)
    RemoveBlips()
    CreateBlips(data)
end)

RegisterNetEvent('zrx_tracker:client:removeTracker', function(blip)
    RemoveBlip(ACTIVE_BLIPS[blip])

    ACTIVE_BLIPS[blip] = nil
end)

RegisterNetEvent('zrx_tracker:client:removeAllTracker', function(blip)
    RemoveBlips()
end)

lib.callback.register('zrx_tracker:client:isInWater', function()
    return IsEntityInWater(cache.ped)
end)