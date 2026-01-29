g_savedata = {
  mode = "debug",
  clock = 0,
  missions = {},
  objects = {},
  subsystems = {
    mission = {
      tickrate = 0,
      count = 0,
      center = matrix.identity(),
      dispersal_min = property.slider("Minimum range in which new missions occur (km)", 0, 10, 1, 1) * 1000,
      dispersal_max = property.slider("Maximum range in which new missions occur (km)", 1, 100, 1, 6) * 1000,
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
  meduim = 4,
  massive = 8,
}


location_catalogue = { {
  pattern = "^mission:climber_missing_%d+$",
  type = "sar",
  report = "悪天候により登山客の集団遭難が発生した. このエリアを捜索し行方不明者を全員救出せよ.",
  note = "警察署からの通報",
  scale = scales.massive,
  geologic = geologics.mainlands,
  case = cases.sar,
  dispersal_area = 1000,
  zone_tag_groups = {
    { landscape = "forest" },
    { landscape = "mountain" },
  },
  sub_location = {
    patterns = { "^mission:climber_missing_%d+$" },
    min = 2,
    max = 3,
  },
}, {
  pattern = "^mission:freighter_fire_%d+$",
  type = "sar",
  report = "船内で突然何かが爆発した! もう助からないぞ!",
  note = "乗員からの通報",
  scale = scales.massive,
  geologic = geologics.waters,
  case = cases.mayday,
  dispersal_area = 1000,
  offshore = true,
  zone_tag_groups = {
    { landscape = "channel" },
  },
  sub_location = {
    patterns = {},
    min = 0,
    max = 0,
  },
}, }


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

    framework.register_command("?mission", "?m", "version", nil, framework.print_version, function(full_message, peer_id, is_admin, is_auth, subject, verb) return is_admin end)
    framework.register_command("?mission", "?m", "all-commands", nil, framework.print_all_commands, function(full_message, peer_id, is_admin, is_auth, subject, verb) return is_admin end)
    framework.register_command("?mission", "?m", "set", "[name] [value]", framework.update, function(full_message, peer_id, is_admin, is_auth, subject, verb, name, value) return is_admin, name, value end)
    framework.register_command("?mission", "?m", "init", "[pattern] [dispersal_max]", mission.load_pattern,
      function(full_message, peer_id, is_admin, is_auth, subject, verb, pattern, dispersal_max)
        dispersal_max = tonumber(dispersal_max)

        if dispersal_max == nil then
          dispersal_max = g_savedata.subsystems.mission.dispersal_max
        end

        return is_admin, pattern, g_savedata.subsystems.mission.center, g_savedata.subsystems.mission.dispersal_min, dispersal_max
      end)
    framework.register_command("?mission", "?m", "clear-all", nil, mission.clear_all, function(full_message, peer_id, is_admin, is_auth, subject, verb) return is_admin end)
    framework.register_command("?mission", "?m", "gather", "[mission id]", function(peer_id, mission_id)
      local transform = server.getPlayerPos(peer_id)

      for k, o in pairs(g_savedata.objects) do
        if o.mission_id == mission_id and object.module(o).is_character(o) then
          server.setObjectPos(o.id, transform)
        end
      end
    end, function(full_message, peer_id, is_admin, is_auth, subject, verb, mission_id) return is_admin, peer_id, tonumber(mission_id) end)
  end,
  on_create = function(is_world_create)
    if is_world_create then
      g_savedata.subsystems.mission.center = tile.get_start()
    end

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
      if m.is_clear then
        mission.unmap(m, framework.players)
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
    local command = table.find(framework.commands, function(x) return (x.subject == args[5] or x.shorthand == args[5]) and x.verb == args[6] end)

    if command == nil then
      return
    end

    framework.invoke_command(command, command.guard(table.unpack(args)))
  end,
  on_player_join = function(steam_id, name, peer_id, is_admin, is_auth)
    steam_id = tostring(steam_id)
    local players = table.find_all(framework.players, function(p) return p.steam_id == steam_id end)
    framework.map(players)
  end,
  register_command = function(subject, shorthand, verb, args, execute, guard)
    if cuard == nil then
      cuard = function() end
    end

    table.insert(framework.commands, {
      subject = subject,
      shorthand = shorthand,
      verb = verb,
      args = args,
      execute = execute,
      guard = guard,
    })
  end,
  print_all_commands = function()
    for _, command in pairs(framework.commands) do
      local text = string.format("%s %s", command.subject, command.verb)

      if command.args ~= nil then
        text = text .. " " .. command.args
      end

      console.log(text)
    end
  end,
  print_version = function()
    console.log(string.format("%s %s", framework.name, framework.version))
  end,
  update = function(name, value)
    if name == "range-min" then
      value = tonumber(value)

      if value == nil then return end

      g_savedata.subsystems.mission.range_min = value
    elseif name == "range-max" then
      value = tonumber(value)

      if value == nil then return end

      g_savedata.subsystems.mission.range_max = value
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
    for k, o in pairs(g_savedata.objects) do
      object.module(o).map(o, players)
    end
  end,
}


mission_type = {
  catalogue = {
    sarod = {}, -- search and rescue or destroy
    disaster = {},
    transport = {},
  },
}

mission = {
  init = function(id, locations)
    local self = {}

    self.id = id
    self.locations = locations
    self.is_activate = true
    self.is_clear = false
    self.is_report = false
    self.elapsed_time = 0
    self.finish_time = 0
    self.reward = 0
    self.objectives = {}
    self.sorted_objectives = {}
    self.required_objectives_count = 0
    self.ui_id = server.getMapID()
    self.marker_type = 8
    self.marker_color = { 255, 255, 0, 255 }
    self.search_center = matrix.multiply(self.locations[1].transform, matrix.translation(math.random() * 500, 0, math.random() * 500))
    self.search_radius = mission.compute_search_radius(self)

    console.notify(string.format("mission#%d has occurred.", self.id))
    server.notify(-1, mission.label(self), "a mission has occured.", 0)

    return self
  end,
  clear = function(self)
    mission.despawn(self)

    self.is_clear = true
    server.notify(-1, mission.label(self), "a mission has cleared.", 4)
    console.notify(string.format("mission#%d has cleared.", self.id))
  end,
  clear_all = function()
    for i = #g_savedata.missions, 1, -1 do
      mission.clear(g_savedata.missions[i])
    end
  end,
  tick = function(self, tick)
    self.objectives = table.select(table.find_all(g_savedata.objects, function(o) return o.mission_id == self.id and o.objective_type ~= nil end), function(o) return objective.module(o).progress(o) end)
    self.sorted_objectives = mission.aggregate_objectives(self, self.objectives)

    if self.is_activate and #self.objectives == 0 then
      mission.clear(self)
    end

    self.elapsed_time = self.elapsed_time + tick
  end,
  aggregate_objectives = function(self, objectives)
    local sorted_objectives = {}

    for k, v in pairs(objective_type.catalogue) do
      sorted_objectives[k] = {
        count = 0,
        text = objective.module(v).label(v),
      }
    end

    for k, o in pairs(objectives) do
      sorted_objectives[o.type].count = sorted_objectives[o.type].count + o.count
    end

    return sorted_objectives
  end,
  compute_search_radius = function(self)
    if self.locations[1].no_search_radius then return 0 end

    local search_radius = self.locations[1].dispersal_area

    for k, o in pairs(g_savedata.objects) do
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

    if self.required_objectives_count > 0 then
      text = text .. "\n\n[目標]"

      for k, ov in pairs(self.objectives) do
        text = text .. string.format("\n%d %s", ov.count, ov.text)
      end
    end

    if self.search_radius > 0 then text = text .. string.format("\n\n[範囲]\n%.1fkm", self.search_radius / 1000) end

    if self.finish_time > 0 then text = text .. string.format("\n\n[残り時間]\n%d分", math.ceil((self.finish_time - self.elapsed_time) / 3600)) end

    return text
  end,
  spawn = function(mission_id, locations)
    for _, l in pairs(locations) do
      local objects = location.spawn(l)

      for _, o in pairs(objects) do
        local tags = tag.deserialize(o.tags_full)
        local ot = objective_type.find(o.type, o.name, tags)

        if o.type == "vehicle" then
          for _, vehicle_id in pairs(o.vehicle_ids) do
            o = vehicle.init(vehicle_id, o.type, o.name, tags, o.object_id, o.parent_id, mission_id)
            o = objective_type.get(ot).init(o, ot)
            table.insert(g_savedata.objects, o)
          end
        else
          o = object.module(o).init(o.id, o.type, o.name, tags, o.parent_id, mission_id)
          o = objective_type.get(ot).init(o, ot)
          table.insert(g_savedata.objects, o)
        end
      end
    end
  end,
  despawn = function(self)
    for k, o in pairs(g_savedata.objects) do
      if o.mission_id == self.id then
        object.module(o).clear(o)
      end
    end
  end,
  map = function(self, players)
    for k, p in pairs(players) do
      ui.map(self, p, self.search_center, self.search_radius, mission.label(self), mission.detail(self))
    end
  end,
  unmap = function(self, players)
    for k, p in pairs(players) do
      ui.unmap(self, p)
    end
  end,
  load = function(center, range_min, range_max, filter_location, filter_zone)
    local locations = location.construct(center, range_min, range_max, filter_location, filter_zone)

    if #locations == 0 then return end

    local sub_locations_count = math.random(locations[1].sub_location.min, locations[1].sub_location.max)

    for i = 1, sub_locations_count do
      for k, v in pairs(location.construct(locations[1].transform, 0, locations[1].dispersal_area, function(l)
          return table.aggregate(locations[1].sub_location.patterns, false, function(result, x) return result or string.match(l.name, x) end)
        end,
        function(z)
          return zone.is_in(z, locations[1].transform, 0, locations[1].dispersal_area) and
              not zone.is_contained_objects(z) and
              not table.any(g_savedata.missions, function(m) return mission.contains(m, z.transform) end)
        end)) do
        table.insert(locations, v)
      end
    end

    local mission_id = g_savedata.subsystems.mission.count + 1
    mission.spawn(mission_id, locations)
    local m = mission.init(mission_id, locations)

    if m == nil then return nil end

    table.insert(g_savedata.missions, m)
    history.record(locations[1])
    g_savedata.subsystems.mission.count = m.id
    -- server.setPlayerPos(0, m.locations[1].transform)
  end,
  load_random = function(geologic, scale, case, center, range_min, range_max) end,
  load_pattern = function(pattern, center, range_min, range_max)
    if pattern == nil then return end

    pattern = "^" .. pattern .. "$"

    mission.load(center, range_min, range_max,
      function(l)
        return string.match(l.name, pattern) ~= nil
      end,
      function(z)
        return zone.is_in(z, g_savedata.subsystems.mission.center, g_savedata.subsystems.mission.dispersal_min, g_savedata.subsystems.mission.dispersal_max) and
            not zone.is_contained_objects(z) and
            not table.any(g_savedata.missions, function(m) return mission.contains(m, z.transform) end)
      end)
  end,
  contains = function(self, transform)
    local distance = matrix.distance(self.locations[1].transform, transform)

    return distance <= self.locations[1].dispersal_area
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
    self.is_simulate = object.simulating(self)
    self.transform = object.get_transform(self)
    self.elapsed_time = 0
    self.ui_id = server.getMapID()
    self.marker_type = 2

    if object.marker_type[self.type] ~= nil then
      self.marker_type = object.marker_type[self.type]
    end

    self.marker_color = { 128, 128, 128, 255 }

    console.notify(string.format("%s#%d has initialized.", self.type, self.id))

    return self
  end,
  clear = function(self)
    object.despawn(self)
    self.is_clear = true
    console.notify(string.format("%s#%d has cleared.", self.type, self.id))
  end,
  lazy_clear = function(self, clear_time)
    self.clear_time = clear_time
  end,
  despawn = function(self)
    if object.module(self).is_vehicle(self) then
      server.despawnVehicle(self.id, true)
    elseif object.module(self).is_object(self) then
      server.despawnObject(self.id, true)
    end
  end,
  tick = function(self, tick)
    self.transform = object.module(self).get_transform(self)
    self.is_simulate = object.module(self).simulating(self)
    self.elapsed_time = self.elapsed_time + 1

    if self.clear_time ~= nil then
      self.clear_time = self.clear_time - tick

      if self.clear_time ~= nil and self.clear_time <= 0 then
        object.module(self).clear(self)
      end
    end
  end,
  get_transform = function(self)
    if object.module(self).is_vehicle(self) then
      return server.getVehiclePos(self.id)
    elseif object.module(self).is_object(self) then
      return server.getObjectPos(self.id)
    elseif self.transform ~= nil then
      return self.transform
    else
      return nil
    end
  end,
  simulating = function(self)
    if object.module(self).is_vehicle(self) then
      return server.getVehicleSimulating(self.id)
    elseif object.module(self).is_object(self) then
      return server.getObjectSimulating(self.id)
    end
  end,
  label = function(self)
    return string.format("%s#%d", self.name, self.id)
  end,
  detail = function(self)
    return string.format("mission#%d", self.mission_id or "nil")
  end,
  map = function(self, players)
    if self.transform == nil then return end

    local id = nil
    local type = nil

    if object.module(self).is_vehicle(self) then
      id = self.id
      type = "vehicle"
    elseif object.module(self).is_object(self) then
      id = self.id
      type = "object"
    end

    for k, p in pairs(players) do
      if g_savedata.mode == "debug" and p.admin then
        ui.map(self, p, self.transform, 0, object.label(self), object.detail(self), type, id)
      end
    end
  end,
  unmap = function(self, players)
    for k, p in pairs(players) do
      ui.unmap(self, p)
    end
  end,
  is_vehicle = function(self)
    return self.type == "vehicle"
  end,
  is_character = function(self)
    return self.type == "character"
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
  init = function(id, type, name, tags, parent_id, mission_id)
    local self = object.init(id, type, name, tags, parent_id, mission_id)
    self.vital = server.getObjectData(self.id)

    return self
  end,
  tick = function(self, tick)
    object.tick(self, tick)
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
}


vehicle = {
  init = function(id, type, name, tags, group_id, parent_id, mission_id)
    local self = object.init(id, type, name, tags, parent_id, mission_id)

    self.group_id = group_id
    self.damages = {}

    return self
  end,
  tick = function(self, tick)
    object.tick(self, tick)
    -- object.aggregate_damages(self)
    -- object.check_components(self)
  end,
}


object_type = {
  catalogue = {
    vehicle = vehicle,
    character = character,
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
    self.is_complete = false
    self.failed = false

    console.notify(string.format("%s#%d has established as a %s.", self.type, self.id, self.objective_type))

    return self
  end,
  tick = function(self, tick)
    if self.objective_type == nil then return end

    self.failed = self.failed or objective.module(self).failed(self)
    local is_complete = self.is_complete or objective.module(self).completed(self)

    if is_complete and not self.is_complete then
      server.notify(-1, objective.module(self).label(self), "a objective has achieved.", 4)
      self.is_complete = is_complete
      object.module(self).lazy_clear(self, 180)
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
      requires = objective.module(self).requires(self),
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
    return self.objective_type == nil
  end,
  failed = function(self)
    return false
  end,
}


rescuee = {
  name = "要救助者",
  how_to_clear = "治療して病院かHQに搬送",
  is_match = function(type, name, tags)
    return type == "character" and tags.tracker == "rescuee"
  end,
  init = function(self, ot)
    self = objective.init(self, ot)
    self.is_disable = false
    self.is_admit_to_headquarter = false
    self.admit_to_headquarter_duration = 0
    self.admit_to_headquarter_threshold = 1800
    self.is_admit_to_hospital = false
    self.admit_to_hospital_duration = 0
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
    local is_heal = character.heals(self)
    local is_sit_headquarter = is_heal and character.sits(self, true)
    local is_stay_hospital = is_heal and character.stays(self, { admit_rescuee = "true" })

    self.is_admit_to_headquarter, self.admit_to_headquarter_duration = util.progress(is_sit_headquarter, self.admit_to_headquarter_duration, self.admit_to_headquarter_threshold, tick)
    self.is_admit_to_hospital, self.admit_to_hospital_duration = util.progress(is_stay_hospital, self.admit_to_hospital_duration, self.admit_to_hospital_threshold, tick)

    if self.is_code_blue then
      character.update_vital(self, self.vital.hp - 2)
    end

    objective.tick(self, tick)

    if self.is_complete and not self.is_disable then
      character.update_vital(self, self.vital.hp, false, false)
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


objective_type = {
  catalogue = {
    rescuee = rescuee
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
    l.dispersal_area = setting.dispersal_area
    l.zone_tag_groups = setting.zone_tag_groups or {}
    l.sub_location = setting.sub_location or {
      patterns = {},
      min = 0,
      max = 0,
    }
    l.components = setting.components or {}
    l.is_historic = setting.is_historic or true
    l.offshore = setting.offshore or false
    l.transform = nil
    l.spawned = false
    l.no_search_radius = setting.no_search_radius or false

    return l
  end,
  load = function(filter)
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

    if filter_location == nil then
      filter_location = function(l) return true end
    end

    if filter_zone == nil then
      filter_zone = function(z) return true end
    end

    for k, l in pairs(location.load(filter_location)) do
      if l == nil then
        goto continue
      end

      local zones = {}

      for _, zone_tags in pairs(l.zone_tag_groups) do
        for _, z in pairs(zone.load(zone_tags, filter_zone)) do
          table.insert(zones, z)
        end
      end

      local is_available_offshore_tile = tile.get_offshore(center, range_min, range_max) ~= nil

      if #zones == 0 and not (l.offshore and is_available_offshore_tile) then goto continue end

      table.insert(locations, l)

      if locations_zones[l.addon_index] == nil then
        locations_zones[l.addon_index] = {}
      end

      locations_zones[l.addon_index][l.location_index] = zones

      ::continue::
    end

    local location_name = table.random(table.distinct(table.select(locations, function(l) return l.name end)))

    locations = table.find_all(locations, function(l, k) return l.name == location_name end)

    for i = #locations, 1, -1 do
      location.locate(locations[i], center, range_min, range_max, locations_zones[locations[i].addon_index][locations[i].location_index], locations)

      if locations[i].transform == nil then
        console.error(string.format("location %s transform is nil.", locations[i].name))
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

    if self.transform == nil then
      console.error(string.format("Failed to locate %s.", self.name))
    end
  end,
  spawn = function(self)
    local objects = {}
    local ordered_components = { vehicles = {}, characters = {}, fires = {}, others = {} }

    for k, c in pairs(component.load(self)) do
      if c.type == "vehicle" then
        table.insert(ordered_components.vehicles, c)
      elseif c.type == "character" then
        table.insert(ordered_components.characters, c)
      elseif c.type == "fire" then
        table.insert(ordered_components.fires, c)
      else
        table.insert(ordered_components.others, c)
      end
    end

    for type, components in pairs(ordered_components) do
      if self.components[type] then
        table.shuffle(components)
        local threshold = math.floor(#components * math.random(self.components[type].min, self.components[type].max) * 0.01)
        local i = #components

        while i > threshold do
          table.remove(components, i)
          i = i - 1
        end
      end

      for k, c in pairs(components) do
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
  spawn = function(self, transform, siblings)
    local transform = matrix.multiply(transform, self.transform)
    local parent_id = nil

    if self.vehicle_parent_component_id > 0 then
      parent = table.find(siblings, function(o)
        return o.component_id == self.vehicle_parent_component_id
      end)

      if parent ~= nil then
        parent_id = parent.id
      end
    end

    self.is_spawing = true
    local o, s = server.spawnAddonComponent(transform, self.addon_index, self.location_index, self.component_index, parent_id)
    self.is_spawing = false

    if not s then
      console.error(string.format("failed to spawn component#%d.#%d.#%d.", self.addon_index, self.location_index, self.component_index))
      return
    end

    o.component_id = self.id
    o.parent_id = parent_id

    return o
  end,
}


zone = {
  init = function(z)
    z.tags = tag.deserialize(z.tags_full)

    return z
  end,
  load = function(tags, filter)
    local zones = {}

    if filter == nil then
      filter = function(z) return true end
    end

    for _, z in pairs(server.getZones(tag.serialize(tags))) do
      z = zone.init(z)

      if filter(z) then
        table.insert(zones, z)
      end
    end

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
  is_contained_objects = function(self)
    local enclosed = false

    for k, o in pairs(g_savedata.objects) do
      enclosed = enclosed or zone.is_in(self, o.transform, 0, 100)
    end

    return enclosed
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

    for _, p in pairs(server.getPlayers()) do
      local p = player.init(p)

      if p ~= nil then
        table.insert(players, p)
      end
    end

    return players
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

    server.removeMapID(p.id, self.ui_id)
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


tag = {
  serialize = function(tags)
    local texts = {}

    for k, v in pairs(tags) do
      table.insert(texts, k .. "=" .. v)
    end

    return table.concat(texts, ",")
  end,
  deserialize = function(text)
    local tags = {}

    for k, v in string.gmatch(text, "([%w_]+)=([^%s%c,]+)") do
      tags[k] = v
    end

    return tags
  end,
  key_value = function(text)
    return string.gmatch(text, "^([%w_]+)=(.+)$")
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


onCreate        = framework.on_create
onTick          = framework.on_tick
onCustomCommand = framework.on_custom_command
framework.on_load()
