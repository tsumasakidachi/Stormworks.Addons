-- TSU Battle Foundation 1.0
-- properties
g_savedata = {
    mode = "debug",
    objects = {},
    game = nil,
    zones = {}
}

zone_properties = {{
    landscape = "base",
    mapped = false,
    icon = 4
}, {
    landscape = "objective",
    mapped = false,
    icon = 1
}}

games = {{
    tracker = "cqt",
    name = "conquest",
    point_of_match = 60,
    deploy_point_start = 200,
    teams = {}
}, {
    tracker = "flg",
    name = "flag",
    point_of_match = 60,
    deploy_point_start = 200,
    teams = {}
}, {
    tracker = "dst",
    name = "destraction",
    point_of_match = 60,
    deploy_point_start = 200,
    teams = {}
}}

maps = {{
    map = "holt_bridge",
    name = "holt bridge",
    center = matrix.translation(-1000, 0, -5000),
    radius = 3000
}, {
    map = "twin_hills",
    name = "twin hills",
    center = matrix.translation(-12400, 0, -31900),
    radius = 2000
}}

game_trackers = {
    cqt = {
        init = function(self, game)
            game.teams = {{
                name = "red",
                match_point = 0,
                delpoy_point = 0
            }, {
                name = "blue",
                match_point = 0,
                delpoy_point = 0
            }}

            game.zones = {}

            for i = 1, #g_savedata.zones do
                if g_savedata.zones[i].tags.map == game.map then
                    table.insert(game.zones, {
                        id = i,
                        value = 0,
                        delta = 0,
                        conquest_by = nil
                    })
                end
            end

            draw_operation_zone(-1, game)
        end,
        clear = function(self, game)
            clear_operation_zone(-1, game)
        end,
        tick = function(self, game, tick)
            if timing == 0 then
                for i = 1, #game.zones do
                    game.zones[i].value = math.min(self.zone_conquest_threshold, math.max(-self.zone_conquest_threshold, game.zones[i].value + game.zones[i].delta))
                    game.zones[i].delta = 0

                    if game.zones[i].value <= -self.zone_conquest_threshold then
                        game.zones[i].conquest_by = 1
                        game.teams[1].match_point = math.min(game.point_of_match, game.teams[1].match_point + 1)
                    elseif game.zones[i].value >= self.zone_conquest_threshold then
                        game.zones[i].conquest_by = 2
                        game.teams[2].match_point = math.min(game.point_of_match, game.teams[2].match_point + 1)
                    else
                        game.zones[i].conquest_by = nil
                    end

                    -- console.notify(string.format("%s: %s", g_savedata.zones[game.zones[i].id].name, game.zones[i].conquest_by))
                end
            end

            for i = 1, #game.players do
                if i % cycle == timing then
                    local transform, is_success = server.getPlayerPos(game.players[i])

                    for j = 1, #game.zones do
                        if g_savedata.zones[game.zones[j].id].landscape == "objective" and is_in_zone(transform, g_savedata.zones[game.zones[j].id]) then
                            console.notify(game.players[i].team_id)

                            if game.players[i].team_id == 1 then
                                game.zones[j].delta = game.zones[j].delta - 1
                            elseif game.players[i].team_id == 2 then
                                game.zones[j].delta = game.zones[j].delta + 1
                            end
                        end
                    end
                end
            end
        end,
        completed = function(self, game)
        end,
        referesh_ui = function(self, game, peer_id)
        end,
        zone_conquest_threshold = 100
    },
    dst = {
        init = function(self, game)
            game.teams = {{
                name = "red",
                ready = false,
                winner = false,
                vehicles = 0,
                deploy_point = 120,
                deploy_point_per_min = 0,
                color = {
                    r = 191,
                    g = 0,
                    b = 0,
                    a = 255
                }
            }, {
                name = "blue",
                ready = false,
                winner = false,
                vehicles = 0,
                deploy_point = 120,
                deploy_point_per_min = 0,
                color = {
                    r = 0,
                    g = 0,
                    b = 191,
                    a = 255
                }
            }}

            draw_operation_zone(-1, game)
        end,
        clear = function(self, game)
            clear_operation_zone(-1, game)
        end,
        tick = function(self, game, tick)
            if not game.started then

                local s = true

                for i = 1, #game.teams do
                    s = s and game.teams[i].ready
                end
                game.started = s

                if game.started then
                    server.notify(-1, "GAME START", string.format("%s\n%s", string.upper(game.name), string.upper(game.map.name)), 5)
                end
            end

            if not game.finished then
                local c = #game.teams

                for i = 1, #game.teams do
                    if game.teams[i].vehicles <= 0 then
                        c = c - 1
                    end
                end

                game.finished = c <= 1

                if game.started then
                    server.notify(-1, "GAME OVER", string.format("%s\n%s", string.upper(game.name), string.upper(game.map.name)), 5)
                end
            end
        end,
        started = function(self, game)
            return game.started
        end,
        finished = function(self, game)
            return game.finished
        end,
        join = function(self, game, peer_id)
            draw_operation_zone(peer_id, game)
        end,
        deploy = function(self, game, vehicle)
            local member = table.find(game.team_members, function(x)
                return x.steam_id == vehicle.owner.steam_id
            end)

            game.teams[member.team_id].vehicles = game.teams[member.team_id].vehicles + 1
        end,
        destroy = function(self, game, vehicle)
            local member = table.find(game.team_members, function(x)
                return x.steam_id == vehicle.owner.steam_id
            end)

            game.teams[member.team_id].vehicles = game.teams[member.team_id].vehicles - 1
        end,
        status = function(self, game)
            local text = ""

            for i = 1, #game.teams do

            end
        end
    }
}

