name = "TSU Battle Foundation"
version = "1.1.1"

-- properties
g_savedata = {
    mode = "prod",
    objects = {},
    game = nil,
    zones = {},
    subsystems = {
        operation_area = true,
        deploy_points = false,
        hit_points = false
    }
}

zone_properties = {{
    landscape = "base",
    mapped = false,
    icon = 4
}, {
    landscape = "center",
    mapped = false,
    icon = 4
}, {
    landscape = "objective",
    mapped = false,
    icon = 1
}, {
    landscape = "storage",
    mapped = false,
    icon = 1
}, {
    landscape = "stronghold",
    mapped = false,
    icon = 1
}}

games = { --     {
--     tracker = "cqt",
--     name = "conquest",
--     point_of_match = 60,
--     deploy_point_start = 200,
--     teams = {}
-- }, 
{
    tracker = "manual",
    name = "manual",
    point_of_match = 60,
    deploy_point_start = 200,
    teams = {}
} -- {
--     tracker = "destruction",
--     name = "destruction",
--     point_of_match = 60,
--     deploy_point_start = 200,
--     teams = {}
-- }
}

game_trackers = {
    -- cqt = {
    --     init = function(self, game)
    --         game.teams = {{
    --             name = "red",
    --             match_point = 0,
    --             delpoy_point = 0
    --         }, {
    --             name = "blue",
    --             match_point = 0,
    --             delpoy_point = 0
    --         }}

    --         game.zones = {}

    --         for i = 1, #g_savedata.zones do
    --             if g_savedata.zones[i].tags.map == game.map then
    --                 table.insert(game.zones, {
    --                     id = i,
    --                     value = 0,
    --                     delta = 0,
    --                     conquest_by = nil
    --                 })
    --             end
    --         end
    --     end,
    --     clear = function(self, game)
    --     end,
    --     tick = function(self, game, tick)
    --         if timing == 0 then
    --             for i = 1, #game.zones do
    --                 game.zones[i].value = math.min(self.zone_conquest_threshold, math.max(-self.zone_conquest_threshold, game.zones[i].value + game.zones[i].delta))
    --                 game.zones[i].delta = 0

    --                 if game.zones[i].value <= -self.zone_conquest_threshold then
    --                     game.zones[i].conquest_by = 1
    --                     game.teams[1].match_point = math.min(game.point_of_match, game.teams[1].match_point + 1)
    --                 elseif game.zones[i].value >= self.zone_conquest_threshold then
    --                     game.zones[i].conquest_by = 2
    --                     game.teams[2].match_point = math.min(game.point_of_match, game.teams[2].match_point + 1)
    --                 else
    --                     game.zones[i].conquest_by = nil
    --                 end

    --                 -- console.notify(string.format("%s: %s", g_savedata.zones[game.zones[i].id].name, game.zones[i].conquest_by))
    --             end
    --         end

    --         for i = 1, #game.players do
    --             if i % cycle == timing then
    --                 local transform, is_success = server.getPlayerPos(game.players[i])

    --                 for j = 1, #game.zones do
    --                     if g_savedata.zones[game.zones[j].id].landscape == "objective" and is_in_zone(transform, g_savedata.zones[game.zones[j].id]) then
    --                         console.notify(game.players[i].team_id)

    --                         if game.players[i].team_id == 1 then
    --                             game.zones[j].delta = game.zones[j].delta - 1
    --                         elseif game.players[i].team_id == 2 then
    --                             game.zones[j].delta = game.zones[j].delta + 1
    --                         end
    --                     end
    --                 end
    --             end
    --         end
    --     end,
    --     completed = function(self, game)
    --     end,
    --     referesh_ui = function(self, game, peer_id)
    --     end,
    --     zone_conquest_threshold = 100
    -- },
    manual = {
        init = function(self, game)
            for i = 1, #game.teams do
                game.teams[i].vehicles = 0
            end
        end,
        clear = function(self, game)
        end,
        tick = function(self, game, tick)
        end,
        finished = function(self, game)
            return false
        end,
        join = function(self, game, peer_id)
        end,
        deploy = function(self, game, vehicle)
            if vehicle.body_index > 0 then
                return
            end

            local member = table.find(game.team_members, function(x)
                return x.steam_id == vehicle.owner.steam_id
            end)

            game.teams[member.team_id].vehicles = game.teams[member.team_id].vehicles + 1
        end,
        destroy = function(self, game, vehicle)
            if vehicle.body_index > 0 then
                return
            end

            local member = table.find(game.team_members, function(x)
                return x.steam_id == vehicle.owner.steam_id
            end)

            game.teams[member.team_id].vehicles = game.teams[member.team_id].vehicles - 1
        end,
        status = function(self, game)
            local text = ""

            for i = 1, #game.teams do
                text = text .. string.upper(game.teams[i].name)

                if game.teams[i].ready then
                    text = text .. "\nready"
                else
                    text = text .. "\ngetting ready..."
                end

                local p = 0

                for j = 1, #game.team_members do
                    if game.team_members[j].team_id == i then
                        p = p + 1
                    end
                end

                text = text .. string.format("\n%d players", p)
                text = text .. string.format("\n%d vehicles", game.teams[i].vehicles)

                if g_savedata.subsystems.deploy_points then
                    text = text .. string.format("\n%d deploy points", game.teams[i].deploy_points)
                end

                if i < #game.teams then
                    text = text .. "\n\n"
                end
            end

            return text
        end
    }
    -- destruction = {
    --     init = function(self, game)
    --         for i = 1, #game.teams do
    --             game.teams[i].vehicles = 0
    --         end
    --     end,
    --     clear = function(self, game)
    --     end,
    --     tick = function(self, game, tick)
    --     end,
    --     finished = function(self, game)
    --         local c = #game.teams

    --         for i = 1, #game.teams do
    --             if game.teams[i].vehicles <= 0 then
    --                 c = c - 1
    --             end
    --         end

    --         return c <= 1
    --     end,
    --     join = function(self, game, peer_id)
    --     end,
    --     deploy = function(self, game, vehicle)
    --         if vehicle.body_index > 0 then
    --             return
    --         end

    --         local member = table.find(game.team_members, function(x)
    --             return x.steam_id == vehicle.owner.steam_id
    --         end)

    --         game.teams[member.team_id].vehicles = game.teams[member.team_id].vehicles + 1
    --     end,
    --     destroy = function(self, game, vehicle)
    --         if vehicle.body_index > 0 then
    --             return
    --         end

    --         local member = table.find(game.team_members, function(x)
    --             return x.steam_id == vehicle.owner.steam_id
    --         end)

    --         game.teams[member.team_id].vehicles = game.teams[member.team_id].vehicles - 1
    --     end,
    --     status = function(self, game)
    --         local text = ""

    --         for i = 1, #game.teams do
    --             text = text .. string.upper(game.teams[i].name)

    --             if game.teams[i].ready then
    --                 text = text .. "\nready"
    --             else
    --                 text = text .. "\ngetting ready..."
    --             end

    --             local p = 0

    --             for j = 1, #game.team_members do
    --                 if game.team_members[j].team_id == i then
    --                     p = p + 1
    --                 end
    --             end

    --             text = text .. string.format("\n%d players", p)
    --             text = text .. string.format("\n%d vehicles", game.teams[i].vehicles)

    --             if g_savedata.subsystems.deploy_points then
    --                 text = text .. string.format("\n%d deploy points", game.teams[i].deploy_points)
    --             end

    --             if i < #game.teams then
    --                 text = text .. "\n\n"
    --             end
    --         end

    --         return text
    --     end
    -- }
}

