-- TSU Mission Foundation 1.1.0
-- properties
g_savedata = {
    mode = "prod",
    missions = {},
    objects = {},
    players = {},
    locations = {},
    locations_history = {},
    zones = {},
    mission_timer_tickrate = 0,
    mission_interval = 0,
    mission_interval_min = property.slider("New missions occurs at a minimum interval of (minutes):", 0, 30, 1, 5) * 3600,
    mission_interval_max = property.slider("New missions occurs at a maximum interval of (minutes):", 0, 30, 1, 10) * 3600,
    mission_range_min = property.slider("New missions occurs in a minimum range of (km):", 0, 100, 1, 1) * 1000,
    mission_range_max = property.slider("New missions occurs in a maximum range of (km):", 6, 100, 1, 10) * 1000,
    mission_range_limited = true,
    mission_count = 0,
    mission_count_limited = true,
    mission_mapped = true,
    mission_spawn_when_players_x = property.slider("New mission occurs when the number of missions is less than players divided by:", 1, 32, 1, 6),
    object_mapped = false,
    location_comparer = "name",
    zone_mapped = false,
    zone_marker_id = nil,
    cpa_recurrence = property.checkbox("CPA Recurrence", true),
    rescuees_has_strobe = property.checkbox("Rescuees has strobe", true),
    eot = true -- END OF TABLE: kore wo kesu to ue no gyou no ckonma ga fo-matta- ni yotte kesareru --
}

location_properties = {{
    pattern = "^mission:(.+)$",
    tracker = "sar",
    suitable_zones = {},
    is_main_location = true,
    sub_locations = {},
    sub_location_min = 0,
    sub_location_max = 0,
    is_unique_sub_location = false,
    range_max = g_savedata.mission_range_max,
    search_radius = 100,
    nortification_type = 0,
    report = "",
    report_timer_min = 0,
    report_timer_max = 0,
    note = "New mission"
}}

zone_properties = {{
    landscape = "base",
    mapped = true,
    icon = 11
}, {
    landscape = "hospital",
    mapped = true,
    icon = 8
}, {
    landscape = "clinic",
    mapped = true,
    icon = 8
}, {
    landscape = "police_station",
    mapped = true,
    icon = 11
}, {
    landscape = "freight_terminal",
    mapped = true,
    icon = 3
}, {
    landscape = "forest"
}, {
    landscape = "hill"
}, {
    landscape = "mountain"
}, {
    landscape = "volcano"
}, {
    landscape = "field"
}, {
    landscape = "beach"
}, {
    landscape = "ait"
}, {
    landscape = "island"
}, {
    landscape = "campsite"
}, {
    landscape = "offshore"
}, {
    landscape = "shallow"
}, {
    landscape = "underwater"
}, {
    landscape = "channel"
}, {
    landscape = "lake"
}, {
    landscape = "diving_spot"
}, {
    landscape = "airfield"
}, {
    landscape = "heliport"
}, {
    landscape = "runway"
}, {
    landscape = "road"
}, {
    landscape = "track"
}, {
    landscape = "crossing"
}, {
    landscape = "tunnel"
}, {
    landscape = "bridge"
}, {
    landscape = "house"
}, {
    landscape = "building"
}, {
    landscape = "plant"
}, {
    landscape = "mine"
}, {
    landscape = "first_spawn"
}, {
    landscape = "respawn"
}}

mission_trackers = {
    sar = {
        init = function(self, mission)
        end,
        clear = function(self, mission)
        end,
        tick = function(self, mission, tick)
            if not mission.spawned then
                for i = 1, #mission.locations do
                    spawn_location(mission.locations[i], mission.id)
                end

                local c, x, y, z = 0, 0, 0, 0

                for i = 1, #g_savedata.objects do
                    if g_savedata.objects[i].mission == mission.id and g_savedata.objects[i].tracker ~= nil then
                        local ox, oy, oz = matrix.position(g_savedata.objects[i].transform)
                        c = c + 1
                        x = x + ox
                        y = y + oy
                        z = z + oz
                    end
                end

                x = x / c
                y = y / c
                z = z / c

                mission.search_center = matrix.translation(x, y, z)
                mission.spawned = true
            end
        end,
        completed = function(self, mission)
            local completed = mission.spawned

            for k, object in pairs(g_savedata.objects) do
                if object.mission == mission.id and object.tracker ~= nil then
                    completed = completed and object_trackers[object.tracker]:completed(object)
                end
            end

            return completed or mission.closed
        end,
        close = function(self, mission)
            mission.closed = true
        end,
        reward = function(self, mission)
            local reward = mission.reward

            for k, object in pairs(g_savedata.objects) do
                if object.mission == mission.id and object.tracker ~= nil and object_trackers[object.tracker]:completed(object) then
                    reward = reward + object_trackers[object.tracker]:reward(object)
                end
            end

            if reward > 0 then
                local distance = matrix.distance(mission.start_position, mission.locations[1].transform)
                reward = reward + math.floor(distance / 1000) * 2000 * 2
            end

            return reward
        end,
        report = function(self, mission)
            local st, en, text = string.find(mission.locations[1].name, mission.locations[1].pattern)
            text = string.gsub(text, "_", " ")
            return string.format("#%d " .. text, mission.id)
        end,
        progress = function(self, mission)
            local test = {}

            for k, v in pairs(object_trackers) do
                test[k] = {
                    count = 0,
                    completed = 0
                }
            end

            for k, v in pairs(g_savedata.objects) do
                if v.mission == mission.id and v.tracker ~= nil then
                    if object_trackers[v.tracker]:completed(v) then
                        test[v.tracker].completed = test[v.tracker].completed + 1
                    end

                    test[v.tracker].count = test[v.tracker].count + 1
                end
            end

            local progresses = {}

            for k, v in pairs(test) do
                if v.count > 0 then
                    table.insert(progresses, string.format("%d\n" .. object_trackers[k].progress, test[k].count))
                end
            end

            return progresses
        end,
        status = function(self, mission)
            local text = "Progress:"

            local progresses = self:progress(mission)

            for k, progress in pairs(progresses) do
                text = text .. "\n\n" .. progress
            end

            return text
        end
    }
}

