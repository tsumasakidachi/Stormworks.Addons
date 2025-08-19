env = "production"
g_savedata = {
	mission_interval = 90000,
	mission_interval_min = 18000,
	mission_interval_max = 54000,
	mission_count = 0,
	mission_count_max = 4,
	mission_range_max = 10000,
	missions = {},
	objectives = {},
	objects = {},
	players = {},
	headquarters = {}
}

locations = {}
landscapes = {}

-- missions

mission_template = { {
	type = "missing",
	tracker = "sar",
	report = "#%d Rescue Call",
	caller = "police station",
	suitable_zones = { "forest", "hill", "mountain", "island" },
	is_submission = false,
	ongoing = false,
	radius = 1000,
	fuzziness = 1000
}, {
	type = "evac",
	tracker = "sar",
	report = "#%d Rescue Call",
	caller = "citizen",
	suitable_zones = { "forest", "hill", "field" },
	is_submission = true,
	ongoing = false,
	radius = 100,
	fuzziness = 100
}, {
	type = "ae",
	tracker = "sar",
	report = "#%d Accident & Emergency Call",
	caller = "citizen",
	suitable_zones = { "campsite", "beach", "airfield" },
	is_submission = true,
	ongoing = false,
	radius = 100,
	fuzziness = 100
}, {
	type = "traffic",
	tracker = "sar",
	report = "#%d Accident & Emergency Call",
	caller = "citizen",
	suitable_zones = { "road", "tunnel", "crossing" },
	is_submission = false,
	ongoing = false,
	radius = 50,
	fuzziness = 50
}, {
	type = "machinery",
	tracker = "sar",
	report = "#%d Fire Call",
	caller = "citizen",
	suitable_zones = { "field" },
	is_submission = false,
	ongoing = false,
	radius = 50,
	fuzziness = 50
}, {
	type = "boat",
	tracker = "sar",
	report = "#%d Rescue Call",
	caller = "citizen",
	suitable_zones = { "lake" },
	is_submission = false,
	ongoing = false,
	radius = 100,
	fuzziness = 100
}, {
	type = "mayday",
	tracker = "sar",
	report = "#%d Mayday Call",
	caller = "crew",
	suitable_zones = { "channel", "offshore" },
	is_submission = false,
	ongoing = false,
	radius = 1000,
	fuzziness = 1000
}, {
	type = "flotsam",
	tracker = "sar",
	report = "#%d Flotsam Call",
	caller = "crew",
	suitable_zones = { "channel" },
	is_submission = false,
	ongoing = false,
	radius = 1000,
	fuzziness = 1000
}, {
	type = "wind",
	tracker = "fire",
	report = "#%d Fire Call\nWind turbine on fire. It's a high spot that can't be reached by spraying water from ground.",
	caller = "staff",
	suitable_zones = { "wind farm" },
	is_submission = false,
	ongoing = false,
	radius = 0,
	fuzziness = 1
}, {
	type = "plant",
	tracker = "fire",
	report = "#%d Fire Call\nFacilities at %s on fire. Extinguish too late could lead to a major fire hazard.",
	caller = "staff",
	suitable_zones = { "petrochemical plant", "power plant", "oil rig" },
	is_submission = false,
	ongoing = false,
	radius = 0,
	fuzziness = 1
}, {
	type = "tornado",
	tracker = "hazard",
	report =
	"#%d Evacuation Alert\nTornado signs have been observed. Citizens are advised to evacuate from this area as a major hazard is expected.",
	caller = "meteorology office",
	suitable_zones = { "forest", "field", "hill", "lake", "road", "channel" },
	is_submission = false,
	submissions = { "evac" },
	ongoing = false,
	radius = 4000,
	fuzziness = 1,
	clear_timer = 14400
} }