object_trackers = {
    vehicle = {
        test_type = function(self, object)
            return object.type == "vehicle"
        end,
        init = function(self, object, group_id, group_cost, owner_steam_id)
            object.group_id = group_id
            object.cost = group_cost
            object.owner = {
                steam_id = tostring(owner_steam_id)
            }
            object.flag = false
            object.components_checked = false
            object.mass = 0
            object.voxels = 0
            object.deploy_point = 0
            object.hp = 0
            object.seats = {}

            if object.name == "" then
                object.name = "Vehicle"
            end
        end,
        load = function(self, object)
            if not object.components_checked then
                vehicle_components(object)

                object.deploy_point = math.ceil(object.mass / 100)
                object.hp = object.mass * 3

                if g_savedata.game ~= nil then
                    deploy_vehicle(g_savedata.game, object)
                end

                if g_savedata.mode == "debug" then
                    server.setVehicleTooltip(object.id, vehicle_spec_table(object))
                end
            end
        end,
        spawn = function(self, object)
        end,
        despawn = function(self, object)
        end,
        clear = function(self, object)
            if g_savedata.game ~= nil then
                destroy_vehicle(g_savedata.game, object)
            end
        end,
        tick = function(self, object, tick)
            if object.components_checked and object.hp <= 0 then
                local transform = server.getVehiclePos(object.id)
                despawn_vehicle_group(object.group_id, true)
                server.spawnExplosion(transform, 0.2)
            end
        end,
        damage = function(self, object, damage)
            object.hp = object.hp - math.max(damage, 0)
        end,
        position = function(self, object)
            return server.getVehiclePos(object.id)
        end
    }
}

-- games

function initialize_game(mode, map, count_team, point_of_match)
    local game = {
        tracker = mode.tracker,
        started = false,
        finished = false,
        name = mode.name,
        map = map,
        stats_marker_id = server.getMapID(),
        operation_zone_marker_id = server.getMapID(),
        count_team = count_team or 2,
        point_of_match = point_of_match or g_savedata.point_of_match,
        team_members = {}
    }

    game_trackers[game.tracker]:init(game)
    game.team_members = team_members(math.min(2, count_team))
    g_savedata.game = game

    server.notify(-1, "MATCHMAKING...", string.format("%s\n%s", string.upper(game.name), string.upper(game.map.name)), 5)
    console.notify(string.format("Matchmaking %s...", game.name))

    for i = 1, #game.team_members do
        local players = server.getPlayers()

        for j = 1, #players do
            if tostring(players[j].steam_id) == game.team_members[i].steam_id then
                console.notify(string.format("%s joined %s team", players[j].name, game.teams[game.team_members[i].team_id].name))
            end
        end
    end
