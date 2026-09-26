g_savedata = {
    mode = "prod",
    clock = 0,
    vehicles = {},
}


framework = {
    name = "TSU Utility",
    version = "1.0.0",
    commands = {},
    players = {},
    on_load = function()
        framework.register_command("?util", "version", nil, nil, function(full_message, peer_id, is_admin, is_auth, subject, verb) return is_admin, peer_id end, framework.print_version)
        framework.register_command("?util", "prod", nil, nil, function(full_message, peer_id, is_admin, is_auth, subject, verb) return is_admin end, function() g_savedata.mode = "prod" end)
        framework.register_command("?util", "debug", nil, nil, function(full_message, peer_id, is_admin, is_auth, subject, verb) return is_admin end, function() g_savedata.mode = "debug" end)
        framework.register_command("?util", "commands", nil, nil, function(full_message, peer_id, is_admin, is_auth, subject, verb) return is_admin, peer_id end, framework.print_all_commands)
        framework.register_command("?util", "hop", "?hop", nil, function(full_message, peer_id, is_admin, is_auth, subject, verb) return true, peer_id end, util.hop)
        framework.register_command("?util", "pin", "?pin", nil, function(full_message, peer_id, is_admin, is_auth, subject, verb) return true, peer_id end, util.pin)
        framework.register_command("?util", "sos", "?sos", nil, function(full_message, peer_id, is_admin, is_auth, subject, verb) return true, peer_id end, util.sos)
        framework.register_command("?util", "position", "?pos", nil, function(full_message, peer_id, is_admin, is_auth, subject, verb) return true, peer_id end, function(peer_id)
            local x, y, z = matrix.position((server.getPlayerPos(peer_id)))
            console.log(string.format("%.3f, %.3f, %.3f", x, y, z))
        end)
        framework.register_command("?util", "clear", "?clear", "[peer_id]", function(full_message, peer_id, is_admin, is_auth, subject, verb, target_peer_id)
            if is_admin and target_peer_id ~= nil then
                peer_id = tonumber(target_peer_id)
            end

            return true, table.find(framework.players, function(p) return p.id == peer_id end)
        end, util.clear_my_vehicles)
        framework.register_command("?util", "teleport", "?tp", "[peer_id]", function(full_message, peer_id, is_admin, is_auth, subject, verb, target_peer_id) return true, peer_id, tonumber(target_peer_id) end, util.teleport)
        framework.register_command("?util", "teleport-to-player", "?ttp", "[peer_id]", function(full_message, peer_id, is_admin, is_auth, subject, verb, target_peer_id) return is_admin, peer_id, tonumber(target_peer_id) end, util.teleport_to_player)
        framework.register_command("?util", "teleport-here-player", "?thp", "[peer_id]", function(full_message, peer_id, is_admin, is_auth, subject, verb, target_peer_id) return is_admin, peer_id, tonumber(target_peer_id) end, util.teleport_here_player)
        framework.register_command("?util", "teleport-to-vehicle", "?ttv", "[vehicle_id]", function(full_message, peer_id, is_admin, is_auth, subject, verb, target_vehicle_id) return is_admin, peer_id, tonumber(target_vehicle_id) end,
            util.teleport_to_vehicle)
        framework.register_command("?util", "teleport-here-vehicle", "?thv", "[vehicle_id]", function(full_message, peer_id, is_admin, is_auth, subject, verb, target_vehicle_id) return is_admin, peer_id, tonumber(target_vehicle_id) end,
            util.teleport_here_vehicle)
        framework.register_command("?util", "kill", "?kill", "[peer_id]", function(full_message, peer_id, is_admin, is_auth, subject, verb, target_peer_id)
            if is_admin and target_peer_id ~= nil then
                target_peer_id = tonumber(target_peer_id)
            else
                target_peer_id = peer_id
            end
            return true, peer_id, target_peer_id
        end, util.kill)
        framework.register_command("?util", "budget", nil, "[money], [research_point]", function(full_message, peer_id, is_admin, is_auth, subject, verb, money, rp) return is_admin, tonumber(money), tonumber(rp) end, util.set_money)
        framework.register_command("?util", "storage", nil, nil, function(full_message, peer_id, is_admin, is_auth, subject, verb) return is_admin, peer_id end, function(peer_id)
            local transform = server.getPlayerPos(peer_id)
            local coal, uranium, diesel, jet, solid_propellant = server.getTileInventory(transform)

            console.log(string.format("coal: %.0f\nuranium: %.0f\ndiesel: %.0f\njet: %.0f,\nsolid propellant: %.0f", coal, uranium, diesel, jet, solid_propellant), peer_id)
        end)
    end,
    on_create = function(is_world_create)
        if g_savedata.mode == "debug" then
            framework.print_version()
            console.log(string.format("%d deployed vehicles", #g_savedata.vehicles))
        end
    end,
    on_tick = function(tick)
        math.randomseed(server.getTimeMillisec())

        if g_savedata.clock % 10 == 0 then
            framework.players = player.load()
        end

        g_savedata.clock = g_savedata.clock + 1
    end,
    on_group_spawn = function(group_id, peer_id, x, y, z, group_cost)
        if peer_id < 0 then return end

        local p = table.find(framework.players, function(p) return p.id == peer_id end)

        for k, v in ipairs(server.getVehicleGroup(group_id)) do
            local data = server.getVehicleData(v)

            data.id = v
            data.owner_steam_id = p.steam_id

            if k == 1 then
                data.cost = group_cost
            else
                data.cost = 0
            end

            table.insert(g_savedata.vehicles, data)
        end

        server.notify(-1, string.format("Paid out $%d.", group_cost), string.format("%s deployed vehicles.", p.name), 2)
    end,
    on_vehicle_despawn = function(vehicle_id)
        for i = #g_savedata.vehicles, 1, -1 do
            if g_savedata.vehicles[i].id == vehicle_id then
                table.remove(g_savedata.vehicles, i)
            end
        end
    end,
    on_player_join = function(steam_id, name, peer_id, is_admin, is_auth)
        server.addAuth(peer_id)
    end,
    on_custom_command = function(...)
        local args = { ... }
        local subject = args[5]
        local verb = args[6]
        local command = table.find(framework.commands, function(x) return x.subject == subject and x.verb == verb or x.shorthand == subject end)

        if command == nil then
            return
        end

        if command.shorthand == subject then
            table.move(args, 5, #args, 6)
        end

        framework.invoke_command(command, command.guard(table.unpack(args)))
    end,
    register_command = function(subject, verb, shorthand, args, guard, execute)
        if guard == nil then
            guard = function() return true end
        end

        table.insert(framework.commands, {
            subject = subject,
            verb = verb,
            shorthand = shorthand,
            args = args,
            execute = execute,
            guard = guard,
        })
    end,
    print_all_commands = function(peer_id)
        for _, command in ipairs(framework.commands) do
            local text = string.format("%s %s", command.subject, command.verb)

            if command.args ~= nil then
                text = text .. " " .. command.args
            end

            console.log(text, peer_id)
        end
    end,
    print_version = function(peer_id)
        console.log(string.format("%s %s", framework.name, framework.version), peer_id)
    end,
    invoke_command = function(command, can_execute, ...)
        if not can_execute then return end

        command.execute(table.unpack({ ... }))
    end,
}


util = {
    hop = function(peer_id)
        server.setPlayerPos(peer_id, matrix.multiply((server.getPlayerPos(peer_id)), matrix.translation(0, 10, 0)))
        console.log(string.format("%s hopped.", (server.getPlayerName(peer_id))))
    end,
    kill = function(actor_peer_id, target_peer_id)
        server.killCharacter((server.getPlayerCharacterID(target_peer_id)))
        console.log(string.format("%s killed by %s.", (server.getPlayerName(target_peer_id)), (server.getPlayerName(actor_peer_id))))
    end,
    teleport = function(actor_peer_id, target_peer_id)
        local oid, s = server.getPlayerCharacterID(target_peer_id)

        if not s then
            return
        end

        local vid = server.getCharacterVehicle(oid)
        local ttp = false

        if vid > 0 then
            ttp = util.teleport_to_vehicle(actor_peer_id, vid)
        end

        if not ttp then
            util.teleport_to_player(actor_peer_id, target_peer_id)
        end
    end,
    teleport_to_player = function(actor_peer_id, target_peer_id, offset)
        local t, s = server.getPlayerPos(target_peer_id)

        if not s then return end
        if offset == nil then offset = matrix.translation(0, 1, 0) end

        t = matrix.multiply(t, offset)
        server.setPlayerPos(actor_peer_id, t)
        console.log(string.format("%s teleported to %s.", (server.getPlayerName(actor_peer_id)), (server.getPlayerName(target_peer_id))))
    end,
    teleport_here_player = function(actor_peer_id, target_peer_id, offset)
        local t, s = server.getPlayerPos(actor_peer_id)

        if not s then return end
        if offset == nil then offset = matrix.translation(0, 1, 0) end

        t = matrix.multiply(t, offset)
        server.setPlayerPos(target_peer_id, t)
        console.log(string.format("%s teleported to %s.", (server.getPlayerName(target_peer_id)), (server.getPlayerName(actor_peer_id))))
    end,
    teleport_to_vehicle = function(actor_peer_id, target_vehicle_id)
        local oid = server.getPlayerCharacterID(actor_peer_id)
        local data, s = server.getVehicleComponents(target_vehicle_id)

        if not s then return false end

        local seat = table.random(table.find_all(data.components.seats, function(s) return s.seated_id == 4294967295 end))

        if seat == nil then return false end

        server.setSeated(oid, target_vehicle_id, seat.pos.x, seat.pos.y, seat.pos.z)
        console.log(string.format("%s teleported to vehicle#%d.", (server.getPlayerName(actor_peer_id)), target_vehicle_id))

        return true
    end,
    teleport_here_vehicle = function(actor_peer_id, target_vehicle_id, offset)
        local data, s = server.getVehicleData(target_vehicle_id)

        if not s then return end
        if offset == nil then offset = matrix.translation(0, 5, 0) end

        local s = server.moveGroup(data.group_id, matrix.multiply((server.getPlayerPos(actor_peer_id)), offset))
        console.log(string.format("vehicle#%d moved to %s.", target_vehicle_id, (server.getPlayerName(actor_peer_id))))
    end,
    set_money = function(money, rp)
        if money == nil then
            money = server.getCurrency()
        end

        if rp == nil then
            rp = server.getResearchPoints()
        end

        server.setCurrency(money, rp)
    end,
    clear_my_vehicles = function(p)
        if p == nil then return end

        local cost = 0

        for i = #g_savedata.vehicles, 1, -1 do
            if g_savedata.vehicles[i].owner_steam_id == p.steam_id then
                cost = cost + g_savedata.vehicles[i].cost
                server.despawnVehicle(g_savedata.vehicles[i].id, true)
            end
        end

        server.notify(-1, string.format("Lost $%d.", cost), string.format("%s abandoned some vehicles. ", p.name), 2)
    end,
}


player = {
    init = function(p)
        if p.id == 0 and p.name == "Server" then
            return nil
        end

        p.object_id, found_player_character = server.getPlayerCharacterID(p.id)

        if not found_player_character then return nil end

        p.steam_id = tostring(p.steam_id)
        p.transform = server.getObjectPos(p.object_id)
        p.vehicle_id = server.getCharacterVehicle(p.object_id)
        p.vital = server.getObjectData(p.object_id)

        return p
    end,
    load = function()
        local players = {}

        for _, p in ipairs(server.getPlayers()) do
            local p = player.init(p)

            if p ~= nil then
                table.insert(players, p)
            end
        end

        return players
    end,
}


console = {
    log = function(text, peer_id)
        peer_id = peer_id or -1

        server.announce("[LOG]", text, peer_id)
    end,
    notify = function(text, peer_id)
        peer_id = peer_id or -1

        if g_savedata.mode == "debug" then
            server.announce("[NOTICE]", text, peer_id)
        end
    end,
    error = function(text, peer_id)
        peer_id = peer_id or -1

        server.announce("[ERROR]", text, peer_id)
    end
}


string.split        = function(s, separator)
    local t = {}

    for part in string.gmatch(s, "([^" .. separator .. "]+)") do
        table.insert(t, part)
    end

    return t
end

string.nil_or_empty = function(s)
    return s == nil or s == ""
end

table.aggregate     = function(t, result, func)
    for k, v in pairs(t) do
        result = func(result, v)
    end

    return result
end


table.any        = function(t, test)
    local any = false

    for i = 1, #t do
        any = any or test(t[i], i)
    end

    return any
end

table.all        = function(t, test)
    local all = true

    for i = 1, #t do
        all = all and test(t[i], i)
    end

    return all
end

table.contains   = function(t, x)
    local contains = false

    for i = 1, #t do
        contains = contains or t[i] == x
    end

    return contains
end

table.find_index = function(t, test)
    for k, v in pairs(t) do
        if test(v, k) then
            return k
        end
    end

    return nil
end

table.find       = function(t, test)
    for k, v in pairs(t) do
        if test(v, k) then
            return v
        end
    end

    -- for i = 1, #t do
    --   if test == nil or test(t[i], i) then
    --     return t[i], i
    --   end
    -- end

    return nil
end

table.find_all   = function(t, test)
    local items = {}

    for i = 1, #t do
        if test(t[i], i) then
            table.insert(items, t[i])
        end
    end

    return items
end

table.for_each   = function(t, action)
    for i = 1, #t do
        action(t[i], i)
    end
end

table.has        = function(t, x)
    for i = 1, #t do
        if t[i] == x then
            return true
        end
    end

    return false
end

table.intersect  = function(m, n)
    local r = {}

    for i = 1, #m do
        for j = 1, #n do
            if n[j] == m[i] then
                table.insert(r, m[i])
            end
        end
    end

    return r
end

table.keys       = function(t)
    local items = {}

    for k, v in pairs(t) do
        table.insert(items, k)
    end

    return items
end

table.random     = function(t)
    if #t == 0 then
        return nil
    end

    local keys = table.keys(t)

    return t[keys[math.random(1, #keys)]]
end

table.select     = function(t, selector)
    local items = {}

    for i = 1, #t do
        local value = selector(t[i], i)

        if value ~= nil then
            table.insert(items, value)
        end
    end

    return items
end

table.where      = function(t, selector)
    local items = {}

    for i = 1, #t do
        if selector(t[i], i) then
            table.insert(items, t[i])
        end
    end

    return items
end

table.copy       = function(t)
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

table.distinct   = function(t)
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

table.join       = function(t1, t2)
    for k, v in pairs(t2) do
        if t1[k] == nil then
            t1[k] = v
        end
    end
end

table.shuffle    = function(x)
    for i = #x, 2, -1 do
        local j = math.random(i)
        x[i], x[j] = x[j], x[i]
    end
end

table.take       = function(t, start, length)
    local u = {}

    if start == nil then start = 1 end
    if length == nil then length = #t end

    local i = 0

    while i < length do
        table.insert(u, t[start + i])
        i = i + 1
    end

    return u
end


onCreate         = framework.on_create
onTick           = framework.on_tick
onCustomCommand  = framework.on_custom_command
onGroupSpawn     = framework.on_group_spawn
onVehicleDespawn = framework.on_vehicle_despawn
onPlayerJoin     = framework.on_player_join
framework.on_load()