object_trackers = {
    rescuee = {
        test_type = function(self, component)
            return component.type == "character" and component.tags.tracker and component.tags.tracker == "rescuee"
        end,
        init = function(self, object)
            local hp_min = -20
            local hp_max = 100

            object.exists = true
            object.completion_timer = 300
            object.vital = server.getCharacterData(object.id)
            object.vital.hp = tonumber(object.tags.hp) or math.max(0, math.random(0, hp_max - hp_min) + hp_min)

            if object.vital.hp == 0 then
                object.cpa_count = 1
            else
                object.cpa_count = 0
            end

            object.on_board = 0
            object.nearby_player = false

            server.setCharacterData(object.id, object.vital.hp, true, object.vital.ai)

            if g_savedata.rescuees_has_strobe then
                server.setCharacterItem(object.id, 2, 23, false, 0, 100)
                server.setCharacterItem(object.id, 4, 24, true, 0, 100)
            end

            server.setCharacterTooltip(object.id, string.format("Rescuee\n%s\n\nMission ID: %d\nObject ID: %d", self.progress, object.mission, object.id))
        end,
        clear = function(self, object)
            server.setCharacterData(object.id, object.vital.hp, false, false)
        end,
        tick = function(self, object, tick)
            local transform, is_success = self:position(object)
            object.exists = is_success

            if not object.exists then
                return
            end

            local on_board = server.getCharacterVehicle(object.id)
            local get_on = on_board ~= 0 and object.on_board == 0
            local get_off = on_board == 0 and object.on_board ~= 0
            local vital_update = server.getCharacterData(object.id)
            local is_in_hospital = is_in_landscape(transform, "hospital")
            local nearby = nearby_players(transform, 250)
            local arrived = nearby and not object.nearby_player
            local leaved = not nearby and object.nearby_player

            if g_savedata.cpa_recurrence and not is_in_hospital then
                if object.vital.hp > 0 and vital_update.hp == 0 then
                    object.cpa_count = object.cpa_count + 1
                end

                vital_update.hp = math.ceil(math.max(vital_update.hp - object.cpa_count, 0))
            end

            if g_savedata.rescuees_has_strobe then
                if (arrived and on_board == 0) or (get_off and nearby) then
                    server.setCharacterItem(object.id, 2, 23, true, 0, 100)
                    server.setCharacterItem(object.id, 4, 24, true, 0, 100)
                end

                if get_on then
                    server.setCharacterItem(object.id, 2, 23, false, 0, 100)
                    server.setCharacterItem(object.id, 4, 24, false, 0, 100)
                end
            end

            object.vital = vital_update

            if is_in_hospital then
                object.completion_timer = math.max(object.completion_timer - tick, 0)
            end

            server.setCharacterData(object.id, object.vital.hp, not is_in_hospital, object.vital.ai)

            object.on_board = on_board
            object.nearby_player = nearby

            console.notify(string.format("%.00f %.00f", object.cpa_count, object.vital.hp))
        end,
        position = function(self, object)
            return server.getObjectPos(object.id)
        end,
        completed = function(self, object)
            return not object.exists or object.completion_timer == 0
        end,
        reward = function(self, object)
            local value = math.ceil(self.reward_base * (math.floor(object.vital.hp / 25) / 4))

            if object.vital.is_dead then
                value = 0
            end

            if g_savedata.cpa_recurrence and object.cpa_count >= 2 then
                value = value - object.cpa_count * 1000
            end

            return value
        end,
        status = function(self, object)
            -- return string.format("%s\nHP: %d/100\nCPR: %d", self.progress, object.vital.hp, object.cpa_count)
            return self.progress
        end,
        reward_base = 2500,
        progress = "Search rescuees\nand admit into medical settings",
        marker_type = 1
    },
    fire = {
        test_type = function(self, component)
            return component.type == "fire"
        end,
        init = function(self, object)
            object.is_lit = server.getFireData(object.id)
        end,
        clear = function(self, object)
        end,
        tick = function(self, object, tick)
            local is_lit, is_success = server.getFireData(object.id)
            object.is_lit = is_success and is_lit
        end,
        position = function(self, object)
            return server.getObjectPos(object.id)
        end,
        completed = function(self, object)
            local is_lit, is_success = server.getFireData(object.object_id)
            return not is_lit
        end,
        reward = function(self, object)
            return self.reward_base
        end,
        status = function(self, object)
            return self.progress
        end,
        reward_base = 1000,
        progress = "Extinguish fires",
        marker_type = 5
    },
    headquarter = {
        test_type = function(self, component)
            return component.type == "vehicle" and component.tags.tracker and component.tags.tracker == "headquarter"
        end,
        init = function(self, object)
        end,
        clear = function(self, object)
        end,
        tick = function(self, object, tick)
        end,
        alert = function(self, object)
            server.pressVehicleButton(object.main_body_id, "Alert")
        end,
        position = function(self, object)
            return server.getVehiclePos(object.main_body_id)
        end,
        completed = function(self, object)
            return false
        end,
        reward = function(self, object)
            return self.reward_base
        end,
        status = function(self, object)
            return self.progress
        end,
        reward_base = 0,
        progress = "",
        marker_type = 11
    }
}

