Config = {}

Config.Item = 'phone'

Config.Sync = {
    live = true, --| Syncs in onesync range 434
    liveRefresh = 800, --| Update blips type rate | lower = impact client fps
    time = 5, --| seconds lower = performance loss
}

Config.Disable = {
    water = true, --| slows down the system
    death = true,
}

Config.ShowNotify = { --| onDeath and onWater only sends when Config.Disable is enabled
    onSend = true,
    onRemove = true,

    onDeath = true,
    onWater = true,
}

Config.Jobs = { --| Jobs that have tracker
    police = true,
    ambulance = true,
    mechanic = true,
    bennys = true,
}

Config.SharedJobs = { --| These jobs see each other tracker | color needs to be in rgba format
    {
        police = { r = 0, g = 0, b = 255 },
        ambulance = { r = 255, g = 0, b = 0 },
    },

    {
        mechanic = { r = 100, g = 100, b = 100 },
        bennys = { r = 200, g = 200, b = 200 },
    },
}

Config.Blip = {
    changeOwn = false, --| Changes the default arrow blip

    types = { --| Blip sprites
        main = 1,

        automobile = 225,
        bike = 348,
        heli = 64,
        boat = 427,
        plane = 307,
        submarine = 308,
        train = 795,
        trailer = 479,

        water = 729,
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

        short = false, --| Not recommended

        friendly = true, --| Right blue ring
        heading = true, --| Shows the direction the player is looking
        height = true, --| Shows a arrow if the player is over or under you
        vision = true, --| Shows the vision field of the player

        flash = false, --| Blip flash on, off, on, off ....
        flashInt = 100, --| ms

        siren = true, --| Siren flash if in vehicle that has siren on
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

--| For example if the player is in aduty mode
Config.ShowPlayer = function(player)
    if IsDuplicityVersion() then
        return true
    else
        return true
    end
end

Config.GetDeathStatus = function(player)
    if IsDuplicityVersion() then
        local xPlayer = ZRX_UTIL.fwObj.GetPlayerFromId(player)

        --| Default death check, depends on your death system
        return exports.oxmysql:scalar_async('SELECT is_dead FROM users WHERE identifier = ?', { xPlayer.identifier })
    else
        return false
    end
end