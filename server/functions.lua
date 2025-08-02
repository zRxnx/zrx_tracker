GetBlipData = function()
    local toReturn = {}
    local xPlayer, jobIndex, water, deathStatus
    local vehicle, ped = 0, 0

    for player, state in pairs(ZRX_UTIL.getPlayers()) do
        xPlayer = ZRX_UTIL.fwObj.GetPlayerFromId(player)

        if not xPlayer then
            goto continue
        end

        if Config.Jobs.__MODE__ == 'whitelist' and not Config.Jobs[xPlayer.job.name] or Config.Jobs[xPlayer.job.name] then
            goto continue
        end

        if Player(player).state['zrx_tracker:disable'] then
            goto continue
        end

        if not Config.ShowPlayer(player) then
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

        water = Player(player).state['zrx_tracker:water']
        toReturn[xPlayer.job.name][player].water = water

        if water then
            if Config.ShowNotify.onWater and not NOTIFY[player].water and Config.Disable.water then
                NOTIFY[player].water = true

                NotifyAllInJob(player, Strings.deactivate_tracker_water:format(xPlayer.getName()))
            end
        elseif NOTIFY[player].water and Config.Disable.water then
            NOTIFY[player].water = false

            NotifyAllInJob(player, Strings.activate_tracker_water:format(xPlayer.getName()))
        end

        if Config.Disable.water and water then
            toReturn[xPlayer.job.name][player] = nil

            goto continue
        end

        deathStatus = Config.GetDeathStatus(player)
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

        if Config.Disable.death and deathStatus then
            toReturn[xPlayer.job.name][player] = nil

            goto continue
        end

        jobIndex = FindJobInTable(xPlayer.job.name)
        if jobIndex then
            toReturn[xPlayer.job.name][player].shared = true
            toReturn[xPlayer.job.name][player].sharedIndex = jobIndex
        end

        ped = GetPlayerPed(player)
        toReturn[xPlayer.job.name][player].coords = GetEntityCoords(ped)
        toReturn[xPlayer.job.name][player].heading = GetEntityHeading(ped)
        toReturn[xPlayer.job.name][player].name = xPlayer.getName()
        toReturn[xPlayer.job.name][player].job = xPlayer.job.name
        toReturn[xPlayer.job.name][player].bucket = GetPlayerRoutingBucket(tostring(player))
        vehicle = GetVehiclePedIsIn(ped, false)

        toReturn[xPlayer.job.name][player].vehType = ''
        if DoesEntityExist(vehicle) and not toReturn[xPlayer.job.name][player].death then
            toReturn[xPlayer.job.name][player].vehType = GetVehicleType(vehicle)

            toReturn[xPlayer.job.name][player].siren = false
            if Config.Blip.extra.siren then
                toReturn[xPlayer.job.name][player].siren = IsVehicleSirenOn(vehicle)
            end
        end

        ::continue::
    end

    return toReturn
end

NotifyAllInJob = function(player, string)
    local job = Player(player).state?.job?.name
    local xTarget

    if not job then
        return
    end

    for target, state in pairs(ZRX_UTIL.getPlayers()) do
        xTarget = ZRX_UTIL.fwObj.GetPlayerFromId(target)

        if player == target then
            goto continue
        end

        if not job or not xTarget then
            goto continue
        end

        if job ~= xTarget.job.name then
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
    local job = Player(player).state?.job?.name
    local jobTarget

    if not job then
        return
    end

    for target, state in pairs(ZRX_UTIL.getPlayers()) do
        jobTarget = Player(target).state?.job?.name

        if not job or not jobTarget then
            goto continue
        end

        if job ~= jobTarget then
            goto continue
        end

        TriggerClientEvent('zrx_tracker:client:removeTracker', target, player, false)
        TriggerClientEvent('zrx_tracker:client:removeTracker', target, player, true)

        ::continue::
    end
end

ShouldInclude = function(bucket, player)
    return not Config.OnlyShowSameBucket or bucket == GetPlayerRoutingBucket(tostring(player))
end

DisableTracker = function(player, state)
    Player(player).state:set('zrx_tracker:disable', state, true)
end
exports('disableTracker', DisableTracker)