scenes = { {
	name = "test",
	count = 0
}, {
	name = "clinic",
	count = 0
}, {
	name = "hospital",
	count = 0
}, {
	name = "police station",
	count = 0
}, {
	name = "safe zone",
	count = 0
}, {
	name = "forest",
	count = 0
}, {
	name = "hill",
	count = 0
}, {
	name = "mountain",
	count = 0
}, {
	name = "field",
	count = 0
}, {
	name = "beach",
	count = 0
}, {
	name = "island",
	count = 0
}, {
	name = "campsite",
	count = 0
}, {
	name = "volcano",
	count = 0
}, {
	name = "offshore",
	count = 0
}, {
	name = "shore",
	count = 0
}, {
	name = "channel",
	count = 0
}, {
	name = "lake",
	count = 0
}, {
	name = "building",
	count = 0
}, {
	name = "airfield",
	count = 0
}, {
	name = "runway",
	count = 0
}, {
	name = "road",
	count = 0
}, {
	name = "tunnel",
	count = 0
}, {
	name = "crossing",
	count = 0
}, {
	name = "wind farm",
	count = 0
}, {
	name = "petrochemical plant",
	count = 0
}, {
	name = "power plant",
	count = 0
}, {
	name = "oil rig",
	count = 0
}, {
	name = "freight terminal",
	count = 0
} }

mission_tracker = {
	sar = {
		initialize = function(self, mission, template, target_zone, target_location, center_transform, radius)
			local location_id = random_location(mission)

			if location_id == nil then
				return mission,
					string.format(
						"ミッション %s の初期化に失敗: ミッションロケーションが見つからない",
						mission.type)
			end

			-- mission.addon_index = location.addon_index
			-- mission.location_index = location.location_index
			mission.location_id = location_id

			local suitable_zones = template.suitable_zones

			if target_zone ~= nil then
				suitable_zones = { target_zone }
			end

			local zone = random_zone(suitable_zones, center_transform, radius)

			if zone ~= nil then
				mission.zone_index = zone.zone_index
				mission.scene = zone.name
				disable_zone(mission.zone_index)
			else
				mission.zone_index = nil
				mission.scene = ""

				return mission,
					string.format("Initialisation failed because a suitable location for %s mission could not be found",
						mission.type)
			end

			return mission, nil
		end,
		dispose = function(self, mission)
			for i = #g_savedata.objectives, 1, -1 do
				if g_savedata.objectives[i].mission_id == mission.mission_id then
					dispose_objective(i, g_savedata.objectives[i])
				end
			end

			enable_zone(mission.zone_index)
		end,
		tick = function(self, mission, tick)
			if not mission.spawned then
				local spawned, transform = spawn_mission_location(mission)
				mission.spawned = spawned
				mission.transform = transform
			end
		end,
		completed = function(self, mission)
			local completed = mission.spawned

			for k, objective in pairs(g_savedata.objectives) do
				if objective.mission_id == mission.mission_id then
					completed = completed and objective_tracker[objective.tracker]:completed(objective)
				end
			end

			return completed or mission.closed
		end,
		close = function(self, mission)
			mission.closed = true
		end,
		reward = function(self, mission)
			local reward = 0

			for k, objective in pairs(g_savedata.objectives) do
				if objective.mission_id == mission.mission_id and objective_tracker[objective.tracker]:completed(objective) then
					reward = reward + objective_tracker[objective.tracker]:reward(objective)
				end
			end

			if reward > 0 then
				local distance = distance_to_base(mission.transform)
				reward = reward + math.floor(distance / 1000) * 1000 * 0.5 * 2
			end

			return reward
		end,
		report = function(self, mission)
			return string.format(mission.report .. "\n" .. locations[mission.location_id].report, mission.mission_id,
				mission.scene)
		end,
		progress = function(self, mission)
			local test = {}

			for k, v in pairs(objective_tracker) do
				test[k] = {
					count = 0,
					completed = 0
				}
			end

			for k, v in pairs(g_savedata.objectives) do
				if v.mission_id == mission.mission_id then
					if objective_tracker[v.tracker]:completed(v) then
						test[v.tracker].completed = test[v.tracker].completed + 1
					end

					test[v.tracker].count = test[v.tracker].count + 1
				end
			end

			local progresses = {}

			for k, v in pairs(test) do
				if v.count > 0 then
					table.insert(progresses,
						string.format(objective_tracker[k].progress, test[k].completed, test[k].count))
				end
			end

			return progresses
		end,
		in_scene = function(self, mission, distance)
			return distance <= 50
		end
	},
	fire = {
		initialize = function(self, mission, template, target_zone, target_location, center_transform, radius)
			local suitable_zones = template.suitable_zones

			if target_zone ~= nil then
				suitable_zones = { target_zone }
			end

			local zone = random_zone(suitable_zones, center_transform, radius)

			if zone ~= nil then
				mission.zone_index = zone.zone_index
				mission.scene = zone.name
				disable_zone(mission.zone_index)
			else
				mission.zone_index = nil
				mission.scene = ""

				return mission,
					string.format("Initialisation failed because a suitable location for %s mission could not be found",
						mission.type)
			end

			mission.zone_index = zone.zone_index
			mission.transform = zone.transform

			return mission
		end,
		dispose = function(self, mission)
			mission_tracker.sar:dispose(mission)
		end,
		tick = function(self, mission, tick)
			if not mission.spawned then
				local fire = random_static_fire(landscapes[mission.zone_index])

				if fire == nil then
					return nil, "Mission initialization has failed because no fire was found"
				end

				fire.mission_id = mission.mission_id
				mission.spawned = true
			end
		end,
		completed = function(self, mission)
			return mission_tracker.sar:completed(mission)
		end,
		close = function(self, mission)
			mission_tracker.sar:close(mission)
		end,
		reward = function(self, mission)
			return mission_tracker.sar:reward(mission)
		end,
		report = function(self, mission)
			return string.format(mission.report, mission.mission_id, mission.scene)
		end,
		progress = function(self, mission)
			return mission_tracker.sar:progress(mission)
		end,
		in_scene = function(self, mission, distance)
			return mission_tracker.sar:in_scene(mission, distance)
		end
	},
	hazard = {
		initialize = function(self, mission, template, target_zone, target_location, center_transform, radius)
			local suitable_zones = template.suitable_zones

			if target_zone ~= nil then
				suitable_zones = { target_zone }
			end

			local zone = random_zone(suitable_zones, center_transform, radius)

			if zone ~= nil then
				mission.zone_index = zone.zone_index
				mission.scene = zone.name
				mission.transform = zone.transform
				disable_zone(mission.zone_index)
			else
				mission.zone_index = nil
				mission.scene = ""

				return mission,
					string.format("Initialisation failed because a suitable location for %s mission could not be found",
						mission.type)
			end

			mission.spawn_timer = math.random(4, 8) * 3600
			mission.clear_timer = template.clear_timer
			mission.submissions = template.submissions
			mission.submission_timer = math.random() * 1.5 * 3600
			mission.submission_count = math.random(3, 4)

			return mission
		end,
		dispose = function(self, mission)
			mission_tracker.sar:dispose(mission)
		end,
		tick = function(self, mission, tick)
			if mission.spawned then
				mission.clear_timer = mission.clear_timer - tick
			elseif mission.spawn_timer <= 0 and mission.type == "tornado" then
				mission.spawned = server.spawnTornado(mission.transform)
			else
				mission.spawn_timer = mission.spawn_timer - tick
			end

			if mission.submission_timer <= 0 and mission.submission_count > 0 then
				initialize_mission("evac", nil, nil, landscapes[mission.zone_index].transform, mission.radius)
				mission.submission_count = mission.submission_count - 1
				mission.submission_timer = math.random() * 3600
			elseif mission.submission_timer > 0 then
				mission.submission_timer = mission.submission_timer - tick
			end
		end,
		completed = function(self, mission)
			return mission.clear_timer <= 0
		end,
		close = function(self, mission)
		end,
		reward = function(self, mission)
			return 0
		end,
		report = function(self, mission)
			return string.format(mission.report, mission.mission_id, mission.scene)
		end,
		progress = function(self, mission)
			return { "Alert ongoing. Stand by for more emergency call." }
		end,
		in_scene = function(self, mission, distance)
			return mission_tracker.sar:in_scene(mission, distance)
		end
	}
}