-- main logics
-- missions

function random_mission(center, range_max, range_min)
    local location, e = random_location(center, range_max, range_min, {}, {}, true, true)

    if location == nil then
        return
    end

    initialize_mission(center, range_min, location.tracker, location)
end

function initialize_mission(center, range_min, tracker, location, report_timer)
    local mission = {}
    mission.id = g_savedata.mission_count + 1

    console.notify(string.format("Initializing mission #%d...", mission.id))

    mission.start_position = center
    mission.tracker = tracker
    mission.locations = {location}
    mission.search_center = nil
    mission.search_radius = mission.locations[1].search_radius
    mission.reported = false
    mission.report_timer = report_timer or math.random(mission.locations[1].report_timer_min, mission.locations[1].report_timer_max)
    mission.spawned = false
    mission.closed = false
    mission.marker = server.getMapID()
    mission.units = {
        sar = false,
        medic = false,
        fire = false,
        specialist = false
    }
    mission.reward = 0
    mission_trackers[mission.tracker]:init(mission)

    record_location_history(location)
    table.insert(g_savedata.missions, mission)
    g_savedata.mission_count = g_savedata.mission_count + 1

    local sub_location_count = math.random(mission.locations[1].sub_location_min, mission.locations[1].sub_location_max)

    for i = 1, sub_location_count do
        local sub_location = random_location(mission.locations[1].transform, mission.search_radius, 0, mission.locations[1].sub_locations, {}, false, true)

        if sub_location then
            table.insert(mission.locations, sub_location)
        end
    end
end

function clear_mission(index)
    for i = #g_savedata.objects, 1, -1 do
        if g_savedata.objects[i].mission == g_savedata.missions[index].id then
            clear_object(i)
        end
    end

    server.removeMapID(-1, g_savedata.missions[index].marker)
    mission_trackers[g_savedata.missions[index].tracker]:clear(g_savedata.missions[index])

    console.notify(string.format("Cleared mission #%d.", g_savedata.missions[index].id))

    table.remove(g_savedata.missions, index)
end

function reward_mission(index)
    local reward = mission_trackers[g_savedata.missions[index].tracker]:reward(g_savedata.missions[index])

    transact(reward, string.format("Completed mission #%d.", g_savedata.missions[index].id))
end

-- objects

function initialize_object(object, mission, tracker)
    object.tracker = tracker or nil
    object.mission = mission

    if object.type == "vehicle" then
        object.id = object.group_id
        object.main_body_id = object.vehicle_ids[1]
    else
        object.id = object.object_id
    end

    if object.tracker ~= nil then
        object.marker = server.getMapID()
        object_trackers[object.tracker]:init(object)
    end

    table.insert(g_savedata.objects, object)

    console.notify(string.format("Initializing object %s#%d.", object.type, object.id))
end

function clear_object(index)
    if g_savedata.objects[index].tracker ~= nil then
        object_trackers[g_savedata.objects[index].tracker]:clear(g_savedata.objects[index])
        server.removeMapID(-1, g_savedata.objects[index].marker)
    end

    if g_savedata.objects[index].type == "character" then
        server.despawnObject(g_savedata.objects[index].id, true)
    elseif g_savedata.objects[index].type == "vehicle" then
        despawn_vehicle_group(g_savedata.objects[index].id, true)
    else
        server.despawnObject(g_savedata.objects[index].id, true)
    end

    console.notify(string.format("Cleared object %s#%d.", g_savedata.objects[index].type, g_savedata.objects[index].id))

    table.remove(g_savedata.objects, index)
