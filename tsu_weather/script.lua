g_savedata = {
    mode = "debug",
    active = true,
    tick = 0,
    wind = {
        value = 0,
        neutral = 0,
        band = 0,
        min = -25,
        max = 50,
    },
    rain = {
        value = 0,
        neutral = 0,
        band = 0,
        min = -250,
        max = 125
    },
    fog = {
        value = 0,
        neutral = 0,
        band = 0,
        min = 0,
        max = 50
    },
    weather = {
        value = 0,
        neutral = 0,
        band = 0,
        min = 10800,
        max = 28800
    }
}

function onTick(tick)
    math.randomseed(server.getTimeMillisec())

    if not g_savedata.active then
        return
    end

    if g_savedata.weather.value > 0 then
        g_savedata.weather.value = math.max(g_savedata.weather.value - tick, 0)
    else
        update(g_savedata.weather)
        update(g_savedata.wind)
        update(g_savedata.rain)
        update(g_savedata.fog)
        local fog = math.min(g_savedata.fog.value + g_savedata.rain.value * math.random() * 0.25 - g_savedata.wind.value * math.random() * 0.25, g_savedata.fog.max)
        weather(g_savedata.wind.value, g_savedata.rain.value, fog)
    end
end

function update(meteorology)
    meteorology.value = math.max(0, math.random(0, meteorology.max - meteorology.min) + meteorology.min)
end

function weather(wind, rain, fog)
    server.setWeather(math.max(0, fog) / 100, math.max(0, rain) / 100, math.max(0, wind) / 100)
    console.notify(string.format("wind: %.00f\nrain: %.00f\nfog: %.00f", wind, rain, fog))
end

function onCustomCommand(full_message, user_peer_id, is_admin, is_auth, command, verb, ...)
    if command ~= "?weather" then
        return
    end

    if verb == "start" and is_admin then
        g_savedata.active = true
    elseif verb == "stop" and is_admin then
        g_savedata.active = false
    elseif verb == "next" and is_admin then
        g_savedata.weather.value = 0
    elseif verb == "prod" and is_admin then
        g_savedata.mode = "prod"
    elseif verb == "debug" and is_admin then
        g_savedata.mode = "debug"
    end
end

-- utils

function parse_tags(tags_full)
    local t = {}

    for k, v in string.gmatch(tags_full, "([%w_]+)=([%w_-]+)") do
        t[k] = v
    end

    return t
end

console = {}

function console.log(text, peer_id)
    if peer_id == nil then
        peer_id = -1
    end

    server.announce("[Weather]", text, peer_id)
end

function console.notify(text, peer_id)
    peer_id = peer_id or -1

    if g_savedata.mode == "debug" then
        server.announce("[Weather]", text, peer_id)
    end
end

function console.error(text, peer_id)
    peer_id = peer_id or -1

    server.announce("[Weather]", text, peer_id)
end

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

function table.shuffle(x)
    for i = #x, 2, -1 do
        local j = math.random(i)
        x[i], x[j] = x[j], x[i]
    end
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

function setmetatable(table1, table2)
    for k, v in pairs(table2) do
        table1[k] = v
    end
end
