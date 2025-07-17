Wait(1000) --| needs to be there to fix some race conditions for the client callback isInWater

NOTIFY = {}

CreateThread(function()
    lib.versionCheck('zrxnx/zrx_tracker')

    local toReturn = {}
    local xPlayer

    while true do
        toReturn = GetBlipData()

        for player, state in pairs(ZRX_UTIL.getPlayers()) do
            xPlayer = ZRX_UTIL.fwObj.GetPlayerFromId(player)

            if not xPlayer then
                goto continue
            end

            if not toReturn[xPlayer.job.name] then
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

            TriggerClientEvent('zrx_tracker:client:getData', player, toReturn[xPlayer.job.name])

            ::continue::
        end

        Wait(Config.Sync.time * 1000)
    end
end)

if ZRX_UTIL.inv == 'ox' then
    ZRX_UTIL.invObj:registerHook('swapItems', function(payload)
        --print(json.encode(payload, {indent = true}))
        local xPlayer = ZRX_UTIL.fwObj.GetPlayerFromId(payload.source)
        local itemCount = ZRX_UTIL.invObj:GetItemCount(payload.source, Config.Item)
        print(itemCount)

        if Config.ShowNotify.onSend and payload.toInventory == payload.source and payload.fromInventory ~= payload.toInventory and itemCount <= 0 then
            print(1)
            NotifyAllInJob(payload.source, Strings.activate_tracker:format(xPlayer.getName()))
        elseif Config.ShowNotify.onRemove and payload.toInventory ~= payload.source and payload.fromInventory ~= payload.toInventory and itemCount - 1 <= 0 then
            print(2)
            NotifyAllInJob(payload.source, Strings.deactivate_tracker:format(xPlayer.getName()))
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
            RemoveTracker(player)
            TriggerClientEvent('zrx_tracker:client:removeAllTracker', player)
        end)
    end
end