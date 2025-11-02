g_savedata = {
    vehicles = {},
    pins = {},
    vehicle_tooltip = property.checkbox("Display custom vehicle tooltip", false),
    vehicle_keep_active = property.checkbox("Keep active all vehicles", false),
    vehicle_clearing = property.checkbox("Clear players vehicle on die", false),
    autosave_interval = property.slider("Autosave interval (min, -1 = disable)", -1, 60, 1, -1) * 3600,
    autosave_next = 0,
    time = 0,
    chats = {}
}

timing_default = 60
timing = timing_default
pilot_seats = { "pilot", "driver", "co-pilot", "copilot" }
spawn_by_myself = false
spawn_location = nil
chat_ignore = false

function onTick(tick)
    for i = #g_savedata.pins, 1, -1 do
        if i % 60 == g_savedata.time % 60 then
            g_savedata.pins[i].remain = g_savedata.pins[i].remain - tick * 60

            if g_savedata.pins[i].remain < 0 then
                server.removeMapID(-1, g_savedata.pins[i].marker)
                table.remove(g_savedata.pins, i)
            end
        end
    end

    if g_savedata.autosave_interval >= 0 and g_savedata.time >= g_savedata.autosave_next then
        local date = server.getDateValue()
        server.save()
        g_savedata.autosave_next = g_savedata.time + g_savedata.autosave_interval
    end

    g_savedata.time = g_savedata.time + 1

    if g_savedata.time >= math.maxinteger then
        g_savedata.time = 0
    end
end

