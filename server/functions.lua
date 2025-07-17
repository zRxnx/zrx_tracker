GetBlipData = function()
    local toReturn = {}
    local xPlayer
    local vehicle = 0
    local ped = 0

    for player, state in pairs(ZRX_UTIL.getPlayers()) do
        xPlayer = ZRX_UTIL.fwObj.GetPlayerFromId(player)

        if not xPlayer then
            goto continue
        end

        if not Config.Jobs[xPlayer.job.name] then
            goto continue
        end

        if ZRX_UTIL.inv == 'ox' then
            if ZRX_UTIL.invObj:GetItemCount(player, Config.Item) <= 0 then
                goto continue
            end
        else
            if not xPlayer.hasItem(Config.Item) then
                goto continue
            end
        end

        if not toReturn[xPlayer.job.name] then
            toReturn[xPlayer.job.name] = {}
        end

        if not NOTIFY[player] then
            NOTIFY[player] = {}
        end

        toReturn[xPlayer.job.name][player] = {}

        local isInWater = lib.callback.await('zrx_tracker:client:isInWater', player)

        toReturn[xPlayer.job.name][player].isInWater = isInWater

        if isInWater then
            if Config.ShowNotify.onWater and not NOTIFY[player].water and Config.Disable.water then
                NOTIFY[player].water = true
                NotifyAllInJob(player, Strings.deactivate_tracker_water:format(xPlayer.getName()))
            end
        elseif NOTIFY[player].water and Config.Disable.water then
            NOTIFY[player].water = false
            NotifyAllInJob(player, Strings.activate_tracker_water:format(xPlayer.getName()))
        end

        local deathStatus = Config.GetDeathStatus(player)

        toReturn[xPlayer.job.name][player].death = deathStatus

        if deathStatus then
            if Config.ShowNotify.onDeath and not NOTIFY[player].death and Config.Disable.death then
                NOTIFY[player].death = true
                NotifyAllInJob(player, Strings.deactivate_tracker_death:format(xPlayer.getName()))
            end
        elseif NOTIFY[player].death and Config.Disable.death then
            NOTIFY[player].death = false
            toReturn[xPlayer.job.name][player].death = false

            NotifyAllInJob(player, Strings.activate_tracker_death:format(xPlayer.getName()))
        end

        ped = GetPlayerPed(player)
        toReturn[xPlayer.job.name][player].coords = GetEntityCoords(ped)
        toReturn[xPlayer.job.name][player].heading = GetEntityHeading(ped)
        toReturn[xPlayer.job.name][player].name = xPlayer.getName()
        vehicle = GetVehiclePedIsIn(ped, false)

        toReturn[xPlayer.job.name][player].vehType = ''
        if DoesEntityExist(vehicle) and not toReturn[xPlayer.job.name][player].death then
            toReturn[xPlayer.job.name][player].vehType = GetVehicleType(vehicle)

            toReturn[xPlayer.job.name][player].siren = false
            if Config.Blip.extra.siren then
                toReturn[xPlayer.job.name][player].siren = IsVehicleSirenOn(vehicle)
            end
        end

        if toReturn[xPlayer.job.name][player].isInWater and Config.Disable.water then
            toReturn[xPlayer.job.name][player] = nil
        elseif toReturn[xPlayer.job.name][player].death and Config.Disable.death then
            toReturn[xPlayer.job.name][player] = nil
        end

        ::continue::
    end

    return toReturn
end

NotifyAllInJob = function(player, string)
    local xPlayer = ZRX_UTIL.fwObj.GetPlayerFromId(player)
    local xTarget

    for target, state in pairs(ZRX_UTIL.getPlayers()) do
        xTarget = ZRX_UTIL.fwObj.GetPlayerFromId(target)

        if player == target then
            goto continue
        end

        if not xPlayer or not xTarget then
            goto continue
        end

        if xPlayer.job.name ~= xTarget.job.name then
            goto continue
        end

        if ZRX_UTIL.inv == 'ox' then
            if ZRX_UTIL.invObj:GetItemCount(target, Config.Item) <= 0 then
                goto continue
            end
        else
            if not xTarget.hasItem(Config.Item) then
                goto continue
            end
        end

        Config.Notify(target, string)

        ::continue::
    end
end

RemoveTracker = function(player)
    local xPlayer = ZRX_UTIL.fwObj.GetPlayerFromId(player)
    local xTarget

    for target, state in pairs(ZRX_UTIL.getPlayers()) do
        xTarget = ZRX_UTIL.fwObj.GetPlayerFromId(target)

        if not xPlayer or not xTarget then
            goto continue
        end

        if xPlayer.job.name ~= xTarget.job.name then
            goto continue
        end

        TriggerClientEvent('zrx_tracker:client:removeTracker', target, player)

        ::continue::
    end
end