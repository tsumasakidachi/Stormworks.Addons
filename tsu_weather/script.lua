g_savedata = {
    mode = "prod",
    active = true,
    probability_of_clear = 25,
    probability_of_clear_today = 20,
    meteorologicals = {
        wind = {
            level = 0,
            level_target = 0,
            level_max = 50,
            remaining = 0
        },
        rain = {
            level = 0,
            level_target = 0,
            level_max = 100,
            remaining = 0
        },
        fog = {
            level = 0,
            level_target = 0,
            level_max = 50,
            remaining = 0
        }
    }
}

function probability_of_clear(poc, min)
    if math.random() * 100 > poc and min < 100 then
        return math.floor(math.random(min, 99) / 5) * 5
    else
        return 100
    end
end

function weather(poc, max)
    if math.random() * 100 > poc and max > 0 then
        return math.ceil(math.random(1, max) / 5) * 5
    else
        return 0
    end
end

-- main logic

day = 0
hour = 0
minute = 0

function onTick(tick)
    math.randomseed(server.getTimeMillisec())

    local day_updated = server.getDateValue()
    local time_updated = server.getTime()
    local hour_updated = time_updated.hour
    local minute_updated = time_updated.minute

    if g_savedata.active and day ~= day_updated then
        g_savedata.probability_of_clear_today = probability_of_clear(g_savedata.probability_of_clear, 0)
        notice(string.format("Probability of clear today: %f", g_savedata.probability_of_clear_today))
    end

    if g_savedata.active and hour ~= hour_updated then
        for k, v in pairs(g_savedata.meteorologicals) do
            if g_savedata.meteorologicals[k].remaining <= 0 then
                g_savedata.meteorologicals[k].level_target = weather(g_savedata.probability_of_clear_today, math.min(100 - g_savedata.probability_of_clear_today, g_savedata.meteorologicals[k].level_max))
                g_savedata.meteorologicals[k].remaining = math.random(2, 8)
            else
                g_savedata.meteorologicals[k].remaining = g_savedata.meteorologicals[k].remaining - 1
            end
        end
    end

    if g_savedata.active and minute ~= minute_updated then
        for k, v in pairs(g_savedata.meteorologicals) do
            if g_savedata.meteorologicals[k].level < g_savedata.meteorologicals[k].level_target then
                g_savedata.meteorologicals[k].level = math.min(g_savedata.meteorologicals[k].level + 5, g_savedata.meteorologicals[k].level_target)
            elseif g_savedata.meteorologicals[k].level > g_savedata.meteorologicals[k].level_target then
                g_savedata.meteorologicals[k].level = math.max(g_savedata.meteorologicals[k].level - 5, g_savedata.meteorologicals[k].level_target)
            end
        end

        server.setWeather(g_savedata.meteorologicals.fog.level / 100, g_savedata.meteorologicals.rain.level / 100, g_savedata.meteorologicals.wind.level / 100)

        notice(string.format("Rain: %d; Wind; %d, Fog: %d", g_savedata.meteorologicals.rain.level, g_savedata.meteorologicals.wind.level, g_savedata.meteorologicals.fog.level))
    end

    day = day_updated
    hour = hour_updated
    minute = minute_updated
end

function onCustomCommand(full_message, user_peer_id, is_admin, is_auth, command, verb, ...)
    if command ~= "?weather" then
        return
    end

    if verb == "start" and is_admin then
        g_savedata.active = true
    elseif verb == "stop" and is_admin then
        g_savedata.active = false
    elseif verb == "poc" and is_admin then
        local poc = ...
        poc = tonumber(poc)

        if poc == nil then
            error("poc is not number")
            return
        end

        g_savedata.probability_of_clear = poc
        notice("Probability of clear: " .. g_savedata.probability_of_clear)
    elseif verb == "prod" and is_admin then
        g_savedata.mode = "prod"
    elseif verb == "debug" and is_admin then
        g_savedata.mode = "debug"
    end
end

-- utils

function notice(text, peer_id)
    peer_id = peer_id or -1

    if g_savedata.mode == "debug" then
        server.announce("[Weather]", text, peer_id)
    end
end

function error(text, peer_id)
    peer_id = peer_id or -1

    server.announce("[Weather]", text, peer_id)
end

function table.random(t)
    if #t == 0 then
        return nil
    end

    return t[math.random(1, #t)]
end

function math.round(x)
    return math.floor(x + 0.5)
end