function onCustomCommand(full_message, peer_id, is_admin, is_auth, command, ...)
    if command == "?hop" then -- hop
        -- local peer_id = tonumber(peer_id) or peer_id
        local transform = server.getPlayerPos(peer_id)
        local hop = matrix.multiply(transform, matrix.translation(0, 5, 0))
        local player = get_player(peer_id)

        server.setPlayerPos(peer_id, hop)
        server.announce("[UTILITY]", string.format("%s hopped.", player.name))
    elseif command == "?pin" then -- pin
        local target = ... or "Pin"
        local transform = server.getPlayerPos(peer_id)
        local player = get_player(peer_id)
        local x, y, z = matrix.position(transform)
        local marker = server.getMapID()

        server.addMapObject(-1, marker, 0, 9, x, z, 0, 0, nil, nil, target, 250, "By " .. player.name, 0, 255, 255, 255)
        server.notify(-1, target, "By " .. player.name, 0)
        table.insert(g_savedata.pins, {
            marker = marker,
            player = player,
            transform = transform,
            remain = 18000
        })
    elseif command == "?kill" then -- kill
        local target = ...
        local peer_id = tonumber(target) or peer_id
        local object_id = server.getPlayerCharacterID(peer_id)

        server.killCharacter(object_id)
    elseif command == "?liv" and is_admin then -- list vehicles
        for i = 1, #g_savedata.vehicles do
            server.announce("liv", vehicle_spec_table(g_savedata.vehicles[i]), peer_id)
        end
    elseif command == "?clv" and is_admin then -- clear vehicle
        local target = ...
        local group_id = tonumber(target)

        if not group_id then
            return
        end

        despawn_vehicle_group(group_id, true)
        server.announce("clv", string.format("Removed vehicle #%d and child vehicles.", group_id), peer_id)
    elseif command == "?clpv" and is_admin then -- clear player vehicle
        local target = ...
        local peer_id = tonumber(target) or peer_id
        local player = get_player(peer_id)

        if not player then
            return
        end

        despawn_players_vehicle(player)
        server.announce("clpv", string.format("Removed %s's vehicles.", player.name), peer_id)
    elseif command == "?ttp" and is_admin then -- teleport to player
        local destination, target = ...
        local destination = tonumber(destination)
        local peer_id = tonumber(target) or peer_id
        local transform, is_success = server.getPlayerPos(destination)
        transform = matrix.multiply(transform, matrix.translation(0, 5, 0))

        if not is_success then
            return
        end

        server.setPlayerPos(peer_id, transform)
    elseif command == "?tto" and is_admin then -- teleport to object
        local destination, target = ...
        local destination = tonumber(destination)
        local peer_id = tonumber(target) or peer_id
        local transform, is_success = server.getObjectPos(destination)
        transform = matrix.multiply(transform, matrix.translation(0, 5, 0))

        if not is_success then
            return
        end

        server.setPlayerPos(peer_id, transform)
    elseif command == "?ttv" and is_admin then -- teleport to vehicle
        local destination, target = ...
        local target = tonumber(target)

        if target == nil then
            target = peer_id
        end

        local vehicle_id = tonumber(destination)
        -- local params = {...}

        -- if vehicle_id == nil or #params > 1 then
        --     local pattern = target

        --     for i = 1, #params do
        --         pattern = pattern .. " " .. params[i]
        --     end

        --     local vehicle = table.find(g_savedata.vehicles, function(x)
        --         return string.match(string.lower(x.name), pattern) ~= nil
        --     end)

        --     if vehicle == nil then
        --         server.announce("[ERROR]", string.format("Vehicle %s not found.", pattern), peer_id)
        --         return
        --     end

        --     vehicle_id = vehicle.id
        -- end

        teleport_to_empty_seat(vehicle_id, target)
    elseif command == "?thp" and is_admin then -- telelport here player
        local target = ...
        target = tonumber(target)
        local transform, is_success = server.getPlayerPos(peer_id)
        transform = matrix.multiply(transform, matrix.translation(0, 2, 0))

        if not is_success then
            return
        end

        server.setPlayerPos(target, transform)
    elseif command == "?tho" and is_admin then -- teleport here object
        local target = ...
        target = tonumber(target)
        local transform, is_success = server.getPlayerPos(peer_id)
        transform = matrix.multiply(transform, matrix.translation(0, 2, 0))

        if not is_success then
            return
        end

        server.setObjectPos(target, transform)
    elseif command == "?thv" and is_admin then -- teleport here vehicle
        local target = ...
        target = tonumber(target)
        local data, s = server.getVehicleData(target)

        if not s then
            console.error("Vehicle %d is not exist.", target)
            return
        end

        local transform, is_success = server.getPlayerPos(peer_id)
        local x, y, z = server.getPlayerLookDirection(peer_id)
        local rotation = matrix.rotationToFaceXZ(x, z)
        local ty = matrix.rotationY(z * 0.5)
        transform = matrix.multiply(transform, rotation)
        -- transform = matrix.multiply(transform, matrix.translation(0, 2, 0))

        if not is_success then
            return
        end

        server.setGroupPos(data.group_id, transform)
    elseif command == "?mv" and is_admin then
        local target, x, y, z = ...
        target = tonumber(target)
        local data, s = server.getVehicleData(target)

        if not s then
            console.error("Vehicle %d is not exist.", target)
            return
        end

        x = tonumber(x) or 0
        y = tonumber(y) or 0
        z = tonumber(z) or 0

        local pos = server.getVehiclePos(target)
        pos = matrix.multiply(pos, matrix.translation(x, y, z))
        server.setGroupPos(data.group_id, pos)
    elseif command == "?budget" and is_admin then -- budget
        local verb, amount = ...
        local amount = tonumber(amount)

        if verb == "add" then
            local currency = server.getCurrency()
            server.setCurrency(currency + amount)
        elseif verb == "set" then
            server.setCurrency(amount)
        end
    elseif command == "?pos" and is_admin then -- position
        local transform, is_success = server.getPlayerPos(peer_id)
        local x, y, z = matrix.position(transform)

        server.announce("[LOG]", string.format("%.00f, %.00f, %.00f", x, y, z))
        -- elseif command == "?weather" and is_admin then -- weather
        --     local transform = server.getPlayerPos(peer_id)
        --     local weather = server.getWeather(transform)

        --     server.announce("[LOG]", string.format("fog: %.3f\nrain: %.3f\nsnow: %.3f\nwind: %.3f\ntemp: %.3f", weather.fog, weather.rain, weather.snow, weather.wind, weather.temp))
    elseif (command == "?location" or command == "?l") and is_admin then
        local verb, name = ...

        if verb == "spawn" then
            locations.spawn(name, peer_id)
        elseif verb == "despawn" then
            locations.despawn(name, peer_id)
        elseif verb == "list" then
            local l = locations.load()

            for i = 1, #l do
                console.log(l[i].name, peer_id)
            end
        end
    elseif (command == "?vehicle" or command == "?v") and is_admin then
        local verb, name = ...

        if verb == "autoclear" then
            local _, value = ...

            if value == "true" then
                g_savedata.vehicle_clearing = true
            elseif value == "false" then
                g_savedata.vehicle_clearing = false
            elseif value == nil then
                g_savedata.vehicle_clearing = not g_savedata.vehicle_clearing
            end

            server.announce("[NOTICE]", string.format("Vehicle clearing: %s", g_savedata.vehicle_clearing))
        elseif verb == "keep-active" then
            local _, value = ...

            g_savedata.vehicle_keep_active = set_or_not(g_savedata.vehicle_keep_active, value)
        elseif verb == "tooltip" then
            local _, value = ...

            if value == "true" then
                g_savedata.vehicle_tooltip = true
            elseif value == "false" then
                g_savedata.vehicle_tooltip = false
            elseif value == nil then
                g_savedata.vehicle_tooltip = not g_savedata.vehicle_tooltip
            end

            for i = 1, #g_savedata.vehicles do
                if g_savedata.vehicle_tooltip then
                    set_vehicle_tooltip(g_savedata.vehicles[i])
                else
                    clear_vehicle_tooltip(g_savedata.vehicles[i])
                end
            end

            server.announce("[NOTICE]", string.format("Vehicle tooltip: %s", g_savedata.vehicle_tooltip))
        elseif verb == "list" then
            for i = 1, #g_savedata.vehicles do
                local data = server.getVehicleData(g_savedata.vehicles[i].id)

                console.log(string.format("#%d %s\n%s, static: %s", g_savedata.vehicles[i].id, data.name or "No name", g_savedata.vehicles[i].player.name, data.static), peer_id)
            end

            console.log(string.format("%d vehicles", #g_savedata.vehicles), peer_id)
        end
    elseif command == "?chat" and is_admin then
        chat_ignore = true

        for i = 1, #g_savedata.chats do
            server.announce(g_savedata.chats[i].name, g_savedata.chats[i].message, peer_id)
        end

        console.log(string.format("%d chat messages.", #g_savedata.chats))
        chat_ignore = false
    elseif command == "?autosave-interval" and is_admin then
        local interval = ...
        interval = tonumber(interval)

        if interval ~= nil then
            g_savedata.autosave_interval = interval * 3600
        end
    end
end

function onGroupSpawn(group_id, peer_id, x, y, z, cost)
    if peer_id >= 0 or spawn_by_myself then
        local player = get_player(peer_id)

        for k, vehicle_id in pairs((server.getVehicleGroup(group_id))) do
            local data, s = server.getVehicleData(vehicle_id)
            local tags = string.parse_tags(data.tags_full)

            if tags.cost ~= nil then
                cost = tonumber(tags.cost)
            end

            if data.name == "" then
                data.name = "Vehicle"
            end

            local vehicle = {
                id = vehicle_id,
                name = data.name,
                group_id = group_id,
                vehicle_id = vehicle_id,
                cost = cost,
                player = player
            }

            if spawn_by_myself then
                vehicle.location = spawn_location
                vehicle.tags = tags

                transact(-vehicle.cost, string.format("Purchased a vehicle: %s.", vehicle.location))
            end

            table.insert(g_savedata.vehicles, vehicle)

            if g_savedata.vehicle_tooltip then
                set_vehicle_tooltip(vehicle)
            end

            if g_savedata.vehicle_keep_active then
                server.setVehicleTransponder(vehicle.id, true)
            end
        end

        if not server.getGameSettings().infinite_money and player ~= nil then
            server.notify(-1, string.format("Paid out $%.00f", cost), string.format("%s deployed vehicle.", player.name), 2)
        end
    end
end

function onChatMessage(peer_id, name, message)
    if not chat_ignore then
        table.insert(g_savedata.chats, {
            peer_id = peer_id,
            name = name,
            message = message,
        })
    end
end

function onPlayerJoin(steam_id, name, peer_id, is_admin, is_auth)
    if not is_auth then
        server.addAuth(peer_id)
    end
end

function onVehicleDespawn(vehicle_id, peer_id)
    if peer_id < 0 then
        return
    end

    for i = #g_savedata.vehicles, 1, -1 do
        if g_savedata.vehicles[i].vehicle_id == vehicle_id then
            table.remove(g_savedata.vehicles, i)
        end
    end
end

function despawn_players_vehicle(player)
    for i = #g_savedata.vehicles, 1, -1 do
        if g_savedata.vehicles[i].player ~= nil and g_savedata.vehicles[i].player.steam_id == player.steam_id then
            server.despawnVehicle(g_savedata.vehicles[i].vehicle_id, true)
        end
    end
end

function get_player(peer_id)
    for k, player in pairs(server.getPlayers()) do
        if player.id == peer_id then
            player.steam_id = tostring(player.steam_id)
            return table.copy(player)
        end
    end

    return nil
end

function teleport_to_empty_seat(vehicle_id, peer_id)
    local data, s = server.getVehicleComponents(vehicle_id)
    local teleported = false

    if not s then
        server.announce("[ERROR]", string.format("Vehicle #%s not found.", vehicle_id), peer_id)
    end

    for j = 1, #pilot_seats do
        for i = 1, #data.components.seats do
            local name = string.lower(data.components.seats[i].name)

            if not teleported and name == pilot_seats[j] then
                local object_id = server.getPlayerCharacterID(peer_id)
                server.setSeated(object_id, vehicle_id, data.components.seats[i].pos.x, data.components.seats[i].pos.y, data.components.seats[i].pos.z)
                teleported = teleported or true
            end
        end
    end

    for i = 1, #data.components.seats do
        local seat = server.getVehicleSeat(vehicle_id, data.components.seats[i].pos.x, data.components.seats[i].pos.y, data.components.seats[i].pos.z)

        if seat.seated_id == 4294967295 then
            local object_id = server.getPlayerCharacterID(peer_id)
            server.setSeated(object_id, vehicle_id, data.components.seats[i].pos.x, data.components.seats[i].pos.y, data.components.seats[i].pos.z)
            return
        end
    end

    console.error("No empty seat.", player.id)
end

function despawn_vehicle_group(group_id, is_instant)
    local vehicle_ids = server.getVehicleGroup(group_id)

    for k, v in pairs(vehicle_ids) do
        server.despawnVehicle(v, is_instant or false)
    end
end

function set_vehicle_tooltip(vehicle)
    server.setVehicleTooltip(vehicle.id, vehicle_spec_table(vehicle))
end

function clear_vehicle_tooltip(vehicle)
    server.setVehicleTooltip(vehicle.id, nil)
end

function vehicle_spec_table(vehicle)
    local owner = ""

    if vehicle.player ~= nil then
        owner = vehicle.player.name
    else
        owner = "Addon"
    end

    return string.format("%s\n\nOwner: %s\nGroup ID: %d\nVehicle ID: %d\nCost: %d", vehicle.name, owner, vehicle.group_id, vehicle.id, vehicle.cost)
end

locations = {
    load = function()
        local items = {}
        local addon_index = 0
        local addon_count = server.getAddonCount()

        while addon_index < addon_count do
            local addon_data = server.getAddonData(addon_index)
            addon_data.index = addon_index
            local location_index = 0
            local location_count = addon_data ~= nil and addon_data.location_count or 0

            while location_index < location_count do
                local location_data = server.getLocationData(addon_index, location_index)

                if location_data ~= nil then
                    location_data.index = location_index
                    location_data.addon = addon_data
                    table.insert(items, location_data)
                end

                location_index = location_index + 1
            end

            addon_index = addon_index + 1
        end

        return items
    end,
    spawn = function(name, peer_id)
        local ls = locations.load()
        local l = table.find(ls, function(x)
            return x.name == name
        end)

        if l == nil then
            console.error(string.format("Location %s is not found.", name), peer_id)
            return
        end

        local pos = matrix.identity()
        spawn_by_myself = true
        spawn_location = name
        local outpos, s = server.spawnAddonLocation(pos, l.addon.index, l.index)
        spawn_by_myself = false
        spawn_location = nil

        if not s then
            console.error(string.format("Failed to spawn a location %s.", name), peer_id)
        end
    end,
    despawn = function(name, peer_id)
        for i = #g_savedata.vehicles, 1 do
            if g_savedata.vehicles[i].location == name then
                server.despawnVehicle(g_savedata.vehicles[i].id, true)
            end
        end
    end
}

function transact(amount, title)
    if server.getGameSettings().infinite_money then
        return
    end

    local not_type = 4
    local text = "Accepted $%d"

    if amount == 0 then
        return
    elseif amount < 0 then
        not_type = 2
        text = "Paid out $%d"
    end

    local money = server.getCurrency() + amount

    server.setCurrency(money)
    server.notify(-1, string.format(text, amount), title, not_type)
end

console = {}

function console.log(text, peer_id)
    if peer_id == nil then
        peer_id = -1
    end

    server.announce("[LOG]", text, peer_id)
end

function console.notify(text, peer_id)
    peer_id = peer_id or -1

    if g_savedata.mode == "debug" then
        server.announce("[NOTICE]", text, peer_id)
    end
end

function console.error(text, peer_id)
    peer_id = peer_id or -1

    server.announce("[ERROR]", text, peer_id)
end

function string.parse_tags(tags_full)
    local t = {}

    for k, v in string.gmatch(tags_full, "([%w_]+)=([^%s%c,]+)") do
        t[k] = v
    end

    return t
end

function table.contains(t, x)
    local contains = false

    for i = 1, #t do
        contains = contains or t[i] == x
    end

    return contains
end

function table.find_index(t, test)
    for i = 1, #t do
        if test(t[i]) then
            return i
        end
    end

    return nil
end

function table.find(t, test)
    for i = 1, #t do
        if test == nil or test(t[i]) then
            return t[i], i
        end
    end

    return nil, nil
end

function table.find_all(t, test)
    local items = {}

    for i = 1, #t do
        if test(t[i]) then
            table.insert(items, t[i])
        end
    end

    return items
end

function table.has(t, x)
    for i = 1, #t do
        if t[i] == x then
            return true
        end
    end

    return false
end

function table.keys(t)
    local items = {}

    for k, v in pairs(t) do
        table.insert(items, k)
    end

    return items
end

function table.random(t)
    if #t == 0 then
        return nil
    end

    return t[math.random(1, #t)]
end

function table.select(t, selector)
    local items = {}

    for i = 1, #t do
        local value = selector(t[i])

        if value ~= nil then
            table.insert(items, selector(value))
        end
    end

    return items
end

function table.where(t, selector)
    local items = {}

    for i = 1, #t do
        if selector(t[i]) then
            table.insert(items, t[i])
        end
    end

    return items
end

function table.copy(t)
    local u = {}

    for k, v in pairs(t) do
        if type(v) == "table" then
            u[k] = table.copy(v)
        else
            u[k] = v
        end
    end

    return u
end

function table.distinct(t)
    local u = {}
    local hash = {}

    for _, v in ipairs(t) do
        if not hash[v] then
            u[#u + 1] = v
            hash[v] = true
        end
    end

    return u
end

function table.shuffle(x)
    for i = #x, 2, -1 do
        local j = math.random(i)
        x[i], x[j] = x[j], x[i]
    end
end
