---@diagnostic disable: param-type-mismatch
NOTIFY = {}

CreateThread(function()
    lib.versionCheck('zrxnx/zrx_tracker')

    local toReturn = {}
    local toReturnShared = {}
    local jobIndex

    Wait(1000) --| needs to be there to fix some race conditions for the client callback isInWater

    while true do
        toReturn = GetBlipData()

        for player, state in pairs(ZRX_UTIL.getPlayers()) do
            toReturnShared = {}

            if not Player(player).state?.job?.name then
                goto continue
            end

            if not toReturn[Player(player).state.job.name] then
                goto continue
            end

            jobIndex = FindJobInTable(Player(player).state.job.name)
            if jobIndex then
                for job, color in pairs(Config.SharedJobs[jobIndex]) do
                    if toReturn[job] then
                        for index, entry in pairs(toReturn[job]) do
                            toReturnShared[index] = entry
                        end
                    end
                end

                TriggerClientEvent('zrx_tracker:client:getData', player, toReturnShared)
            else
                TriggerClientEvent('zrx_tracker:client:getData', player, toReturn[Player(player).state.job.name])
            end

            ::continue::
        end

        Wait(Config.Sync.time * 1000)
    end
end)

if ZRX_UTIL.inv == 'ox' then
    ZRX_UTIL.invObj:registerHook('swapItems', function(payload)
        local xPlayer = ZRX_UTIL.fwObj.GetPlayerFromId(payload.source)
        local itemCount = ZRX_UTIL.invObj:GetItemCount(payload.source, Config.Item)

        if Config.ShowNotify.onSend and payload.toInventory == payload.source and payload.fromInventory ~= payload.toInventory and itemCount <= 0 then
            NotifyAllInJob(payload.source, Strings.activate_tracker:format(xPlayer.getName()))
            Player(payload.source).state:set('zrx_tracker:hasItem', true, true)
        elseif Config.ShowNotify.onRemove and payload.toInventory ~= payload.source and payload.fromInventory ~= payload.toInventory and itemCount - 1 <= 0 then
            NotifyAllInJob(payload.source, Strings.deactivate_tracker:format(xPlayer.getName()))
            Player(payload.source).state:set('zrx_tracker:hasItem', false, true)
            RemoveTracker(payload.source)
            TriggerClientEvent('zrx_tracker:client:removeAllTracker', payload.source)
        end

        return true
    end, {
        print = true,
    })
else
    if Config.ShowNotify.onSend then
        AddEventHandler('esx:onAddInventoryItem', function(player, itemName, itemCount)
            if itemName ~= Config.Item then
                return
            end

            local xPlayer = ZRX_UTIL.fwObj.GetPlayerFromId(player)

            if xPlayer.hasItem(Config.Item) then
                return
            end

            NotifyAllInJob(player, Strings.activate_tracker:format(xPlayer.getName()))
            Player(player).state:set('zrx_tracker:hasItem', true, true)
        end)
    end

    if Config.ShowNotify.onRemove then
        AddEventHandler('esx:onRemoveInventoryItem', function(player, itemName, itemCount)
            if itemName ~= Config.Item then
                return
            end

            local xPlayer = ZRX_UTIL.fwObj.GetPlayerFromId(player)

            if xPlayer.hasItem(Config.Item) then
                return
            end

            NotifyAllInJob(player, Strings.deactivate_tracker:format(xPlayer.getName()))
            Player(player).state:set('zrx_tracker:hasItem', false, true)
            RemoveTracker(player)
            TriggerClientEvent('zrx_tracker:client:removeAllTracker', player)
        end)
    end
end


if Config.Sync.live then
    AddEventHandler('playerEnteredScope', function(data)
        local playerEntering, player = data.player, data['for']
        playerEntering = tonumber(playerEntering)
        player = tonumber(player)

        TriggerClientEvent('zrx_tracker:client:removeTracker', player, playerEntering, false)
        TriggerClientEvent('zrx_tracker:client:trackPlayer', player, playerEntering)
    end)

    AddEventHandler('playerLeftScope', function(data)
        local playerLeaving, player = data.player, data['for']
        playerLeaving = tonumber(playerLeaving)
        player = tonumber(player)

        TriggerClientEvent('zrx_tracker:client:removeTracker', player, playerLeaving, true)

        local toReturnShared = {}
        local jobIndex
        local toReturn = GetBlipData()

        for player2, state in pairs(ZRX_UTIL.getPlayers()) do
            toReturnShared = {}

            if not Player(player2).state?.job?.name then
                goto continue
            end

            if not toReturn[Player(player2).state.job.name] then
                goto continue
            end

            jobIndex = FindJobInTable(Player(player2).state.job.name)
            if jobIndex then
                for job, color in pairs(Config.SharedJobs[jobIndex]) do
                    if toReturn[job] then
                        for index, entry in pairs(toReturn[job]) do
                            toReturnShared[index] = entry
                        end
                    end
                end

                TriggerClientEvent('zrx_tracker:client:getData', player2, toReturnShared)
            else
                TriggerClientEvent('zrx_tracker:client:getData', player2, toReturn[Player(player2).state.job.name])
            end

            ::continue::
        end
    end)
end

AddEventHandler('esx:setJob', function(target, job)
    local jobIndex

    for player, state in pairs(ZRX_UTIL.getPlayers()) do

        if not Player(player).state?.job?.name then
            goto continue
        end

        jobIndex = FindJobInTable(Player(player).state.job.name)
        if jobIndex then
            for job2, color in pairs(Config.SharedJobs[jobIndex]) do
                if job2 ~= job.name then
                    TriggerClientEvent('zrx_tracker:client:removeTracker', player, target, true)
                end
            end
        else
            TriggerClientEvent('zrx_tracker:client:removeTracker', player, target, true)
        end

        ::continue::
    end
end)