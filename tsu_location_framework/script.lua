g_savedata = {
  mode = "debug",
  subsystems = {
    zone = {
      ui_id = nil,
    },
  },
  objects = {},
  locations = {},
  object_count = 0,
  location_count = 0,
}


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


fluid_prices = {
  fresh_water = {
    consumer = 0,
    provider = 0,
  },
  diesel = {
    consumer = 3,
    provider = 2,
  },
  jet = {
    consumer = 6,
    provider = 5,
  },
  air = {
    consumer = 0,
    provider = 0,
  },
  exhaust = {
    consumer = 0,
    provider = 0,
  },
  oil = {
    consumer = 2,
    provider = 1,
  },
  sea_water = {
    consumer = 0,
    provider = 0,
  },
  steam = {
    consumer = 0,
    provider = 0,
  },
  slurry = {
    consumer = 0,
    provider = 0,
  },
  saturated_slurry = {
    consumer = 0,
    provider = 0,
  },
  oxygen = {
    consumer = 0,
    provider = 0,
  },
  nitrogen = {
    consumer = 0,
    provider = 0,
  },
  hydrogen = {
    consumer = 0,
    provider = 0,
  },
}


metals = {
  coal = 0,
  iron = 1,
  aluminium = 2,
  gold = 3,
  gold_dirt = 4,
  uranium = 5,
  ingot_iron = 6,
  ingot_steel = 7,
  ingot_aluminium = 8,
  ingot_gold_impure = 9,
  ingot_gold = 10,
  ingot_uranium = 11,
  solid_propellant = 12,
}


metal_prices = {
  coal = {
    consumer = 1,
    provider = 0.5,
  },
  iron = {
    consumer = 0,
    provider = 0,
  },
  aluminium = {
    consumer = 0,
    provider = 0,
  },
  gold = {
    consumer = 0,
    provider = 0,
  },
  gold_dirt = {
    consumer = 0,
    provider = 0,
  },
  uranium = {
    consumer = 0,
    provider = 0,
  },
  ingot_iron = {
    consumer = 0,
    provider = 0,
  },
  ingot_steel = {
    consumer = 150,
    provider = 145,
  },
  ingot_aluminium = {
    consumer = 85,
    provider = 80,
  },
  ingot_gold_impure = {
    consumer = 150,
    provider = 145,
  },
  ingot_gold = {
    consumer = 2000,
    provider = 1995,
  },
  ingot_uranium = {
    consumer = 1500,
    provider = 1450,
  },
  solid_propellant = {
    consumer = 100,
    provider = 90,
  },
}


cargo_types = {
  consumes = "consumes",
  chemicals = "chemicals",
  coal = "coal",
  food = "food",
  fuel = "fuel",
  ore = "ore",
  parcel = "parcel",
  plunk = "plunk",
  spare_parts = "spare_parts",
  steel = "steel",
  wood = "wood",
}


cargo_categories = {
  all = {
    cargo_types.consumes,
    cargo_types.chemicals,
    cargo_types.coal,
    cargo_types.food,
    cargo_types.fuel,
    cargo_types.ore,
    cargo_types.parcel,
    cargo_types.plunk,
    cargo_types.spare_parts,
    cargo_types.steel,
    cargo_types.wood,
  },
}


cargoes = {
  [cargo_types.consumes] = {
    name = "Consumes",
  },
  [cargo_types.chemicals] = {
    name = "Chemicals",
  },
  [cargo_types.coal] = {
    name = "Coal",
  },
  [cargo_types.food] = {
    name = "Food",
  },
  [cargo_types.fuel] = {
    name = "Fuel",
  },
  [cargo_types.ore] = {
    name = "Ore",
  },
  [cargo_types.parcel] = {
    name = "Parcel",
  },
  [cargo_types.plunk] = {
    name = "Plunk",
  },
  [cargo_types.spare_parts] = {
    name = "Spare Parts",
  },
  [cargo_types.steel] = {
    name = "Steel",
  },
  [cargo_types.wood] = {
    name = "Wood",
  },
}


cargo_unit_costs = {
  trailer = 1.5,
  container = 0.8,
  container_40 = 1.6,
  container_20 = 0.8,
  container_10 = 0.4,
  pallet = 0.5,
}


