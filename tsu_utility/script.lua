g_savedata = {
    vehicles = {},
    pins = {},
    tooltip = true,
}

timing_default = 60
timing = timing_default

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
    -- kill
    if command == "?kill" then
        for i = #g_savedata.vehicles, 1, -1 do
            if g_savedata.vehicles[i].player.id == peer_id then
                server.despawnVehicle(g_savedata.vehicles[i].vehicle_id, true)
            end
        end

        local object_id, is_success = server.getPlayerCharacterID(peer_id)
        server.killCharacter(object_id)
    end

    -- hop
    if command == "?hop" then
        local target_peer_id = tonumber(target)
        local transform, is_success = server.getPlayerPos(target_peer_id)
        local hop = matrix.translation(0, 10, 0)

        if not is_success then
            return
        end

        server.setPlayerPos(peer_id, matrix.multiply(transform, hop))
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

        for i = #g_savedata.vehicles, 1, -1 do
            if g_savedata.vehicles[i].player.steam_id == player.steam_id then
                server.despawnVehicle(g_savedata.vehicles[i].vehicle_id, true)
            end
        end

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
        local target_vehicle_id = tonumber(target)
        local transform, is_success = server.getVehiclePos(target_vehicle_id)
        transform = matrix.multiply(transform, matrix.translation(0, 5, 0))

        if not is_success then
            return
        end

        server.setPlayerPos(peer_id, transform)
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

    if command == "?tooltip" and is_admin then
        g_savedata.tooltip = not g_savedata.tooltip

        for i = 1, #g_savedata.vehicles do
            if g_savedata.tooltip then
                set_vehicle_tooltip(g_savedata.vehicles[i])
            else
                clear_vehicle_tooltip(g_savedata.vehicles[i])
            end
        end
    end
end

function onGroupSpawn(group_id, peer_id, x, y, z, cost)
    if peer_id < 0 then
        return
    end

    local player = get_player(peer_id)

    if not player then
        return
    end

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

        if g_savedata.tooltip then
            set_vehicle_tooltip(vehicle)
        end
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

function get_player(peer_id)
    for k, player in pairs(server.getPlayers()) do
        if player.id == peer_id then
            return table.copy(player)
        end
    end

    return nil
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
    return string.format("%s\n\nOwner: %s\nGroup ID: %d\nVehicle ID: %d\nCost: %d", vehicle.name, vehicle.player.name, vehicle.group_id, vehicle.id, vehicle.cost)
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