function initialize_mission(mission_type, target_zone, target_location, cencter_transform, radius)
	local template = table.random(table.find_all(mission_template, function(x)
		return (mission_type == nil or mission_type == x.type) and (mission_type ~= nil or not x.is_submission) and
			(mission_type ~= nil or not x.ongoing)
	end))

	if template == nil then
		error(string.format("Mission type %s is not found", mission_type))
		return
	end

	local mission = {}
	mission.mission_id = g_savedata.mission_count + 1
	mission.tracker = template.tracker
	mission.type = template.type
	mission.is_submission = template.is_submission
	mission.report = template.report
	mission.caller = template.caller
	mission.arrived = false
	mission.spawned = false
	mission.closed = false
	mission.objectives = {}
	mission.marker_id = server.getMapID()
	mission.transform = nil
	mission.radius = template.radius
	mission.fuzziness = template.fuzziness
	mission.marker_x = 0
	mission.marker_y = 0

	local mission, e = mission_tracker[template.tracker]:initialize(mission, template, target_zone, target_location,
		cencter_transform, radius)

	if e ~= nil then
		error(e)
		return
	end

	notice(string.format("Mission #%d has initialized", mission.mission_id))
	server.notify(-1, mission_tracker[mission.tracker]:report(mission),
		string.format("Emergency call from %s", mission.caller), 0)
	lock_ongoing_mission(mission.type)

	for k, hq in pairs(g_savedata.headquarters) do
		alert(hq, mission)
	end

	table.insert(g_savedata.missions, mission)
	g_savedata.mission_count = g_savedata.mission_count + 1