object_trackers = {
    vehicle = {
        test_type = function(self, object, group_id, body_index, cost, owner_steam_id)
            return object.type == "vehicle" and owner_steam_id ~= nil
        end,
        init = function(self, object, group_id, body_index, cost, owner_steam_id)
            object.group_id = group_id
            object.body_index = body_index
            object.cost = cost
            object.owner = {
                steam_id = tostring(owner_steam_id)
            }
            object.flag = false
            object.components_checked = false
            object.mass = 0
            object.voxels = 0
            object.deploy_points = 0
            object.hit_points = 0
            object.damage = 0
            object.exploded = false
            object.seats = {}
            object.icon = 12

            if object.name == "" then
                object.name = "Vehicle"
            end

            local name = string.lower(object.name)

            if string.find(name, "[flag]", 1, true) ~= nil then
                object.icon = 9
            elseif string.find(name, "[tank]", 1, true) ~= nil then
                object.icon = 14
            elseif string.find(name, "[plane]", 1, true) ~= nil then
                object.icon = 13
            elseif string.find(name, "[heli]", 1, true) ~= nil then
                object.icon = 15
            elseif string.find(name, "[ship]", 1, true) ~= nil then
                object.icon = 16
            elseif string.find(name, "[boat]", 1, true) ~= nil then
                object.icon = 17
            end
        end,
        load = function(self, object)
            if not object.components_checked then
                vehicle_components(object)

                object.deploy_points = math.ceil(object.mass * 0.01)
                object.hit_points = object.mass * 2

                if g_savedata.game ~= nil then
                    deploy_vehicle(g_savedata.game, object)
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
            if g_savedata.subsystems.hit_points and object.components_checked and not object.exploded and object.body_index == 0 and object.damage > object.hit_points then
                local transform = server.getVehiclePos(object.id)
                server.spawnExplosion(transform, 0.25)
                object.exploded = true

                console.notify(string.format("%s#%d Exploded", object.name, object.id))
            end
        end,
        damage = function(self, object, damage)
            object.damage = object.damage + damage
        end,
        position = function(self, object)
            return server.getVehiclePos(object.id)
        end
    },
    stronghold = {
        test_type = function(self, object, group_id, body_index, cost, owner_steam_id)
            return object.type == "vehicle" and object.tracker == "stronghold"
        end,
        init = function(self, object, group_id)
            object.group_id = group_id
        end,
        load = function(self, object)
        end,
        spawn = function(self, object)
        end,
        despawn = function(self, object)
        end,
        clear = function(self, object)
        end,
        tick = function(self, object, tick)
        end,
        damage = function(self, object, damage)
        end,
        position = function(self, object)
            return server.getVehiclePos(object.id)
        end
    }
}

-- games

