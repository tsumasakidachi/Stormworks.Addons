g_savedata = {
  mode = "debug",
  clock = 0,
  missions = {},
  objects = {},
  player_missions = {},
  subsystems = {
    mission = {
      tickrate = 0,
      count = 0,
      center = matrix.identity(),
      dispersal_min = property.slider("Minimum range in which new missions occur (km)", 0, 10, 1, 2) * 1000,
      dispersal_max = property.slider("Maximum range in which new missions occur (km)", 1, 100, 1, 8) * 1000,
      history = {},
    },
    rescuee = {
      code_blue_probability = property.slider("Probability of Code Blue to occur (%)", 0, 100, 1, 12),
      code_blue_required_players = property.slider("Number of players required for a Code Blue to occur", 0, 32, 1, 8),
    },
    location = {
      count = 0,
    },
    component = {
      count = 0,
    },
  },
  flags = {},
}


mission_type = {
  catalogue = {
    sarod = {}, -- search and rescue or destroy
    disaster = {},
    transport = {},
  },
}


cases = {
  ems = {
    id = 1,
    text = "EMS 救急",
  },
  far = {
    id = 2,
    text = "FAR 火災",
  },
  sar = {
    id = 3,
    text = "SAR 捜索救難",
  },
  water = {
    id = 4,
    text = "WAT 水難",
  },
  securite = {
    id = 5,
    text = "SEC 警備行動",
  },
  supply = {
    id = 6,
    text = "SUP 物資輸送",
  },
  accident = {
    id = 51,
    text = "ACC 事故",
  },
  mayday = {
    id = 52,
    text = "MDY メーデー",
  },
  alert = {
    id = 91,
    text = "WRN 警報"
  }
}


geologics = {
  mainlands = "mainlands",
  islands = "islands",
  waters = "waters",
}


scales = {
  small = 2,
  medium = 4,
  massive = 8,
}


location_catalogue = { {
  pattern = "^mission:climber_missing_%d+$",
  type = "sar",
  report = "悪天候により登山客の集団遭難が発生した. このエリアを捜索し行方不明者を全員救出せよ.",
  note = "警察署からの通報",
  scale = scales.medium,
  case = cases.sar,
  geologic = geologics.mainlands,
  search_radius = 1000,
  zone_tag_groups = {
    { landscape = "forest" },
    { landscape = "mountain" },
  },
  sub_location = {
    patterns = { "^mission:climber_missing_%d+$" },
    min = 1,
    max = 3,
    dispersal_radius = 1000,
  },
}, {
  pattern = "^mission:freighter_fire_%d+$",
  type = "sar",
  report = "船内で突然何かが爆発した! もう助からないぞ!",
  note = "乗員からの通報",
  scale = scales.medium,
  case = cases.mayday,
  geologic = geologics.waters,
  offshore = true,
  zone_tag_groups = {
    { landscape = "channel" },
  },
  sub_location = {
    patterns = { "^mission:passenger_fallen_water_%d+$", "^mission:lifeboat_%d+$" },
    min = 1,
    max = 3,
    dispersal_radius = 1000,
  },
}, {
  pattern = "^mission:passenger_fallen_land_%d+$",
  type = "sar",
  report = "落下者",
  note = "",
  geologic = geologics.waters,
  zone_tag_groups = {
    { landscape = "field" },
    { landscape = "mountain" },
    { landscape = "forest" }
  },
}, {
  pattern = "^mission:passenger_fallen_water_%d+$",
  type = "sar",
  report = "落水者",
  note = "",
  geologic = geologics.waters,
  offshore = true,
  zone_tag_groups = {
    { landscape = "channel" },
    { landscape = "shallow" },
  },
}, {
  pattern = "^mission:lifeboat_%d+$",
  type = "sar",
  report = "救命ボート",
  note = "",
  geologic = geologics.waters,
  offshore = true,
  zone_tag_groups = {
    { landscape = "channel" },
    { landscape = "shallow" },
  },
}, {
  pattern = "^mission:wind_turbine_fire_%d+$",
  type = "sar",
  report = "洋上風力発電機のエレベーターが故障, タービン室から降りられず閉じこめられている.",
  note = "パトロールからの通報",
  scale = scales.small,
  case = cases.ems,
  geologic = geologics.waters,
}, {
  pattern = "^mission:piracy_boat_%d+$",
  type = "sar",
  report = "武装した小型船を発見した. 乗員を拘束せよ.",
  note = "哨戒機からの通報",
  scale = scales.medium,
  case = cases.securite,
  geologic = geologics.waters,
  offshore = true,
  search_radius = 2000,
  sub_location = {
    patterns = { "^mission:piracy_boat_%d+$" },
    min = 1,
    max = 2,
    dispersal_radius = 500,
  },
}, {
  pattern = "^mission:piracy_gunboat_%d+$",
  type = "sar",
  report = "武装した船を発見した. 乗員を拘束せよ.",
  note = "哨戒機からの通報",
  scale = scales.massive,
  case = cases.securite,
  geologic = geologics.waters,
  offshore = true,
  search_radius = 2000,
  sub_location = {
    patterns = { "^mission:piracy_boat_%d+$" },
    min = 2,
    max = 3,
    dispersal_radius = 500,
  },
}, {
  pattern = "^mission:piracy_boat_watch_%d+$",
  type = "sar",
  report = "武装した小型船が沖合を航行している. 見つからないように追跡, 動向を監視せよ. なお当該船舶は時間経過と共にエリア外へ出る場合がある.",
  note = "哨戒機からの通報",
  scale = scales.small,
  case = cases.securite,
  geologic = geologics.waters,
  offshore = true,
  search_radius = 2000,
  sub_mission = {
    patterns = { "^mission:piracy_hideout_%d+$" },
    dispersal_radius = 50000,
  },
}, {
  pattern = "^mission:piracy_hideout_%d+$",
  type = "sar",
  report = "海賊のアジトと思われる島を発見.",
  note = "哨戒機からの通報",
  scale = scales.small,
  case = cases.securite,
  geologic = geologics.islands,
  offshore = true,
  search_radius = 1000,
  flag_required_for_spawn = "detects_priate_hideout",
  sub_location = {
    patterns = { "^mission:piracy_infantry_%d+$", "^mission:piracy_static_%d+$", "^mission:piracy_gunboat_%d+$", "^mission:piracy_boat_%d+$" },
    min = 7,
    max = 11,
    dispersal_radius = 1000,
  },
}, {
  pattern = "^mission:piracy_infantry_%d+$",
  type = "sar",
  report = "海賊の歩兵",
  note = "",
  zone_tag_groups = {
    { landscape = "island" },
    { landscape = "road" },
    { landscape = "forest" },
    { landscape = "hill" },
    { landscape = "field" },
    { landscape = "beach" },
  },
}, {
  pattern = "^mission:piracy_static_%d+$",
  type = "sar",
  report = "海賊のスタティック",
  note = "",
  zone_tag_groups = {
    { spawn_point = "static" },
  },
}, {
  pattern = "^mission:piracy_technical_%d+$",
  type = "sar",
  report = "海賊のテクニカル",
  note = "",
  zone_tag_groups = {
    { spawn_point = "technical" },
  },
} }


fluids = {
  fresh_water = 0,
  diesel = 1,
  jet = 2,
  air = 3,
  exhaust = 4,
  oil = 5,
  sea_water = 6,
  steam = 7,
  slurry = 8,
  saturated_slurry = 9,
  oxygen = 10,
  nitrogen = 11,
  hydrogen = 12,
}


weapons = { {
  id = 35,
  slot = 2,
  ammo = 10,
}, {
  id = 37,
  slot = 1,
  ammo = 45,
}, {
  id = 39,
  slot = 1,
  ammo = 30,
} }


destination_points = {
  port = {
    landscape = "port",

  }
}