end

function find_parent_object(vehicle_parent_component_id, mission_id)
    local obj = table.find(g_savedata.objects, function(x)
        return x.mission == mission_id and x.component_id == vehicle_parent_component_id
    end)

    if obj == nil then
        obj = table.find(g_savedata.objects, function(x)
            return x.mission == mission_id and x.component_id == vehicle_parent_component_id
        end)
    end

    return obj
end

function spawn_character(transform, data)
    local object_id, is_scuccess = server.spawnCharacter(transform, data.character_outfit_type)
    local object = {}
    object.object_id = object_id
    object.group_id = nil
    object.vehicle_id = nil
    object.vehicle_ids = {}
    object.id = nil
    object.tags_full = data.tags_full
    object.tags = data.tags
    object.display_name = data.display_name
    object.type = data.type
    object.transform = server.getObjectPos(object.object_id)

    return object
end

function spawn_equipment(transform, type, int, flt)
    local object_id, is_success = server.spawnEquipment(transform, type, int, flt)
    local object = {}
    object.object_id = object_id
    object.group_id = nil
    object.vehicle_id = nil
    object.vehicle_ids = {}
    object.id = nil
    object.tags_full = ""
    object.tags = {}
    object.display_name = nil
    object.type = type
    object.transform = server.getObjectPos(object.object_id)

    return object
end

-- locations

