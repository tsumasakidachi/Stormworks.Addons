g_savedata = {
	vehicles = {}
}

function initialize_store(object_id, component_name, type, addon_index, name, resource_material, resource_type,
				price_unit)
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
		price_unit = price_unit,
		purchase = 0
	})
end

function fluid_store(vehicle)
	local button, is_success = server.getVehicleButton(vehicle.object_id, "To Vehicle")

	if not is_success then
		return
	end

	local tank, is_success = server.getVehicleTank(vehicle.object_id, "Output")

	if not is_success then
		return
	end

	if button.on then
		vehicle.purchase = vehicle.purchase + (tank.capacity - tank.value)
	end

	local value = vehicle.purchase * vehicle.price_unit

	if vehicle.purchase > 0 then
		server.setVehicleKeypad(vehicle.object_id, "Value", math.ceil(value))
	end

	if (not button.on) and vehicle.purchase > 0 then
		local money = server.getCurrency()
		money = math.ceil(money - value)
		server.setCurrency(money)
		server.setVehicleKeypad(vehicle.object_id, "Value", 0)
		vehicle.purchase = 0
		server.notify(-1, string.format("Pay out $%d in resource cost", math.ceil(value)), "", 8)
	end

	if tank.value < tank.capacity then
		server.setVehicleTank(vehicle.object_id, "Output", tank.capacity, vehicle.resource_type)
	end
end

function onSpawnAddonComponent(object_id, component_name, type, addon_index)
	if component_name == "water store" then
		initialize_store(object_id, component_name, type, addon_index, "Water $%.1f", "fluid", 0, 0)
	elseif component_name == "diesel store" then
		initialize_store(object_id, component_name, type, addon_index, "Diesel $%.1f", "fluid", 1, 2)
	elseif component_name == "diesel store low price" then
		initialize_store(object_id, component_name, type, addon_index, "Diesel $%.1f", "fluid", 1, 0.4)
	elseif component_name == "jet store" then
		initialize_store(object_id, component_name, type, addon_index, "Jet $%.1f", "fluid", 2, 4)
	elseif component_name == "jet store low price" then
		initialize_store(object_id, component_name, type, addon_index, "Jet $%.1f", "fluid", 2, 0.8)
	end
end

timing_default = 60
timing = timing_default

function onCustomCommand(full_message, user_peer_id, is_admin, is_auth, command, verb, ...)
	if command ~= "?trade" then
		return
	end
end

function onTick(tick)
	for i = 1, #g_savedata.vehicles, 1 do
		if timing % timing_default == 0 and server.getVehicleSimulating(g_savedata.vehicles[i].object_id) then
			if g_savedata.vehicles[i].resource_material == "fluid" then
				fluid_store(g_savedata.vehicles[i], 1, 2)
			elseif g_savedata.vehicles[i].resource_material == "ore" then
				ore_store(g_savedata.vehicles[i])
			end
		end
	end

	timing = timing - 1

	if timing <= 0 then
		timing = timing_default
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