end

function clear_game(game)
    for i = #g_savedata.objects, 1, -1 do
        despawn_object(g_savedata.objects[i])
    end

    game_trackers[game.tracker]:clear(game)
    g_savedata.game = nil
    console.notify("Cleared ongoing game")
end

function game_tick(game, tick)
    game_trackers[g_savedata.game.tracker]:tick(game, tick)
end

function map_game_stats(game, peer_id)
    local text = string.format("%s\n%s", string.upper(game.name), string.upper(game.map.name))
end

function ready(game, steam_id)
    local member = table.find(game.team_members, function(x)
        return x.steam_id == tostring(steam_id)
    end)

    if member == nil then
        return
    end

    game.teams[member.team_id].ready = not game.teams[member.team_id].ready

    local text = ""

    if game.teams[member.team_id].ready then
        text = "READY"
    else
        text = "GETTING READY..."
    end

    server.notify(-1, string.format("%s TEAM IS %s", string.upper(game.teams[member.team_id].name), text), nil, 5)
end

-- objects

function initialize_object(id, object, ...)
    local params = {...}

    for k, v in pairs(object_trackers) do
        if v:test_type(object) then
            object.tracker = k
            break
        end
    end

    object.id = id
    object.marker_id = server.getMapID()
    object.exists = true

    if object.tracker then
        object_trackers[object.tracker]:init(object, table.unpack(params))
    end

    table.insert(g_savedata.objects, object)
    console.notify(string.format("Initializing object %s#%d.", object.type, object.id))
end

function clear_object(object)
    if object.tracker ~= nil then
        object_trackers[object.tracker]:clear(object)
    end

    object.exists = false
    console.notify(string.format("Cleared object %s#%d.", object.type, object.id))
end

function despawn_object(object)
    if object.type == "character" then
        server.despawnObject(object.id, true)
    elseif object.type == "vehicle" then
        despawn_vehicle_group(object.group_id, true)
    else
        server.despawnObject(object.id, true)
    end
end

function tick_object(object, tick)
    object_trackers[object.tracker]:tick(object, tick)
end

function deploy_vehicle(game, vehicle)
    local member = table.find(game.team_members, function(x)
        return x.steam_id == vehicle.owner.steam_id
    end)

    game.teams[member.team_id].deploy_point = game.teams[member.team_id].deploy_point - vehicle.deploy_point

    if game.teams[member.team_id].deploy_point < 0 then
        console.notify(string.format("You need %d points to deploy this vehicle.", vehicle.deploy_point))
        server.despawnVehicleGroup(vehicle.group_id, true)
    end

    map_vehicle_friendry(game, vehicle)
    game_trackers[g_savedata.game.tracker]:deploy(game, vehicle)
end

function destroy_vehicle(game, vehicle)
    unmap_vehicle_friendry(game, vehicle)
    game_trackers[g_savedata.game.tracker]:destroy(game, vehicle)
end

function damage_vehicle(vehicle, damage)
    if vehicle.tracker ~= "vehicle" then
        return
    end

    object_trackers[vehicle.tracker]:damage(vehicle, damage)
end

function vehicle_components(object)
    local bodies, s = server.getVehicleGroup(object.group_id)

    for j = 1, #bodies do
        local d, s = server.getVehicleComponents(bodies[j])

        object.voxels = object.voxels + d.voxels
        object.mass = object.mass + d.mass

        if j == 1 then
            for k = 1, #d.components.seats do
                table.insert(object.seats, d.components.seats[k])
            end
        end
    end

    object.components_checked = true
end

