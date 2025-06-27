g_savedata = {
    date_base = 0
}

function onCreate(is_world_create)
    if is_world_create then
        server.command("?mdisaster false")
        server.command("?mfreq 7.5")
        server.command("?mlife 45")
        server.command("?autosave-interval 10")
    end
end

function onCustomCommand(message, user_id, admin, auth, command, one, two, three, four)
    -- if server.getGameSettings().settings_menu == false then
    -- 	return
    -- end

    if command == "?mdifficulty" and admin == true then
        local dif = tonumber(one)

        if dif ~= nil then
            g_savedata.mission_difficulty_base = dif
        end
    end

    if command == "?mfreq" and admin == true then
        local freq = tonumber(one)

        if freq ~= nil then
            g_savedata.mission_frequency = freq * 60 * 60
        end
    end

    if command == "?mlife" and admin == true then
        local life = tonumber(one)

        if life ~= nil then
            g_savedata.mission_life_base = life * 60 * 60
        end
    end

    if command == "?mdisaster" and admin == true then
        if one == "true" then
            g_savedata.enable_disasters = true
        elseif one == "false" then
            g_savedata.enable_disasters = false
        end
    end

    if command == "?mdata" and admin == true then
        server.announce("[Mission]", string.format("Mission frequency: %.1fmin", g_savedata.mission_frequency / 60 / 60))
        server.announce("[Mission]", string.format("Mission lifetime: %.1fmin", g_savedata.mission_life_base / 60 / 60))
        server.announce("[Mission]", string.format("Disaster: %s", g_savedata.enable_disasters))
        server.announce("[Mission]", string.format("Date: %d", getDate()))
    end
end

function getDifficulty()
	local mission_difficulty_factor = 1
	if server.getGameSettings().no_clip == false then
		mission_difficulty_factor = math.min(1, getDate() / 60)
	end
	return mission_difficulty_factor
end

function getDate()
    return server.getDateValue() + g_savedata.date_base
end

