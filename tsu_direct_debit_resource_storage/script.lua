g_savedata = {
    bases = {},
    payment_max = 20000
}

fuels = {
    coal = {
        name = "Coal",
        unit = "",
        value = 1
    },
    uranium = {
        name = "Uranium",
        unit = "",
        value = 100
    },
    diesel = {
        name = "Diesel",
        unit = "l",
        value = 2
    },
    jet = {
        name = "Jet",
        unit = "l",
        value = 4
    },
    solid = {
        name = "Solid Propellant",
        unit = "",
        value = 80
    }
}

-- storage

function update_storage_level(base)
    local latest_data = get_storage_level(base.transform)
    local payments = 0

    for k, v in pairs(fuels) do
        local differ = latest_data[k] - base.storage[k]
        local payments = math.floor(payments + differ * v.value)

        transact(payments, string.format("%s %.0f%s", v.name, differ, v.unit))
    end

    reset_storage_level(base)
end

function reset_storage_level(base)
    for k, v in pairs(fuels) do
        base.storage[k] = default_storage_level(k)
    end

    set_storage_level(base.transform, base.storage)
end

function get_storage_level(transform)
    local coal, uranium, diesel, jet, solid = server.getTileInventory(transform)
    local data = {
        coal = coal,
        uranium = uranium,
        diesel = diesel,
        jet = jet,
        solid = solid
    }

    return data
end

function set_storage_level(transform, data)
    server.setTileInventory(transform, data.coal, data.uranium, data.diesel, data.jet, data.solid)
end

function default_storage_level(id)
    return math.ceil(g_savedata.payment_max / fuels[id].value)
end

function display_storage_level(transform, peer_id)
    local data = get_storage_level(transform)
    local peer_id = peer_id or -1

    server.announce("[Storage Foundation]", string.format(
        "Coal: %.0f\nUranium: %.0f\nDiesel: %.0f\nJet: %.0f\nSolid: %.0f", data.coal, data.uranium, data.diesel, data.jet, data.solid), peer_id)
end

-- bases

function load_bases()
    local addon_index = server.getAddonIndex()
    local addon_data = server.getAddonData(addon_index)
    local location_index = 0

    g_savedata.bases = {}

    while location_index < addon_data.location_count do
        local location_data = server.getLocationData(addon_index, location_index)
        location_data.transform = (server.getTileTransform(matrix.translation(0, 0, 0), location_data.tile, 1000000))
        location_data.storage = get_storage_level(location_data.transform)

        table.insert(g_savedata.bases, location_data)
        location_index = location_index + 1
    end
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

-- main logic

timing_default = 60
timing = timing_default

function onTick(tick)
    math.randomseed(server.getTimeMillisec())

    timing = timing - 1

    for i = 1, #g_savedata.bases do
        if i % timing_default == timing then
            update_storage_level(g_savedata.bases[i])
        end
    end

    if timing <= 0 then
        timing = timing_default
    end
end

function onCustomCommand(full_message, peer_id, is_admin, is_auth, command, verb, ...)
    if command ~= "?storage" then
        return
    end

    if verb == "display" and is_admin then
        local transform = server.getPlayerPos(peer_id)
        display_storage_level(transform, peer_id)
    elseif verb == "display-all" then
        for i = 1, #g_savedata.bases do
            server.announce("[Storage Foundation]", g_savedata.bases[i].tile, peer_id)
            display_storage_level(g_savedata.bases[i].transform, peer_id)
        end
    end
end

function onCreate(is_world_create)
    load_bases()

    if is_world_create then
        for i = 1, #g_savedata.bases do
            reset_storage_level(g_savedata.bases[i])
        end
    end
end