function map_vehicle_friendry(game, vehicle)
    local owner = table.find(game.team_members, function(x)
        return x.steam_id == vehicle.owner.steam_id
    end)

    local players = server.getPlayers()

    for i = 1, #players do
        local member = table.find(game.team_members, function(x)
            return x.steam_id == tostring(players[i].steam_id) and x.team_id == owner.team_id
        end)

        if member ~= nil then
            server.addMapObject(players[i].id, vehicle.marker_id, 1, 14, 0, 0, 0, 0, vehicle.id, nil, vehicle.name, 0, nil, game.teams[member.team_id].color.r, game.teams[member.team_id].color.g, game.teams[member.team_id].color.b, 255)
        end
    end
end

function unmap_vehicle_friendry(game, vehicle)
    local owner = table.find(game.team_members, function(x)
        return x.steam_id == vehicle.owner.steam_id
    end)

    local players = server.getPlayers()

    for i = 1, #players do
        local member = table.find(game.team_members, function(x)
            return x.steam_id == tostring(players[i].steam_id) and x.team_id == owner.team_id
        end)

        if member ~= nil then
            server.removeMapID(players[i].id, vehicle.marker_id)
        end
    end

    console.notify("oi")
end

function vehicle_spec_table(vehicle)
    local player = get_player()
    return string.format("%s\n\nOwner: %s\nGroup ID: %d\nVehicle ID: %d\nDeploy points: %d\nCost: %d\nVoxels: %d\nMass: %d", vehicle.name, "test", vehicle.group_id, vehicle.id, vehicle.deploy_point, vehicle.cost, vehicle.voxels, math.floor(vehicle.mass))
end

-- zones

function is_zone_out_range(zone, center, range_max)
    return matrix.distance(center, zone.transform) > range_max
end

function is_zone_in_range(zone, center, range_max, range_min)
    local d = matrix.distance(center, zone.transform)
    return d >= range_min and d <= range_max
end

function is_in_landscape(transform, landscape)
    local is = false

    for i = 1, #g_savedata.zones do
        is = is or g_savedata.zones[i].landscape == landscape and is_in_zone(transform, g_savedata.zones[i])
    end

    return is
end

function is_in_zone(transform, zone)
    return server.isInTransformArea(transform, zone.transform, zone.size.x, zone.size.y, zone.size.z)
end

function map_zone(zone, peer_id)
    if peer_id == nil then
        peer_id = -1
    end

    if g_savedata.zone_mapped or zone.mapped then
        local x, y, z = matrix.position(zone.transform)
        local color = zone.icon == 8 and 255 or 0
        local name = zone.name

        if name == "" then
            name = zone.landscape
        end

        server.addMapLabel(peer_id, zone.marker_id, zone.icon, name, x, z, color, color, color, 255)
    end
end

function load_zones()
    for i = 1, #g_savedata.zones do
        server.removeMapID(-1, g_savedata.zones[i].marker_id)
    end

    g_savedata.zones = {}

    local zone_type_ids = table.keys(zone_properties)
    local id = 1

    for _, zone in pairs(server.getZones()) do
        local tags = parse_tags(zone.tags_full)

        for i = 1, #zone_properties do
            if tags.landscape and zone_properties[i].landscape == tags.landscape then
                zone.id = id
                zone.tags = tags
                zone.landscape = zone_properties[i].landscape
                zone.marker_id = server.getMapID()
                zone.mapped = zone_properties[i].mapped or false
                zone.icon = zone_properties[i].icon or 0

                map_zone(zone)
                table.insert(g_savedata.zones, zone)

                id = id + 1
            end
        end
    end
end

-- players

players = {}

function team_members(count)
    local players = server.getPlayers()
    local members = {}

    if players[1].name == "Server" then
        table.remove(players, 1)
    end

    table.shuffle(players)

    for i = 1, #players do
        local player = {
            steam_id = tostring(players[i].steam_id),
            team_id = (i % count)
        }
        table.insert(members, player)
    end

    return members
end

-- UIs