end

function reward_mission(mission)
	local reward = mission_tracker[mission.tracker]:reward(mission)
	local money = server.getCurrency() + reward
	local rp = server.getResearchPoints()
	server.setCurrency(money, rp)
	server.notify(-1, string.format("Receive $%d reward", reward),
		string.format("Mission #%d has closed", mission.mission_id), 4)
end

function dispose_mission(mission)
	for i = #g_savedata.objects, 1, -1 do
		if g_savedata.objects[i].mission_id == mission.mission_id then
			if g_savedata.objects[i].type == "vehicle" then
				server.despawnVehicle(g_savedata.objects[i].object_id, true)
			else
				server.despawnObject(g_savedata.objects[i].object_id, true)
			end

			notice(string.format("Object %s #%d has disposed", g_savedata.objects[i].type,
				g_savedata.objects[i].object_id))
			table.remove(g_savedata.objects, i)
		end
	end

	mission_tracker[mission.tracker]:dispose(mission)
	server.removeMapID(-1, mission.marker_id)

	local index = table.find_index(g_savedata.missions, function(x)
		return x.mission_id == mission.mission_id
	end)
	unlock_ongoing_mission(mission.type)
	table.remove(g_savedata.missions, index)
	notice(string.format("Mission #%d has disposed", mission.mission_id))
end

on_spawn_mission_id = nil

function spawn_mission_location(mission)
	if on_spawn_mission_id ~= nil then
		return false
	end

	on_spawn_mission_id = mission.mission_id

	local transform = matrix.translation(0, 0, 0)

	if mission.zone_index ~= nil then
		transform = landscapes[mission.zone_index].transform
	end

	local out_transform, is_success = server.spawnAddonLocation(transform, locations[mission.location_id].addon_index,
		locations[mission.location_id].location_index)

	on_spawn_mission_id = nil

	return is_success, out_transform
end

function arrived_to_missiion_scene(mission, player)
	if player.name == "Server" or mission.transform == nil then
		return
	end

	local player_transform = server.getPlayerPos(player.peer_id)
	local distance = matrix.distance(mission.transform, player_transform)

	if not mission.arrived and mission_tracker[mission.tracker]:in_scene(mission, distance) then
		mission.arrived = true
		server.notify(-1, string.format("#%d - We have got a full report", mission.mission_id),
			"Team has arrived to scene", 0)
	end
end

function lock_ongoing_mission(type)
	for i = 1, #mission_template, 1 do
		if mission_template[i].type == type then
			mission_template[i].ongoing = true
		end
	end
end

function unlock_ongoing_mission(type)
	for i = 1, #mission_template, 1 do
		if mission_template[i].type == type then
			mission_template[i].ongoing = false
		end
	end
end

-- objectives

