g_savedata = {
    mode = "prod",
    active = true,
    tick = 0,
    weather = {
        wind = {
            transition = 0,
            duration = 0,
            tick = 0,
            target = 0,
            past = 0,
            target_min = 0,
            target_max = 20,
            clear = 0,
        },
        rain = {
            target = 0,
            past = 0,
            tick = 0,
            transition = 0,
            duration = 0,
            target_min = 0,
            target_max = 80,
            clear = 50,
        },
        fog = {
            target = 0,
            past = 0,
            tick = 0,
            transition = 0,
            duration = 0,
            target_min = 0,
            target_max = 40,
            clear = 0,
        }
    }
}

local cycle = 60
local timing = 0

function onTick(tick)
    math.randomseed(server.getTimeMillisec())

    if timing % 60 == 0 then
        for k, v in pairs(g_savedata.weather) do
            tick_weather(v, tick * cycle, k)
        end

        weather(g_savedata.weather)
    end

    if timing + 1 < cycle then
        timing = timing + 1
    else
        timing = 0
    end
end

function tick_weather(w, tick, type)
    if w.tick < w.duration then
        w.tick = w.tick + tick
    else
        local shift = math.round(w.target_max * (w.clear * 0.01))
        local max = w.target_max - shift
        local min = w.target_min - shift
        local factor = w.target_max / max
        w.tick = 0
        w.past = w.target
        w.target = math.max(0, (math.random(0, max - min) + min) * factor)
        w.duration = math.random(14400, 57600)
        w.transition = math.ceil(w.duration * math.random(10, 25) * 0.01)
    end
end

function value_weather(w)
    local x1 = 0
    local y1 = w.past
    local x2 = w.transition
    local y2 = w.target

    return ((y2 - y1) / (x2 - x1)) * math.min(w.tick, w.transition) + ((x2 * y1 - x1 * y2) / (x2 - x1))
end

function weather(w)
    local rain = value_weather(w.rain) * 0.01
    local wind = value_weather(w.wind) * 0.01
    local fog = value_weather(w.fog) * 0.01 + rain * 0.5 - wind * 0.25

    server.setWeather(fog, rain, wind)
    console.notify(string.format("F %3.6f; R %3.6f; W %3.6f", fog, rain, wind))
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
        g_savedata.weather.rain.tick = g_savedata.weather.rain.duration
        g_savedata.weather.wind.tick = g_savedata.weather.wind.duration
        g_savedata.weather.fog.tick = g_savedata.weather.fog.duration
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