function draw_operation_zone(peer_id, game)
    local t1 = 0
    local x1 = game.map.radius * math.cos(t1 * math.pi)
    local y1 = game.map.radius * math.sin(t1 * math.pi)
    local t2, x2, y2 = 0, 0, 0

    for i = 1, 60, 1 do
        t2 = 2 / 60 * i
        x2 = game.map.radius * math.cos(t2 * math.pi)
        y2 = game.map.radius * math.sin(t2 * math.pi)

        server.addMapLine(peer_id, game.operation_zone_marker_id, matrix.multiply(game.map.center, matrix.translation(x1, 0, y1)), matrix.multiply(game.map.center, matrix.translation(x2, 0, y2)), 1, 255, 255, 255, 255)

        t1 = t2
        x1 = x2
        y1 = y2
    end
end

function clear_operation_zone(peer_id, game)
    server.removeMapID(peer_id, g_savedata.game.operation_zone_marker_id)
end

function draw_conquest_zone(peer_id, game, zone)
    local cx, _, cz = matrix.position(zone.transform)
    local x1 = cx + zone.x / 2
    local y1 = cz + zone.z / 2
    local x2 = cx + zone.x / 2
    local y2 = cz - zone.z / 2
    local x3 = cx - zone.x / 2
    local y3 = cz - zone.z / 2
    local x4 = cx - zone.x / 2
    local y4 = cz + zone.z / 2

    local xd1 = 0
end

-- callbacks

cycle = 60
timing = 0

function onTick(tick)
    math.randomseed(server.getTimeMillisec())

    if timing == 0 then
        players = server.getPlayers()
    end

    if timing == 0 and g_savedata.game ~= nil then
        game_tick(g_savedata.game, tick)
    end

    for i = #g_savedata.objects, 1, -1 do
        if i % cycle == timing and g_savedata.objects[i].tracker ~= nil then
            tick_object(g_savedata.objects[i], tick)

            if not g_savedata.objects[i].exists then
                table.remove(g_savedata.objects, i)
            end
        end
    end

    if timing + 1 < cycle then
        timing = timing + 1
    else
        timing = 0
    end
end

function onCustomCommand(full_message, user_peer_id, is_admin, is_auth, command, verb, ...)
    if command == "?battle" then
        if is_admin and verb == "init" then
            local gamemode, mapname, count_team, point_of_match = ...
            count_team = tonumber(count_team) or 2
            point_of_match = tonumber(point_of_match) or 300
            local game = table.find(games, function(x)
                return x.tracker == gamemode
            end)

            if game == nil then
                console.error(string.format("%s is not valid gamemode", gamemode))
                return
            end

            local map = table.find(maps, function(x)
                return x.map == mapname
            end)

            if map == nil then
                console.error(string.format("%s is not valid map", mapname))
                return
            end

            if g_savedata.game ~= nil then
                clear_game(g_savedata.game)
            end

            initialize_game(game, map, point_of_match)
        elseif is_admin and verb == "clear" then
            clear_game(g_savedata.game)
        end
    elseif command == "?ready" then
        if g_savedata.game == nil then
            return
        end

        local player = get_player(user_peer_id)

        ready(g_savedata.game, tostring(player.steam_id))
    end
end