addon = {
  name = "TSU Mission",
  version = "0.0.0",
  commands = {},
  clock = 0,
  on_load = function()
    location_type.build()
    object_type.build()
    objective_type.build()

    addon.register_command("?location", "version", nil, nil, function(full_message, peer_id, is_admin, is_auth, subject, verb) return is_admin, peer_id end, addon.print_version)
    addon.register_command("?location", "prod", nil, nil, function(full_message, peer_id, is_admin, is_auth, subject, verb) return is_admin end, function() g_savedata.mode = "prod" end)
    addon.register_command("?location", "debug", nil, nil, function(full_message, peer_id, is_admin, is_auth, subject, verb) return is_admin end, function() g_savedata.mode = "debug" end)
    addon.register_command("?location", "commands", nil, nil, function(full_message, peer_id, is_admin, is_auth, subject, verb) return is_admin, peer_id end, addon.print_all_commands)
    addon.register_command("?location", "reset", nil, nil, function(full_message, peer_id, is_admin, is_auth, subject, verb) return is_admin end, addon.reset)
    addon.register_command("?facility", "replace", "?replace", "[name]", function(full_message, peer_id, is_admin, is_auth, subject, verb, name) return is_admin, name end, location_controller.replace_facility)
  end,
  on_create = function(is_world_create)
    if g_savedata.mode == "debug" then
      addon.print_version()
    end

    player_controller.create(is_world_create)
    zone_controller.create(is_world_create)
    object_controller.create(is_world_create)
    location_controller.create(is_world_create)
  end,
  on_tick = function(tick)
    player_controller.tick(tick, addon.clock)
    zone_controller.tick(tick, addon.clock)
    object_controller.tick(tick, addon.clock)
    location_controller.tick(tick, addon.clock)

    addon.clock = addon.clock + 1
  end,
  on_player_join = function(steam_id, name, peer_id, is_admin, is_auth)
    local p = {
      id = peer_id,
      name = name,
      admin = is_admin,
      auth = is_auth,
      steam_id = tostring(steam_id),
      object_id = server.getPlayerCharacterID(peer_id),
    }

    player_controller.join(p)
    zone_controller.join(p)
    object_controller.join(p)
    location_controller.join(p)
  end,
  on_group_spawn = function(group_id, peer_id, x, y, z, group_cost)
    if peer_id < 0 then return end

    for k, vehicle_id in ipairs((server.getVehicleGroup(group_id))) do
      local p = table.find(player_controller.players, function(p) return p.id == peer_id end)
      local v = server.getVehicleData(vehicle_id)

      v.type = "vehicle"
      v.vehicle_id = vehicle_id

      if k == 1 then v.cost = group_cost end

      object_controller.spawn(v, function(v) unit.init(v, p) end)
    end
  end,
  on_object_spawn = function(o)
    object_controller.spawn(o)
  end,
  on_location_spawn = function(l)
    location_controller.spawn(l)
  end,
  on_custom_command = function(...)
    local args = { ... }
    local subject = args[5]
    local verb = args[6]
    local command = table.find(addon.commands, function(x) return x.subject == subject and x.verb == verb or x.shorthand == subject end)

    if command == nil then
      return
    end

    if command.shorthand == subject then
      table.move(args, 5, #args, 6)
    end

    addon.invoke_command(command, command.guard(table.unpack(args)))
  end,
  reset = function()
    location_controller.clear_all()
    object_controller.clear_all()
  end,
  register_command = function(subject, verb, shorthand, args, guard, execute)
    if guard == nil then
      guard = function() return true end
    end

    table.insert(addon.commands, {
      subject = subject,
      verb = verb,
      shorthand = shorthand,
      args = args,
      execute = execute,
      guard = guard,
    })
  end,
  print_all_commands = function(peer_id)
    for _, command in ipairs(addon.commands) do
      local text = string.format("%s %s", command.subject, command.verb)

      if command.args ~= nil then
        text = text .. " " .. command.args
      end

      console.log(text, peer_id)
    end
  end,
  print_version = function(peer_id)
    console.log(string.format("%s %s", addon.name, addon.version), peer_id)
  end,
  print_all_locations = function(peer_id)
    local locations = location.load()

    for k, l in ipairs(locations) do
      console.log(l.name, peer_id)
    end

    console.log(string.format("%d locations found.", #locations), peer_id)
  end,
  invoke_command = function(command, can_execute, ...)
    if not can_execute then return end

    command.execute(table.unpack({ ... }))
  end,
}


player_controller = {
  players = {},
  create = function(is_world_create)
    player_controller.players = player.load()
  end,
  tick = function(tick, clock)
    player_controller.players = player.load()
  end,
  join = function(p)
  end,
}


zone_controller = {
  cargo_destinations = {},
  cargo_spawns = {},
  create = function(is_world_create)
    if is_world_create then
      g_savedata.subsystems.zone.ui_id = server.getMapID()
    end

    zone_controller.cargo_destinations = zone.load({ destination_point = "cargo" })
    table.for_each(zone_controller.cargo_destinations, zone_controller.init_cargo_destination)
    table.shuffle(zone_controller.cargo_destinations)
    zone_controller.cargo_spawns = zone.load({ spawn_point = "cargo" })
    table.for_each(zone_controller.cargo_spawns, zone_controller.init_cargo_spawn)
    table.shuffle(zone_controller.cargo_spawns)
  end,
  tick = function(tick, clock)
    for i = 1, #zone_controller.cargo_spawns do
      if i % 1800 == clock % 1800 then
        if table.any(player_controller.players, function(p)
              return matrix.distance(p.transform, zone_controller.cargo_spawns[i].transform) <= 2000
            end) and
            table.all(g_savedata.objects, function(o)
              return not zone.contains(zone_controller.cargo_spawns[i], o.transform)
            end) then
          location_controller.place_cargo(zone_controller.cargo_spawns[i].transform, zone_controller.cargo_spawns[i].cargo_types, zone_controller.cargo_spawns[i].cargo_loads)
        end
      end
    end
  end,
  join = function(p)
    zone.map_all(zone_controller.cargo_destinations, p)
  end,
  init_cargo_destination = function(z)
    z.region = string.match(z.tags_full, "region=([%w_]+)")
    z.cargo_category = string.match(z.tags_full, "cargo_category=([%w_]+)")

    if not string.nil_or_empty(z.cargo_category) then
      z.cargo_types = cargo_categories[z.cargo_category]
    else
      local s = string.match(z.tags_full, "cargo_types=([%w_;]+)")

      z.cargo_types = s ~= nil and string.split(s, ";") or {}
    end
  end,
  init_cargo_spawn = function(z)
    z.region = string.match(z.tags_full, "region=([%w_]+)")

    local cargo_loads = string.match(z.tags_full, "cargo_loads=([%w_;]+)")

    z.cargo_loads = not string.nil_or_empty(cargo_loads) and string.split(cargo_loads, ";") or {}
    z.cargo_category = string.match(z.tags_full, "cargo_category=([%w_;]+)")

    if not string.nil_or_empty(z.cargo_category) then
      z.cargo_types = cargo_categories[z.cargo_category]
    else
      local s = string.match(z.tags_full, "cargo_types=([%w_;]+)")

      z.cargo_types = not string.nil_or_empty(s) and string.split(s, ";") or {}
    end
  end,
}


object_controller = {
  create = function(is_world_create)
    if g_savedata.mode == "debug" then
      console.log(string.format("%d objects", #g_savedata.objects))
    end
  end,
  tick = function(tick, clock)
    for i = #g_savedata.objects, 1, -1 do
      if i % 60 == clock % 60 then
        object_type.get(g_savedata.objects[i]).tick(g_savedata.objects[i], tick * 60)

        if g_savedata.objects[i].objective_type ~= nil then
          objective_type.get(g_savedata.objects[i]).tick(g_savedata.objects[i], tick * 60)
        end

        if not g_savedata.objects[i].exists then
          for k, p in ipairs(player_controller.players) do
            object_type.get(g_savedata.objects[i]).unmap(g_savedata.objects[i], p)
          end

          object_type.get(g_savedata.objects[i]).clear(g_savedata.objects[i])
          table.remove(g_savedata.objects, i)
        end
      end
    end
  end,
  join = function(p)
    object.map_all(g_savedata.objects, p)
  end,
  spawn = function(o, init_objective)
    object_type.get(o).init(o, object_type.get(o).make_id(o))

    if init_objective == nil then
      local objective = objective_type.find(o)

      if objective ~= nil then
        objective.init(o)
      end
    else
      init_objective(o)
    end

    table.insert(g_savedata.objects, o)

    for k, p in ipairs(player_controller.players) do
      object_type.get(o).map(o, p)
    end
  end,
  clear_all = function()
    for k, o in ipairs(g_savedata.objects) do
      object_type.get(o).despawn(o)
    end
  end,
}


location_controller = {
  create = function(is_world_create)
    if is_world_create then
      location_controller.place_existing_facility()
    end

    console.log(string.format("%d locations", #g_savedata.locations))
  end,
  tick = function(tick, clock)
    for i = #g_savedata.locations, 1, -1 do
      if i % 60 == clock % 60 then
        location_type.get(g_savedata.locations[i]).tick(g_savedata.locations[i], tick * 600)

        if not g_savedata.locations[i].exists then
          for pk, p in ipairs(player_controller.players) do
            location_type.get(g_savedata.locations[i]).unmap(g_savedata.locations[i], p)
          end

          location_type.get(g_savedata.locations[i]).clear(g_savedata.locations[i])
          table.remove(g_savedata.locations, i)
        end
      end
    end
  end,
  join = function(p)
    location.map_all(g_savedata.locations, p)
  end,
  spawn = function(l)
    local location = location_type.find(l)

    if location == nil then return end

    location.init(l, location.make_id(l))
    table.insert(g_savedata.locations, l)

    for k, p in ipairs(player_controller.players) do
      location.map(l, p)
    end
  end,
  clear_all = function()
    for k, l in ipairs(g_savedata.locations) do
      location.despawn(l)
    end
  end,
  replace_facility = function(name)
    local cost = 0
    cost = cost + location_controller.remove_facility(name)
    cost = cost + location_controller.place_facility(name)
    money.transact(cost, string.format("facility.%s replaced.", name))
  end,
  place_existing_facility = function()
    location_controller.place_facility("[%w_]+")
  end,
  place_facility = function(name)
    local price = 0
    local locations = location.load_all(function(l) return not l.env_mod and string.match(l.name, "^facility." .. name .. "$") ~= nil end)

    for k, l in ipairs(locations) do
      for tk, transform in ipairs(facility.locate(l, matrix.identity(), 0, 128000)) do
        location.spawn(l, transform)
      end

      price = price - l.cost
    end

    return price
  end,
  remove_facility = function(name)
    local price = 0

    for i = # g_savedata.locations, 1, -1 do
      if not g_savedata.locations[i].env_mod and string.match(g_savedata.locations[i].name, "^facility." .. name .. "$") ~= nil then
        price = price + g_savedata.locations[i].cost
        facility.despawn(g_savedata.locations[i])
      end
    end

    return price
  end,
  place_cargo = function(transform, cargo_types, cargo_loads)
    local locations = location.load_all(function(l)
      local _load, _type = string.match(l.name, "^cargo%.([%w_]+)%.([%w_]+)%.[%w_]+$")

      return _load ~= nil and table.contains(cargo_loads, _load) and table.contains(cargo_types, _type)
    end)

    local l = table.random(locations)

    if l == nil then return end

    location.spawn(l, transform)
  end,
}


location = {
  load = function(addon_index, location_index)
    local l, s = server.getLocationData(addon_index, location_index)

    if s then
      l.addon_index = addon_index
      l.location_index = location_index
    end

    return l, s
  end,
  load_all = function(filter)
    if filter == nil then
      filter = function(l) return true end
    end

    local locations = {}
    local addon_index = 0
    local addon_count = server.getAddonCount()

    while addon_index < addon_count do
      local a = server.getAddonData(addon_index)
      local location_index = 0
      local location_count = a ~= nil and a.location_count or 0

      while location_index < location_count do
        local l, s = location.load(addon_index, location_index)

        if not s then goto continue end
        if not filter(l) then goto continue end

        l.objects = {}

        table.insert(locations, l)

        ::continue::

        location_index = location_index + 1
      end

      addon_index = addon_index + 1
    end

    return locations
  end,
  locate = function(self, center, radius_min, radius_max)
    if string.nil_or_empty(self.tile) then
      return server.getOceanTransform(center, radius_min, radius_max)
    else
      return server.getTileTransform(center, self.tile, radius_max)
    end
  end,
  make_id = function(self)
    g_savedata.location_count = g_savedata.location_count + 1

    return g_savedata.location_count
  end,
  init = function(self, id, type)
    self.id = id
    self.type = type
    self.exists = true

    console.notify(string.format("%s initialized.", self.name))
  end,
  clear = function(self)
    console.notify(string.format("%s cleared.", self.name))
  end,
  tick = function(self, tick)
  end,
  spawn = function(self, transform)
    local grouped_components = { {}, {} }
    local vehicle_ids = {}

    for k, c in ipairs(object.load_all(self)) do
      if c.type == "vehicle" then
        table.insert(grouped_components[1], c)
      else
        table.insert(grouped_components[2], c)
      end
    end

    for gk, components in ipairs(grouped_components) do
      for ck, c in ipairs(components) do
        for k, o in ipairs(object.spawn(c, transform, vehicle_ids)) do
          if o.type == "vehicle" then
            vehicle_ids[c.id] = o.vehicle_ids[1]
          end

          table.insert(self.objects, o.id)
        end
      end
    end

    addon.on_location_spawn(self)
  end,
  despawn = function(self)
    for k, o in ipairs(g_savedata.objects) do
      if table.contains(self.objects, o.id) then
        object_type.get(o).despawn(o)
      end
    end

    self.exists = false
  end,
  map = function(self, p)
  end,
  map_all = function(objects, p)
  end,
  unmap = function(self, p)
  end,
  unmap_all = function(objects, p)
  end,
}


facility = {
  match = function(self)
    return string.match(self.name, "^facility.[%w_]+$") ~= nil
  end,
  tick = function(self, tick)
    location.tick(self, tick)
  end,
  locate = function(self, center, radius_min, radius_max)
    if string.nil_or_empty(self.tile) then
      return table.select(zone.load({ spawn_point = self.name }), function(z) return z.transform end)
    else
      return { (server.getTileTransform(center, self.tile, radius_max)) }
    end
  end,
  init = function(self, id)
    location.init(self, id, "facility")

    self.cost = table.aggregate(g_savedata.objects, 0, function(result, o)
      if table.contains(self.objects, o.id) then
        result = result + o.cost
      end

      return result
    end)
  end,
}


location_type = {
  catalogue = {
    facility = facility,
  },
  extend = function(self, base)
    for k, v in pairs(base) do
      if self[k] == nil then
        self[k] = v
      end
    end
  end,
  build = function()
    for k, v in pairs(location_type.catalogue) do
      location_type.extend(v, location)
    end
  end,
  get = function(l)
    if location_type.catalogue[l.type] ~= nil then return location_type.catalogue[l.type] end

    return nil
  end,
  find = function(l)
    for k, v in pairs(location_type.catalogue) do
      if v.match(l) then
        return location_type.catalogue[k]
      end
    end

    return nil
  end,
}


object = {
  load = function(addon_index, location_index, component_index)
    local c, s = server.getLocationComponentData(addon_index, location_index, component_index)

    if s then
      c.addon_index = addon_index
      c.location_index = location_index
      c.component_index = component_index
    end

    return c, s
  end,
  load_all = function(l)
    local component_index = 0
    local components = {}

    while component_index < l.component_count do
      local c, s = object.load(l.addon_index, l.location_index, component_index)

      if not s then goto continue end

      table.insert(components, c)

      ::continue::

      component_index = component_index + 1
    end

    return components
  end,
  make_id = function(self)
    g_savedata.object_count = g_savedata.object_count + 1

    return g_savedata.object_count
  end,
  init = function(self, id, name, type)
    self.id = id

    if type ~= nil then self.type = type end
    if name ~= nil then self.name = name end
    if self.tags == nil then self.tags = {} end
    if self.transform == nil then self.transform = matrix.identity() end
    if self.simulating == nil then self.simulating = false end
    if not string.nil_or_empty(self.tags.cost) and (self.is_object or self.is_vehicle and self.body_id == 1) then self.cost = tonumber(self.tags.cost) end
    if self.cost == nil then self.cost = 0 end

    self.exists = true
    self.mapped = false
    self.ui_id = server.getMapID()
    self.marker_position_type = 2
    self.marker_type = 2
    self.marker_color = { r = 127, g = 127, b = 127, a = 255, }
    self.is_object = object_type.get(self).is_object(self)
    self.is_vehicle = object_type.get(self).is_vehicle(self)
    self.is_character = object_type.get(self).is_character(self)
    self.is_fire = object_type.get(self).is_fire(self)
    self.is_animal = object_type.get(self).is_animal(self)
    self.is_creature = object_type.get(self).is_creature(self)

    console.notify(string.format("%s initialized.", object_type.get(self).identity(self)))
  end,
  tick = function(self, tick)
    self.simulating, self.exists = object_type.get(self).simulated(self)

    if not self.exists then return end

    self.transform = object_type.get(self).get_pos(self)
  end,
  clear = function(self)
    console.notify(string.format("%s cleared.", object_type.get(self).identity(self)))
  end,
  spawn = function(component, transform, vehicle_ids)
    local objects = {}
    local transform = matrix.multiply(transform, component.transform)
    local parent_id = nil

    if component.vehicle_parent_component_id > 0 then
      parent_id = vehicle_ids[component.vehicle_parent_component_id]
    end

    local o, s = server.spawnAddonComponent(transform, component.addon_index, component.location_index, component.component_index, parent_id)

    if not s then
      console.error(string.format("failed to spawn component#%d.#%d.#%d.", component.addon_index, component.location_index, component.component_index))
      return objects, s
    end

    o.id = nil
    o.addon_index = component.addon_index
    o.location_index = component.location_index
    o.component_index = component.component_index
    o.component_id = component.component_id
    o.parent_id = parent_id
    o.name = o.display_name
    o.tags = tag.deserialize(o.tags)

    if o.type == "zone" then
      return objects, s
    elseif o.type == "vehicle" then
      for k, vehicle_id in ipairs(o.vehicle_ids) do
        local v = server.getVehicleData(vehicle_id)

        o.object_id = nil
        o.body_id = k
        o.vehicle_id = vehicle_id
        o.simulating = v.simulating
        o.editable = v.editable
        o.invulnerable = v.invulnerable
        o.static = o.static

        if not string.nil_or_empty(v.name) then o.name = v.name end

        table.insert(objects, o)
        addon.on_object_spawn(o)
      end
    else
      table.insert(objects, o)
      addon.on_object_spawn(o)
    end

    return objects, s
  end,
  despawn = function(self)
    if self.is_vehicle then
      server.despawnVehicle(self.vehicle_id, true)
    elseif self.is_object then
      server.despawnObject(self.object_id, true)
    else
      self.exists = false
    end
  end,
  map = function(self, p)
    if g_savedata.mode == "debug" and p.admin then
      local x, y, z = matrix.position(self.transform)
      server.addMapObject(p.id, self.ui_id, self.marker_position_type, self.marker_type, x, z, 0, 0, self.vehicle_id, self.object_id, object_type.get(self).identity(self), 0, self.name, self.marker_color.r, self.marker_color.g, self.marker_color.b,
        self.marker_color.a)
    end
  end,
  map_all = function(objects, p)
    for k, o in ipairs(objects) do
      object_type.get(o).map(o, p)
    end
  end,
  unmap = function(self, p)
    server.removeMapID(p.id, self.ui_id)
  end,
  unmap_all = function(objects, p)
    for k, o in ipairs(objects) do
      object_type.get(o).unmap(o, p)
    end
  end,
  identity = function(self)
    return string.format("%s#%d", self.type, self.object_id)
  end,
  get_pos = function(self)
    if self.is_vehicle then
      return server.getVehiclePos(self.vehicle_id)
    elseif self.is_object then
      return server.getObjectPos(self.object_id)
    else
      return self.transform, true
    end
  end,
  simulated = function(self)
    if self.is_vehicle then
      return server.getVehicleSimulating(self.vehicle_id)
    elseif self.is_object then
      return server.getObjectSimulating(self.object_id)
    else
      return true, self.exists
    end
  end,
  is_object = function(self)
    return self.type == "object" or self.type == "character" or self.type == "flare" or self.type == "fire" or self.type == "loot" or self.type == "button" or self.type == "animal" or self.type == "creature" or self.type == "ice"
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
  is_animal = function(self)
    return self.type == "animal"
  end,
  is_creature = function(self)
    return self.type == "creature"
  end,
}


vehicle = {
  init = function(self, id, name, cost)
    object.init(self, id, name, "vehicle")

    self.marker_position_type = 1
    self.marker_type = 17

    if cost ~= nil then self.cost = cost end

    self.components_checked = false
    self.voxels = 0
    self.mass = 0
    self.signs = {}
    self.seats = {}
    self.buttons = {}
    self.tanks = {}
    self.batteries = {}
    self.hoppers = {}
    self.guns = {}
    self.rope_hooks = {}
    self.refills = self.tags.refills == "true"
    self.economic = "consumer"

    if self.tags.provider == "true" then self.economic = "provider" end

    self.refill_infinite = self.tags.refill_infinite == "true"
    self.refill_sources = self.tags.refill_sources or { "money" }
  end,
  tick = function(self, tick)
    object.tick(self, tick)

    if not self.components_checked then
      vehicle.check_components(self)
    end

    if self.refills then
      vehicle.refill_tanks(self)
      vehicle.refill_hoppers(self)
      vehicle.refill_batteries(self)
    end
  end,
  identity = function(self)
    return string.format("%s#%d", self.type, self.vehicle_id)
  end,
  check_components = function(self)
    if not self.simulating then return end

    local components = server.getVehicleComponents(self.vehicle_id)
    self.voxels = components.voxels
    self.mass = components.mass
    self.signs = components.components.signs
    self.dials = components.components.dials
    self.seats = components.components.seats
    self.buttons = components.components.buttons
    self.tanks = components.components.tanks
    self.batteries = components.components.batteries
    self.hoppers = components.components.hoppers
    self.guns = components.components.guns
    self.rope_hooks = components.components.rope_hooks
    self.components_checked = true
  end,
  refill_tanks = function(self)
    if not self.simulating or not self.components_checked then return end

    local purchased = server.getTilePurchased(self.transform)
    local settings = server.getGameSettings()

    for k, t in ipairs(self.tanks) do
      if string.nil_or_empty(t.name) then goto continue end

      local fill_type = string.lower(t.name)

      if fluids[fill_type] == nil then goto continue end
      if fluid_prices[fill_type][self.economic] == nil then goto continue end

      local t_update, s = server.getVehicleTank(self.vehicle_id, t.pos.x, t.pos.y, t.pos.z)

      if t_update.values[fluids[fill_type]] > t.values[fluids[fill_type]] * 0.75 and t_update.values[fluids[fill_type]] < t.values[fluids[fill_type]] * 1.25 then goto continue end

      local subtotal = t_update.values[fluids[fill_type]] - t.values[fluids[fill_type]]

      if self.refill_infinite or fluid_prices[fill_type][self.economic] == 0 or settings.infinite_money then
        subtotal = 0
      end

      if subtotal ~= 0 and table.contains(self.refill_sources, "tile") and purchased then
        subtotal = tile.transact(self.transform, fill_type, subtotal)
      end

      if subtotal ~= 0 and table.contains(self.refill_sources, "money") then
        money.transact(subtotal * fluid_prices[fill_type][self.economic])
        subtotal = 0
      end

      t_update.value = subtotal + t.values[fluids[fill_type]]
      server.setVehicleTank(self.vehicle_id, t.pos.x, t.pos.y, t.pos.z, t_update.value, fluids[fill_type])

      ::continue::
    end
  end,
  refill_hoppers = function(self)
    if not self.simulating or not self.components_checked then return end

    local purchased = server.getTilePurchased(self.transform)

    for k, h in ipairs(self.hoppers) do
      if string.nil_or_empty(h.name) then goto continue end

      local fill_type = string.lower(h.name)

      if metals[fill_type] == nil then goto continue end
      if metal_prices[fill_type][self.economic] == nil then goto continue end

      local h_update = server.getVehicleHopper(self.vehicle_id, h.pos.x, h.pos.y, h.pos.z)

      if h_update.values[metals[fill_type]] > h.values[metals[fill_type]] * 0.75 and h_update.values[metals[fill_type]] < h.values[metals[fill_type]] * 1.25 then goto continue end

      local subtotal = h_update.values[metals[fill_type]] - h.values[metals[fill_type]]

      if self.refill_infinite or metal_prices[fill_type][self.economic] == 0 then
        subtotal = 0
      end

      if subtotal ~= 0 and table.contains(self.refill_sources, "tile") and purchased then
        subtotal = tile.transact(self.transform, fill_type, subtotal)
      end

      if subtotal ~= 0 and table.contains(self.refill_sources, "money") then
        money.transact(subtotal * metal_prices[fill_type][self.economic])
        subtotal = 0
      end

      h_update.value = subtotal + h.values[metals[fill_type]]
      server.setVehicleHopper(self.vehicle_id, h.pos.x, h.pos.y, h.pos.z, h_update.value, metals[fill_type])

      ::continue::
    end
  end,
  refill_batteries = function(self)
    if not self.simulating or not self.components_checked then return end

    for k, b in ipairs(self.batteries) do
      local fill_type = string.lower(b.name)

      if fill_type == "power" then
        server.setVehicleBattery(self.vehicle_id, b.pos.x, b.pos.y, b.pos.z, 1)
      end
    end
  end,
}


object_type = {
  catalogue = {
    vehicle = vehicle,
  },
  extend = function(self, base)
    for k, v in pairs(base) do
      if self[k] == nil then
        self[k] = v
      end
    end
  end,
  build = function()
    for k, v in pairs(object_type.catalogue) do
      object_type.extend(v, object)
    end
  end,
  get = function(o)
    if object_type.catalogue[o.type] ~= nil then return object_type.catalogue[o.type] end

    return object
  end,
}


objective = {
  name = "",
  init = function(self, type)
    if type == nil then return end

    self.objective_type = type
    self.despawn_lazy = false
    self.despawn_timer = 300
    self.failed = false
    self.terminated = false

    if string.nil_or_empty(self.name) then self.name = objective_type.get(self).name end

    console.notify(string.format("%s assigned %s.", object_type.get(self).identity(self), self.objective_type))
  end,
  tick = function(self, tick)
    if not self.terminated and objective_type.get(self).fails(self) then
      self.terminated = true
      objective_type.get(self).despawn(self)
      server.notify(-1, object_type.get(self).identity(self), "objective failed.", 2)
    end

    if not self.terminated and objective_type.get(self).completes(self) then
      self.terminated = true
      money.transact(objective_type.get(self).reward(self, "rewards for your work."))
      objective_type.get(self).despawn(self)
      server.notify(-1, object_type.get(self).identity(self), "objective achieved.", 4)
    end

    if self.despawn_lazy then
      self.despawn_timer = math.max(self.despawn_timer - tick, 0)
      console.log(self.despawn_timer)
    end

    if self.despawn_timer == 0 then
      object_type.get(self).despawn(self)
    end
  end,
  despawn = function(self)
    self.despawn_lazy = true
  end,
  reward = function(self)
    return 0
  end,
  completes = function(self)
    return false
  end,
  fails = function(self)
    return false
  end,
  identity = function(self)
    return string.format("%s#%d", self.objective_type, self.vehicle_id)
  end,
}


cargo = {
  name = "Cargo",
  match = function(self)
    return self.tags.objective == "cargo"
  end,
  init = function(self)
    objective.init(self, "cargo")

    self.initial_transform = table.copy(self.transform)
    self.cargo_load = self.tags.cargo_load
    self.cargo_type = self.tags.cargo_type
    self.destination = cargo.make_destination(self)
    self.unit_costs = cargo_unit_costs[self.cargo_load]

    server.setVehicleTooltip(self.vehicle_id, string.format("$%.0f\n%s\n%s", cargo.reward(self), cargoes[self.cargo_type].name, self.destination.name))
  end,
  tick = function(self, tick)
    objective.tick(self, tick)

    if matrix.distance(self.transform, self.initial_transform) <= 500 and table.all(player_controller.players, function(p) return matrix.distance(p.transform, self.transform) >= 2000 end) then
      object_type.get(self).despawn(self)
    end
  end,
  make_destination = function(self)
    return table.random(table.find_all(zone_controller.cargo_destinations, function(z) return table.contains(z.cargo_types, self.cargo_type) and matrix.distance(z.transform, self.initial_transform) >= 1000 end))
  end,
  reward = function(self)
    return math.floor(matrix.distance(self.initial_transform, self.destination.transform) * self.unit_costs / 100) * 100
  end,
  completes = function(self)
    return zone.contains(self.destination, self.transform)
  end,
}


unit = {
  match = function(self)
    return false
  end,
  init = function(self, p)
    objective.init(self, "unit")

    self.steam_id = p.steam_id
  end,
}


objective_type = {
  catalogue = {
    cargo = cargo,
    unit = unit,
  },
  extend = function(self, base)
    for k, v in pairs(base) do
      if self[k] == nil then
        self[k] = v
      end
    end
  end,
  build = function()
    for k, v in pairs(objective_type.catalogue) do
      objective_type.extend(v, objective)
    end
  end,
  get = function(o)
    if objective_type.catalogue[o.objective_type] ~= nil then return objective_type.catalogue[o.objective_type] end

    return nil
  end,
  find = function(o)
    for k, v in pairs(objective_type.catalogue) do
      if v.match(o) then
        return objective_type.catalogue[k]
      end
    end

    return nil
  end,
}


zone = {
  init = function(self)
  end,
  load = function(tags, filter)
    local zones = {}

    if filter == nil then
      filter = function(z) return true end
    end

    for k, z in ipairs(server.getZones(tag.serialize(tags))) do
      zone.init(z)

      if filter(z) then
        table.insert(zones, z)
      end
    end

    return zones
  end,
  load_by_groups = function(zone_tag_groups, filter_zone)
    local zones = {}

    for _, zone_tags in ipairs(zone_tag_groups) do
      for _, z in ipairs(zone.load(zone_tags, filter_zone)) do
        table.insert(zones, z)
      end
    end

    return zones
  end,
  contains = function(self, transform)
    return server.isInTransformArea(transform, self.transform, self.size.x, self.size.y, self.size.z)
  end,
  map = function(self, p)
    if g_savedata.mode == "debug" and p.admin or not string.nil_or_empty(self.name) then
      local x, y, z = matrix.position(self.transform)

      server.addMapLabel(p.id, g_savedata.subsystems.zone.ui_id, zone.icon(self), self.name, x, z)
    end
  end,
  map_all = function(zones, p)
    for k, z in ipairs(zones) do
      zone.map(z, p)
    end
  end,
  unmap = function(self, p)
    server.removeMapID(p.id, self.ui_id)
  end,
  unmap_all = function(zones, p)
    for k, z in ipairs(zones) do
      zone.unmap(z, p)
    end
  end,
  icon = function(self)
    if table.contains(self.tags, "destination_point=cargo") then
      return 3
    else
      return 1
    end
  end,
}


player = {
  load = function()
    local players = {}

    for _, p in ipairs(server.getPlayers()) do
      if p.id == 0 and p.name == "Server" then goto continue end

      p.steam_id = tostring(p.steam_id)
      p.transform = server.getPlayerPos(p.id)
      p.vehicle_id = server.getCharacterVehicle(p.object_id)
      p.vital = server.getObjectData(p.object_id)

      table.insert(players, p)

      ::continue::
    end

    return players
  end,
}


money = {
  transact = function(amount, message)
    if server.getGameSettings().infinite_money then return true end

    if amount > 0 then
      amount = math.ceil(amount)
    elseif amount < 0 then
      amount = math.floor(amount)
    else
      return true
    end

    local money = server.getCurrency()
    local money_update = money + amount
    local not_type = 4
    local title = string.format("Accepted $%d.", amount)

    if amount < 0 then
      not_type = 2
      title = string.format("Paid out $%d.", math.abs(amount))
    end

    if money > 0 and money_update <= 0 then
      server.notify(-1, "Budgets fall into the red.", nil, 2)
    end

    server.setCurrency(money_update)

    if not string.nil_or_empty(message) then
      server.notify(-1, title, message, not_type)
    end

    return true
  end,
}

tile = {
  transact = function(transform, type, value)
    local coal, uranium, diesel, jet, solid_propellant = server.getTileInventory(transform)

    if type == "coal" then
      local subtotal = coal + value
      value = math.min(subtotal, 0)
      coal = math.max(subtotal, 0)
    elseif type == "uranium" then
      local subtotal = uranium + value
      value = math.min(subtotal, 0)
      uranium = math.max(subtotal, 0)
    elseif type == "diesel" then
      local subtotal = diesel + value
      value = math.min(subtotal, 0)
      diesel = math.max(subtotal, 0)
    elseif type == "jet" then
      local subtotal = jet + value
      value = math.min(subtotal, 0)
      jet = math.max(subtotal, 0)
    elseif type == "solid_propellant" then
      local subtotal = solid_propellant + value
      value = math.min(subtotal, 0)
      solid_propellant = math.max(subtotal, 0)
    end

    server.setTileInventory(transform, coal, uranium, diesel, jet, solid_propellant)

    return value
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
    local key, value = tag.parseKeyValue(text)

    if key == nil then
      value = text
    end

    if string.find(text, ";", 1, true) ~= nil then
      value = string.split(value, ";")
    end

    return value, key
  end,
  parseKeyValue = function(text)
    return string.match(text, "^([%w_]+)=(.+)$")
  end,
  match = function(self, key, pattern)
    return string.match(self, "^" .. key .. "=" .. pattern .. "$") ~= nil
  end,
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
  for k, v in ipairs(t) do
    result = func(result, v)
  end

  return result
end

table.any           = function(t, test)
  local any = false

  for i = 1, #t do
    any = any or test(t[i], i)
  end

  return any
end

table.all           = function(t, test)
  local all = true

  for i = 1, #t do
    all = all and test(t[i], i)
  end

  return all
end

table.contains      = function(t, x)
  local contains = false

  for i = 1, #t do
    contains = contains or t[i] == x
  end

  return contains
end

table.find          = function(t, test)
  for k, v in ipairs(t) do
    if test(v, k) then
      return v, k
    end
  end

  -- for i = 1, #t do
  --   if test == nil or test(t[i], i) then
  --     return t[i], i
  --   end
  -- end

  return nil
end

table.find_all      = function(t, test)
  local items = {}

  for i = 1, #t do
    if test(t[i], i) then
      table.insert(items, t[i])
    end
  end

  return items
end

table.for_each      = function(t, action)
  for i = 1, #t do
    action(t[i], i)
  end
end

table.has           = function(t, x)
  for i = 1, #t do
    if t[i] == x then
      return true
    end
  end

  return false
end

table.intersect     = function(m, n)
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

table.keys          = function(t)
  local items = {}

  for k, v in pairs(t) do
    table.insert(items, k)
  end

  return items
end

table.random        = function(t)
  local keys = table.keys(t)

  if #keys == 0 then
    return nil
  end

  return t[keys[math.random(1, #keys)]]
end

table.select        = function(t, selector)
  local items = {}

  for i = 1, #t do
    local value = selector(t[i], i)

    if value ~= nil then
      table.insert(items, value)
    end
  end

  return items
end

table.where         = function(t, selector)
  local items = {}

  for i = 1, #t do
    if selector(t[i], i) then
      table.insert(items, t[i])
    end
  end

  return items
end

table.copy          = function(t)
  local u = {}

  for k, v in ipairs(t) do
    if type(v) == "table" then
      u[k] = table.copy(v)
    else
      u[k] = v
    end
  end

  return u
end

table.distinct      = function(t)
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

table.join          = function(t1, t2)
  for k, v in ipairs(t2) do
    if t1[k] == nil then
      t1[k] = v
    end
  end
end

table.shuffle       = function(x)
  for i = #x, 2, -1 do
    local j = math.random(i)
    x[i], x[j] = x[j], x[i]
  end
end

table.take          = function(t, start, length)
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

addon.on_load()
onCreate        = addon.on_create
onTick          = addon.on_tick
onCustomCommand = addon.on_custom_command
onPlayerJoin    = addon.on_player_join
onGroupSpawn    = addon.on_group_spawn