objective_tracker = {
	rescuee = {
		initialize = function(self, objective, option)
			objective.cpa_count = 0
			objective.cpa_timer = nil
			objective.cpa_limit = math.random(1, 6)
			objective.vital = server.getObjectData(objective.object_id)
			objective.is_in_hospital = false

			local hp = tonumber(option)

			if hp == nil then
				local hp_min = -14.285714
				local hp_max = 100
				hp = math.max(0, (hp_max - hp_min) * math.random() + hp_min)
			end

			server.setCharacterData(objective.object_id, hp, true, false)
		end,
		dispose = function(self, objective)
			local data = server.getObjectData(objective.object_id)
			server.setCharacterData(objective.object_id, data.hp, false, false)
		end,
		tick = function(self, objective, tick)
			local transform = server.getObjectPos(objective.object_id)
			objective.is_in_hospital = server.isInZone(transform, "clinic") or server.isInZone(transform, "hospital")

			local vital_update = server.getObjectData(objective.object_id)

			if objective.vital.hp > 0 and vital_update.hp <= 0 then
				objective.cpa_count = objective.cpa_count + 1

				local cpa_relapse = math.random()

				if cpa_relapse <= math.min((objective.cpa_count / objective.cpa_limit), 1) then
					objective.cpa_timer = math.random(1, 10) * 3600
				end

				server.setCharacterTooltip(objective.object_id,
					string.format("rescuee\nCPA Count: %d", objective.cpa_count))
			end

			local transform = server.getObjectPos(objective.object_id)

			if objective.cpa_timer ~= nil and not objective.is_in_hospital then
				objective.cpa_timer = objective.cpa_timer - tick

				if objective.cpa_timer <= 0 then
					server.setCharacterData(objective.object_id, 0, true, false)
				end
			end

			objective.vital = vital_update
		end,
		completed = function(self, objective)
			return objective.is_in_hospital
		end,
		reward = function(self, objective)
			local value = math.ceil(250 * (math.floor(objective.vital.hp / 25) / 4))

			if objective.vital.is_dead then
				value = 0
			end

			return value
		end,
		progress = "%d/%d Rescuee - Care and take to clinic or hospital"
	},
	evacuee = {
		initialize = function(self, objective)
			objective.is_in_safe_zone = false
		end,
		dispose = function(self, objective)
			local data = server.getObjectData(objective.object_id)
			server.setCharacterData(objective.object_id, data.hp, false, false)
		end,
		tick = function(self, objective, tick)
			local transform = server.getObjectPos(objective.object_id)
			objective.is_in_safe_zone = server.isInZone(transform, "clinic") or server.isInZone(transform, "hospital") or
				server.isInZone(transform, "police station") or
				server.isInZone(transform, "safe zone")
		end,
		completed = function(self, objective)
			return objective.is_in_safe_zone
		end,
		reward = function(self, objective)
			return 200
		end,
		progress = "%d/%d Evacuee - Take to clinic, hospital, police station or safe zone"
	},
	vehicle = {
		initialize = function(self, objective)
			objective.fire_count = 0
		end,
		dispose = function(self, objective)
		end,
		tick = function(self, objective, tick)
			local fire_count, is_success = server.getVehicleFireCount(objective.object_id)
			objective.fire_count = fire_count
		end,
		completed = function(self, objective)
			return objective.fire_count <= 0
		end,
		reward = function(self)
			return 1000
		end,
		progress = "%d/%d Vehicle on Fire - Extinguish the spread of fire"
	},
	fire = {
		initialize = function(self, objective)
			objective.is_lit = server.getFireData(objective.object_id)
		end,
		dispose = function(self, objective)
		end,
		tick = function(self, objective, tick)
			local is_lit, is_success = server.getFireData(objective.object_id)
			objective.is_lit = is_lit

			local nearby = nil
			local distance = g_savedata.mission_range_max * 2

			if objective.mission_id == nil and is_lit then
				local objective_transform = server.getObjectPos(objective.object_id)

				for i = 1, #g_savedata.missions, 1 do
					if g_savedata.missions[i].tracker == "fire" then
						local d = matrix.distance(g_savedata.missions[i].transform, objective_transform)

						if d < distance then
							nearby = g_savedata.missions[i]
							distance = d
						end
					end
				end

				if nearby ~= nil then
					objective.mission_id = nearby.mission_id
				else
					server.setFireData(objective.object_id, false, false)
				end
			end
		end,
		completed = function(self, objective)
			local is_lit, is_success = server.getFireData(objective.object_id)
			return not is_lit
		end,
		reward = function(self)
			return 1000
		end,
		progress = "%d/%d Fire Source - Search source of fire and extinguish"
	},
	flotsam = {
		initialize = function(self, objective)
		end,
		dispose = function(self, objective)
		end,
		tick = function(self, objective, tick)

		end,
		completed = function(self, objective)
			local transform = nil

			if objective.type == "vehicle" then
				transform = server.getVehiclePos(objective.object_id)
			else
				transform = server.getObjectPos(objective.object_id)
			end

			local in_zone = server.isInZone(transform, "freight terminal")

			return in_zone
		end,
		reward = function(self, objective)
			return 2500
		end,
		progress = "%d/%d Flotsam - Salvage and transport to freight terminal"
	}
}

