g_savedata = {
	vehicles = {}
}

function initialize_storage(object_id, component_name, type, addon_index, name, resource_material, resource_type)
	table.insert(g_savedata.vehicles, {
		object_id = object_id,
		component_name = component_name,
		type = type,
		addon_index = addon_index,
		transform = server.getVehiclePos(object_id),
		marker_id = server.getMapID(),
		name = name,
		resource_material = resource_material,
		resource_type = resource_type,
		purchase = 0
	})
end

function initialize_display(object_id, component_name, type, addon_index)
	table.insert(g_savedata.vehicles, {
		object_id = object_id,
		component_name = component_name,
		type = type,
		addon_index = addon_index,
		transform = server.getVehiclePos(object_id),
		marker_id = server.getMapID()
	})
end

function fluid_storage(vehicle)
	local coal, uranium, diesel, jet, solid = server.getTileInventory(vehicle.transform)

	local input = 0
	local output = 0

	local input_button, input_button_available = server.getVehicleButton(vehicle.object_id, "To Storage")
	local input_tank, input_tank_available = server.getVehicleTank(vehicle.object_id, "Input")

	if input_button_available and input_tank_available and input_button.on then
		input = input_tank.values[vehicle.resource_type]
	end

	local output_button, output_button_available = server.getVehicleButton(vehicle.object_id, "To Vehicle")
	local output_tank, output_tank_available = server.getVehicleTank(vehicle.object_id, "Output")

	if output_button_available and output_tank_available and output_button.on then
		output = output_tank.capacity - output_tank.values[vehicle.resource_type]
	end

	local storage_level = 0
	local delta = input - output

	if vehicle.resource_type == 1 then
		diesel = math.max(diesel + delta, 0)
		storage_level = diesel
	elseif vehicle.resource_type == 2 then
		jet = math.max(jet + delta, 0)
		storage_level = jet
	end

	if input > 0 or output > 0 then
		server.setVehicleTank(vehicle.object_id, "Input", 0, vehicle.resource_type)
		server.setVehicleTank(vehicle.object_id, "Output", math.min(storage_level, output_tank.capacity),
						vehicle.resource_type)
		server.setTileInventory(vehicle.transform, coal, uranium, diesel, jet, solid)
	end

	server.setVehicleKeypad(vehicle.object_id, "Value", storage_level)
end

function storage_display(vehicle)
	local budget = server.getCurrency()
	local coal, uranium, diesel, jet, solid = server.getTileInventory(vehicle.transform)

	server.setVehicleKeypad(vehicle.object_id, "Budget", budget)
	server.setVehicleKeypad(vehicle.object_id, "Coal", coal)
	server.setVehicleKeypad(vehicle.object_id, "Uranium", uranium)
	server.setVehicleKeypad(vehicle.object_id, "Diesel", diesel)
	server.setVehicleKeypad(vehicle.object_id, "Jet", jet)
	server.setVehicleKeypad(vehicle.object_id, "Solid", solid)
end

timing_default = 60
timing = timing_default

function onTick(tick)
	for i = 1, #g_savedata.vehicles, 1 do
		if timing % timing_default == 0 and server.getVehicleSimulating(g_savedata.vehicles[i].object_id) then
			if g_savedata.vehicles[i].component_name == "storage display" then
				storage_display(g_savedata.vehicles[i])
			elseif g_savedata.vehicles[i].resource_material == "fluid" then
				fluid_storage(g_savedata.vehicles[i])
			elseif g_savedata.vehicles[i].resource_material == "ore" then
			end
		end
	end

	timing = timing - 1

	if timing <= 0 then
		timing = timing_default
	end
end

function onSpawnAddonComponent(object_id, component_name, type, addon_index)
	if component_name == "storage display" then
		initialize_display(object_id, component_name, type, addon_index)
	elseif component_name == "diesel storage" then
		initialize_storage(object_id, component_name, type, addon_index, "Diesel Storage", "fluid", 1)
	elseif component_name == "jet storage" then
		initialize_storage(object_id, component_name, type, addon_index, "Jet Storage", "fluid", 2)
	end
end

function onCustomCommand(full_message, user_peer_id, is_admin, is_auth, command, verb, ...)
	if command ~= "?storage" then
		return
	end
end

function onPlayerJoin(steam_id, name, peer_id, is_admin, is_auth)
	if name == "Server" then
		return
	end

	for i = 1, #g_savedata.vehicles, 1 do
		local vehicle = g_savedata.vehicles[i]
		if vehicle.name ~= nil then
			local x, y, z = matrix.position(vehicle.transform)
			server.addMapLabel(peer_id, vehicle.marker_id, 13, string.format(vehicle.name, vehicle.price_unit), x, z)
		end
	end
end