function onCreate(is_world_create)
    load_zones()

    console.notify(string.format("Zones: %d", #g_savedata.zones))
    console.notify(string.format("Objects: %d", #g_savedata.objects))
end

function onGroupSpawn(group_id, peer_id, x, y, z, group_cost)
    if peer_id < 0 then
        return
    end

    local bodies, s = server.getVehicleGroup(group_id)

    if not s then
        console.error(string.format("Spawned vehicle #%d, which has no body", group_id))
        return
    end

    local main, s = server.getVehicleData(bodies[1])
    if not s then
        console.error(string.format("Spawned vehicle #%d, which has no body", group_id))
        return
    end

    main.type = "vehicle"

    local owner = get_player(peer_id)

    initialize_object(bodies[1], main, group_id, group_cost, owner.steam_id)
end

function onVehicleLoad(vehicle_id)
    for i = 1, #g_savedata.objects do
        if g_savedata.objects[i].type == "vehicle" and g_savedata.objects[i].id == vehicle_id then
            object_trackers.vehicle:load(g_savedata.objects[i])
        end
    end
end

function onVehicleDespawn(vehicle_id, peer_id)
    for i = #g_savedata.objects, 1, -1 do
        if g_savedata.objects[i].type == "vehicle" and g_savedata.objects[i].id == vehicle_id then
            clear_object(g_savedata.objects[i])
        end
    end
end

function onVehicleDamaged(vehicle_id, damage_amount, voxel_x, voxel_y, voxel_z, body_index)
    for i = #g_savedata.objects, 1, -1 do
        if g_savedata.objects[i].type == "vehicle" and g_savedata.objects[i].id == vehicle_id then
            damage_vehicle(g_savedata.objects[i], damage_amount)
        end
    end
end

function onPlayerJoin(steam_id, name, peer_id, is_admin, is_auth)
    if peer_id < 0 or name == "Server" then
        return
    end

    for i = 1, #g_savedata.zones do
        map_zone(g_savedata.zones[i], peer_id)
    end

end

function onEquipmentDrop(object_id_actor, object_id_target, type)
    server.despawnObject(object_id_target, false)
end

-- utils

function get_player(peer_id)
    for k, player in pairs(server.getPlayers()) do
        if player.id == peer_id then
            return table.copy(player)
        end
    end

    return nil
end

function despawn_vehicle_group(group_id, is_instant)
    local vehicle_ids, is_success = server.getVehicleGroup(group_id)

    if not is_success then
        return
    end

    for i = #vehicle_ids, 1, -1 do
        server.despawnVehicle(vehicle_ids[i], is_instant or false)
    end
end

function ntf(t, d)
    d = d or 0

    for k, v in pairs(t) do
        if type(v) == "table" then
            -- ntf(t, d + 1)
        else
            local spc = ""
            for i = 1, d do
                spc = spc .. " "
            end
            console.notify(string.format("%s%s=%s", spc, k, v))
        end
    end
end

function parse_tags(tags_full)
    local t = {}

    for k, v in string.gmatch(tags_full, "([%w_]+)=([%w_-]+)") do
        t[k] = v
    end

    return t
end

console = {
    notify = function(text, peer_id, always)
        if peer_id == nil then
            peer_id = -1
        end

        if always or g_savedata.mode == "debug" then
            server.announce("[Mission Foundation]", text, peer_id)
        end
    end,
    error = function(text, peer_id)
        if peer_id == nil then
            peer_id = -1
        end

        server.announce("[Mission Foundation]", text, peer_id)
    end
}

table.shuffle = function(x)
    for i = #x, 2, -1 do
        local j = math.random(i)
        x[i], x[j] = x[j], x[i]
    end
end

table.contains = function(t, x)
    local contains = false

    for i = 1, #t do
        contains = contains or t[i] == x
    end

    return contains
end

table.find_index = function(t, test)
    for i = 1, #t do
        if test(t[i]) then
            return i
        end
    end

    return nil
end

table.find = function(t, test)
    for i = 1, #t do
        if test == nil or test(t[i]) then
            return t[i], i
        end
    end

    return nil, nil
end

table.find_all = function(t, test)
    local items = {}

    for i = 1, #t do
        if test(t[i]) then
            table.insert(items, t[i])
        end
    end

    return items
end

table.has = function(t, x)
    for i = 1, #t do
        if t[i] == x then
            return true
        end
    end

    return false
end

table.keys = function(t)
    local items = {}

    for k, v in pairs(t) do
        table.insert(items, k)
    end

    return items
end

table.random = function(t)
    if #t == 0 then
        return nil
    end

    return t[math.random(1, #t)]
end

table.select = function(t, selector)
    local items = {}

    for i = 1, #t do
        local value = selector(t[i])

        if value ~= nil then
            table.insert(items, selector(value))
        end
    end

    return items
end

table.where = function(t, selector)
    local items = {}

    for i = 1, #t do
        if selector(t[i]) then
            table.insert(items, t[i])
        end
    end

    return items
end

table.copy = function(t)
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

table.distinct = function(t)
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

math.round = function(x)
    return math.floor(x + 0.5)
end

string.split = function(text, sepatator)
    local result = {}

    for sub in string.gmatch(text, "([^" .. sepatator .. "])") do
        table.insert(result, sub)
    end
end