function initialize_objective(mission_id, object_id, name, type, tracker, static, option)
	local objective = {}
	objective.object_id = object_id
	objective.mission_id = mission_id
	objective.name = name
	objective.tracker = tracker
	objective.type = type
	objective.static = static
	objective_tracker[objective.tracker]:initialize(objective, option)
	table.insert(g_savedata.objectives, objective)
	notice(string.format("Objective %s #%d has initialized", objective.tracker, objective.object_id))
end

function dispose_objective(index, objective)
	objective.mission_id = nil

	objective_tracker[objective.tracker]:dispose(objective)
	if not objective.static then
		if objective.type == "character" then
			server.despawnObject(objective.object_id, false)
		elseif objective.type == "vehicle" then
			server.despawnVehicle(objective.object_id, true)
		else
			server.despawnObject(objective.object_id, true)
		end

		table.remove(g_savedata.objectives, index)
	end

	notice(string.format("Objective %s #%d has disposed", objective.type, objective.object_id))
end

-- headquarters

function initialize_headquarter(object_id)
	local hq = {
		object_id = object_id
	}
	table.insert(g_savedata.headquarters, hq)
end

function alert(hq, mission)
	server.pressVehicleButton(hq.object_id, "Alert")
end

-- static fire

function random_static_fire(zone)
	local fires = table.find_all(g_savedata.objectives, function(x)
		local transform = server.getObjectPos(x.object_id)

		return x.name == "static fire" and x.mission_id == nil and
			server.isInTransformArea(transform, zone.transform, zone.size.x, zone.size.y, zone.size.z) and
			distance_to_base(server.getObjectPos(x.object_id)) <= g_savedata.mission_range_max
	end)

	if #fires == 0 then
		return nil
	end

	local f = table.random(fires)
	local explosion = math.random() > 0.666667

	server.setFireData(f.object_id, true, explosion)

	return f
end

-- markers

function refresh_mission_marker(peer, mission)
	if mission.transform == nil then
		return
	end

	local x, y, z = matrix.position(mission.transform)
	x = math.round(x / mission.fuzziness) * mission.fuzziness
	z = math.round(z / mission.fuzziness) * mission.fuzziness

	local text = ""
	text = text .. string.format("Progress", mission.arrived)
	-- text = string.format("Arrived to scene: %s", mission.arrived)

	if true then
		local progresses = mission_tracker[mission.tracker]:progress(mission)

		for k, progress in pairs(progresses) do
			text = text .. "\n\n" .. progress
		end
	end

	server.removeMapObject(peer, mission.marker_id)
	server.addMapObject(peer, mission.marker_id, 0, 1, x, z, 0, 0, nil, nil,
		mission_tracker[mission.tracker]:report(mission), math.sqrt((mission.radius / 2) ^ 2 + (mission.radius / 2) ^ 2),
		text, 255, 63, 191, 255)
end

-- zones

function load_zones()
	for k, zone in pairs(server.getZones()) do
		local scene_index = table.find_index(scenes, function(x)
			return x.name == zone.name
		end)

		if scene_index ~= nil and matrix.distance(zone.transform, start_tile_matrix()) <= g_savedata.mission_range_max then
			zone.zone_index = #landscapes + 1
			zone.marker_id = server.getMapID()
			zone.available = true

			table.insert(landscapes, zone.zone_index, zone)

			scenes[scene_index].count = scenes[scene_index].count + 1
		end
	end
end

function initialize_offshore_zone()
	local start_tile = server.getStartTile()
	local transform, is_success = server.getOceanTransform(matrix.translation(start_tile.x, start_tile.y, start_tile.z),
		4000, 12000)
	local x, y, z = matrix.position(transform)
	x = x + math.random() * 2000 - 1
	z = z + math.random() * 2000 - 1
	transform = matrix.translation(x, y, z)
	local zone_index = #landscapes + 1
	local zone = {
		zone_index = zone_index,
		tags_full = "",
		tags = {},
		name = "offshore",
		transform = transform,
		size = {
			x = 20,
			y = 20,
			z = 20
		},
		radius = 10,
		type = 0,
		parent_vehicle_id = nil,
		parent_relative_transform = nil
	}

	table.insert(landscapes, zone_index, zone)

	return zone
end

