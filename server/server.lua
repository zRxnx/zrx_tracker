---@diagnostic disable: param-type-mismatch
NOTIFY = {}

CreateThread(function()
    lib.versionCheck('zrxnx/zrx_tracker')

    local toReturn, toReturnShared, jobData = {}, {}, {}
    local sharedJobs, playerState, jobIndex, job

    while true do
        toReturn = GetBlipData()

        for player, _ in pairs(ZRX_UTIL.getPlayers()) do
            toReturnShared = {}
            playerState = Player(player).state
            job = playerState?.job?.name
            jobData = toReturn[job]

            if not job or not jobData then
                goto continue
            end

            jobIndex = FindJobInTable(job)
            sharedJobs = jobIndex and Config.SharedJobs[jobIndex] or nil

            if sharedJobs then
                for sharedJob, _ in pairs(sharedJobs) do
                    for targetPlayer, entry in pairs(toReturn[sharedJob] or {}) do
                        if ShouldInclude(entry, player) then
                            toReturnShared[targetPlayer] = entry
                        end
                    end
                end
            else
                for targetPlayer, entry in pairs(jobData) do
                    if ShouldInclude(entry, player) then
                        toReturnShared[targetPlayer] = entry
                    end
                end
            end

            TriggerClientEvent('zrx_tracker:client:getData', player, toReturnShared)

            TriggerEvent('zrx_tracker:server:onSend', {
                player = player,
                playerJob = job,
                data = jobData[player]
            })

            ::continue::
        end

        Wait(Config.Sync.time * 1000)
    end
end)

if ZRX_UTIL.inv == 'ox' then
    ZRX_UTIL.invObj:registerHook('swapItems', function(payload)
        local itemCount = ZRX_UTIL.invObj:GetItemCount(payload.source, Config.Item)

        if Config.ShowNotify.onSend and payload.toInventory == payload.source and payload.fromInventory ~= payload.toInventory and itemCount <= 0 then
            Player(payload.source).state:set('zrx_tracker:hasItem', true, true)
            NotifyAllInJob(payload.source, Strings.activate_tracker:format(Player(payload.source).state.name))
        elseif Config.ShowNotify.onRemove and payload.toInventory ~= payload.source and payload.fromInventory ~= payload.toInventory and itemCount - 1 <= 0 then
            Player(payload.source).state:set('zrx_tracker:hasItem', false, true)

            NotifyAllInJob(payload.source, Strings.deactivate_tracker:format(Player(payload.source).state.name))
            RemoveTracker(payload.source)
            TriggerClientEvent('zrx_tracker:client:removeAllTracker', payload.source)
        end

        return true
    end, {
        print = true,
        itemFilter = {
            [Config.Item] = true
        }
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

            Player(player).state:set('zrx_tracker:hasItem', true, true)
            NotifyAllInJob(player, Strings.activate_tracker:format(xPlayer.getName()))
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

            Player(player).state:set('zrx_tracker:hasItem', false, true)

            NotifyAllInJob(player, Strings.deactivate_tracker:format(xPlayer.getName()))
            RemoveTracker(player)
            TriggerClientEvent('zrx_tracker:client:removeAllTracker', player)
        end)
    end
end


if Config.Sync.live then
    AddEventHandler('playerEnteredScope', function(data)
        local playerEntering, player = tonumber(data.player), tonumber(data['for'])

        TriggerClientEvent('zrx_tracker:client:removeTracker', player, playerEntering, false)
        TriggerClientEvent('zrx_tracker:client:trackPlayer', player, playerEntering)
    end)

    AddEventHandler('playerLeftScope', function(data)
        local playerLeaving, player = tonumber(data.player), tonumber(data['for'])

        TriggerClientEvent('zrx_tracker:client:removeTracker', player, playerLeaving, true)

        local toReturn, sharedData, jobData = GetBlipData(), {}, {}
        local jobIndex, job

        for player2, state in pairs(ZRX_UTIL.getPlayers()) do
            sharedData = {}
            job = Player(player2).state?.job?.name
            jobData = toReturn[job]

            if not job or not jobData then
                goto continue
            end

            if not toReturn[job] then
                goto continue
            end

            jobIndex = FindJobInTable(job)
            if jobIndex then
                for sharedJob, _ in pairs(Config.SharedJobs[jobIndex]) do
                    for targetPlayer, entry in pairs(toReturn[sharedJob] or {}) do
                        if ShouldInclude(entry, player) then
                            sharedData[targetPlayer] = entry
                        end
                    end
                end

                TriggerClientEvent('zrx_tracker:client:getData', player, sharedData)
            else
                for targetPlayer, entry in pairs(jobData) do
                    if ShouldInclude(entry, player) then
                        sharedData[targetPlayer] = entry
                    end
                end

                TriggerClientEvent('zrx_tracker:client:getData', player, sharedData)
            end

            ::continue::
        end
    end)
end

AddEventHandler('esx:setJob', function(player, job, lastJob)
    local jobIndex, jobTarget
    local found = false

    for target, state in pairs(ZRX_UTIL.getPlayers()) do
        jobTarget = Player(target).state?.job?.name

        if not jobTarget then
            goto continue
        end

        if lastJob.name ~= jobTarget then
            goto continue
        end

        if job.name == jobTarget then
            goto continue
        end

        TriggerClientEvent('zrx_tracker:client:removeTracker', target, player, true)
        print('Remove')

        ::continue::
    end
end)