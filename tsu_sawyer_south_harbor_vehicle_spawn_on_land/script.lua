g_savedata = {
	selector = nil,
	vehicle_spawn_zone_land = nil,
	vehicle_spawn_zone_sea = nil
}

function onCreate(is_world_create)
	for k, v in pairs(server.getZones()) do
		if v.name == "vehicle_spawn_zone_land" then
			g_savedata.vehicle_spawn_zone_land = v
		elseif v.name == "vehicle_spawn_zone_sea" then
			g_savedata.vehicle_spawn_zone_sea = v
		end
	end
end

function onSpawnAddonComponent(object_id, component_name, type, addon_index)
	if addon_index == server.getAddonIndex() and component_name == "sawyer_south_harbor_vehicle_on_land_selector" then
		g_savedata.selector = {
			id = object_id,
			name = component_name
		}
	end
end

-- function onVehicleLoad(vehicle_id)
-- 	local transform = server.getVehiclePos(vehicle_id)

-- 	if g_savedata.selector ~= nil and g_savedata.vehicle_spawn_zone_land ~= nil and g_savedata.vehicle_spawn_zone_sea ~= nil and server.isInZone(transform, g_savedata.vehicle_spawn_zone_sea.name) then
-- 		local data, is_success = server.getVehicleButton(g_savedata.selector.id, "Spawn on land")

-- 		if data.on then
-- 			server.setVehiclePos(vehicle_id, g_savedata.vehicle_spawn_zone_land.transform)
-- 		end
-- 	end
-- end

function onGroupSpawn(group_id, peer_id, x, y, z, cost)
	local vehicles = server.getVehicleGroup(group_id)

	if vehicles[1] ~= nil then
		local transform = server.getVehiclePos(vehicles[1])

		if g_savedata.selector ~= nil and g_savedata.vehicle_spawn_zone_land ~= nil and g_savedata.vehicle_spawn_zone_sea ~=
						nil and server.isInZone(transform, g_savedata.vehicle_spawn_zone_sea.name) then
			local data, is_success = server.getVehicleButton(g_savedata.selector.id, "Spawn on land")

			if data.on then
				server.setGroupPos(group_id, g_savedata.vehicle_spawn_zone_land.transform)
			end
		end
	end
end
