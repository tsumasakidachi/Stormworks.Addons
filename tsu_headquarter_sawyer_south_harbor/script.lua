function onSpawnAddonComponent(vehicle_id, component_name, type, addon_index)
    if addon_index ~= (server.getAddonIndex()) then
        return
    end

    if type == "vehicle" and component_name == "headquarter" then
        local data = server.getVehicleData(vehicle_id)

        server.announce("[]", "group id: " .. data.group_id .. "\nvehicle_id: " .. vehicle_id)

        server.command(string.format("?mission register-hq %d", data.group_id))
    end
end

