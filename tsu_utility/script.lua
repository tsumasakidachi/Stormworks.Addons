g_savedata = {
    vehicles = {},
    pins = {},
    vehicle_tooltip = property.checkbox("Display custom vehicle tooltip", false),
    vehicle_clearing = property.checkbox("Clear players vehicle on die", false)
}

timing_default = 60
timing = timing_default
pilot_seats = {"pilot", "driver", "co-pilot", "copilot"}

function onTick()
    for i = #g_savedata.pins, 1, -1 do
        if i % timing_default == timing then
            g_savedata.pins[i].remain = g_savedata.pins[i].remain - timing_default

            if g_savedata.pins[i].remain < 0 then
                server.removeMapID(-1, g_savedata.pins[i].marker)
                table.remove(g_savedata.pins, i)
            end
        end
    end

    timing = timing - 1

    if timing <= 0 then
        timing = timing_default
    end
end

function onCustomCommand(full_message, peer_id, is_admin, is_auth, command, target, ...)
    -- hop
    if command == "?hop" then
        -- local peer_id = tonumber(peer_id) or peer_id
        local transform = server.getPlayerPos(peer_id)
        local hop = matrix.multiply(transform, matrix.translation(0, 10, 0))
        local player = get_player(peer_id)

        server.setPlayerPos(peer_id, hop)
        server.announce("[UTILITY]", string.format("%s hopped.", player.name))
    end

    -- pin
    if command == "?pin" then
        local target = target or "Pin"
        local transform = server.getPlayerPos(peer_id)
        local player = get_player(peer_id)
        local x, y, z = matrix.position(transform)
        local marker = server.getMapID()

        server.addMapObject(-1, marker, 0, 9, x, z, 0, 0, nil, nil, target, 0, "By " .. player.name, 0, 255, 255, 255)
        server.notify(-1, target, "By " .. player.name, 0)
        table.insert(g_savedata.pins, {
            marker = marker,
            player = player,
            transform = transform,
            remain = 18000
        })
    end

    -- kill
    if command == "?kill" then
        local object = server.getPlayerCharacterID(peer_id)
        server.killCharacter(object)
    end

    -- list vehicles
    if command == "?liv" and is_admin then
        for i = 1, #g_savedata.vehicles do
            server.announce("liv", vehicle_spec_table(g_savedata.vehicles[i]), peer_id)
        end
    end

    -- clear vehicle
    if command == "?clv" and is_admin then
        local group_id = tonumber(target)

        if not group_id then
            return
        end

        despawn_vehicle_group(group_id, true)
        server.announce("clv", string.format("Removed vehicle #%d", group_id), peer_id)
    end

    -- clear player vehicle
    if command == "?clpv" and is_admin then
        local peer_id = tonumber(target)
        local player = get_player(peer_id)

        if not player then
            return
        end

        despawn_players_vehicle(player)
        server.announce("clpv", string.format("Removed %s's vehicle", player.name), peer_id)
    end

    -- teleport to player
    if command == "?ttp" and is_admin then
        local target_peer_id = tonumber(target)
        local transform, is_success = server.getPlayerPos(target_peer_id)
        transform = matrix.multiply(transform, matrix.translation(0, 5, 0))

        if not is_success then
            return
        end

        server.setPlayerPos(peer_id, transform)
    end

    -- teleport to object
    if command == "?tto" and is_admin then
        local target_object_id = tonumber(target)
        local transform, is_success = server.getObjectPos(target_object_id)
        transform = matrix.multiply(transform, matrix.translation(0, 5, 0))

        if not is_success then
            return
        end

        server.setPlayerPos(peer_id, transform)
    end

    -- teleport to vehicle
    if command == "?ttv" and is_admin then
        if target == nil then
            server.announce("[ERROR]", "Vehicle identifier is invalid.")
            return
        end

        local vehicle_id = tonumber(target)
        local addition = {...}

        if vehicle_id == nil or #addition > 0 then
            local pattern = "^" .. target

            for i = 1, #addition do
                pattern = pattern .. " " .. addition[i]
            end

            local vehicle = table.find(g_savedata.vehicles, function(x)
                return string.match(string.lower(x.name), pattern) ~= nil
            end)

            if vehicle == nil then
                server.announce("[ERROR]", string.format("Vehicle %s not found.", pattern), peer_id)
                return
            end

            vehicle_id = vehicle.id
        end

        teleport_to_empty_seat(vehicle_id, peer_id)
    end

    -- telelport here player
    if command == "?thp" and is_admin then
        local target_peer_id = tonumber(target)
        local transform, is_success = server.getPlayerPos(peer_id)
        transform = matrix.multiply(transform, matrix.translation(0, 2, 0))

        if not is_success then
            return
        end

        server.setPlayerPos(target_peer_id, transform)
    end

    -- teleport here object
    if command == "?tho" and is_admin then
        local target_object_id = tonumber(target)
        local transform, is_success = server.getPlayerPos(peer_id)
        transform = matrix.multiply(transform, matrix.translation(0, 2, 0))

        if not is_success then
            return
        end

        server.setObjectPos(target_object_id, transform)
    end

    -- teleport here vehicle
    if command == "?thv" and is_admin then
        local target_vehicle_id = tonumber(target)
        local transform, is_success = server.getPlayerPos(peer_id)
        transform = matrix.multiply(transform, matrix.translation(0, 2, 0))

        if not is_success then
            return
        end

        server.setVehiclePos(target_vehicle_id, transform)
    end

    -- budget
    if command == "?budget" and is_admin then
        local amount = ...
        local amount = tonumber(amount)

        if target == "add" then
            local currency = server.getCurrency()
            server.setCurrency(currency + amount)
        elseif target == "set" then
            server.setCurrency(amount)
        end
    end

    -- position
    if command == "?pos" and is_admin then
        local transform, is_success = server.getPlayerPos(peer_id)
        local x, y, z = matrix.position(transform)

        server.announce("[LOG]", string.format("%.00f, %.00f, %.00f", x, y, z))
    end

    if command == "?util" and target == "tooltip" and is_admin then
        local value = ...

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
    elseif command == "?util" and target == "clearing" and is_admin then
        local value = ...

        if value == "true" then
            g_savedata.vehicle_clearing = true
        elseif value == "false" then
            g_savedata.vehicle_clearing = false
        elseif value == nil then
            g_savedata.vehicle_clearing = not g_savedata.vehicle_clearing
        end

        server.announce("[NOTICE]", string.format("Vehicle clearing: %s", g_savedata.vehicle_clearing))
    end
end

function onGroupSpawn(group_id, peer_id, x, y, z, cost)
    if peer_id < 0 then
        return
    end

    local player = get_player(peer_id)

    for k, vehicle_id in pairs((server.getVehicleGroup(group_id))) do
        local data, s = server.getVehicleData(vehicle_id)

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

        table.insert(g_savedata.vehicles, vehicle)

        if g_savedata.vehicle_tooltip then
            set_vehicle_tooltip(vehicle)
        end
    end

    if not server.getGameSettings().infinite_money then
        server.notify(-1, string.format("Paid out $%.00f", cost), string.format("%s deployed vehicle.", player.name), 2)
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

