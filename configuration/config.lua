Config = {}

Config.Item = 'phone'

Config.Sync = {
    time = 5, --| seconds lower = performance loss
}

Config.Disable = {
    water = true, --| slows down the system
    death = true,
}

Config.ShowNotify = {
    onDeath = true,
    onSend = true,
    onRemove = true,
    onWater = true,
}

Config.Jobs = {
    police = true,
    ambulance = true,
    mechanic = true,
}

Config.Blip = {
    changeOwn = true,

    types = { --| Blip sprites
        main = 1,
        automobile = 225,
        bike = 348,
        heli = 64,
        boat = 427,
        water = 729,
        plane = 307,
        death = 310,
    },

    color = { --| Supports RGBA format and gta default color
        default = 0,
        vehicle = { r = 211, g = 211, b = 211, a = 255 },
        water = { r = 173, g = 216, b = 230, a = 255 },
        death = { r = 139, g = 0, b = 0, a = 255 },
        blue = { r = 0, g = 0, b = 255, a = 255 },
        red = { r = 255, g = 0, b = 0, a = 255 },
    },

    extra = {
        scale = 1.2,
        alpha = 255,
        priority = 100,
        category = 7,

        short = false,

        friendly = true,
        heading = true,
        height = true,
        vision = true,

        flash = false,
        flashInt = 100, --| ms

        siren = true,
    }
}

Config.Notify = function(player, msg, title, type, color, time)
    if IsDuplicityVersion() then
        TriggerClientEvent('ox_lib:notify', player, {
            title = title,
            description = msg,
            type = type,
            duration = time,
            style = {
                color = color
            }
        })
    else
        lib.notify({
            title = title,
            description = msg,
            type = type,
            duration = time,
            style = {
                color = color
            }
        })
    end
end

Config.GetDeathStatus = function(player)
    if IsDuplicityVersion() then
        local xPlayer = ZRX_UTIL.fwObj.GetPlayerFromId(player)

        return MySQL.scalar.await('SELECT is_dead FROM users WHERE identifier = ?', { xPlayer.identifier })
    else
        return false
    end
end