function random_location(center, range_max, range_min, location_names, zone_names, is_main_location, check_dupe)
    if #g_savedata.locations == 0 then
        console.error("Mission location does not exist. Check if your add-ons contains valid mission location.")
        return nil
    end

    local location_candidates = {}

    for i = 1, #g_savedata.locations do
        if is_main_location and not g_savedata.locations[i].is_main_location then
            goto continue_location
        end

        if check_dupe and (is_main_location or g_savedata.locations[i].is_unique_sub_location) and is_location_duplicated(g_savedata.locations[i]) then
            goto continue_location
        end

        if #location_names > 0 and not match_location_name(g_savedata.locations[i], location_names) then
            goto continue_location
        end

        local location_candidate = table.copy(g_savedata.locations[i])

        if g_savedata.locations[i].tile == "" then
            local zone_candidate_keys = {}
            local zone_candidate_types = {}

            for j = 1, #g_savedata.zones do
                if #zone_names > 0 and not table.contains(zone_names, g_savedata.zones[j].landscape) then
                    goto continue_zone
                end

                if not table.contains(g_savedata.locations[i].suitable_zones, g_savedata.zones[j].landscape) then
                    goto continue_zone
                end

                if (not is_main_location or g_savedata.mission_range_limited) and not is_zone_in_range(g_savedata.zones[j], center, range_max, range_min) then
                    goto continue_zone
                end

                for k = 1, #g_savedata.missions do
                    for l = 1, #g_savedata.missions[k].locations do
                        if g_savedata.missions[k].locations[l].zone and g_savedata.missions[k].locations[l].zone.id == g_savedata.zones[j].id then
                            goto continue_zone
                        end
                    end
                end

                table.insert(zone_candidate_keys, j)
                table.insert(zone_candidate_types, g_savedata.zones[j].landscape)

                ::continue_zone::
            end

            zone_candidate_types = table.distinct(zone_candidate_types)

            if (#zone_names > 0 and table.contains(zone_names, "offshore")) or (#zone_names == 0 and table.contains(g_savedata.locations[i].suitable_zones, "offshore")) then
                table.insert(zone_candidate_types, "offshore")
            end

            local zone_candidate_type = table.random(zone_candidate_types)

            if zone_candidate_type == "offshore" then
                location_candidate.zone = random_offshore_zone(center, range_max, range_min)

                if location_candidate.zone == nil then
                    goto continue_location
                end
            else
                for j = #zone_candidate_keys, 1, -1 do
                    if g_savedata.zones[zone_candidate_keys[j]].landscape ~= zone_candidate_type then
                        table.remove(zone_candidate_keys, j)
                    end
                end

                if #zone_candidate_keys == 0 then
                    goto continue_location
                end

                local zone_candidate_key = table.random(zone_candidate_keys)

                location_candidate.zone = table.copy(g_savedata.zones[zone_candidate_key])
            end

            location_candidate.transform = location_candidate.zone.transform
        else
            local transform, is_success = server.getTileTransform(center, g_savedata.locations[i].tile, range_max)

            if not is_success or g_savedata.mission_range_limited and matrix.distance(center, transform) > range_max then
                goto continue_location
            end

            location_candidate.transform = transform
        end

        table.insert(location_candidates, location_candidate)

        ::continue_location::
    end

    if #location_candidates == 0 then
        -- console.error("No available locations were found. Either overlap with missions ongoing, or there is no suitable zones within mission range.")

        local text = "No available locations were found with name: "

        for i = 1, #location_names do
            text = text .. location_names[i]

            if i < #location_names then
                text = text .. ", "
            end
        end

        console.error(text)

        return nil
    end

    return table.random(location_candidates)
end

function match_location_name(location, patterns)
    local matched = false

    for i = 1, #patterns do
        matched = matched or string.match(location.name, patterns[i]) ~= nil
    end

    return matched
end

function is_location_free(location, mission)
    return location.id ~= mission.locations[1].id;
end

function is_location_duplicated(location)
    local dupe = false
    local l = {}
    local unique = 0

    for i = 1, #g_savedata.missions do
        for j = 1, #g_savedata.missions[i].locations do
            dupe = dupe or (g_savedata.missions[i].locations[j][g_savedata.location_comparer] == location[g_savedata.location_comparer])
        end
    end

    for i = 1, #g_savedata.locations do
        if g_savedata.locations[i].is_main_location then
            l[g_savedata.locations[i][g_savedata.location_comparer]] = true
        end
    end

    for _, v in pairs(l) do
        unique = unique + 1
    end

    local history_back = #g_savedata.locations_history - math.floor(unique * 0.75) + 1

    for i = #g_savedata.locations_history, math.max(history_back, 1), -1 do
        dupe = dupe or g_savedata.locations_history[i][g_savedata.location_comparer] == location[g_savedata.location_comparer]
    end

    return dupe
end

function spawn_location(location, mission_id)
    local vehicles = {}
    local others = {}

    for component_index = 0, location.component_count do
        local data = server.getLocationComponentData(location.addon_index, location.location_index, component_index)

        if data ~= nil then
            data.addon_index = location.addon_index
            data.location_index = location.location_index
            data.component_index = component_index
            data.tags = parse_tags(data.tags_full)

            if data.type == "vehicle" then
                table.insert(vehicles, data)
            else
                table.insert(others, data)
            end
        end
    end

    if location.zone then
        console.notify(string.format("Spawning dynamic location %s in zone %s#%d", location.name, location.zone.name, location.zone.id))
    else
        console.notify(string.format("Spawning fixed location %s", location.name))
    end

    for k, v in pairs(vehicles) do
        spawn_component(v, location.transform, mission_id)
    end

    for k, v in pairs(others) do
        spawn_component(v, location.transform, mission_id)
    end
end

function spawn_component(component, transform, mission_id)
    local obj_types = table.keys(object_trackers)
    local transform = matrix.multiply(transform, component.transform)
    local parent_object_id = nil

    if component.vehicle_parent_component_id > 0 then
        local parent_object = find_parent_object(component.vehicle_parent_component_id, mission_id)
        parent_object_id = parent_object.main_body_id
    end

    local object, is_success = server.spawnAddonComponent(transform, component.addon_index, component.location_index, component.component_index, parent_object_id)
    local tracker = nil

    for k, v in pairs(object_trackers) do
        if v:test_type(component) then
            tracker = k
            break
        end
    end

    object.tags = parse_tags(object.tags_full)
    object.component_id = component.id

    initialize_object(object, mission_id, tracker)
end

function load_locations()
    g_savedata.locations = {}

    local addon_count = server.getAddonCount()
    local addon_index = 0

    while addon_index <= addon_count do
        local location_count = (server.getAddonData(addon_index) or {
            location_count = 0
        }).location_count
        local location_index = 0

        while location_index <= location_count do
            local location = server.getLocationData(addon_index, location_index)

            if location and not location.env_mod then
                for i = 1, #location_properties do
                    if string.match(location.name, location_properties[i].pattern) then
                        location.id = #g_savedata.locations + 1
                        location.addon_index = addon_index
                        location.location_index = location_index
                        location.pattern = location_properties[i].pattern or nil
                        location.tracker = location_properties[i].tracker or nil
                        location.suitable_zones = location_properties[i].suitable_zones or {}

                        if location_properties[i].is_main_location ~= nil then
                            location.is_main_location = location_properties[i].is_main_location
                        else
                            location.is_main_location = true
                        end

                        location.sub_locations = location_properties[i].sub_locations or {}
                        location.sub_location_min = location_properties[i].sub_location_min or 0
                        location.sub_location_max = location_properties[i].sub_location_max or 0
                        location.is_unique_sub_location = location_properties[i].is_unique_sub_location or false
                        location.search_radius = location_properties[i].search_radius or 0
                        location.notification_type = location_properties[i].notification_type or 0
                        location.report = location_properties[i].report or ""
                        location.report_timer_min = location_properties[i].report_timer_min or 0
                        location.report_timer_max = location_properties[i].report_timer_max or 0
                        location.note = location_properties[i].note or ""

                        table.insert(g_savedata.locations, location)
                    end
                end
            end

            location_index = location_index + 1
        end

        addon_index = addon_index + 1
    end
end

function list_locations(peer_id)
    for i = 1, #g_savedata.locations do
        server.announce("[Mission Foundation]", g_savedata.locations[i].name, peer_id)
    end

    server.announce("[Mission Foundation]", string.format("%d all locations", #g_savedata.locations), peer_id)
end

function record_location_history(location)
    table.insert(g_savedata.locations_history, table.copy(location))
end

function list_location_history(peer_id)
    local peer_id = peer_id

    for i = 1, #g_savedata.locations_history do
        server.announce("[Mission Foundation]", string.format("%d %s", i, g_savedata.locations_history[i].name), peer_id)
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
        is = is or g_savedata.zones[i].landscape == landscape and is_in_zone(transform, g_savedata.zones[i])
    end

    return is
end

function is_in_zone(transform, zone)
    return server.isInTransformArea(transform, zone.transform, zone.size.x, zone.size.y, zone.size.z)
end

function random_offshore_zone(center, range_max, range_min)
    local transform, is_success = server.getOceanTransform(center, range_min, range_max)

    if not is_success then
        return nil
    end

    local x, y, z = matrix.position(transform)
    local error = matrix.translation(math.random() * 500, 0, math.random() * 500)
    transform = matrix.multiply(transform, error)
    local id = #g_savedata.zones + 1
    local zone = {
        id = id,
        tags_full = "",
        tags = {},
        display_name = "",
        transform = transform,
        size = {
            x = 20,
            y = 20,
            z = 20
        },
        radius = 10,
        type = 0,
        parent_vehicle_id = nil,
        parent_relative_transform = nil,
        mapped = false,
        icon = 0
    }

    return zone
end

function map_zone(zone, peer_id)
    local peer_id = peer_id or -1

    if g_savedata.zone_mapped or zone.mapped then
        local x, y, z = matrix.position(zone.transform)
        local color = zone.icon == 8 and 255 or 0
        local name = zone.name

        if name == "" then
            name = zone.landscape
        end

        server.addMapLabel(peer_id, zone.marker, zone.icon, name, x, z, color, color, color, 255)
    end
end

function load_zones()
    for i = 1, #g_savedata.zones do
        server.removeMapID(-1, g_savedata.zones[i].marker)
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
                zone.marker = server.getMapID()
                zone.mapped = zone_properties[i].mapped or false
                zone.icon = zone_properties[i].icon or 0

                map_zone(zone)
                table.insert(g_savedata.zones, zone)

                id = id + 1
            end
        end
    end
end

-- headquarter

function initialize_headquarter(group_id)
    local vehicle_ids, is_success = server.getVehicleGroup(group_id)
    local hq = {}

    if not is_success or is_headquarter_overlap(group_id) then
        return
    end

    local transform = server.getVehiclePos(vehicle_ids[1])

    hq.tags_full = ""
    hq.tags = {}
    hq.display_name = ""
    hq.transform = transform
    hq.type = "vehicle"
    hq.group_id = group_id
    hq.vehicle_ids = vehicle_ids
    hq.component_id = nil

    initialize_object(hq, nil, "headquarter")
end

function alert_headquarter()
    for i = 1, #g_savedata.objects do
        if g_savedata.objects[i].tracker == "headquarter" then
            object_trackers.headquarter:alert(g_savedata.objects[i])
        end
    end
end

function is_headquarter_overlap(group_id)
    local is = false

    for i = 1, #g_savedata.objects do
        is = is or g_savedata.objects[i].tracker == "headquarter" and g_savedata.objects.id == group_id
    end

    return is
end

-- budgets

function transact(amount, title)
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

function nearby_players(transform, distance)
    local result = false

    for i = 1, #players do
        local d = matrix.distance(players[i].transform, transform)

        result = result or matrix.distance(players[i].transform, transform) <= distance
    end

    return result
end

-- spawn point

function teleport_to_spawn_points(peer_id)
    local spawn_zone_keys = {}

    for i = 1, #g_savedata.zones do
        if g_savedata.zones[i].landscape == "respawn" then
            table.insert(spawn_zone_keys, i)
        end
    end

    if #spawn_zone_keys == 0 then
        return
    end

    local spawn_zone_key = table.random(spawn_zone_keys)

    server.setPlayerPos(peer_id, g_savedata.zones[spawn_zone_key].transform)
end

-- players

players = {}
players_map = {}

-- callbacks

timing_default = 60
timing = timing_default

function onTick(tick)
    math.randomseed(server.getTimeMillisec())

    if g_savedata.mission_timer_tickrate > 0 then
        if g_savedata.mission_interval <= 0 and (not g_savedata.mission_count_limited or missions_less_than_limit()) then
            random_mission(start_tile_transform(), g_savedata.mission_range_max, g_savedata.mission_range_min)
            g_savedata.mission_interval = math.random(g_savedata.mission_interval_min, g_savedata.mission_interval_max)
        else
            g_savedata.mission_interval = g_savedata.mission_interval - (tick * g_savedata.mission_timer_tickrate)
        end
    end

    if timing % 10 == 0 then
        players = server.getPlayers()

        for k, v in pairs(players) do
            local transform, is_success = server.getPlayerPos(v.id)

            if is_success then
                v.transform = transform
            end

            v.open_map = players_map[k] or false
        end
    end

    for i = #g_savedata.objects, 1, -1 do
        if i % timing_default == timing and g_savedata.objects[i].tracker ~= nil then
            object_trackers[g_savedata.objects[i].tracker]:tick(g_savedata.objects[i], tick * timing_default)
            server.removeMapID(-1, g_savedata.objects[i].marker)

            if g_savedata.object_mapped then
                local transform = object_trackers[g_savedata.objects[i].tracker]:position(g_savedata.objects[i])
                local x, y, z = matrix.position(transform)
                local r, g, b, a = 127, 127, 127, 255
                local label = string.format("%s #%d", g_savedata.objects[i].tracker, g_savedata.objects[i].id)
                local popup = string.format("X: %.0f\nY: %.0f\nZ: %.0f", x, y, z)
                local marker_type = object_trackers[g_savedata.objects[i].tracker].marker_type

                server.addMapObject(-1, g_savedata.objects[i].marker, 0, marker_type, x, z, 0, 0, nil, nil, label, 0, popup, r, g, b, a)
            end

            if g_savedata.objects[i].mission and object_trackers[g_savedata.objects[i].tracker]:completed(g_savedata.objects[i]) then
                for j = 1, #g_savedata.missions do
                    if g_savedata.missions[j].id == g_savedata.objects[i].mission then
                        g_savedata.missions[j].reward = g_savedata.missions[j].reward + object_trackers[g_savedata.objects[i].tracker]:reward(g_savedata.objects[i])
                    end
                end

                server.notify(-1, object_trackers[g_savedata.objects[i].tracker]:status(g_savedata.objects[i]), "Objective achieved", 4)
                clear_object(i)
            end
        end
    end

    for i = #g_savedata.missions, 1, -1 do
        if i % timing_default == timing then
            mission_trackers[g_savedata.missions[i].tracker]:tick(g_savedata.missions[i], tick * timing_default)
            server.removeMapID(-1, g_savedata.missions[i].marker)

            if g_savedata.mission_mapped and g_savedata.missions[i].search_center then
                local label = mission_trackers[g_savedata.missions[i].tracker]:report(g_savedata.missions[i])
                local label_hover = mission_trackers[g_savedata.missions[i].tracker]:status(g_savedata.missions[i])
                local x, y, z = matrix.position(g_savedata.missions[i].search_center)

                server.addMapObject(-1, g_savedata.missions[i].marker, 0, 8, x, z, 0, 0, nil, nil, label, g_savedata.missions[i].locations[1].search_radius, label_hover, 255, 0, 255, 255)
            end

            g_savedata.missions[i].report_timer = math.max(g_savedata.missions[i].report_timer - tick * timing_default, 0)

            if not g_savedata.missions[i].reported and g_savedata.missions[i].report_timer == 0 then
                alert_headquarter()
                server.notify(-1, mission_trackers[g_savedata.missions[i].tracker]:report(g_savedata.missions[i]), g_savedata.missions[i].locations[1].note, g_savedata.missions[i].locations[1].notification_type)
                g_savedata.missions[i].reported = true
            end

            if mission_trackers[g_savedata.missions[i].tracker]:completed(g_savedata.missions[i]) then
                reward_mission(i)
                clear_mission(i)
            end
        end
    end

    timing = timing - 1

    if timing <= 0 then
        timing = timing_default
    end
end

function onCustomCommand(full_message, peer_id, is_admin, is_auth, command, verb, ...)
    if command == "?mission" then
        if verb == "list" and is_admin then
            list_locations(peer_id)
        elseif verb == "history" then
            list_location_history(peer_id)
        elseif verb == "start" and is_admin then
            g_savedata.mission_timer_tickrate = 1
        elseif verb == "stop" and is_admin then
            g_savedata.mission_timer_tickrate = 0
        elseif verb == "init" and is_admin then
            local location, report_timer = ...
            local report_timer = tonumber(report_timer)
            local center = start_tile_transform()
            location = "^" .. location .. "$"
            local location = random_location(center, g_savedata.mission_range_max, g_savedata.mission_range_min, {location}, {}, true, false)

            if location == nil then
                return
            end

            initialize_mission(center, g_savedata.mission_range_min, location.tracker, location, report_timer)
        elseif verb == "clear-all" and is_admin then
            for i = #g_savedata.missions, 1, -1 do
                clear_mission(i)
            end
        elseif verb == "clear" and is_admin then
            local id = ...
            id = tonumber(id)
            local index = table.find_index(g_savedata.missions, function(x)
                return x.id == id
            end)

            if index == nil then
                console.error(string.format("Mission #%d is not exist.", id))
                return
            end

            clear_mission(index)
        elseif verb == "next" and is_admin then
            g_savedata.mission_interval = 0
        elseif verb == "close" and is_admin then
            local id = ...
            id = tonumber(id)
            local mission = table.find(g_savedata.missions, function(x)
                return x.id == id
            end)

            if mission == nil then
                console.error(string.format("Mission #%d is not exist.", id))
                return
            end

            mission_trackers[mission.tracker]:close(mission)
        elseif verb == "register-hq" and is_admin then
            local group_id = ...
            local group_id = tonumber(group_id)

            if not group_id then
                console.error("Vehicle Group ID is not a number.")
                return
            end

            initialize_headquarter(group_id)
        elseif verb == "prod" and is_admin then
            g_savedata.mode = "prod"
        elseif verb == "debug" and is_admin then
            g_savedata.mode = "debug"
        elseif verb == "map" and is_admin then
            local target = ...

            if target == "mission" then
                g_savedata.mission_mapped = not g_savedata.mission_mapped
            elseif target == "zone" then
                g_savedata.zone_mapped = not g_savedata.zone_mapped

                for i = 1, #g_savedata.zones do
                    server.removeMapID(-1, g_savedata.zones[i].marker)
                    map_zone(g_savedata.zones[i])
                end
            elseif target == "object" then
                g_savedata.object_mapped = not g_savedata.object_mapped
            end
        elseif verb == "limit-count" and is_admin then
            g_savedata.mission_count_limited = not g_savedata.mission_count_limited
        elseif verb == "limit-range" and is_admin then
            g_savedata.mission_range_limited = not g_savedata.mission_range_limited
        elseif verb == "close-in" and is_admin then
            local mission_id = ...
            mission_id = tonumber(mission_id)
            local transform, is_success = server.getPlayerPos(peer_id)

            for i = #g_savedata.objects, 1, -1 do
                if g_savedata.objects[i].tracker == "rescuee" and g_savedata.objects[i].mission == mission_id then
                    server.setObjectPos(g_savedata.objects[i].id, transform)
                end
            end
        elseif verb == "cpa-recurrence" and is_admin then
            g_savedata.cpa_recurrence = not g_savedata.cpa_recurrence

            console.notify(string.format("CPA Recurrence: %s", g_savedata.cpa_recurrence))
        elseif verb == "clear-history" and is_admin then
            g_savedata.locations_history = {}
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

    local transform = server.getPlayerPos(peer_id)

    if is_in_landscape(transform, "first_spawn") then
        teleport_to_spawn_points(peer_id)
    end
end

function onPlayerLeave(steam_id, name, peer_id, is_admin, is_auth)
end

function onPlayerRespawn(peer_id)
    teleport_to_spawn_points(peer_id)

    if not server.getGameSettings().infinite_money then
        local player = table.find(players, function(p)
            return p.id == peer_id
        end)
        transact(-10000, string.format("%s bought a new life.", player.name))
    end
end

function onToggleMap(peer_id, is_open)
    players_map[peer_id] = is_open
end

function onCreate(is_world_create)
    if is_world_create then
        server.command("?clearing")
    end

    load_zones()
    load_locations()

    console.notify(string.format("Locations: %d", #g_savedata.locations))
    console.notify(string.format("Zones: %d", #g_savedata.zones))
    console.notify(string.format("Gone missions: %d", #g_savedata.locations_history))
    console.notify(string.format("Active missions: %d", #g_savedata.missions))
    console.notify(string.format("Active objects: %d", #g_savedata.objects))
end

function onEquipmentDrop(object_id_actor, object_id_target, equipment_id)
    local is_npc = false

    for i = #g_savedata.objects, 1, -1 do
        is_npc = is_npc or g_savedata.objects[i].type == "character" and g_savedata.objects[i].id == object_id_actor
    end

    server.despawnObject(object_id_target, is_npc)
end

-- utils

function toggle_vehicle_button(vehicle_id, button_name, value)
    local data, s = server.getVehicleButton(vehicle_id, button_name)

    if s and ((value or data.on) and (not value or not data.on)) then
        server.pressVehicleButton(vehicle_id, button_name)
    end
end

function missions_less_than_limit()
    return #g_savedata.missions < math.min(#players / g_savedata.mission_spawn_when_players_x, 48)
end

function despawn_vehicle_group(group_id, is_instant)
    local vehicle_ids, is_success = server.getVehicleGroup(group_id)

    if not is_success then
        return
    end

    for k, v in pairs(vehicle_ids) do
        server.despawnVehicle(v, is_instant or false)
    end
end

function start_tile_transform()
    local start_tile = server.getStartTile()
    return matrix.translation(start_tile.x, start_tile.y, start_tile.z)
end

function parse_tags(tags_full)
    local t = {}

    for k, v in string.gmatch(tags_full, "([%w_]+)=([%w_-]+)") do
        t[k] = v
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

function math.round(x)
    return math.floor(x + 0.5)
end

function string.split(text, sepatator)
    local result = {}

    for sub in string.gmatch(text, "([^" .. sepatator .. "])") do
        table.insert(result, sub)
    end
end