framework = {
  name = "TSU Mission Framework",
  version = "1.0.0",
  cycle_objects = 60,
  cycle_missions = 60,
  cycle_players = 10,
  commands = {},
  players = {},
  on_load = function()
    object_type.build()
    objective_type.build()

    framework.register_command("?mission", "version", "?v", nil, function(full_message, peer_id, is_admin, is_auth, subject, verb) return is_admin, peer_id end, framework.print_version)
    framework.register_command("?mission", "prod", nil, nil, function(full_message, peer_id, is_admin, is_auth, subject, verb) return is_admin end, function() g_savedata.mode = "prod" end)
    framework.register_command("?mission", "debug", nil, nil, function(full_message, peer_id, is_admin, is_auth, subject, verb) return is_admin end, function() g_savedata.mode = "debug" end)
    framework.register_command("?mission", "commands", "?commands", nil, function(full_message, peer_id, is_admin, is_auth, subject, verb) return is_admin, peer_id end, framework.print_all_commands)
    framework.register_command("?mission", "locations", "?locations", nil, function(full_message, peer_id, is_admin, is_auth, subject, verb) return is_admin, peer_id end, framework.print_all_locations)
    framework.register_command("?mission", "setting", nil, "[name] [value]", function(full_message, peer_id, is_admin, is_auth, subject, verb, name, value) return is_admin, name, value end, framework.update)
    framework.register_command("?mission", "init", "?init", "[pattern] [dispersal_max]",
      function(full_message, peer_id, is_admin, is_auth, subject, verb, pattern, dispersal_max)
        if pattern ~= nil then
          pattern = "^" .. pattern .. "$"
        end

        dispersal_max = tonumber(dispersal_max)

        if dispersal_max == nil then
          dispersal_max = g_savedata.subsystems.mission.dispersal_max
        end

        return is_admin, pattern, g_savedata.subsystems.mission.center, g_savedata.subsystems.mission.dispersal_min, dispersal_max
      end, mission.load_pattern)
    framework.register_command("?mission", "clear-all", "?cls", nil, function(full_message, peer_id, is_admin, is_auth, subject, verb) return is_admin end, mission.clear_all)
    framework.register_command("?mission", "gather", "?gather", "[mission id]",
      function(full_message, peer_id, is_admin, is_auth, subject, verb, mission_id) return is_admin, peer_id, tonumber(mission_id) end,
      function(peer_id, mission_id)
        local transform = server.getPlayerPos(peer_id)

        for k, o in ipairs(g_savedata.objects) do
          if o.mission_id == mission_id and o.is_character then
            server.setObjectPos(o.id, transform)
          end
        end
      end)
    framework.register_command("?mission", "go", "?go", "[mission id]", function(full_message, peer_id, is_admin, is_auth, subject, verb, mission_id)
      local mission_id = tonumber(mission_id)

      if mission_id == nil then return false end

      local m = table.find(g_savedata.missions, function(m) return m.id == mission_id end)

      if m == nil then return false end

      local p = table.find(framework.players, function(p) return p.id == peer_id end)

      if p == nil then return false end

      return true, m, p
    end, mission.checkin)
    framework.register_command("?zone", "map", nil, nil,
      function(full_message, peer_id, is_admin, is_auth, subject, verb, vehicle_id) return is_admin end,
      function()
        if g_savedata.ui_id == nil then g_savedata.ui_id = server.getMapID() end

        server.removeMapID(-1, g_savedata.ui_id)

        for k, zn in ipairs(zone.load({})) do
          local x, y, z = matrix.position(zn.transform)

          server.addMapLabel(-1, g_savedata.ui_id, 1, zn.name, x, z)
        end
      end)
    framework.register_command("?vehicle", "set-hq", "?hq", "[id]",
      function(full_message, peer_id, is_admin, is_auth, subject, verb, vehicle_id) return is_admin, tonumber(vehicle_id) end,
      function(vehicle_id)
        if vehicle_id == nil then return false end

        local v = table.find(g_savedata.objects, function(o) return o.is_vehicle and o.id == vehicle_id end)

        if v == nil then return end

        v.is_headquarter = true
      end)
    framework.register_command("?doctor", "respawn", nil, nil,
      function(full_message, peer_id, is_admin, is_auth, subject, verb, vehicle_id) return is_admin end,
      function()
        doctor.spawn()
      end)
    framework.register_command("?police", "respawn", nil, nil,
      function(full_message, peer_id, is_admin, is_auth, subject, verb, vehicle_id) return is_admin end,
      function()
        police.spawn()
      end)
  end,
  on_create = function(is_world_create)
    if is_world_create then
      g_savedata.subsystems.mission.center = tile.get_start()

      doctor.spawn()
      police.spawn()

      for _, z in ipairs(zone.load({}, function(z) return z.detective_point ~= nil end)) do
        table.insert(g_savedata.objects, z)
      end
    end

    g_savedata.flags = {}

    if g_savedata.mode == "debug" then
      framework.print_version()
      console.notify(string.format("%d ongoing missions", #g_savedata.missions))
      console.notify(string.format("%d objects", #g_savedata.objects))
    end
  end,
  on_tick = function(tick)
    math.randomseed(server.getTimeMillisec())

    if g_savedata.clock % 10 == 0 then
      framework.players = player.load()
    end

    framework.tick(g_savedata.objects, framework.cycle_objects, function(o, k)
      object.module(o).unmap(o, framework.players)

      if o.is_clear then
        object.module(o).unmap(o, framework.players)
        table.remove(g_savedata.objects, k)
      else
        object.module(o).tick(o, tick * framework.cycle_objects)
        objective.module(o).tick(o, tick * framework.cycle_objects)
        object.module(o).map(o, framework.players)
      end
    end)

    framework.tick(g_savedata.missions, framework.cycle_missions, function(m, k)
      mission.unmap(m, framework.players)

      if m.is_clear then
        table.remove(g_savedata.missions, k)
      else
        mission.tick(m, tick * framework.cycle_missions)
        mission.map(m, framework.players)
      end
    end)

    g_savedata.clock = g_savedata.clock + 1
  end,
  on_custom_command = function(...)
    local args = { ... }
    local subject = args[5]
    local verb = args[6]
    local command = table.find(framework.commands, function(x) return x.subject == subject and x.verb == verb or x.shorthand == subject end)

    if command == nil then
      return
    end

    if command.shorthand == subject then
      table.move(args, 5, #args, 6)
    end

    framework.invoke_command(command, command.guard(table.unpack(args)))
  end,
  on_player_join = function(steam_id, name, peer_id, is_admin, is_auth)
    steam_id = tostring(steam_id)
    framework.map(table.find_all(framework.players, function(p) return p.steam_id == steam_id end))
    server.setAICharacterTeam((server.getPlayerCharacterID(peer_id)), 1)
  end,
  on_group_spawn = function(group_id, peer_id, x, y, z, group_cost)
    if component.is_spawing then return end

    local player_steam_id = nil
    local p = table.find(framework.players, function(p) return p.id == peer_id end)

    if p ~= nil then
      player_steam_id = p.steam_id
    end

    for k, v in ipairs(server.getVehicleGroup(group_id)) do
      local cost = 0
      local data = server.getVehicleData(v)
      local tags = tag.deserialize(data.tags)

      if k == 1 then cost = group_cost end

      v = vehicle.init(v, "vehicle", data.name, tags, group_id, player_steam_id, cost)

      if v.is_player_unit then
        table.insert(g_savedata.objects, v)
      end
    end
  end,
  on_vehicle_despawn = function(vehicle_id, peer_id, x, y, z, group_cost, group_id)
    for k, v in ipairs(g_savedata.objects) do
      if v.is_vehicle and v.id == vehicle_id then
        object.module(v).clear(v)
      end
    end
  end,
  register_command = function(subject, verb, shorthand, args, guard, execute)
    if guard == nil then
      guard = function() return true end
    end

    table.insert(framework.commands, {
      subject = subject,
      verb = verb,
      shorthand = shorthand,
      args = args,
      execute = execute,
      guard = guard,
    })
  end,
  print_all_commands = function(peer_id)
    for _, command in ipairs(framework.commands) do
      local text = string.format("%s %s", command.subject, command.verb)

      if command.args ~= nil then
        text = text .. " " .. command.args
      end

      console.log(text, peer_id)
    end
  end,
  print_version = function(peer_id)
    console.log(string.format("%s %s", framework.name, framework.version), peer_id)
  end,
  print_all_locations = function(peer_id)
    local locations = location.load()

    for k, l in ipairs(locations) do
      console.log(l.name, peer_id)
    end

    console.log(string.format("%d locations found.", #locations), peer_id)
  end,
  update = function(name, value)
    if name == "dispersal-min" then
      value = tonumber(value)

      if value == nil then return end

      g_savedata.subsystems.mission.dispersal_min = value
    elseif name == "dispersal-max" then
      value = tonumber(value)

      if value == nil then return end

      g_savedata.subsystems.mission.dispersal_max = value
    end
  end,
  invoke_command = function(command, can_execute, ...)
    if not can_execute then return end

    command.execute(table.unpack({ ... }))
  end,
  tick = function(items, cycle, action)
    for i = #items, 1, -1 do
      if i % cycle == g_savedata.clock % cycle then
        action(items[i], i)
      end
    end
  end,
  map = function(players)
    for k, o in ipairs(g_savedata.objects) do
      object.module(o).map(o, players)
    end
  end,
}


mission = {
  init = function(id, locations)
    local self = {}

    self.id = id
    self.locations = locations
    self.is_active = false
    self.is_clear = false
    self.reported = false
    self.elapsed_time = 0
    self.finish_time = 0
    self.objective_reward = 0
    self.objectives = {}
    self.sorted_objectives = {}
    self.required_objectives_count = 0
    self.ui_id = server.getMapID()
    self.marker_type = 8
    self.marker_color = { 255, 255, 0, 255 }
    self.search_center = matrix.multiply(self.locations[1].transform, matrix.translation(math.random() * 500, 0, math.random() * 500))
    self.search_radius = nil

    console.notify(string.format("mission#%d has occurred.", self.id))

    return self
  end,
  clear = function(self)
    mission.despawn(self)

    self.is_clear = true
    server.notify(-1, mission.label(self), "a mission has cleared.", 4)
  end,
  clear_all = function()
    for i = #g_savedata.missions, 1, -1 do
      mission.clear(g_savedata.missions[i])
    end
  end,
  tick = function(self, tick)
    mission.spawn(self)

    self.is_active = self.is_active or table.aggregate(framework.players, false, function(result, p) return result or mission.contains(self, p.transform) end) or
        table.aggregate(g_savedata.objects, false, function(result, v) return result or v.is_vehicle and v.is_player_unit and mission.contains(self, v.transform) end)
    self.objectives = table.select(table.find_all(g_savedata.objects, function(o) return o.mission_id == self.id and o.objective_type ~= nil end), function(o) return objective.module(o).progress(o) end)
    self.sorted_objectives, self.required_objectives_count = mission.aggregate_objectives(self, self.objectives)

    if not self.reported and #self.objectives > 0 then
      server.notify(-1, mission.label(self), "a mission has occured.", 0)
      self.reported = true
    end

    if self.is_active and self.required_objectives_count == 0 then
      money.transact(mission.reward(self), string.format("reward to cleared mission#%d.", self.id))
      console.notify(string.format("mission#%d has cleared.", self.id))
      mission.clear(self)
    end

    self.elapsed_time = self.elapsed_time + tick
  end,
  aggregate_objectives = function(self, objectives)
    local sorted_objectives = {}
    local required_objectives_count = 0

    for k, v in pairs(objective_type.catalogue) do
      sorted_objectives[k] = {
        count = 0,
        text = objective.module(v).label(v),
      }
    end

    for k, o in ipairs(objectives) do
      sorted_objectives[o.type].count = sorted_objectives[o.type].count + o.count

      if o.is_require then
        required_objectives_count = required_objectives_count + 1
      end
    end

    return sorted_objectives, required_objectives_count
  end,
  compute_search_radius = function(self)
    local search_radius = self.locations[1].search_radius

    for k, o in ipairs(g_savedata.objects) do
      if o.mission_id == self.id then
        local object_distance = matrix.distance(o.transform, self.search_center)
        search_radius = math.max(search_radius, object_distance)
      end
    end

    return math.ceil(search_radius / 500) * 500
  end,
  label = function(self)
    return string.format("mission#%d\n%s\n%s", self.id, self.locations[1].case.text, self.locations[1].report)
  end,
  detail = function(self)
    local text = self.locations[1].note

    if #self.objectives > 0 then
      text = text .. "\n\n[目標]"

      for k, ov in pairs(self.sorted_objectives) do
        if ov.count > 0 then
          text = text .. string.format("\n%d %s", ov.count, ov.text)
        end
      end
    end

    if self.search_radius > 0 then text = text .. string.format("\n\n[半径]\n%.1fkm", self.search_radius / 1000) end

    if self.finish_time > 0 then text = text .. string.format("\n\n[残り時間]\n%d分", math.ceil((self.finish_time - self.elapsed_time) / 3600)) end

    local count = 0
    text = text .. string.format("\n\n[対応中]")

    for k, p in ipairs(table.find_all(framework.players, function(p) return g_savedata.player_missions[p.steam_id] ~= nil and g_savedata.player_missions[p.steam_id] == self.id end)) do
      text = text .. "\n" .. p.name
      count = count + 1
    end

    if count < self.locations[1].scale then
      text = text .. string.format("\n%d人以上必要", self.locations[1].scale)
    end

    text = text .. string.format("\n?go %d (全て小文字) でチェックイン", self.id)

    return text
  end,
  reward = function(self)
    return math.ceil(matrix.distance(g_savedata.subsystems.mission.center, self.locations[1].transform) * 4 / 100) * 100 + self.objective_reward
  end,
  add_reward = function(self, amount, title)
    self.objective_reward = self.objective_reward + amount
  end,
  checkin = function(self, p)
    g_savedata.player_missions[p.steam_id] = self.id
    server.notify(-1, string.format("%s is enroute to mission#%d", p.name, self.id), nil, 5)
  end,
  spawn = function(self)
    local count = 0

    for _, l in ipairs(self.locations) do
      if not l.spawned and (l.flag_required_for_spawn == nil or g_savedata.flags[l.flag_required_for_spawn]) then
        local objects = location.spawn(l)

        for _, o in ipairs(objects) do
          local ot = objective_type.find(o.type, o.name, o.tags)

          if o.type == "vehicle" then
            for _, vehicle_id in ipairs(o.vehicle_ids) do
              o = vehicle.init(vehicle_id, o.type, o.name, o.tags, o.group_id, nil, 0, o.parent_id, self.id)
              o = objective_type.get(ot).init(o, ot)
              table.insert(g_savedata.objects, o)
            end
          elseif o.type == "character" then
            o = character.init(o.id, o.type, o.name, o.tags, o.mount_id, o.parent_id, self.id)
            o = objective_type.get(ot).init(o, ot)
            table.insert(g_savedata.objects, o)
          else
            o = object.module(o).init(o.id, o.type, o.name, o.tags, o.parent_id, self.id)
            o = objective_type.get(ot).init(o, ot)
            table.insert(g_savedata.objects, o)
          end
        end

        count = count + #objects
      end
    end

    if count > 0 then
      self.search_radius = mission.compute_search_radius(self)
    end
  end,
  despawn = function(self)
    for k, o in ipairs(g_savedata.objects) do
      if o.mission_id == self.id then
        object.module(o).despawn(o)
      end
    end
  end,
  map = function(self, players)
    if self.search_center ~= nil and self.search_radius ~= nil then
      for k, p in ipairs(players) do
        ui.map(self, p, self.search_center, self.search_radius, mission.label(self), mission.detail(self))
      end
    end
  end,
  unmap = function(self, players)
    for k, p in ipairs(players) do
      ui.unmap(self, p)
    end
  end,
  load = function(center, range_min, range_max, filter_location, filter_zone)
    local locations = location.construct(center, range_min, range_max, filter_location, filter_zone)

    if #locations == 0 then return end

    if locations[1].sub_location ~= nil then
      local sub_locations_count = math.random(locations[1].sub_location.min, locations[1].sub_location.max)

      for i = 1, sub_locations_count do
        for k, v in ipairs(location.construct(locations[1].transform, 0, locations[1].sub_location.dispersal_radius, function(l)
            return table.aggregate(locations[1].sub_location.patterns, false, function(result, x) return result or string.match(l.name, x) end)
          end,
          function(z)
            return zone.is_in(z, locations[1].transform, 0, locations[1].sub_location.dispersal_radius) and
                not zone.is_contained_objects(z, 10)
          end)) do
          table.insert(locations, v)
        end
      end
    end

    local mission_id = g_savedata.subsystems.mission.count + 1
    local m = mission.init(mission_id, locations)

    if m == nil then return nil end

    table.insert(g_savedata.missions, m)
    history.record(locations[1])
    g_savedata.subsystems.mission.count = m.id
    mission.load_sub_missions(m)
  end,
  load_random = function(geologic, scale, case, center, range_min, range_max) end,
  load_pattern = function(pattern, center, range_min, range_max)
    if pattern == nil then return end

    mission.load(center, range_min, range_max,
      function(l)
        return string.match(l.name, pattern) ~= nil
      end,
      function(z)
        return zone.is_in(z, center, range_min, range_max) and
            not zone.is_contained_objects(z, 10) and
            not table.any(g_savedata.missions, function(m) return mission.contains(m, z.transform) end)
      end)
  end,
  load_sub_missions = function(self)
    for _, l in ipairs(self.locations) do
      if l.sub_mission ~= nil then
        for _, pattern in ipairs(l.sub_mission.patterns) do
          mission.load_pattern(pattern, l.transform, 0, l.sub_mission.dispersal_radius)
        end
      end
    end
  end,
  contains = function(self, transform)
    return self.search_radius ~= nil and matrix.distance(self.search_center, transform) <= self.search_radius
  end,
}


object = {
  marker_type = {
    character = 1,
    vehicle = 12,
    animal = 6,
    creature = 6,
    fire = 5,
    forest_fire = 5,
  },
  module = function(self)
    return object_type.get(self.type)
  end,
  init = function(id, type, name, tags, parent_id, mission_id)
    local self = {}
    self.id = id
    self.type = type
    self.name = name

    if string.nil_or_empty(self.name) then
      self.name = self.type
    end

    self.tags = tags
    self.parent_id = parent_id
    self.mission_id = mission_id
    self.is_clear = false
    self.is_vehicle = object.is_vehicle(self)
    self.is_object = object.is_object(self)
    self.is_character = object.is_character(self)
    self.is_fire = object.is_fire(self)
    self.is_zone = object.is_zone(self)
    self.is_tile = object.is_tile(self)
    self.is_disaster = object.is_disaster(self)
    self.is_simulate = object.simulating(self)
    self.transform = object.update_transform(self)
    self.elapsed_time = 0
    self.ui_id = server.getMapID()
    self.marker_type = 2

    if object.marker_type[self.type] ~= nil then
      self.marker_type = object.marker_type[self.type]
    end

    self.marker_color = { 128, 128, 128, 255 }

    if not self.is_zone then console.notify(string.format("%s#%d has initialized.", self.type, self.id)) end

    return self
  end,
  clear = function(self)
    self.is_clear = true
    console.notify(string.format("%s#%d has cleared.", self.type, self.id))
  end,
  lazy_clear = function(self, clear_time)
    self.clear_time = clear_time
  end,
  despawn = function(self)
    if self.is_vehicle then
      server.despawnVehicle(self.id, true)
    elseif self.is_object then
      server.despawnObject(self.id, true)
      object.module(self).clear(self)
    end
  end,
  tick = function(self, tick)
    self.transform = object.update_transform(self)
    self.is_simulate = object.simulating(self)
    self.elapsed_time = self.elapsed_time + 1

    if self.clear_time ~= nil then
      self.clear_time = self.clear_time - tick

      if self.clear_time ~= nil and self.clear_time <= 0 then
        object.module(self).despawn(self)
      end
    end
  end,
  update_transform = function(self)
    if self.is_vehicle then
      return server.getVehiclePos(self.id)
    elseif self.is_object then
      return server.getObjectPos(self.id)
    elseif self.transform ~= nil then
      return self.transform
    else
      return nil
    end
  end,
  simulating = function(self)
    if self.is_vehicle then
      return server.getVehicleSimulating(self.id)
    elseif self.is_object then
      return server.getObjectSimulating(self.id)
    end
  end,
  label = function(self)
    return string.format("%s#%d", self.name, self.id)
  end,
  detail = function(self)
    return self.mission_id ~= nil and string.format("mission#%d", self.mission_id) or nil
  end,
  map = function(self, players)
    if self.transform == nil then return end

    local id = nil
    local type = nil

    if self.is_vehicle then
      id = self.id
      type = "vehicle"
    elseif self.is_object then
      id = self.id
      type = "object"
    end

    for k, p in ipairs(players) do
      if g_savedata.mode == "debug" and p.admin then
        ui.map(self, p, self.transform, 0, object.label(self), object.detail(self), type, id)
      end
    end
  end,
  unmap = function(self, players)
    for k, p in ipairs(players) do
      ui.unmap(self, p)
    end
  end,
  is_vehicle = function(self)
    return self.type == "vehicle"
  end,
  is_character = function(self)
    return self.type == "character"
  end,
  is_fire = function(self)
    return self.type == "fire"
  end,
  is_object = function(self)
    return self.type == "object" or self.type == "character" or self.type == "flare" or self.type == "fire" or self.type == "loot" or self.type == "button" or self.type == "animal" or self.type == "creature" or self.type == "ice"
  end,
  is_tile = function(self)
    return self.type == "forest_fire" or self.type == "oil_spill"
  end,
  is_zone = function(self)
    return self.type == "zone"
  end,
  is_disaster = function(self)
    return self.type == "tornado" or self.type == "tsunami" or self.type == "whirlpool" or self.type == "meteor" or self.type == "eruption"
  end,
}


character = {
  roles = {
    ship_pilot = "^pilot%sship",
    gunner = "^gunner",
  },
  ai_states = {
    drive = {
      ship_pilot = 1,
    },
    attack = {
      gunner = 1,
      designator = 1,
    },
  },
  init = function(id, type, name, tags, mount_id, parent_id, mission_id)
    local self = object.init(id, type, name, tags, parent_id, mission_id)
    self.mount_id = mount_id
    self.is_mount = false
    self.seat = nil
    self.vehicle_id = server.getCharacterVehicle(self.id)
    self.vital = server.getObjectData(self.id)
    self.commands = self.tags.commands
    self.observable_radius = tonumber(tags.invocation_distance)
    self.role = nil
    self.paths = {}
    self.target_transform = nil
    self.target_id = nil
    self.target_type = nil

    if self.tags.destination ~= nil then
      self.destination = table.random(zone.load({ destination_point = self.tags.destination }))
    end

    self.destination_routed = false

    return self
  end,
  tick = function(self, tick)
    object.tick(self, tick)

    character.mount(self)
    character.travel(self)

    if self.is_simulate and self.destination ~= nil and not self.destination_routed and self.role == "ship_pilot" then
      character.route(self, self.destination.transform, "ocean_path")
      self.destination_routed = true
    end

    self.vehicle_id = server.getCharacterVehicle(self.id)
    self.vital = server.getObjectData(self.id)
  end,
  heals = function(self) return self.vital.hp >= 95 end,
  sits = function(self, is_headquarter) return false end,
  stays = function(self, zone_tags, time)
    return table.any(zone.load(zone_tags), function(z)
      return zone.contains(z, self.transform)
    end)
  end,
  update_vital = function(self, hp, interactable, ai)
    if hp ~= nil then
      self.vital.hp = hp
    end

    if interactable ~= nil then
      self.vital.interactable = interactable
    end

    if ai ~= nil then
      self.vital.ai = ai
    end

    server.setCharacterData(self.id, self.vital.hp, self.vital.interactable, self.vital.ai)
  end,
  mount = function(self)
    if self.is_mount or not self.is_simulate then return end

    local v = table.find(g_savedata.objects, function(o) return o.is_vehicle and o.id == self.mount_id end)

    if v == nil then return end

    local seat = vehicle.assign_seat(v, self)

    if seat == nil then return end

    character.seat(self, v, seat)

    self.is_mount = true

    console.notify(string.format("%s#%d has mounted on %s#%d.", self.type, self.id, v.type, v.id))
  end,
  seat = function(self, v, seat)
    self.seat = seat

    console.notify(string.format("%s#%d seat.", self.type, self.id))
    server.setSeated(self.id, v.id, seat.pos.x, seat.pos.y, seat.pos.z)

    local seat_name = string.lower(self.seat.name)

    if seat_name == "pilot" and v.vehicle_type == "ship" then
      self.role = "ship_pilot"
    elseif seat_name == "gunner" then
      self.role = "gunner"
    elseif seat_name == "designator" then
      self.role = "designator"
    end

    console.notify(string.format("%s#%d has seated on %s.", self.type, self.id, self.seat.name))
  end,
  unseat = function(self)
    server.setObjectPos(self.id, matrix.multiply(self.transform, matrix.translation(0, 0.5, 0)))
  end,
  seats_with = function(self, filter)
    return self.vehicle_id > 0 and table.aggregate(g_savedata.objects, false, function(result, o)
      return result or filter(o) and o.vehicle_id == self.vehicle_id
    end)
  end,
  invoke_command = function(self)
    if not self.is_simulate or self.command ~= nil then return end
    if #self.commands == 0 then return end
    -- if self.mount_id ~= nil and self.seat == nil then return end
    if self.observable_radius == nil or not table.aggregate(framework.players, false, function(result, p) return result or character.observes(self, self.observable_radius, p.transform) end) then return end

    self.command = table.aggregate(g_savedata.objects, nil, function(result, o)
      if o.id ~= self.id and o.mission_id == self.mission_id and o.type == self.type and o.command ~= nil then
        result = o.command
      end

      return result
    end)

    if self.command == nil then
      self.command = table.random(self.commands)
    end

    character.update_vital(self, nil, nil, true)
    console.notify(string.format("%s#%d has invoke %s command", self.type, self.id, self.command))
  end,
  observes = function(self, radius, transform)
    return self.is_simulate and matrix.distance(self.transform, transform) <= radius
  end,
  travel = function(self)
    if not self.is_simulate then return end
    if self.target_transform ~= nil and matrix.distance(self.transform, self.target_transform) > 150 then return end
    if #self.paths < 1 then return end

    character.drive(self, self.paths[1])
    table.remove(self.paths, 1)
  end,
  drive = function(self, target_transform)
    self.target_transform = target_transform
    local x, y, z = matrix.position(self.target_transform)
    character.update_vital(self, nil, nil, true)
    server.setAIState(self.id, character.ai_states.drive[self.role])
    server.setAITarget(self.id, self.target_transform)
    console.notify(string.format("%s#%s drive to %.0f, %.0f, %.0f, %.0fm", self.type, self.id, x, y, z, matrix.distance(self.transform, self.target_transform)))
  end,
  attack = function(self, target_id, target_type)
    character.update_vital(self, nil, nil, true)

    if target_type == "vehicle" then
      server.setAITargetVehicle(self.id, target_id)
    elseif target_type == "character" then
      server.setAITargetCharacter(self.id, target_id)
    end

    server.setAIState(self.id, character.ai_states.attack[self.role])
    console.notify(string.format("%s#%s has attacked to %s#%d", self.type, self.id, target_type, target_id))
  end,
  terminate = function(self)
    self.paths = {}
    self.target_transform = nil
    server.setAIState(self.id, 0)
    character.update_vital(self, nil, nil, false)
  end,
  route = function(self, goal, required_tags, avoided_tags)
    character.clear_route(self)

    for k, t in ipairs(path.find(self.transform, goal, required_tags, avoided_tags)) do
      table.insert(self.paths, t)
    end

    table.insert(self.paths, goal)
  end,
  clear_route = function(self)
    self.paths = {}
  end,
  nearest_unit = function(self, distance_max)
    local nearest_obj = nil
    local distance_min = math.maxinteger

    if distance_max == nil then
      distance_max = math.maxinteger
    end

    for k, o in ipairs(g_savedata.objects) do
      if o.is_vehicle and o.is_player_unit then
        local distance = matrix.distance(o.transform, self.transform)

        if distance < distance_max and distance < distance_min then
          nearest_obj = o
          distance_min = distance
        end
      end
    end

    return nearest_obj, distance_min
  end,
  nearest_player = function(self, distance_max)
    local nearest_obj = nil
    local distance_min = math.maxinteger

    if distance_max == nil then
      distance_max = math.maxinteger
    end

    for k, p in ipairs(framework.players) do
      local distance = matrix.distance(p.transform, self.transform)

      if distance < distance_max and distance < distance_min then
        nearest_obj = p
        distance_min = distance
      end
    end

    return nearest_obj, distance_min
  end,
  signal = function(self)
    if self.is_signal and self.vehicle_id > 0 and self.vital.hp >= 95 then
      local on_player_unit = table.find(g_savedata.objects, function(o) return o.is_vehicle and o.id == self.vehicle_id and o.is_player_unit end) ~= nil

      if on_player_unit then
        server.setCharacterItem(self.id, 2, 23, false, 0, 100)
        self.is_signal = false
      end
    elseif not self.is_signal and (self.vehicle_id == 0 or self.vital.hp < 95) then
      local is_near_player = character.nearest_player(self, 250) ~= nil

      if is_near_player then
        server.setCharacterItem(self.id, 2, 23, true, 0, 100)
        self.is_signal = true
      end
    end
  end,
}


doctor = {
  init = function(id, type, name, tags, mount_id, parent_id, mission_id)
    local self = character.init(id, type, name, tags, mount_id, parent_id, mission_id)

    self.doctor = true

    server.setCharacterTooltip(self.id, name)

    return self
  end,
  spawn = function()
    local zones = zone.load({ spawn_point = "helper" })
    local z = table.random(zones)

    if z == nil then
      console.error("There is no spawn zone for the helper.")
      return
    end

    for k, o in ipairs(g_savedata.objects) do
      if o.type == "character" and o.doctor then
        object.module(o).despawn(o)
      end
    end

    local id = server.spawnCharacter(z.transform, 9)
    local d = doctor.init(id, "character", "Doctor", {})

    table.insert(g_savedata.objects, d)
  end,
}


police = {
  init = function(id, type, name, tags, mount_id, parent_id, mission_id)
    local self = character.init(id, type, name, tags, mount_id, parent_id, mission_id)

    self.police = true

    server.setCharacterTooltip(self.id, name)

    return self
  end,
  spawn = function()
    local zones = zone.load({ spawn_point = "helper" })
    local z = table.random(zones)

    if z == nil then
      console.error("There is no spawn zone for the helper.")
      return
    end

    for k, o in ipairs(g_savedata.objects) do
      if o.type == "character" and o.police then
        object.module(o).despawn(o)
      end
    end

    local id = server.spawnCharacter(z.transform, 7)
    local d = police.init(id, "character", "Police", {})

    table.insert(g_savedata.objects, d)
  end,
}


vehicle = {
  role_specific_seats = { "^pilot", "^driver", "^designator", "^gunner" },
  init = function(id, type, name, tags, group_id, player_steam_id, cost, parent_id, mission_id)
    local self = object.init(id, type, name, tags, parent_id, mission_id)

    self.vehicle_type = self.tags.vehicle_type
    self.cost = cost
    self.player_steam_id = player_steam_id
    self.is_player_unit = self.player_steam_id ~= nil or tags.player_unit == "true" or tags.tracker == "unit"
    self.is_enemy_unit = self.tags.enemy_unit == "true"
    self.group_id = group_id
    self.is_check_components = false
    self.is_refill = self.tags.refill == "true"
    self.damages = {}
    self.is_mount = false
    self.mass = 0
    self.signs = {}
    self.seats = {}
    self.buttons = {}
    self.tanks = {}
    self.batteries = {}
    self.hoppers = {}
    self.guns = {}
    self.rope_hooks = nil
    self.is_headquarter = self.tags.headquarter == "true"
    self.missions = {}

    if self.is_player_unit then
      server.setAIVehicleTeam(self.id, 1)
    end

    return self
  end,
  tick = function(self, tick)
    object.tick(self, tick)
    -- object.aggregate_damages(self)
    vehicle.check_components(self)
    vehicle.set_mission_data(self)
    vehicle.refill(self)
  end,
  assign_seat = function(self, c, seat_name)
    if not self.is_check_components or not self.is_simulate then return nil end

    local seat = nil

    if seat_name ~= nil then
      seat = vehicle.find_empty_seat(self, seat_name)
    else
      seat = vehicle.find_empty_sepcific_seat(self)

      if seat == nil then
        seat = vehicle.find_empty_seat(self, seat_name)
      end
    end

    if seat == nil then return nil end

    seat.seated_id = c.id

    return seat
  end,
  find_empty_sepcific_seat = function(self)
    local seat = nil

    for rk, r in ipairs(vehicle.role_specific_seats) do
      for sk, s in ipairs(self.seats) do
        if s.seated_id >= 4294967295 and string.match(string.lower(s.name), r) ~= nil then
          seat = s
          break
        end
      end
    end

    return seat
  end,
  find_empty_seat = function(self, seat_name)
    return table.find(self.seats, function(s) return s.seated_id >= 4294967295 and (seat_name == nil or string.match(string.lower(s.name), seat_name) ~= nil) end)
  end,
  check_components = function(self)
    if self.is_check_components or not self.is_simulate then return end

    local components = server.getVehicleComponents(self.id)
    self.voxels = components.voxels
    self.mass = components.mass
    self.signs = components.components.signs
    self.seats = components.components.seats
    self.buttons = components.components.buttons
    self.tanks = components.components.tanks
    self.batteries = components.components.batteries
    self.hoppers = components.components.hoppers
    self.guns = components.components.guns
    self.rope_hooks = components.components.rope_hooks

    if self.is_headquarter then
      self.attention = table.find(self.buttons, function(b) return string.lower(b.name) == "attention" end)

      for i = 1, 5 do
        self.missions[i] = {}
        self.missions[i].id = table.find(self.buttons, function(b) return string.lower(b.name) == string.format("mission_%d_id", i) end)
        self.missions[i].c = table.find(self.buttons, function(b) return string.lower(b.name) == string.format("mission_%d_code", i) end)
        self.missions[i].x = table.find(self.buttons, function(b) return string.lower(b.name) == string.format("mission_%d_gpsx", i) end)
        self.missions[i].y = table.find(self.buttons, function(b) return string.lower(b.name) == string.format("mission_%d_gpsy", i) end)
        self.missions[i].r = table.find(self.buttons, function(b) return string.lower(b.name) == string.format("mission_%d_radius", i) end)
      end
    end

    self.is_check_components = true
  end,
  set_mission_data = function(self)
    if not self.is_headquarter then return end

    for i = 1, 5 do
      local id = 0
      local x = 0
      local y = 0
      local r = 0
      local c = 0

      if g_savedata.missions[i] ~= nil then
        local _x, _y, _z = matrix.position(g_savedata.missions[i].search_center)
        id = g_savedata.missions[i].id
        x = _x
        y = _z
        r = g_savedata.missions[i].search_radius
        c = g_savedata.missions[i].locations[1].case.id
      end

      if self.missions[i].id ~= nil then vehicle.set_keypad(self, self.missions[i].id, id) end
      if self.missions[i].c ~= nil then vehicle.set_keypad(self, self.missions[i].c, c) end
      if self.missions[i].x ~= nil then vehicle.set_keypad(self, self.missions[i].x, x) end
      if self.missions[i].y ~= nil then vehicle.set_keypad(self, self.missions[i].y, y) end
      if self.missions[i].r ~= nil then vehicle.set_keypad(self, self.missions[i].r, r) end
    end
  end,
  set_button = function(self, button, value)
    local data, s = server.getVehicleButton(self.id, button.pos.x, button.pos.y, button.pos.z)

    if s and ((value or data.on) and (not value or not data.on)) then
      vehicle.press_button(self, button)
    end
  end,
  press_button = function(self, button)
    -- server.pressVehicleButton(vehicle_id, 0, 0, 0)
    server.pressVehicleButton(self.id, button.name)
  end,
  set_keypad = function(self, keypad, value)
    server.setVehicleKeypad(self.id, keypad.pos.x, keypad.pos.y, keypad.pos.z, value)
  end,
  refill = function(self)
    if not self.is_refill or not self.is_check_components or not self.is_simulate then return end

    for k, t in ipairs(self.tanks) do
      local fliud_type = string.lower(t.name)

      if fliud_type == nil or fluids[fliud_type] == nil then goto continue end

      server.setVehicleTank(self.id, t.pos.x, t.pos.y, t.pos.z, 0, fluids.air)
      server.setVehicleTank(self.id, t.pos.x, t.pos.y, t.pos.z, 0, fluids.sea_water)
      server.setVehicleTank(self.id, t.pos.x, t.pos.y, t.pos.z, t.capacity, fluids[fliud_type])
      ::continue::
    end

    for k, b in ipairs(self.batteries) do
      server.setVehicleBattery(self.id, b.pos.x, b.pos.y, b.pos.z, 1)
    end
  end,
}


fire = {
  init = function(id, type, name, tags, parent_id, mission_id)
    local self = object.init(id, type, name, tags, parent_id, mission_id)

    self.is_lit = server.getFireData(self.id)

    return self
  end,
  tick = function(self, tick)
    object.tick(self, tick)

    self.is_lit = server.getFireData(self.id)
  end,
}


zone = {
  init = function(id, type, name, tags, parent_id, mission_id, transform, size, parent_relative_transform)
    if string.nil_or_empty(name) and tags.landscape ~= nil then name = tags.landscape end

    local self = object.init(id, type, name, tags, parent_id, mission_id)

    self.transform = transform
    self.size = size
    self.parent_vehicle_id = parent_id
    self.parent_relative_transform = parent_relative_transform
    self.detective_point = self.tags.detective_point
    self.detective_radius = tonumber(self.tags.detective_radius)
    self.flag = self.tags.flag

    return self
  end,
  tick = function(self, tick)
    zone.detect(self)
  end,
  detect = function(self)
    if g_savedata.flags[self.flag] then return end

    local u, ud = character.nearest_unit(self, self.detective_radius)
    local p, pd = character.nearest_player(self, self.detective_radius)

    if u == nil and p == nil then return end

    g_savedata.flags[self.flag] = true

    local x, y, z = matrix.position(self.transform)

    console.notify(string.format("%s is found at %.0f, %.0f, %.0f.", self.detective_point, x, y, z))
  end,
  load = function(tags, filter)
    local zones = {}

    if filter == nil then
      filter = function(z) return true end
    end

    local count_tag = 0
    local count_filter = 0

    for id, z in ipairs(server.getZones(tag.serialize(tags))) do
      z = zone.init(id, "zone", z.name, tag.deserialize(z.tags), z.parent_vehicle_id, nil, z.transform, z.size, z.parent_relative_transform)
      count_tag = count_tag + 1

      if filter(z) then
        table.insert(zones, z)
        count_filter = count_filter + 1
      end
    end

    console.notify(string.format("%d/%d zones matched.", count_filter, count_tag))

    return zones
  end,
  is_in = function(self, transform, range_min, renage_max)
    local distance = matrix.distance(self.transform, transform)
    return distance >= range_min and distance <= renage_max
  end,
  is_occupied = function(self)
    return false
  end,
  contains = function(self, transform)
    return server.isInTransformArea(transform, self.transform, self.size.x, self.size.y, self.size.z)
  end,
  is_contained_objects = function(self, distance)
    local enclosed = false

    for k, o in ipairs(g_savedata.objects) do
      enclosed = enclosed or zone.is_in(self, o.transform, 0, distance)
    end

    return enclosed
  end,
}


object_type = {
  catalogue = {
    vehicle = vehicle,
    character = character,
    fire = fire,
    zone = zone,
  },
  inherit = function(self, base)
    for k, v in pairs(base) do
      if self[k] == nil then
        self[k] = v
      end
    end
  end,
  build = function()
    for k, v in pairs(object_type.catalogue) do
      object_type.inherit(v, object)
    end
  end,
  get = function(type)
    if object_type.catalogue[type] == nil then return object end

    return object_type.catalogue[type]
  end,
}



objective = {
  module = function(self)
    if self.objective_type == nil or objective_type.catalogue[self.objective_type] == nil then return objective end

    return objective_type.get(self.objective_type)
  end,
  init = function(self, ot)
    if ot == nil then return self end

    self.objective_type = ot

    if string.nil_or_empty(self.name) or self.name == self.type then
      self.name = objective.module(self).name
    end

    self.how_to_clear = objective.module(self).how_to_clear
    self.is_finish = false
    self.failed = false
    self.is_active = false
    self.lazy_clear_time = 180

    console.notify(string.format("%s#%d has established as a %s.", self.type, self.id, self.objective_type))

    return self
  end,
  tick = function(self, tick)
    if self.objective_type == nil then return end

    local is_fail = objective.module(self).failed(self)

    if not self.is_finish and objective.module(self).failed(self) then
      server.notify(-1, objective.module(self).label(self), "a objective has failed.", 2)
      self.is_finish = true
      object.module(self).lazy_clear(self, self.lazy_clear_time)
    end

    if not self.is_finish and objective.module(self).completed(self) then
      server.notify(-1, objective.module(self).label(self), "a objective has achieved.", 4)
      mission.add_reward(table.find(g_savedata.missions, function(m) return m.id == self.mission_id end), objective.module(self).reward(self))
      self.is_finish = true
      object.module(self).lazy_clear(self, self.lazy_clear_time)
    end
  end,
  label = function(self)
    return string.format("%sを%s", self.name, self.how_to_clear)
  end,
  progress = function(self)
    if self.objective_type == nil then return nil end

    return {
      type = self.objective_type,
      count = objective.module(self).count(self),
      is_require = objective.module(self).requires(self),
    }
  end,
  count = function(self)
    return 1
  end,
  reward = function(self)
    return 0
  end,
  requires = function(self)
    return true
  end,
  completed = function(self)
    return false
  end,
  failed = function(self)
    return false
  end,
}


rescuee = {
  name = "要救助者",
  how_to_clear = "病院かHQに搬送",
  is_match = function(type, name, tags)
    return type == "character" and tags.tracker == "rescuee"
  end,
  init = function(self, ot)
    self = objective.init(self, ot)
    self.is_disable = false
    self.is_admit_to_headquarter = false
    self.admit_to_headquarter_progress = 0
    self.admit_to_headquarter_threshold = 1800
    self.is_admit_to_hospital = false
    self.admit_to_hospital_progress = 0
    self.admit_to_hospital_threshold = 180
    self.is_code_blue = #framework.players >= g_savedata.subsystems.rescuee.code_blue_required_players and math.random(0, 99) < g_savedata.rescuee.code_blue_probabillity

    if self.vital.hp == 100 then
      local hp = math.random(0, 100)

      if self.tags.hp ~= nil then
        hp = tonumber(self.tags.hp)
      end

      character.update_vital(self, hp)
    end

    server.setCharacterTooltip(self.id, self.name)
    return self
  end,
  tick = function(self, tick)
    local is_done = character.heals(self) or self.vital.dead
    local is_sit_headquarter = is_done and self.vehicle_id > 0 and character.seats_with(self, function(o) return o.type == "character" and o.doctor end)
    local is_stay_hospital = is_done and character.stays(self, { admit_rescuee = "true" }) or character.stays(self, { landscape = "hosital" })

    self.is_admit_to_headquarter, self.admit_to_headquarter_progress = util.progress(is_sit_headquarter, self.admit_to_headquarter_progress, self.admit_to_headquarter_threshold, tick)
    self.is_admit_to_hospital, self.admit_to_hospital_progress = util.progress(is_stay_hospital, self.admit_to_hospital_progress, self.admit_to_hospital_threshold, tick)

    if self.is_simulated and self.is_code_blue then
      character.update_vital(self, self.vital.hp - 2)
    end

    character.signal(self)
    objective.tick(self, tick)

    if self.is_finish and not self.is_disable then
      local is_interactable = self.vehicle_id > 0
      character.update_vital(self, nil, is_interactable, nil)
      self.is_disable = true
    end
  end,
  reward = function(self)
    return 2000
  end,
  completed = function(self)
    return self.is_admit_to_headquarter or self.is_admit_to_hospital
  end,
  failed = function(self) return false end,
}


suspect = {
  name = "被疑者",
  how_to_clear = "警察署かHQに護送",
  is_match = function(type, name, tags)
    return type == "character" and tags.tracker == "suspect"
  end,
  init = function(self, ot)
    self = objective.init(self, ot)
    self.is_disable = false
    self.is_neutralize = false
    self.is_admit_to_headquarter = false
    self.admit_to_headquarter_progress = 0
    self.admit_to_headquarter_threshold = 1800
    self.is_admit_to_police_station = false
    self.admit_to_police_station_progress = 0
    self.admit_to_police_station_threshold = 180
    self.can_change_target = false
    self.fix_target_progress = 0
    self.fix_target_threshold = 900

    local weapon = table.random(weapons)

    server.setCharacterItem(self.id, weapon.slot, weapon.id, false, weapon.ammo, 0)
    server.setAICharacterTeam(self.id, 2)
    server.setAICharacterTargetTeam(self.id, 1, true)
    server.setCharacterTooltip(self.id, self.name)

    return self
  end,
  tick = function(self, tick)
    local is_done = character.heals(self) or self.vital.dead
    local is_sit_headquarter = is_done and self.vehicle_id > 0 and character.seats_with(self, function(o) return o.type == "character" and o.police end)
    local is_stay_police_station = is_done and character.stays(self, { admit_suspect = "true" })

    self.is_admit_to_headquarter, self.admit_to_headquarter_progress = util.progress(is_sit_headquarter, self.admit_to_headquarter_progress, self.admit_to_headquarter_threshold, tick)
    self.is_admit_to_police_station, self.admit_to_police_station_progress = util.progress(is_stay_police_station, self.admit_to_police_station_progress, self.admit_to_police_station_threshold, tick)

    character.invoke_command(self)
    suspect.neutralize(self)
    suspect.act(self, tick)

    if self.is_neutralize then character.signal(self) end

    self.is_active = self.is_active or self.command ~= nil and self.role ~= nil

    objective.tick(self, tick)

    if self.is_finish and not self.is_disable then
      local is_interactable = self.vehicle_id > 0
      character.update_vital(self, nil, is_interactable, nil)
      self.is_disable = true
    end
  end,
  reward = function(self)
    return 4000
  end,
  completed = function(self)
    return self.is_admit_to_headquarter or self.is_admit_to_police_station
  end,
  failed = function(self) return self.vital.dead end,
  neutralize = function(self)
    if self.is_neutralize or not (self.vital.incapacitated or self.vital.dead or self.is_active and self.role ~= nil and self.vehicle_id == 0) then return end

    character.terminate(self)
    server.setAICharacterTargetTeam(self.id, 1, false)
    self.is_neutralize = true
    console.notify(string.format("%s#%d has neutralized.", self.type, self.id))
  end,
  act = function(self, tick)
    if self.is_neutralize then return end

    if self.role == "ship_pilot" and self.command == "attack" then
      self.can_change_target, self.fix_target_progress = util.progress(not self.can_change_target, self.fix_target_progress, self.fix_target_threshold, tick)

      if not self.can_change_target then return end

      local u, ud = character.nearest_unit(self, self.observable_radius)

      if u ~= nil then
        character.clear_route(self)
        character.drive(self, u.transform)
      end
    elseif self.role == "ship_pilot" and self.command == "escape" and #self.paths == 0 then
      character.clear_route(self)
      character.route(self, tile.get_offshore(self.transform, 2000, 4000), "ocean_path")
    elseif self.role == "gunner" and self.command == "attack" then
      self.can_change_target, self.fix_target_progress = util.progress(not self.can_change_target, self.fix_target_progress, self.fix_target_threshold, tick)

      if not self.can_change_target then return end

      local target_type = nil
      local target_id = nil
      local u, ud = character.nearest_unit(self, self.observable_radius)
      local p, pd = character.nearest_player(self, self.observable_radius)

      if u ~= nil then
        target_type = "vehicle"
        target_id = u.id
      end

      if p ~= nil and pd < ud then
        target_type = "character"
        target_id = p.object_id
      end

      if target_type ~= nil and target_type ~= self.target_type and target_id ~= nil and target_id ~= self.target_id then
        character.attack(self, target_id, target_type)
        self.can_change_target = false
        self.fix_target_progress = 0
      end
    elseif self.role == nil and self.command ~= nil then
      local p = character.nearest_player(self, 200)

      if p ~= nil and self.vehicle_id > 0 then
        character.unseat(self)
      elseif p == nil and self.vehicle_id == 0 then
        local v = table.find(g_savedata.objects, function(x) return x.id == self.mount_id end)
        character.seat(self, v, self.seat)
      end
    end
  end,
}


fire_objective = {
  name = "炎",
  how_to_clear = "鎮圧",
  is_match = function(type, name, tags)
    return type == "fire"
  end,
  init = function(self, ot)
    self = objective.init(self, ot)
    self.is_extinguish = false
    self.extinguish_progress = 0
    self.extinguish_threshold = 3600

    return self
  end,
  tick = function(self, tick)
    self.is_active = self.is_active or self.is_lit
    self.is_extinguish, self.extinguish_progress = util.progress(self.is_active and not self.is_lit, self.extinguish_progress, self.extinguish_threshold, tick)

    objective.tick(self, tick)
  end,
  reward = function(self)
    return 1000
  end,
  completed = function(self)
    return self.is_extinguish
  end,
}


wreckage = {
  name = "残骸",
  how_to_clear = "HQに輸送または完全に破壊",
  is_match = function(type, name, tags)
    return type == "vehicle" and tags.tracker == "wreckage"
  end,
  init = function(self, ot)
    self = objective.init(self, ot)
    self.lazy_clear_time = 7200
    self.is_disable = false
    self.is_in_yard = false
    self.is_in_yard_progress = 0
    self.is_in_yard_threshold = 180

    server.setVehicleTooltip(self.id, self.name)
    return self
  end,
  tick = function(self, tick)
    local is_in_yard = table.any(zone.load({ collect_wreckage = "true" }), function(z)
      return zone.contains(z, self.transform)
    end)

    self.is_is_in_yard, self.is_in_yard_progress = util.progress(is_in_yard, self.is_in_yard_progress, self.is_in_yard_threshold, tick)

    objective.tick(self, tick)
  end,
  reward = function(self)
    return 5000
  end,
  completed = function(self)
    return self.is_is_in_yard
  end,
  failed = function(self) return false end,
}


objective_type = {
  catalogue = {
    rescuee = rescuee,
    suspect = suspect,
    fire = fire_objective,
    wreckage = wreckage,
  },
  inherit = function(self, base)
    for k, v in pairs(base) do
      if self[k] == nil then
        self[k] = v
      end
    end
  end,
  build = function()
    for k, v in pairs(objective_type.catalogue) do
      objective_type.inherit(v, objective)
    end
  end,
  get = function(type)
    if objective_type.catalogue[type] == nil then return objective end

    return objective_type.catalogue[type]
  end,
  find = function(type, name, tags)
    return table.find_index(objective_type.catalogue, function(x)
      return x.is_match(type, name, tags)
    end)
  end,
}


location = {
  init = function(id, addon_index, location_index)
    local l = server.getLocationData(addon_index, location_index)
    local setting = table.find(location_catalogue, function(x) return string.match(l.name, x.pattern) ~= nil end)

    if setting == nil then return nil end

    l.id = id
    l.addon_index = addon_index
    l.location_index = location_index
    l.pattern = setting.pattern
    l.type = setting.type
    l.scale = setting.scale
    l.report = setting.report
    l.note = setting.note
    l.case = setting.case
    l.geologic = setting.geologics
    l.search_radius = setting.search_radius or 0
    l.zone_tag_groups = setting.zone_tag_groups or {}
    l.sub_location = nil

    if setting.sub_location ~= nil then
      l.sub_location = {
        patterns = setting.sub_location.patterns or {},
        min = setting.sub_location.min or 0,
        max = setting.sub_location.max or 0,
        dispersal_radius = setting.sub_location.dispersal_radius or 0
      }
    end

    l.sub_mission = nil

    if setting.sub_mission ~= nil then
      l.sub_mission = {
        patterns = setting.sub_mission.patterns or {},
        dispersal_radius = setting.sub_mission.dispersal_radius or 0
      }
    end

    l.components = setting.components or {}
    l.is_historic = setting.is_historic or true
    l.offshore = setting.offshore or false
    l.transform = nil
    l.spawned = false
    l.flag_required_for_spawn = setting.flag_required_for_spawn

    return l
  end,
  load = function(filter)
    if filter == nil then
      filter = function(l) return true end
    end

    local locations = {}
    local addon_index = 0
    local addon_count = server.getAddonCount()

    while addon_index < addon_count do
      local addon_data = server.getAddonData(addon_index)
      addon_data.index = addon_index
      local location_index = 0
      local location_count = addon_data ~= nil and addon_data.location_count or 0

      while location_index < location_count do
        local l = location.init(g_savedata.subsystems.location.count + 1, addon_index, location_index)

        if l ~= nil then
          if filter(l) then
            table.insert(locations, l)
            g_savedata.subsystems.location.count = l.id
          end
        end

        location_index = location_index + 1
      end

      addon_index = addon_index + 1
    end

    return locations
  end,
  construct = function(center, range_min, range_max, filter_location, filter_zone)
    local locations = {}
    local locations_zones = {}

    for k, l in ipairs(location.load(filter_location)) do
      if l == nil then
        goto continue
      end

      if l.tile == "" then
        local zones = {}

        for _, zone_tags in ipairs(l.zone_tag_groups) do
          for _, z in ipairs(zone.load(zone_tags, filter_zone)) do
            table.insert(zones, z)
          end
        end

        if #zones == 0 and not (l.offshore and tile.get_offshore(center, range_min, range_max) ~= nil) then
          goto continue
        end

        if locations_zones[l.addon_index] == nil then
          locations_zones[l.addon_index] = {}
        end

        locations_zones[l.addon_index][l.location_index] = zones
      else
        local transform, s = server.getTileTransform(center, l.tile, range_max)

        if not s then
          goto continue
        end
      end

      table.insert(locations, l)

      ::continue::
    end

    if #locations == 0 then
      return {}
    end

    local location_name = table.random(table.distinct(table.select(locations, function(l) return l.name end)))

    locations = table.find_all(locations, function(l, k) return l.name == location_name end)

    for i = #locations, 1, -1 do
      local zones = {}

      if locations_zones[locations[i].addon_index] ~= nil and locations_zones[locations[i].addon_index][locations[i].location_index] ~= nil then
        zones = locations_zones[locations[i].addon_index][locations[i].location_index]
      end

      location.locate(locations[i], center, range_min, range_max, zones, locations)

      if locations[i].transform == nil then
        console.error(string.format("location %s has nil transform.", locations[i].name))
        table.remove(locations, i)

        goto continue
      end

      local x, y, z = matrix.position(locations[i].transform)
      console.notify(string.format("%s has constructed at %.0f, %.0f, %.0f.", locations[i].name, x, y, z))

      ::continue::
    end

    return locations
  end,
  locate = function(self, center, range_min, range_max, zones, locations)
    if self.tile == "" then
      local landscapes = table.distinct(table.select(zones, function(z) return z.tags.landscape end))

      if self.offshore then
        table.insert(landscapes, "offshore")
      end

      local landscape = table.random(landscapes)

      if landscape == "offshore" then
        self.transform = tile.get_offshore(center, range_min, range_max)
        self.transform = matrix.multiply(self.transform, matrix.translation(math.random() * 1000 - 500, 0, math.random() * 1000 - 500))
      else
        zones = table.find_all(zones, function(z)
          return z.tags.landscape == landscape and table.all(locations, function(l) return l.transform == nil or not zone.is_in(z, l.transform, 0, 100) end)
        end)
        local z = table.random(zones)
        self.transform = z.transform
      end
    else
      self.transform = server.getTileTransform(center, self.tile, range_max)
    end

    if self.transform == nil then
      console.error(string.format("Failed to locate %s.", self.name))
    end
  end,
  spawn = function(self)
    local objects = {}
    local ordered_components = { {}, {}, {}, {} }

    for k, c in ipairs(component.load(self)) do
      if c.type == "vehicle" then
        table.insert(ordered_components[1], c)
      elseif c.type == "character" then
        table.insert(ordered_components[2], c)
      elseif c.type == "fire" then
        table.insert(ordered_components[3], c)
      else
        table.insert(ordered_components[4], c)
      end
    end

    for type, components in ipairs(ordered_components) do
      if self[type] then
        table.shuffle(components)
        local threshold = math.floor(#components * math.random(self[type].min, self[type].max) * 0.01)
        local i = #components

        while i > threshold do
          table.remove(components, i)
          i = i - 1
        end
      end

      for k, c in ipairs(components) do
        local o = component.spawn(c, self.transform, objects)

        table.insert(objects, o)
      end
    end

    self.spawned = true

    return objects
  end,
}


component = {
  is_spawing = false,
  init = function(addon_index, location_index, component_index, location_id)
    local c, s = server.getLocationComponentData(addon_index, location_index, component_index)

    if not s then
      return nil
    end

    c.addon_index = addon_index
    c.location_index = location_index
    c.component_index = component_index
    c.location_id = location_id

    return c
  end,
  load = function(l)
    local component_index = 0
    local components = {}

    while component_index < l.component_count do
      local c = component.init(l.addon_index, l.location_index, component_index, l.id)

      if c == nil then goto continue end

      table.insert(components, c)

      ::continue::

      component_index = component_index + 1
    end

    return components
  end,
  spawn = function(self, transform, sibling_objects)
    local transform = matrix.multiply(transform, self.transform)
    local parent_id = nil

    if self.vehicle_parent_component_id > 0 then
      parent = table.find(sibling_objects, function(o)
        return o.component_id == self.vehicle_parent_component_id
      end)

      if parent ~= nil then
        parent_id = parent.id
      end
    end

    component.is_spawing = true
    local o, s = server.spawnAddonComponent(transform, self.addon_index, self.location_index, self.component_index, parent_id)
    component.is_spawing = false

    if not s then
      console.error(string.format("failed to spawn component#%d.#%d.#%d.", self.addon_index, self.location_index, self.component_index))
      return
    end

    o.tags = tag.deserialize(o.tags)
    o.component_id = self.id
    o.parent_id = parent_id
    o.mount_id = nil

    if o.tags.mount ~= nil then
      local mount_component_id = tonumber(o.tags.mount)
      local mount_component = table.find(sibling_objects, function(x)
        return x.component_id == mount_component_id
      end)

      if mount_component ~= nil then
        o.mount_id = mount_component.id
      end
    end

    return o
  end,
}


player = {
  init = function(p)
    if p.id == 0 and p.name == "Server" then
      return nil
    end

    p.object_id, found_player_character = server.getPlayerCharacterID(p.id)

    if not found_player_character then return nil end

    p.steam_id = tostring(p.steam_id)
    p.transform = server.getObjectPos(p.object_id)
    p.vehicle_id = server.getCharacterVehicle(p.object_id)
    p.vital = server.getObjectData(p.object_id)

    return p
  end,
  load = function()
    local players = {}

    for _, p in ipairs(server.getPlayers()) do
      local p = player.init(p)

      if p ~= nil then
        table.insert(players, p)
      end
    end

    return players
  end,
}


money = {
  transact = function(amount, message)
    local inf = server.getGameSettings().infinite_money
    if amount == 0 then
      return true
    end

    local money = server.getCurrency() + amount

    if not inf and money < 0 then
      server.notify(-1, "Payment failed.", "There is not enough money in your account.", 2)
      return false
    end

    local not_type = 4
    local title = string.format("Accepted $%d.", amount)

    if amount < 0 then
      not_type = 2
      text = string.format("Paid out $%d.", math.abs(amount))
    end

    server.setCurrency(money)
    server.notify(-1, title, message, not_type)

    return true
  end,
}


ui = {
  init = function(position_type, marker_type, vehicle_id, object_id)
    return {
      id = server.getMapID(),
      position_type = position_type,
      marker_type = marker_type,
      vehicle_id = vehicle_id,
      object_id = object_id,
    }
  end,
  map = function(self, p, transform, radius, label, label_hover, parent_type, parent_id)
    local vehicle_id = nil
    local object_id = nil
    local position_type = 0
    local x, y, z = matrix.position(transform)

    if parent_type == "vehicle" then
      vehicle_id = parent_id
      position_type = 1
    elseif parent_type == "object" then
      object_id = parent_id
      position_type = 2
    end

    server.addMapObject(p.id, self.ui_id, position_type, self.marker_type, x, z, 0, 0, vehicle_id, object_id, label, radius, label_hover, self.marker_color[1], self.marker_color[2], self.marker_color[3], self.marker_color[4])
  end,
  unmap = function(self, p)
    server.removeMapID(p.id, self.ui_id)
  end,
}


history = {
  record = function(l)
    if not l.is_historic then return end

    table.insert(g_savedata.subsystems.mission.history, l.name)
  end,
  clear_all = function()
    g_savedata.subsystems.mission.history = {}
  end,
  is_recorded = function(l, length)
    if not l.is_historic then return false end

    local mission_history = table.take(g_savedata.subsystems.mission.history, 1, length)

    return table.any(mission_history, function(name) return name == l.name end)
  end,
}


tile = {
  get_start = function()
    local start_tile = server.getStartTile()
    return matrix.translation(start_tile.x, start_tile.y, start_tile.z)
  end,
  get_offshore = function(center, range_min, range_max)
    local transform, s = server.getOceanTransform(center, range_min, range_max)

    if not s then return nil end

    return transform
  end,
}

path = {
  find = function(start, goal, required_tags, avoided_tags)
    local paths = {}

    for k, p in ipairs(server.pathfind(start, goal, required_tags, avoided_tags)) do
      table.insert(paths, matrix.translation(p.x, 0, p.z))
    end

    return paths
  end,
}


tag = {
  serialize = function(tags)
    local texts = {}

    for key, value in pairs(tags) do
      local key_type = type(key)
      local value_type = type(value)

      if value_type == "table" then
        value = table.concat(value, ";")
      end

      local t = ""

      if key_type == "string" then
        t = key .. "=" .. value
      else
        t = value
      end

      table.insert(texts, t)
    end

    return table.concat(texts, ",")
  end,
  deserialize = function(tags)
    -- local tags = {}

    -- for k, v in string.gmatch(text, "([%w_]+)=([^%s%c,]+)") do
    --   tags[k] = v
    -- end

    -- return tags

    local deserialized_tags = {}

    for key, value in ipairs(tags) do
      local value, encoded_key = tag.encode(value)

      if encoded_key == nil then
        encoded_key = key
      end

      deserialized_tags[encoded_key] = value
    end

    return deserialized_tags
  end,
  encode = function(text)
    local key, value = tag.key_value(text)

    if key == nil then
      value = text
    end

    if string.find(text, ";", 1, true) ~= nil then
      value = tag.separate_semiclron(value)
    end

    return value, key
  end,
  key_value = function(text)
    return string.match(text, "^([%w_]+)=(.+)$")
  end,
  separate_semiclron = function(text)
    return string.split(text, ";")
  end,
  match = function(self, key, pattern)
    return string.match(self, "^" .. key .. "=" .. pattern .. "$") ~= nil
  end,
}


util = {
  progress = function(executes, duration, threshold, increment)
    local result = false

    if executes then
      duration = duration + increment
      result = duration >= threshold
    elseif duration > 0 then
      duration = 0
    end

    return result, duration
  end
}


console = {
  log = function(text, peer_id)
    peer_id = peer_id or -1

    server.announce("[LOG]", text, peer_id)
  end,
  notify = function(text, peer_id)
    peer_id = peer_id or -1

    if g_savedata.mode == "debug" then
      server.announce("[NOTICE]", text, peer_id)
    end
  end,
  error = function(text, peer_id)
    peer_id = peer_id or -1

    server.announce("[ERROR]", text, peer_id)
  end
}


string.split        = function(s, separator)
  local t = {}

  for part in string.gmatch(s, "([^" .. separator .. "]+)") do
    table.insert(t, part)
  end

  return t
end

string.nil_or_empty = function(s)
  return s == nil or s == ""
end

table.aggregate     = function(t, result, func)
  for k, v in pairs(t) do
    result = func(result, v)
  end

  return result
end


table.any        = function(t, test)
  local any = false

  for i = 1, #t do
    any = any or test(t[i], i)
  end

  return any
end

table.all        = function(t, test)
  local all = true

  for i = 1, #t do
    all = all and test(t[i], i)
  end

  return all
end

table.contains   = function(t, x)
  local contains = false

  for i = 1, #t do
    contains = contains or t[i] == x
  end

  return contains
end

table.find_index = function(t, test)
  for k, v in pairs(t) do
    if test(v, k) then
      return k
    end
  end

  return nil
end

table.find       = function(t, test)
  for k, v in pairs(t) do
    if test(v, k) then
      return v
    end
  end

  -- for i = 1, #t do
  --   if test == nil or test(t[i], i) then
  --     return t[i], i
  --   end
  -- end

  return nil
end

table.find_all   = function(t, test)
  local items = {}

  for i = 1, #t do
    if test(t[i], i) then
      table.insert(items, t[i])
    end
  end

  return items
end

table.for_each   = function(t, action)
  for i = 1, #t do
    action(t[i], i)
  end
end

table.has        = function(t, x)
  for i = 1, #t do
    if t[i] == x then
      return true
    end
  end

  return false
end

table.intersect  = function(m, n)
  local r = {}

  for i = 1, #m do
    for j = 1, #n do
      if n[j] == m[i] then
        table.insert(r, m[i])
      end
    end
  end

  return r
end

table.keys       = function(t)
  local items = {}

  for k, v in pairs(t) do
    table.insert(items, k)
  end

  return items
end

table.random     = function(t)
  if #t == 0 then
    return nil
  end

  return t[math.random(1, #t)]
end

table.select     = function(t, selector)
  local items = {}

  for i = 1, #t do
    local value = selector(t[i], i)

    if value ~= nil then
      table.insert(items, value)
    end
  end

  return items
end

table.where      = function(t, selector)
  local items = {}

  for i = 1, #t do
    if selector(t[i], i) then
      table.insert(items, t[i])
    end
  end

  return items
end

table.copy       = function(t)
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

table.distinct   = function(t)
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

table.join       = function(t1, t2)
  for k, v in pairs(t2) do
    if t1[k] == nil then
      t1[k] = v
    end
  end
end

table.shuffle    = function(x)
  for i = #x, 2, -1 do
    local j = math.random(i)
    x[i], x[j] = x[j], x[i]
  end
end

table.take       = function(t, start, length)
  local u = {}

  if start == nil then start = 1 end
  if length == nil then length = #t end

  local i = 0

  while i < length do
    table.insert(u, t[start + i])
    i = i + 1
  end

  return u
end


onCreate         = framework.on_create
onTick           = framework.on_tick
onCustomCommand  = framework.on_custom_command
onGroupSpawn     = framework.on_group_spawn
onVehicleDespawn = framework.on_vehicle_despawn
onPlayerJoin     = framework.on_player_join
framework.on_load()