function initialize_game(mode, map_id, red_count, blue_count)
    for i = #g_savedata.objects, 1, -1 do
        despawn_object(g_savedata.objects[i])
    end

    local zone_center = table.find(g_savedata.zones, function(x)
        return x.tags.map == map_id and x.tags.landscape == "center" and x.tags.radius ~= nil
    end)

    if zone_center == nil then
        console.error("Operation zone center is invalid.")
        return
    end

    zone_center.tags.radius = tonumber(zone_center.tags.radius)

    if zone_center.tags.radius == nil then
        console.error("Operation zone radius is not number")
    end

    local zone_base_red = table.find(g_savedata.zones, function(x)
        return x.tags.map == map_id and x.tags.landscape == "base" and x.tags.team == "red"
    end)

    if zone_base_red == nil then
        console.error("Red base zone is invalid.")
        return
    end

    local zone_base_blue = table.find(g_savedata.zones, function(x)
        return x.tags.map == map_id and x.tags.landscape == "base" and x.tags.team == "blue"
    end)

    if zone_base_blue == nil then
        console.error("Blue base zone is invalid.")
        return
    end

    local zone_strongholds = {}

    for k, v in pairs(table.find_all(g_savedata.zones, function(x)
        return x.tags.map == map_id and x.tags.landscape == "stronghold"
    end)) do
        table.insert(zone_strongholds, initialize_stronghold(v))
    end

    -- if #zone_strongholds == 0 then

    local game = {
        tracker = mode.tracker,
        started = false,
        finished = false,
        name = mode.name,
        map_id = map_id,
        center = zone_center,
        strongholds = zone_strongholds,
        game_stats_marker_id = server.getMapID(),
        team_status_marker_id = server.getMapID(),
        operation_area_marker_id = server.getMapID(),
        out_of_area_marker_id = server.getMapID(),
        count_team = 2,
        teams = {{
            name = "red",
            ready = false,
            base = zone_base_red,
            deploy_points = 100,
            tickets = 0,
            color = {
                r = 204,
                g = 43,
                b = 43,
                a = 255
            }
        }, {
            name = "blue",
            ready = false,
            base = zone_base_blue,
            deploy_points = 100,
            tickets = 0,
            color = {
                r = 40,
                g = 149,
                b = 204,
                a = 255
            }
        }},
        team_members = {}
    }

    game_trackers[game.tracker]:init(game)

    game.team_members = {}

    local p = shuffle_players()
    local limit = math.round(red_count / (red_count + blue_count) * #p)

    for i = 1, #p do
        local team_id = nil

        if i <= limit then
            team_id = 1
        else
            team_id = 2
        end

        local player = team_member(p[i], team_id)
        table.insert(game.team_members, player)
    end

    spawn_storage(map_id)
    g_savedata.game = game

    if g_savedata.subsystems.operation_area then
        map_operation_area(-1, game)
    end

    set_damages(false)
    set_teleports(true)
    set_maps(false)
    set_name_plates(true)

    server.notify(-1, "MATCHMAKING...", string.format("%s\n%s", string.upper(game.name), game.map_id), 5)
    console.log(string.format("Matchmaking %s...", game.name))

    for i = 1, #game.team_members do
        local object_id = server.getPlayerCharacterID(game.team_members[i].id)

        clear_inventory(object_id)
        set_default_inventory(object_id)
        map_member(game, game.team_members[i])
        teleport_to_base(game, game.team_members[i])
        console.log(string.format("%s assigned to %s team", game.team_members[i].name, game.teams[game.team_members[i].team_id].name), game.team_members[i].id)
    end
end

function clear_game(game)
    for i = #g_savedata.objects, 1, -1 do
        despawn_object(g_savedata.objects[i])
    end

    clear_stronghold_markers(game)

    for i = 1, #game.team_members do
        local object_id = server.getPlayerCharacterID(game.team_members[i].id)

        clear_inventory(object_id)
        set_default_inventory(object_id)
        reset_player_hp(object_id)
        unmap_member(game, game.team_members[i])
        teleport_to_start_tile(game.team_members[i])
    end

    game_trackers[game.tracker]:clear(game)

    if g_savedata.subsystems.operation_area then
        unmap_operation_area(-1, game)
    end

    set_damages(false)
    set_teleports(true)
    set_maps(true)
    set_name_plates(true)
    unmap_game_stats(game)

    g_savedata.game = nil
    console.log("Cleared ongoing game")
end

function tick_game(game, tick)
    strongholds(game, tick)
    game_trackers[g_savedata.game.tracker]:tick(game, tick)
    start_game(game)
    finish_game(game)
    map_game_stats(game)
end

function start_game(game)
    if not game.started then
        local s = true

        for i = 1, #game.teams do
            s = s and game.teams[i].ready
        end

        game.started = s

        if game.started then
            set_damages(true)
            set_teleports(false)
            set_maps(false)
            set_name_plates(false)
            server.notify(-1, "GAME START", string.format("%s\n%s", string.upper(game.name), game.map_id), 5)
        end
    end
end

function finish_game(game)
    if game.started and not game.finished then
        game.finished = game_trackers[game.tracker]:finished(game)

        if game.finished then
            set_damages(false)
            set_teleports(true)
            set_maps(true)
            set_name_plates(true)
            console.notify(-1, "GAME OVER", string.format("%s\n%s", string.upper(game.name), game.map_id), 5)
        end
    end
end

function map_game_stats(game)
    local text = string.format("%s\n%s", string.upper(game.name), game.map_id)
    text = text .. "\n\n" .. game_trackers[game.tracker]:status(game)

    for i = 1, #game.team_members do
        server.setPopupScreen(game.team_members[i].id, game.game_stats_marker_id, "STATS", true, text, 0.9, -0.5)
        server.setPopupScreen(game.team_members[i].id, game.team_stats_marker_id, "TEAM", true, team_stats(game, game.team_members[i]), 0.725, -0.5)
    end
end

function unmap_game_stats(game)
    for i = 1, #game.team_members do
        server.removeMapID(game.team_members[i].id, game.game_stats_marker_id)
        server.removeMapID(game.team_members[i].id, game.team_stats_marker_id)
    end
end

function team_stats(game, member)
    local text = string.upper(game.teams[member.team_id].name) .. "\n"

    text = text .. string.format("%d tickets", game.teams[member.team_id].tickets) .. "\n"

    for i = 1, #game.team_members do
        if game.team_members[i].team_id == member.team_id then
            local object_id, s = server.getPlayerCharacterID(game.team_members[i].id)
            local data = server.getObjectData(object_id)
            local status = "-"

            if data ~= nil and data.hp <= 0 then
                status = "*"
            elseif game.team_members[i].flag then
                status = "="
            end

            text = text .. string.format("\n%s%s", status, game.team_members[i].name)

            ::continue::
        end
    end

    return text
end

function ready(game, player, r)
    local member = table.find(game.team_members, function(x)
        return x.steam_id == tostring(player.steam_id)
    end)

    if member == nil then
        return
    end

    game.teams[member.team_id].ready = r

    local text = ""
    local type = 5

    if game.teams[member.team_id].ready then
        text = "READY"
        type = 5
    else
        text = "GETTING READY..."
        type = 6
    end

    server.notify(-1, string.format("%s TEAM IS %s", string.upper(game.teams[member.team_id].name), text), player.name, type)
end

function ticket(game, player, amount)
    if amount == nil then
        console.error("Amount is not number.")
        return
    end

    amount = math.ceil(amount)

    local member = table.find(game.team_members, function(x)
        return x.steam_id == tostring(player.steam_id)
    end)

    if member == nil then
        return
    end

    local type = 5

    if amount >= 0 then
        type = 5
    else
        type = 6
    end

    game.teams[member.team_id].tickets = game.teams[member.team_id].tickets + amount

    console.log(string.format("%s team tickets was %+d by %s", game.teams[member.team_id].name, amount, player.name))
    server.notify(-1, string.format("%s TEAM TICKETS WAS %+d", string.upper(game.teams[member.team_id].name), amount), player.name, type)
end

function set_teleports(v)
    -- server.setGameSetting("fast_travel", v)
    server.setGameSetting("teleport_vehicle", v)
    server.setGameSetting("map_teleport", v)
    server.setGameSetting("no_clip", v)
end

function set_maps(v)
    server.setGameSetting("map_show_players", v)
    server.setGameSetting("map_show_vehicles", v)
end

function set_name_plates(v)
    server.setGameSetting("show_name_plates", v)
end

function set_damages(v)
    server.setGameSetting("vehicle_damage", v)
    server.setGameSetting("player_damage", v)
    server.setGameSetting("npc_damage", v)
end

-- objects

function initialize_object(id, type, object, ...)
    local params = {...}

    object.id = id
    object.type = type
    object.marker_id = server.getMapID()
    object.cleared = false

    for k, v in pairs(object_trackers) do
        if v:test_type(object, table.unpack(params)) then
            object.tracker = k
            break
        end
    end

    if object.tracker ~= nil then
        object_trackers[object.tracker]:init(object, table.unpack(params))
    end

    table.insert(g_savedata.objects, object)
    console.notify(string.format("Initializing object %s#%d.", object.type, object.id))
end

function clear_object(object)
    if object.cleared then
        return
    end

    if object.tracker ~= nil then
        object_trackers[object.tracker]:clear(object)
    end

    object.cleared = true
    console.notify(string.format("Cleared object %s#%d.", object.type, object.id))
end

function despawn_object(object)
    if object.type == "character" then
        server.despawnObject(object.id, true)
    elseif object.type == "vehicle" then
        server.despawnVehicle(object.id, true)
    else
        server.despawnObject(object.id, true)
    end
end

function tick_object(object, tick)
    if object.tracker ~= nil then
        object_trackers[object.tracker]:tick(object, tick)
    end
end

function deploy_vehicle(game, vehicle)
    if vehicle.tracker ~= "vehicle" then
        return
    end

    if g_savedata.subsystems.deploy_points then
        local member = table.find(game.team_members, function(x)
            return x.steam_id == vehicle.owner.steam_id
        end)

        game.teams[member.team_id].deploy_points = game.teams[member.team_id].deploy_points - vehicle.deploy_points

        if game.teams[member.team_id].deploy_points < 0 then
            console.notify(string.format("You need %d points to deploy this vehicle.", vehicle.deploy_points))
            despawn_object(vehicle, true)
        end
    end

    map_vehicle_friendry(game, vehicle)
    game_trackers[g_savedata.game.tracker]:deploy(game, vehicle)
end

function destroy_vehicle(game, vehicle)
    if vehicle.tracker ~= "vehicle" then
        return
    end

    if g_savedata.subsystems.deploy_points then
        local t, s = server.getVehiclePos(vehicle.id)
        local member = table.find(game.team_members, function(x)
            return x.steam_id == vehicle.owner.steam_id
        end)
        local respawn = table.find(g_savedata.zones, function(x)
            return x.tags.map == game.map_id and x.tags.landscape == "base" and x.tags.team == game.teams[member.team_id].name
        end)

        if respawn ~= nil and is_in_zone(t, respawn) then
            game.teams[member.team_id].deploy_points = game.teams[member.team_id].deploy_points + vehicle.deploy_points
            console.notify(string.format("Your %d deploy points back.", vehicle.deploy_points))
        else
            console.notify(string.format("You lost %d deploy points.", vehicle.deploy_points))
        end
    end

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

    -- for j = 1, #bodies do
    --     local d, s = server.getVehicleComponents(bodies[j])

    --     object.voxels = object.voxels + d.voxels
    --     object.mass = object.mass + d.mass

    --     if j == 1 then
    --         for k = 1, #d.components.seats do
    --             table.insert(object.seats, d.components.seats[k])
    --         end
    --     end
    -- end

    local d, s = server.getVehicleComponents(object.id)

    object.voxels = d.voxels
    object.mass = d.mass

    for k = 1, #d.components.seats do
        table.insert(object.seats, d.components.seats[k])
    end

    object.components_checked = true
end

function map_vehicle_friendry(game, vehicle)
    if vehicle.tracker ~= "vehicle" or vehicle.body_index > 0 then
        return
    end

    local owner = table.find(game.team_members, function(x)
        return x.steam_id == vehicle.owner.steam_id
    end)

    for i = 1, #game.team_members do
        local label = string.format("#%d %s", vehicle.id, vehicle.name)
        local detail = vehicle_spec_table(vehicle)

        if game.team_members[i].team_id == owner.team_id then
            server.addMapObject(game.team_members[i].id, vehicle.marker_id, 1, vehicle.icon, 0, 0, 0, 0, vehicle.id, nil, label, 0, detail, game.teams[owner.team_id].color.r, game.teams[owner.team_id].color.g, game.teams[owner.team_id].color.b, 255)
        end
    end
end

function unmap_vehicle_friendry(game, vehicle)
    local owner = table.find(game.team_members, function(x)
        return x.steam_id == vehicle.owner.steam_id
    end)

    for i = 1, #game.team_members do
        if game.team_members[i].team_id == owner.team_id then
            server.removeMapID(game.team_members[i].id, vehicle.marker_id)
        end
    end
end

function vehicle_spec_table(vehicle)
    local player = table.find(players, function(x)
        return x.steam_id == vehicle.owner.steam_id
    end)
    return string.format("%s\n\n%.00f voxels\n%.00f mass", player.name, vehicle.voxels, vehicle.mass)
end

function spawn_storage(map_id)
    for i = 1, #g_savedata.zones do
        if g_savedata.zones[i].tags.map == map_id and g_savedata.zones[i].tags.landscape == "storage" then
            server.spawnNamedAddonLocation("storage", g_savedata.zones[i].transform)
        end
    end
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
        is = is or g_savedata.zones[i].tags.landscape == landscape and is_in_zone(transform, g_savedata.zones[i])
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
            name = zone.tags.landscape
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
    local z = server.getZones()

    for _, zone in pairs(z) do
        local tags = parse_tags(zone.tags)

        for i = 1, #zone_properties do
            if tags.landscape ~= nil and zone_properties[i].landscape == tags.landscape then
                zone.id = id
                zone.tags = tags
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

function initialize_stronghold(zone)
    zone.stronghold_marker_id = server.getMapID()
    zone.occupied_by = 0

    return zone
end

function strongholds(game)
    for i = 1, #game.strongholds do
        local in_zone_players = {0, 0}

        for j = 1, #game.team_members do
            local object_transform = server.getPlayerPos(game.team_members[j].id)
            local is_in = server.isInTransformArea(object_transform, game.strongholds[i].transform, game.strongholds[i].size.x, game.strongholds[i].size.y, game.strongholds[i].size.z)

            if is_in then
                in_zone_players[game.team_members[j].team_id] = in_zone_players[game.team_members[j].team_id] + 1
            end
        end

        local occupied_by = -1

        if in_zone_players[1] > 0 and in_zone_players[1] > in_zone_players[2] then
            occupied_by = 1
        elseif in_zone_players[2] > 0 and in_zone_players[2] > in_zone_players[1] then
            occupied_by = 2
        elseif in_zone_players[1] > 0 and in_zone_players[2] > 0 and in_zone_players[1] == in_zone_players[2] then
            occupied_by = 0
        end

        if occupied_by >= 0 and occupied_by ~= game.strongholds[i].occupied_by then
            game.strongholds[i].occupied_by = occupied_by
            refresh_stronghold_marker(game, game.strongholds[i])
        end
    end
end

function refresh_stronghold_marker(game, zone)
    local x, y, z = matrix.position(zone.transform)
    local r, g, b, a = 191, 191, 191, 255

    if zone.occupied_by > 0 then
        r = game.teams[zone.occupied_by].color.r
        g = game.teams[zone.occupied_by].color.g
        b = game.teams[zone.occupied_by].color.b
    end

    server.removeMapID(-1, zone.stronghold_marker_id)
    server.addMapObject(-1, zone.stronghold_marker_id, 0, 9, x, z, 0, 0, nil, nil, zone.name, 0, nil, r, g, b, a)
end

function clear_stronghold_markers(game)
    for i = 1, #game.strongholds do
        server.removeMapID(-1, game.strongholds[i].stronghold_marker_id)
    end
end

-- players

players = {}
peers_map_open = {}

function assign(player, team_id)
end

function team_members(a, b)
    local p = table.copy(players)
    local limit = math.round(a / (a + b) * #p)

    if p[1].name == "Server" then
        table.remove(p, 1)
    end

    table.shuffle(p)

    for i = 1, #p do
        if i <= limit then
            p[i].team_id = 1
        else
            p[i].team_id = 2
        end

        p[i].marker_id = server.getMapID()
        p[i].commander = false
        p[i].opend_map = false
    end

    return p
end

function team_member(player, team_id)
    player.team_id = team_id
    player.marker_id = server.getMapID()
    player.commander = false
    player.opend_map = false

    return player
end

function shuffle_players()
    local p = table.copy(players)

    if p[1].name == "Server" then
        table.remove(p, 1)
    end

    table.shuffle(p)

    return p
end

function clear_inventory(object_id)
    for i = 1, 10 do
        server.setCharacterItem(object_id, i, nil, false)
    end
end

function set_default_inventory(object_id)
    server.setCharacterItem(object_id, 2, 15, false, 0, 100)
    server.setCharacterItem(object_id, 3, 6, false)
end

function map_member(game, member)
    local object_id = server.getPlayerCharacterID(member.id)

    for i = 1, #game.team_members do
        if game.team_members[i].team_id == member.team_id then
            map_player(game.team_members[i].id, game, member)
        end
    end
end

function unmap_member(game, member)
    for i = 1, #game.team_members do
        if game.team_members[i].team_id == member.team_id then
            server.removeMapID(game.team_members[i].id, member.marker_id)
        end
    end
end

function map_player(peer_id, game, player)
    local object_id = server.getPlayerCharacterID(player.id)

    if object_id == nil then
        return
    end

    local vehicle_id = server.getCharacterVehicle(object_id)

    if vehicle_id == nil then
        return
    end

    server.addMapObject(peer_id, player.marker_id, 2, 1, 0, 0, 0, 0, nil, object_id, player.name, 0, nil, game.teams[player.team_id].color.r, game.teams[player.team_id].color.g, game.teams[player.team_id].color.b, 255)
end

function select_commander(game, player)
    local steam_id = tostring(player.steam_id)
    local member = table.find(game.team_members, function(x)
        return x.steam_id == steam_id
    end)

    if member == nil then
        return
    end

    for i = 1, #game.team_members do
        if game.team_members[i].team_id == member.team_id and game.team_members[i].steam_id == steam_id then
            game.team_members[i].commander = true
        elseif game.team_members[i].team_id == member.team_id then
            game.team_members[i].commander = false
        end
    end
end

function teleport(game, player, target)
    local target = tonumber(target)
    local steam_id = tostring(player.steam_id)
    local member = table.find(game.team_members, function(x)
        return x.steam_id == steam_id
    end)

    if member == nil then
        return
    end

    local transform = server.getPlayerPos(player.id)

    if not is_in_landscape(transform, "base") then
        console.error("You are not in base.", player.id)
        return
    end

    if target ~= nil then
        local vehicle = table.find(g_savedata.objects, function(x)
            return x.tracker == "vehicle" and x.id == target and x.body_index == 0
        end)

        if vehicle == nil then
            console.error(string.format("No vehicle#%d.", target), player.id)
            return
        end

        teleport_to_empty_seat(vehicle, player)
    elseif game.tracker == "flag" then
        local commander = table.find(game.team_members, function(x)
            return x.team_id == member.team_id and x.commander
        end)

        if commander == nil then
            console.error("No commander.", player.id)
            return
        end

        local cv = table.find(g_savedata.objects, function(x)
            return x.tracker == "vehicle" and x.owner.steam_id == commander.steam_id
        end)

        if cv == nil then
            console.error("No commander's vehicle.", player.id)
            return
        end

        teleport_to_empty_seat(cv, player)
    end
end

function teleport_to_empty_seat(vehicle, player)
    for i = 1, #vehicle.seats do
        local seat = server.getVehicleSeat(vehicle.id, vehicle.seats[i].pos.x, vehicle.seats[i].pos.y, vehicle.seats[i].pos.z)

        if seat.seated_id == 4294967295 then
            local object_id = server.getPlayerCharacterID(player.id)
            server.setSeated(object_id, vehicle.id, vehicle.seats[i].pos.x, vehicle.seats[i].pos.y, vehicle.seats[i].pos.z)
            return
        end
    end

    console.error("No empty seat.", player.id)
end

function teleport_to_base(game, member)
    server.setPlayerPos(member.id, game.teams[member.team_id].base.transform)

    for i = 1, #g_savedata.objects do
        if g_savedata.objects[i].tracker == "vehicle" and g_savedata.objects[i].owner.steam_id == member.steam_id then
            despawn_object(g_savedata.objects[i])
        end
    end
end

function teleport_to_start_tile(player)
    local start_tile = server.getStartTile()
    local t = matrix.translation(start_tile.x, start_tile.y, start_tile.z)
    server.setPlayerPos(player.id, t)
end

function reset_player_hp(object_id)
    server.setCharacterData(object_id, 100, false, false)
end

-- UIs

function map_operation_area(peer_id, game)
    local t1 = 0
    local x1 = game.center.tags.radius * math.cos(t1 * math.pi)
    local y1 = game.center.tags.radius * math.sin(t1 * math.pi)
    local t2, x2, y2 = 0, 0, 0

    for i = 1, 60, 1 do
        t2 = 2 / 60 * i
        x2 = game.center.tags.radius * math.cos(t2 * math.pi)
        y2 = game.center.tags.radius * math.sin(t2 * math.pi)

        server.addMapLine(peer_id, game.operation_area_marker_id, matrix.multiply(game.center.transform, matrix.translation(x1, 0, y1)), matrix.multiply(game.center.transform, matrix.translation(x2, 0, y2)), 1, 255, 255, 255, 255)

        t1 = t2
        x1 = x2
        y1 = y2
    end
end

function unmap_operation_area(peer_id, game)
    server.removeMapID(peer_id, g_savedata.game.operation_area_marker_id)
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

        for i = 1, #players do
            players[i].steam_id = tostring(players[i].steam_id)
        end

        if false then
            table.insert(players, {
                id = 100,
                name = "a",
                is_admin = false,
                is_auth = false,
                steam_id = "100"
            })
            table.insert(players, {
                id = 101,
                name = "b",
                is_admin = false,
                is_auth = false,
                steam_id = "101"
            })
            table.insert(players, {
                id = 102,
                name = "c",
                is_admin = false,
                is_auth = false,
                steam_id = "102"
            })
            table.insert(players, {
                id = 103,
                name = "d",
                is_admin = false,
                is_auth = false,
                steam_id = "103"
            })
            table.insert(players, {
                id = 104,
                name = "e",
                is_admin = false,
                is_auth = false,
                steam_id = "104"
            })
        end
    end

    if timing == 0 and g_savedata.game ~= nil then
        tick_game(g_savedata.game, tick * cycle)
    end

    for i = #g_savedata.objects, 1, -1 do
        if i % cycle == timing then
            tick_object(g_savedata.objects[i], tick)

            if g_savedata.objects[i].cleared then
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

function onCustomCommand(full_message, peer_id, is_admin, is_auth, command, verb, ...)
    if command == "?battle" then
        if is_admin and verb == "init" then
            local params = parse_tags({...})
            local mode_id = params.mode or "manual"
            local map_id = params.map
            local a, b = 1, 1

            if params.ratio ~= nil then
                local _a, _b = string.match(params.ratio, "^(%d+):(%d+)$")

                if _a ~= nil and _b ~= nil then
                    a = tonumber(_a)
                    b = tonumber(_b)
                end

            end

            local game = table.find(games, function(x)
                return x.tracker == mode_id
            end)

            if game == nil then
                console.error(string.format("%s is not valid gamemode", mode_id))
                return
            end

            if g_savedata.game ~= nil then
                clear_game(g_savedata.game)
            end

            initialize_game(game, map_id, a, b)
        elseif is_admin and verb == "clear" and g_savedata.game ~= nil then
            clear_game(g_savedata.game)
        elseif is_admin and verb == "assign" and g_savedata.game ~= nil then
            local peer_id, team_name = ...
            peer_id = tonumber(peer_id)

            if g_savedata.game == nil then
                return
            end

            local player = table.find(players, function(x)
                return x.id == peer_id
            end)

            if player == nil then
                console.error(string.format("Player %d no exists", peer_id), peer_id)
                return
            end

            local team_id = table.find_index(g_savedata.game.teams, function(x)
                return x.name == string.lower(team_name)
            end)

            if team_id == nil then
                console.error(string.format("Team %s no exists", team_name), peer_id)
                return
            end

            local member_index = table.find_index(g_savedata.game.team_members, function(x)
                return x.steam_id == player.steam_id
            end)

            if member_index ~= nil then
                console.error(string.format("Player %d already assined", peer_id), peer_id)
                -- table.remove(g_savedata.game.team_members, member_index)
                return
            end

            local member = team_member(player, team_id)
            table.insert(g_savedata.game.team_members, member)
            local object_id = server.getPlayerCharacterID(member.id)

            for i = 1, #g_savedata.game.team_members do
                if member ~= nil and g_savedata.game.team_members[i].team_id == member.team_id then
                    map_player(member.id, g_savedata.game, g_savedata.game.team_members[i])
                    map_player(g_savedata.game.team_members[i].id, g_savedata.game, member)
                end
            end

            for i = 1, #g_savedata.objects do
                map_vehicle_friendry(g_savedata.game, g_savedata.objects[i])
            end

            clear_inventory(object_id)
            set_default_inventory(object_id)
            teleport_to_base(g_savedata.game, member)
        elseif is_admin and verb == "map" then
        elseif is_admin and verb == "deploy_points" then
            g_savedata.subsystems.deploy_points = not g_savedata.subsystems.deploy_points
            server.announce("[Battle]", string.format("Deploy points: %s", g_savedata.subsystems.deploy_points), -1)
        elseif is_admin and verb == "hit_points" then
            g_savedata.subsystems.hit_points = not g_savedata.subsystems.hit_points
            server.announce("[Battle]", string.format("Deploy points: %s", g_savedata.subsystems.hit_points), -1)
        elseif is_admin and verb == "operation_area" then
            g_savedata.subsystems.operation_area = not g_savedata.subsystems.operation_area
            server.announce("[Battle]", string.format("Deploy points: %s", g_savedata.subsystems.operation_area), -1)
        elseif verb == "prod" and is_admin then
            g_savedata.mode = "prod"
        elseif verb == "debug" and is_admin then
            g_savedata.mode = "debug"
        elseif is_admin and verb == "get-friendly" then
            local peer_id, response = ...
            local peer_id = tonumber(peer_id)
            local team = ""
            local members = ""

            if peer_id == nil then
                console.error("Peer ID is null.")
                return
            end

            if g_savedata.game == nil then
                console.error("Game does not initialized.")
                return
            end

            local p = table.find(g_savedata.game.team_members, function(x) return x.id == peer_id end)

            if p == nil then
                console.error("Player is not exists.")
                return
            end

            team = g_savedata.game.teams[p.team_id].name

            local m = table.find_all(g_savedata.game.team_members, function(x) return x.team_id == p.team_id end)

            for i = 1, #m do
                if i > 1 then
                    members = members .. ","
                end

                members = members .. string.format("%d", m[i].id)
            end

            server.command(string.format("?%s %s %s", response, team, members))
        elseif is_admin and verb == "get-members" then
            local team_name, response = ...
            local members = ""

            if team_name == nil then
                console.error("Team name is null.")
                return
            end

            if g_savedata.game == nil then
                console.error("Game does not initialized.")
                return
            end

            local team_index = table.find_index(g_savedata.game.teams, function(x) return x.name == team_name end)

            if team_index == nil then
                console.error("Team is not exist.")
                return
            end

            local m = table.find_all(g_savedata.game.team_members, function(x) return x.team_id == team_index end)

            for i = 1, #m do
                if i > 1 then
                    members = members .. ","
                end

                members = members .. string.format("%d", m[i].id)
            end

            server.command(string.format("?%s %s", response, members))
        end
    elseif command == "?ready" and g_savedata.game ~= nil then
        if g_savedata.game == nil then
            return
        end

        local player = get_player(peer_id)

        ready(g_savedata.game, player, true)
    elseif command == "?wait" and g_savedata.game ~= nil then
        if g_savedata.game == nil then
            return
        end

        local player = get_player(peer_id)

        ready(g_savedata.game, player, false)
    elseif command == "?kill" and g_savedata.game ~= nil then
        local object_id = server.getPlayerCharacterID(peer_id)
        server.killCharacter(object_id)
    elseif command == "?cv" and g_savedata.game ~= nil then
        local player = get_player(peer_id)
        select_commander(g_savedata.game, player)
    elseif command == "?tp" and g_savedata.game ~= nil then
        local player = get_player(peer_id)
        teleport(g_savedata.game, player, verb)
    elseif command == "?ticket" and g_savedata.game ~= nil then
        local player = get_player(peer_id)
        local amount = tonumber(verb)

        ticket(g_savedata.game, player, amount)
    end
end

function onCreate(is_world_create)
    load_zones()

    if is_world_create then
        set_damages(false)
        set_teleports(true)
        set_maps(true)
    end

    if g_savedata.game ~= nil then
        console.notify(string.format("Battle: %s, %s ", g_savedata.game.name, g_savedata.game.map_id))
    else
        console.notify("Battle: no available")
    end

    console.notify(name)
    console.notify(version)
    console.notify(string.format("Zones: %d", #g_savedata.zones))
    console.notify(string.format("Objects: %d", #g_savedata.objects))
end

-- function onVehicleSpawn(vehicle_id, peer_id, x, y, z, group_cost, group_id)
--     if peer_id < 0 then
--         return
--     end

--     local data, s = server.getVehicleData(vehicle_id)
--     if not s then
--         console.error(string.format("Spawned vehicle #%d, which has no body", group_id))
--         return
--     end

--     data.type = "vehicle"

--     local owner = get_player(peer_id)

--     initialize_object(vehicle_id, data, group_id, 0, owner.steam_id)
-- end

function onGroupSpawn(group_id, peer_id, x, y, z, group_cost)
    local vehicle_ids = server.getVehicleGroup(group_id)

    for i = 1, #vehicle_ids do
        local data, s = server.getVehicleData(vehicle_ids[i])
        local tags = parse_tags(data.tags)

        if tags.tracker == "storage" then
            initialize_object(vehicle_ids[i], "vehicle", data)
        elseif tags.tracker == "stronghold" then
            initialize_object(vehicle_ids[i], "vehicle", data, group_id)
        elseif peer_id >= 0 then
            local owner = get_player(peer_id)
            local body_index = i - 1

            initialize_object(vehicle_ids[i], "vehicle", data, group_id, body_index, 0, owner.steam_id)
        end
    end
end

function onVehicleLoad(vehicle_id)
    for i = 1, #g_savedata.objects do
        if g_savedata.objects[i].type == "vehicle" and g_savedata.objects[i].id == vehicle_id then
            if g_savedata.objects[i].tracker ~= nil then
                object_trackers.vehicle:load(g_savedata.objects[i])
            end
        end
    end
end

function onVehicleDespawn(vehicle_id, peer_id)
    for i = #g_savedata.objects, 1, -1 do
        if g_savedata.objects[i].type == "vehicle" and g_savedata.objects[i].id == vehicle_id then
            if g_savedata.objects[i].tracker ~= nil then
                object_trackers[g_savedata.objects[i].tracker]:despawn(g_savedata.objects[i])
            end

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

    local steam_id = tostring(steam_id)

    for i = 1, #g_savedata.zones do
        map_zone(g_savedata.zones[i], peer_id)
    end

    if g_savedata.game ~= nil then
        local member = nil

        for i = 1, #g_savedata.game.team_members do
            if g_savedata.game.team_members[i].steam_id == steam_id then
                g_savedata.game.team_members[i].id = peer_id
                member = g_savedata.game.team_members[i]
            end
        end

        for i = 1, #g_savedata.game.team_members do
            if member ~= nil and g_savedata.game.team_members[i].team_id == member.team_id then
                map_player(member.id, g_savedata.game, g_savedata.game.team_members[i])
                map_player(g_savedata.game.team_members[i].id, g_savedata.game, member)
            end
        end

        for i = 1, #g_savedata.objects do
            map_vehicle_friendry(g_savedata.game, g_savedata.objects[i])
        end

        if g_savedata.subsystems.operation_area then
            map_operation_area(peer_id, g_savedata.game)
        end
    end
end

function onPlayerRespawn(peer_id)
    local player = table.find(players, function(x)
        return x.id == peer_id
    end)

    local object_id = server.getPlayerCharacterID(player.id)
    set_default_inventory(object_id)

    if g_savedata.game ~= nil then
        local member = table.find(g_savedata.game.team_members, function(x)
            return x.id == player.id
        end)

        if member ~= nil then
            unmap_member(g_savedata.game, member)
            map_member(g_savedata.game, member)
            teleport_to_base(g_savedata.game, member)
            console.log(string.format("%s dead.", member.name))
        else
            teleport_to_start_tile(player)
        end
    else
        teleport_to_start_tile(player)
    end
end

function onPlayerSit(peer_id, vehicle_id, seat_name)
    if g_savedata.game ~= nil then
        local member = table.find(g_savedata.game.team_members, function(x)
            return x.id == peer_id
        end)
        unmap_member(g_savedata.game, member)
    end
end

function onPlayerUnsit(peer_id, vehicle_id, seat_name)
    if g_savedata.game ~= nil then
        local member = table.find(g_savedata.game.team_members, function(x)
            return x.id == peer_id
        end)
        map_member(g_savedata.game, member)
    end
end

function onToggleMap(peer_id, is_open)
    if g_savedata.game ~= nil then
        local player = get_player(peer_id)

        for i = 1, #g_savedata.game.team_members do
            if g_savedata.game.team_members[i].steam_id == tostring(player.steam_id) then
                g_savedata.game.team_members[i].opend_map = is_open
            end
        end
    end
end

function onEquipmentDrop(object_id_actor, object_id_target, type)
    server.despawnObject(object_id_target, false)
end

-- utils

function get_player(peer_id)
    for k, player in pairs(players) do
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

function parse_tags(tags)
    if tags == nil then
        return
    end

    local t = {}

    for i = 1, #tags do
        local k, v = string.match(tags[i], "^([%w_]+)=([%w_+-*/:]+)$")

        if k ~= nil and v ~= nil then
            t[k] = v
        end
    end

    return t
end

console = {
    log = function(text, peer_id)
        if peer_id == nil then
            peer_id = -1
        end

        server.announce("[LOG]", text, peer_id)
    end,
    notify = function(text, peer_id, always)
        if peer_id == nil then
            peer_id = -1
        end

        if always or g_savedata.mode == "debug" then
            server.announce("[NOTICE]", text, peer_id)
        end
    end,
    error = function(text, peer_id)
        if peer_id == nil then
            peer_id = -1
        end

        server.announce("[ERROR]", text, peer_id)
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