function random_zone(pattern, center_transform, range)
	for i = #pattern, 1, -1 do
		local scene = table.find(scenes, function(x)
			return x.name == pattern[i]
		end)

		if pattern ~= "offshore" and scene.count == 0 then
			table.remove(pattern, i)
		end
	end

	if #pattern == 0 then
		return nil, nil
	end

	if range == nil then
		range = g_savedata.mission_range_max
	end

	local suitable_zone = table.random(pattern)

	if suitable_zone == "offshore" then
		return initialize_offshore_zone(), nil
	end

	local zones = table.find_all(landscapes, function(x)
		return x.available and x.name == suitable_zone and
			(center_transform == nil or matrix.distance(x.transform, center_transform) <= range)
	end)

	if #zones == 0 then
		return nil
	end

	return table.random(zones)
end

function enable_zone(zone_index)
	if landscapes[zone_index] == nil then
		return
	end

	landscapes[zone_index].available = true
end

function disable_zone(zone_index)
	if landscapes[zone_index] == nil then
		return
	end

	landscapes[zone_index].available = false
end

-- locations

function load_locations()
	local addon_count = server.getAddonCount()
	local addon_index = 1
	while addon_index <= addon_count do
		local location_count = (server.getAddonData(addon_index) or {
			location_count = 0
		}).location_count
		local location_index = 1

		while location_index <= location_count do
			local location = server.getLocationData(addon_index, location_index)
			if location ~= nil then
				local st, en, type, report = string.find(location.name, "^(%w+):(.+)$")

				if not location.env_mod and st ~= nil then
					location.addon_index = addon_index
					location.location_index = location_index
					location.type = type
					location.report = report
					table.insert(locations, location)
				end
			end

			location_index = location_index + 1
		end

		addon_index = addon_index + 1
	end
end

function random_location(mission)
	local keys = {}

	for i = 1, #locations, 1 do
		if locations[i].type == mission.type then
			table.insert(keys, i)
		end
	end

	if #locations == 0 then
		return nil
	end

	return table.random(keys)
end

-- main logic

timing_default = 60
timing = timing_default

function onTick(clock)
	math.randomseed(server.getTimeMillisec())

	if g_savedata.mission_interval <= 0 and #g_savedata.missions < g_savedata.mission_count_max then
		initialize_mission(nil, nil, nil)
		g_savedata.mission_interval = math.random(g_savedata.mission_interval_min, g_savedata.mission_interval_max)
	else
		g_savedata.mission_interval = g_savedata.mission_interval - clock
	end

	for i = #g_savedata.objectives, 1, -1 do
		if i % timing_default == timing then
			objective_tracker[g_savedata.objectives[i].tracker]:tick(g_savedata.objectives[i], clock * timing_default)
		end
	end

	for i = #g_savedata.missions, 1, -1 do
		if i % timing_default == timing then
			mission_tracker[g_savedata.missions[i].tracker]:tick(g_savedata.missions[i], clock * timing_default)

			-- for k, player in pairs(server.getPlayers()) do
			-- 	arrived_to_missiion_scene(g_savedata.missions[i], player)
			-- end

			refresh_mission_marker(-1, g_savedata.missions[i])

			if mission_tracker[g_savedata.missions[i].tracker]:completed(g_savedata.missions[i]) then
				reward_mission(g_savedata.missions[i])
				dispose_mission(g_savedata.missions[i])
			end
		end
	end

	timing = timing - 1

	if timing <= 0 then
		timing = timing_default
	end
end

function onCreate(is_world_create)
	if is_world_create then
		local settings = server.getGameSettings()
	end

	load_zones()
	load_locations()

	notice(#landscapes .. " zones loaded")

	for k, v in pairs(scenes) do
		notice(string.format("    %d %s", v.count, v.name))
	end

	notice(#locations .. " locations loaded")
	notice(string.format("%d missions is available", #g_savedata.missions))
	notice(string.format("%d objectives is available", #g_savedata.objectives))
	notice(string.format("%d objectis is available", #g_savedata.objects))
end

function onPlayerJoin(steam_id, name, peer_id, is_admin, is_auth)
	if name == "Server" then
		return
	end

	for i = 1, #landscapes, 1 do
		if landscapes[i].name == "clinic" then
			local x, y, z = matrix.position(landscapes[i].transform)
			server.addMapLabel(peer_id, landscapes[i].marker_id, 8, "Clinic", x, z)
		elseif landscapes[i].name == "hospital" then
			local x, y, z = matrix.position(landscapes[i].transform)
			server.addMapLabel(peer_id, landscapes[i].marker_id, 8, "Hospital", x, z)
		elseif landscapes[i].name == "freight terminal" then
			local x, y, z = matrix.position(landscapes[i].transform)
			server.addMapLabel(peer_id, landscapes[i].marker_id, 3, "Freight Terminal", x, z)
		elseif landscapes[i].name == "safe zone" then
			local x, y, z = matrix.position(landscapes[i].transform)
			server.addMapLabel(peer_id, landscapes[i].marker_id, 11, "Safe Zone", x, z)
		end
	end
end

function onCustomCommand(full_message, user_peer_id, is_admin, is_auth, command, verb, ...)
	if command ~= "?mission" then
		return
	end

	if verb == "init" and is_admin then
		local mission_type, zone, location = ...
		initialize_mission(mission_type, zone, location)
	elseif verb == "dispose-all" and is_admin then
		for i = #g_savedata.missions, 1, -1 do
			dispose_mission(g_savedata.missions[i])
		end
	elseif verb == "dispose" and is_admin then
		local mission_id = ...
		mission_id = tonumber(mission_id)
		local mission = table.find(g_savedata.missions, function(x)
			return x.mission_id == mission_id
		end)

		if mission == nil then
			error(string.format("Mission #%d is not found", mission_id))
			return
		end

		dispose_mission(mission)
	elseif verb == "close" and is_admin then
		local mission_id = ...
		mission_id = tonumber(mission_id)
		local mission = table.find(g_savedata.missions, function(x)
			return x.mission_id == mission_id
		end)

		if mission == nil then
			error(string.format("Mission #%d is not found", mission_id))
			return
		end

		mission_tracker[mission.tracker]:close(mission)
	end
end

function onSpawnAddonComponent(object_id, component_name, type, addon_index)
	if on_spawn_mission_id ~= nil then
		local roles = table.keys(objective_tracker)
		local tracker = type

		local st, en, component_name, option = string.find(component_name, "^(%w+)[:]?(.*)$")

		if component_name ~= "" then
			tracker = component_name
		end

		if table.contains(roles, tracker) then
			initialize_objective(on_spawn_mission_id, object_id, component_name, type, tracker, false, option)
		else
			table.insert(g_savedata.objects, {
				object_id = object_id,
				mission_id = on_spawn_mission_id,
				type = type
			})
			notice(string.format("Object #%d has initialized", object_id))
		end
	elseif type == "fire" and component_name == "static fire" then
		initialize_objective(nil, object_id, component_name, type, "fire", true)
	elseif type == "vehicle" and component_name == "headquarter" then
		initialize_headquarter(object_id)
	end
end

function onGroupSpawn()
end

-- util

function notice(text, peer_id)
	peer_id = peer_id or -1

	if env == "debug" then
		server.announce("[Mission Foundation]", text, peer_id)
	end
end

function error(text, peer_id)
	peer_id = peer_id or -1

	server.announce("[Mission Foundation]", text, peer_id)
end

math.round = function(x)
	return math.floor(x + 0.5)
end

table.contains = function(t, x)
	local contains = false

	for k, v in pairs(t) do
		contains = contains or v == x
	end

	return contains
end

table.random = function(t)
	if #t == 0 then
		return nil
	end

	return t[math.random(1, #t)]
end

table.find_index = function(t, test)
	for k, v in pairs(t) do
		if test(v) then
			return k
		end
	end

	return nil
end

table.find = function(t, test)
	for k, v in pairs(t) do
		if test(v) then
			return v, k
		end
	end

	return nil, nil
end

table.find_all = function(t, test)
	local items = {}

	for k, v in pairs(t) do
		if test(v) then
			table.insert(items, v)
		end
	end

	return items
end

table.keys = function(t)
	local items = {}

	for k, v in pairs(t) do
		table.insert(items, k)
	end

	return items
end

string.split = function(text, sepatator)
	local result = {}

	for sub in string.gmatch(text, "([^" .. sepatator .. "])") do
		table.insert(result, sub)
	end
end

function distance_to_base(target)
	local start_tile = start_tile_matrix()
	return matrix.distance(target, start_tile)
end

function start_tile_matrix()
	local t = server.getStartTile()
	return matrix.translation(t.x, t.y, t.z)
end
